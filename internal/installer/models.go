package installer

import (
	"encoding/json"
	"errors"
	"fmt"
	"sort"
)

// NamingPool identifies the historical naming tradition used by generated
// agent conventions.
type NamingPool string

const (
	NamingRoman    NamingPool = "roman"
	NamingNorse    NamingPool = "norse"
	NamingHellenic NamingPool = "hellenic"
)

// ConflictPolicy controls how customized existing files are handled.
type ConflictPolicy string

const (
	ConflictAsk       ConflictPolicy = "ask"
	ConflictKeep      ConflictPolicy = "keep"
	ConflictOverwrite ConflictPolicy = "overwrite"
	ConflictFail      ConflictPolicy = "fail"
)

// ChangeStatus describes the action selected for a planned file.
type ChangeStatus string

const (
	ChangeAdd       ChangeStatus = "add"
	ChangeUpdate    ChangeStatus = "update"
	ChangeUnchanged ChangeStatus = "unchanged"
	ChangeKeep      ChangeStatus = "keep"
	ChangeConflict  ChangeStatus = "conflict"
	ChangeBlocked   ChangeStatus = "blocked"
)

var statusOrder = []ChangeStatus{
	ChangeAdd,
	ChangeUpdate,
	ChangeUnchanged,
	ChangeKeep,
	ChangeConflict,
	ChangeBlocked,
}

// Error categories let callers select an exit path with errors.Is while the
// displayed Error() text remains identical to the user-facing Python errors.
var (
	ErrInstaller          = errors.New("installer error")
	ErrInvalidInput       = errors.New("invalid input")
	ErrUnsafePath         = errors.New("unsafe path")
	ErrUnresolvedConflict = errors.New("unresolved conflict")
)

// Error is a safe, user-facing installer failure.
type Error struct {
	Kind    error
	Message string
	Cause   error
}

func (e *Error) Error() string { return e.Message }

func (e *Error) Unwrap() error { return e.Cause }

func (e *Error) Is(target error) bool {
	return target == ErrInstaller || target == e.Kind
}

func installerError(kind error, cause error, format string, args ...any) error {
	return &Error{Kind: kind, Message: fmt.Sprintf(format, args...), Cause: cause}
}

// NamingProfile contains the text substituted into the agent convention
// template for a naming pool.
type NamingProfile struct {
	Key         NamingPool
	Title       string
	Tradition   string
	Description string
	Examples    string
}

// InstallOptions contains every choice that influences a plan.
type InstallOptions struct {
	Target          string
	Principal       string
	Naming          NamingPool
	InstallSkills   bool
	CreateWorkspace bool
	IntegrateClaude bool
	AllowNonGit     bool
}

// FileChange is a single preflighted file operation. ExistingPresent is kept
// separately because an existing empty file and a missing file are distinct.
type FileChange struct {
	RelativePath    string
	Desired         []byte
	Existing        []byte
	ExistingPresent bool
	Status          ChangeStatus
	Label           string
	Group           string
	Managed         bool
	Reason          string
}

// WillWrite reports whether applying the plan will replace this file.
func (c *FileChange) WillWrite() bool {
	return c.Status == ChangeAdd || c.Status == ChangeUpdate
}

// DirectoryChange is a directory required by the installation.
type DirectoryChange struct {
	RelativePath string
	Create       bool
}

// InstallPlan is an immutable snapshot once FinalizePlan succeeds. The fields
// remain exported so the UI can render and resolve explicit conflict choices.
type InstallPlan struct {
	Options         InstallOptions
	Files           []*FileChange
	Directories     []DirectoryChange
	Notes           []string
	IsGitRepository bool
	Finalized       bool
}

// Conflicts returns unresolved customized files in plan order.
func (p *InstallPlan) Conflicts() []*FileChange {
	var result []*FileChange
	for _, change := range p.Files {
		if change.Status == ChangeConflict {
			result = append(result, change)
		}
	}
	return result
}

// Blocked returns unsafe destinations in plan order.
func (p *InstallPlan) Blocked() []*FileChange {
	var result []*FileChange
	for _, change := range p.Files {
		if change.Status == ChangeBlocked {
			result = append(result, change)
		}
	}
	return result
}

// GroupedConflicts groups unresolved conflicts by their atomic decision key.
func (p *InstallPlan) GroupedConflicts() map[string][]*FileChange {
	result := make(map[string][]*FileChange)
	for _, change := range p.Conflicts() {
		result[change.Group] = append(result[change.Group], change)
	}
	return result
}

// ConflictGroups returns conflict group keys in their first appearance order.
func (p *InstallPlan) ConflictGroups() []string {
	seen := make(map[string]bool)
	var result []string
	for _, change := range p.Conflicts() {
		if !seen[change.Group] {
			seen[change.Group] = true
			result = append(result, change.Group)
		}
	}
	return result
}

// Counts returns every file status plus the number of directories to create.
func (p *InstallPlan) Counts() map[string]int {
	counts := make(map[string]int, len(statusOrder)+1)
	for _, status := range statusOrder {
		counts[string(status)] = 0
	}
	counts["directories"] = 0
	for _, change := range p.Files {
		counts[string(change.Status)]++
	}
	for _, directory := range p.Directories {
		if directory.Create {
			counts["directories"]++
		}
	}
	return counts
}

// Ready reports whether the plan has no unsafe paths or unresolved conflicts.
func (p *InstallPlan) Ready() bool {
	return len(p.Conflicts()) == 0 && len(p.Blocked()) == 0
}

// ChangeOutput represents either a file or directory in a JSON plan. Label
// and Reason are non-nil for every file, even when the strings are empty;
// Kind is non-nil only for directories.
type ChangeOutput struct {
	Path   string  `json:"path"`
	Action string  `json:"action"`
	Label  *string `json:"label,omitempty"`
	Reason *string `json:"reason,omitempty"`
	Kind   *string `json:"kind,omitempty"`
}

// OptionsOutput is the stable machine-readable subset of InstallOptions.
type OptionsOutput struct {
	Principal string `json:"principal"`
	Naming    string `json:"naming"`
	Skills    bool   `json:"skills"`
	Workspace bool   `json:"workspace"`
	Claude    bool   `json:"claude"`
}

// PlanOutput is the stable schema emitted by --json.
type PlanOutput struct {
	Schema        int            `json:"schema"`
	Target        string         `json:"target"`
	GitRepository bool           `json:"git_repository"`
	Options       OptionsOutput  `json:"options"`
	Changes       []ChangeOutput `json:"changes"`
	Counts        map[string]int `json:"counts"`
	Notes         []string       `json:"notes"`
	Ready         bool           `json:"ready"`
}

// Output returns the exact machine-readable plan representation.
func (p *InstallPlan) Output() PlanOutput {
	changes := make([]ChangeOutput, 0, len(p.Files)+len(p.Directories))
	for _, change := range p.Files {
		label := change.Label
		reason := change.Reason
		changes = append(changes, ChangeOutput{
			Path:   change.RelativePath,
			Action: string(change.Status),
			Label:  &label,
			Reason: &reason,
		})
	}
	for _, directory := range p.Directories {
		if directory.Create {
			kind := "directory"
			changes = append(changes, ChangeOutput{
				Path:   directory.RelativePath,
				Action: string(ChangeAdd),
				Kind:   &kind,
			})
		}
	}
	notes := append([]string(nil), p.Notes...)
	if notes == nil {
		notes = []string{}
	}
	return PlanOutput{
		Schema:        1,
		Target:        p.Options.Target,
		GitRepository: p.IsGitRepository,
		Options: OptionsOutput{
			Principal: p.Options.Principal,
			Naming:    string(p.Options.Naming),
			Skills:    p.Options.InstallSkills,
			Workspace: p.Options.CreateWorkspace,
			Claude:    p.Options.IntegrateClaude,
		},
		Changes: changes,
		Counts:  p.Counts(),
		Notes:   notes,
		Ready:   p.Ready(),
	}
}

// MarshalJSON makes json.Marshal(plan) use the public schema rather than
// leaking preflight snapshots or desired file contents.
func (p InstallPlan) MarshalJSON() ([]byte, error) {
	return json.Marshal((&p).Output())
}

// ApplyResult reports relative paths changed by a successful transaction.
type ApplyResult struct {
	Written            []string
	CreatedDirectories []string
	Counts             map[string]int
}

// ApplyResultOutput is the stable machine-readable result representation.
type ApplyResultOutput struct {
	Written            []string       `json:"written"`
	CreatedDirectories []string       `json:"created_directories"`
	Counts             map[string]int `json:"counts"`
}

// Output returns a defensive copy of the public result.
func (r ApplyResult) Output() ApplyResultOutput {
	written := append([]string(nil), r.Written...)
	created := append([]string(nil), r.CreatedDirectories...)
	if written == nil {
		written = []string{}
	}
	if created == nil {
		created = []string{}
	}
	counts := make(map[string]int, len(r.Counts))
	for key, value := range r.Counts {
		counts[key] = value
	}
	return ApplyResultOutput{Written: written, CreatedDirectories: created, Counts: counts}
}

// MarshalJSON emits the same shape as the Python ApplyResult.to_dict method.
func (r ApplyResult) MarshalJSON() ([]byte, error) { return json.Marshal(r.Output()) }

// ParseNamingPool validates a CLI string.
func ParseNamingPool(value string) (NamingPool, error) {
	pool := NamingPool(value)
	for _, candidate := range []NamingPool{NamingRoman, NamingNorse, NamingHellenic} {
		if pool == candidate {
			return pool, nil
		}
	}
	return "", installerError(ErrInvalidInput, nil, "Unknown naming pool: %s", value)
}

// ParseConflictPolicy validates a CLI string.
func ParseConflictPolicy(value string) (ConflictPolicy, error) {
	policy := ConflictPolicy(value)
	for _, candidate := range []ConflictPolicy{
		ConflictAsk,
		ConflictKeep,
		ConflictOverwrite,
		ConflictFail,
	} {
		if policy == candidate {
			return policy, nil
		}
	}
	return "", installerError(ErrInvalidInput, nil, "Unknown conflict policy: %s", value)
}

func sortedKeys[V any](values map[string]V) []string {
	keys := make([]string, 0, len(values))
	for key := range values {
		keys = append(keys, key)
	}
	sort.Strings(keys)
	return keys
}
