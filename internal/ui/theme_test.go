package ui

import (
	"strings"
	"testing"

	"charm.land/lipgloss/v2"
)

func TestThemeNeverUsesSelectionBackgrounds(t *testing.T) {
	styles := Theme(false).Theme(true)
	tests := map[string]lipgloss.Style{
		"focused option":            styles.Focused.Option,
		"focused selected option":   styles.Focused.SelectedOption,
		"focused unselected option": styles.Focused.UnselectedOption,
		"focused selected prefix":   styles.Focused.SelectedPrefix,
		"focused unselected prefix": styles.Focused.UnselectedPrefix,
		"focused select selector":   styles.Focused.SelectSelector,
		"focused multi selector":    styles.Focused.MultiSelectSelector,
		"focused button":            styles.Focused.FocusedButton,
		"focused blurred button":    styles.Focused.BlurredButton,
		"blurred option":            styles.Blurred.Option,
		"blurred selected option":   styles.Blurred.SelectedOption,
		"blurred unselected option": styles.Blurred.UnselectedOption,
		"blurred selected prefix":   styles.Blurred.SelectedPrefix,
		"blurred unselected prefix": styles.Blurred.UnselectedPrefix,
		"blurred select selector":   styles.Blurred.SelectSelector,
		"blurred multi selector":    styles.Blurred.MultiSelectSelector,
		"blurred focused button":    styles.Blurred.FocusedButton,
		"blurred button":            styles.Blurred.BlurredButton,
	}

	for name, style := range tests {
		t.Run(name, func(t *testing.T) {
			if _, ok := style.GetBackground().(lipgloss.NoColor); !ok {
				t.Fatalf("background = %#v; want lipgloss.NoColor", style.GetBackground())
			}
		})
	}
}

func TestThemeUsesRequestedIndicators(t *testing.T) {
	styles := Theme(true).Theme(true)
	if got := styles.Focused.SelectSelector.String(); !strings.Contains(got, "» ") {
		t.Fatalf("select selector = %q; want it to contain %q", got, "» ")
	}
	if got := styles.Focused.SelectedPrefix.String(); !strings.Contains(got, "● ") {
		t.Fatalf("selected prefix = %q; want it to contain %q", got, "● ")
	}
	if got := styles.Focused.UnselectedPrefix.String(); !strings.Contains(got, "○ ") {
		t.Fatalf("unselected prefix = %q; want it to contain %q", got, "○ ")
	}
}
