package ui

import (
	"strings"
	"testing"

	"charm.land/huh/v2"
)

func TestComponentsFieldShowsEveryChoice(t *testing.T) {
	selected := []string{"skills", "workspace", "claude"}
	field := newComponentsField([]huh.Option[string]{
		huh.NewOption("Claude Code skills", "skills"),
		huh.NewOption("Workspace directories", "workspace"),
		huh.NewOption("CLAUDE.md integration", "claude"),
	}, &selected)
	field.WithTheme(Theme(true))
	field.Init()
	field.Focus()
	view := field.View()

	for _, label := range []string{
		"Claude Code skills",
		"Workspace directories",
		"CLAUDE.md integration",
	} {
		if !strings.Contains(view, label) {
			t.Fatalf("field view does not show %q:\n%s", label, view)
		}
	}
}

func TestExplicitComponentChoicesAreOmittedAndPreserved(t *testing.T) {
	prompted := componentState{workspace: true}
	choices := componentChoices(prompted)
	selected := []string{"skills"}
	field := newComponentsField(choices, &selected)
	field.WithTheme(Theme(true))
	field.Init()
	field.Focus()
	view := field.View()
	if strings.Contains(view, "Claude Code skills") || strings.Contains(view, "CLAUDE.md integration") {
		t.Fatalf("explicit component rows are still editable:\n%s", view)
	}
	if !strings.Contains(view, "Workspace directories") {
		t.Fatalf("unspecified component row is missing:\n%s", view)
	}

	defaults := componentState{skills: false, workspace: true, claude: true}
	result := mergeComponentSelection(defaults, prompted, []string{"skills"})
	if result.skills || result.workspace || !result.claude {
		t.Fatalf("merged components = %+v; explicit values changed or prompted value was ignored", result)
	}
}
