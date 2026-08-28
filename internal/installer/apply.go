package installer

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

type fileSnapshot struct {
	Content []byte
	Mode    os.FileMode
	Exists  bool
}

func preservedMode(mode os.FileMode) os.FileMode {
	return mode & (os.ModePerm | os.ModeSetuid | os.ModeSetgid | os.ModeSticky)
}

func atomicWriteFile(destination string, content []byte, mode os.FileMode) error {
	temporary, err := os.CreateTemp(filepath.Dir(destination), "."+filepath.Base(destination)+".")
	if err != nil {
		return err
	}
	temporaryPath := temporary.Name()
	closed := false
	defer func() {
		if !closed {
			_ = temporary.Close()
		}
		_ = os.Remove(temporaryPath)
	}()

	if _, err := temporary.Write(content); err != nil {
		return err
	}
	if err := temporary.Sync(); err != nil {
		return err
	}
	if err := temporary.Close(); err != nil {
		return err
	}
	closed = true
	if err := os.Chmod(temporaryPath, mode); err != nil {
		return err
	}
	if err := os.Rename(temporaryPath, destination); err != nil {
		return err
	}
	return nil
}

// atomicWrite is a package seam used by fault-injection tests.
var atomicWrite = atomicWriteFile

// makeDirectory is a package seam used to exercise concurrent mkdir races.
var makeDirectory = os.Mkdir

func validatedFileSnapshot(target string, change *FileChange) (fileSnapshot, error) {
	destination := diskPath(target, change.RelativePath)
	unsafeReason, err := unsafeDestinationReason(target, change.RelativePath)
	if err != nil {
		return fileSnapshot{}, err
	}
	if unsafeReason != "" {
		return fileSnapshot{}, installerError(
			ErrUnsafePath,
			nil,
			"Destination changed after review: %s (%s)",
			destination,
			unsafeReason,
		)
	}
	info, exists, err := lstat(destination)
	if err != nil {
		return fileSnapshot{}, err
	}
	if !change.ExistingPresent {
		if exists {
			return fileSnapshot{}, installerError(
				ErrInstaller,
				nil,
				"Destination appeared after review: %s",
				destination,
			)
		}
		return fileSnapshot{}, nil
	}
	if !exists || !info.Mode().IsRegular() {
		return fileSnapshot{}, installerError(
			ErrInstaller,
			nil,
			"Destination disappeared after review: %s",
			destination,
		)
	}
	current, err := os.ReadFile(destination)
	if err != nil {
		return fileSnapshot{}, err
	}
	if !bytes.Equal(current, change.Existing) {
		return fileSnapshot{}, installerError(
			ErrInstaller,
			nil,
			"Destination content changed after review: %s",
			destination,
		)
	}
	info, err = os.Stat(destination)
	if err != nil {
		return fileSnapshot{}, err
	}
	return fileSnapshot{
		Content: append([]byte{}, current...),
		Mode:    preservedMode(info.Mode()),
		Exists:  true,
	}, nil
}

func contextError(ctx context.Context) error {
	select {
	case <-ctx.Done():
		return ctx.Err()
	default:
		return nil
	}
}

func validatePlanSnapshot(ctx context.Context, plan *InstallPlan) error {
	for _, change := range plan.Files {
		if err := contextError(ctx); err != nil {
			return err
		}
		if _, err := validatedFileSnapshot(plan.Options.Target, change); err != nil {
			return err
		}
		if err := contextError(ctx); err != nil {
			return err
		}
	}
	return nil
}

type applyTransaction struct {
	ctx                context.Context
	plan               *InstallPlan
	originalFiles      map[string]fileSnapshot
	createdDirectories []string
	written            []string
}

func (transaction *applyTransaction) rollback(cause error) error {
	var rollbackErrors []string
	for index := len(transaction.written) - 1; index >= 0; index-- {
		relativePath := transaction.written[index]
		destination := diskPath(transaction.plan.Options.Target, relativePath)
		original := transaction.originalFiles[relativePath]
		var err error
		if !original.Exists {
			err = os.Remove(destination)
			if errors.Is(err, os.ErrNotExist) {
				err = nil
			}
		} else {
			err = atomicWriteFile(destination, original.Content, original.Mode)
		}
		if err != nil {
			rollbackErrors = append(rollbackErrors, fmt.Sprintf("%s: %v", relativePath, err))
		}
	}
	for index := len(transaction.createdDirectories) - 1; index >= 0; index-- {
		relativePath := transaction.createdDirectories[index]
		err := os.Remove(diskPath(transaction.plan.Options.Target, relativePath))
		if errors.Is(err, os.ErrNotExist) {
			continue
		}
		if err != nil {
			rollbackErrors = append(rollbackErrors, fmt.Sprintf("%s/: %v", relativePath, err))
		}
	}
	if len(rollbackErrors) > 0 {
		return installerError(
			ErrInstaller,
			cause,
			"Install failed and rollback was incomplete: %s",
			strings.Join(rollbackErrors, "; "),
		)
	}
	return installerError(
		ErrInstaller,
		cause,
		"Install failed; all changes were rolled back: %v",
		cause,
	)
}

func (transaction *applyTransaction) run() (result ApplyResult, returnErr error) {
	defer func() {
		if recovered := recover(); recovered != nil {
			returnErr = transaction.rollback(fmt.Errorf("%v", recovered))
			result = ApplyResult{}
		}
	}()

	if err := contextError(transaction.ctx); err != nil {
		return ApplyResult{}, transaction.rollback(err)
	}
	if err := validatePlanSnapshot(transaction.ctx, transaction.plan); err != nil {
		return ApplyResult{}, transaction.rollback(err)
	}
	for _, directory := range transaction.plan.Directories {
		if err := contextError(transaction.ctx); err != nil {
			return ApplyResult{}, transaction.rollback(err)
		}
		destination := diskPath(transaction.plan.Options.Target, directory.RelativePath)
		info, exists, err := lstat(destination)
		if err != nil {
			return ApplyResult{}, transaction.rollback(err)
		}
		if exists {
			if info.Mode()&os.ModeSymlink != 0 || !info.IsDir() {
				return ApplyResult{}, transaction.rollback(installerError(
					ErrUnsafePath,
					nil,
					"Directory changed during setup: %s",
					destination,
				))
			}
			continue
		}
		if err := contextError(transaction.ctx); err != nil {
			return ApplyResult{}, transaction.rollback(err)
		}
		transaction.createdDirectories = append(transaction.createdDirectories, directory.RelativePath)
		if err := makeDirectory(destination, 0o777); err != nil {
			transaction.createdDirectories = transaction.createdDirectories[:len(transaction.createdDirectories)-1]
			return ApplyResult{}, transaction.rollback(err)
		}
		if err := contextError(transaction.ctx); err != nil {
			return ApplyResult{}, transaction.rollback(err)
		}
	}

	for _, change := range transaction.plan.Files {
		if err := contextError(transaction.ctx); err != nil {
			return ApplyResult{}, transaction.rollback(err)
		}
		if !change.WillWrite() {
			continue
		}
		destination := diskPath(transaction.plan.Options.Target, change.RelativePath)
		original, err := validatedFileSnapshot(transaction.plan.Options.Target, change)
		if err != nil {
			return ApplyResult{}, transaction.rollback(err)
		}
		if err := contextError(transaction.ctx); err != nil {
			return ApplyResult{}, transaction.rollback(err)
		}
		transaction.originalFiles[change.RelativePath] = original
		mode := os.FileMode(0o644)
		if original.Exists {
			mode = original.Mode
		}
		transaction.written = append(transaction.written, change.RelativePath)
		if err := atomicWrite(destination, change.Desired, mode); err != nil {
			return ApplyResult{}, transaction.rollback(err)
		}
		if err := contextError(transaction.ctx); err != nil {
			return ApplyResult{}, transaction.rollback(err)
		}
	}
	if err := contextError(transaction.ctx); err != nil {
		return ApplyResult{}, transaction.rollback(err)
	}

	return ApplyResult{
		Written:            append([]string(nil), transaction.written...),
		CreatedDirectories: append([]string(nil), transaction.createdDirectories...),
		Counts:             transaction.plan.Counts(),
	}, nil
}

// ApplyPlanContext performs a single rollback-capable transaction. It
// revalidates the entire reviewed snapshot before mutation and every file
// immediately before its own atomic replacement. Cancellation is observed
// between filesystem operations and triggers a complete rollback.
func ApplyPlanContext(ctx context.Context, plan *InstallPlan) (ApplyResult, error) {
	if ctx == nil {
		ctx = context.Background()
	}
	if !plan.Finalized {
		return ApplyResult{}, installerError(
			ErrInstaller,
			nil,
			"Install plan must be finalized before it is applied.",
		)
	}
	if len(plan.Conflicts()) > 0 || len(plan.Blocked()) > 0 {
		return ApplyResult{}, installerError(
			ErrUnresolvedConflict,
			nil,
			"Install plan is not safe to apply.",
		)
	}
	transaction := &applyTransaction{
		ctx:           ctx,
		plan:          plan,
		originalFiles: make(map[string]fileSnapshot),
	}
	return transaction.run()
}

// ApplyPlan preserves the original API for callers that do not need
// cancellation. Command-line callers should use ApplyPlanContext.
func ApplyPlan(plan *InstallPlan) (ApplyResult, error) {
	return ApplyPlanContext(context.Background(), plan)
}
