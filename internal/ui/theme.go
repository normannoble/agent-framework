package ui

import (
	"charm.land/huh/v2"
	"charm.land/lipgloss/v2"
)

const (
	focusColor  = "#7c6df2"
	answerColor = "#65d1a7"
	dimColor    = "#777777"
	errorColor  = "#ff5f5f"
)

// Theme returns the installer theme. Focus is communicated only with a
// foreground color, weight, and selector; no style in the theme has a
// background color.
func Theme(noColor bool) huh.Theme {
	return huh.ThemeFunc(func(_ bool) *huh.Styles {
		normal := lipgloss.NewStyle()
		focus := themedStyle(noColor, focusColor, true)
		answer := themedStyle(noColor, answerColor, true)
		dim := themedStyle(noColor, dimColor, false)
		failure := themedStyle(noColor, errorColor, true)

		focused := huh.FieldStyles{
			Base:                normal,
			Title:               focus,
			Description:         dim,
			ErrorIndicator:      failure.SetString(" *"),
			ErrorMessage:        failure.SetString(" *"),
			SelectSelector:      focus.SetString("» "),
			Option:              normal,
			NextIndicator:       focus.SetString("→"),
			PrevIndicator:       focus.SetString("←"),
			Directory:           focus,
			File:                normal,
			MultiSelectSelector: focus.SetString("» "),
			SelectedOption:      answer,
			SelectedPrefix:      answer.SetString("● "),
			UnselectedOption:    normal,
			UnselectedPrefix:    dim.SetString("○ "),
			TextInput: huh.TextInputStyles{
				Cursor:      focus,
				CursorText:  normal,
				Placeholder: dim,
				Prompt:      focus,
				Text:        answer,
			},
			FocusedButton: focus,
			BlurredButton: dim,
			Card:          normal,
			NoteTitle:     focus,
			Next:          focus,
		}

		blurred := focused
		blurred.Title = normal
		blurred.SelectSelector = normal.SetString("  ")
		blurred.MultiSelectSelector = normal.SetString("  ")
		blurred.NextIndicator = normal
		blurred.PrevIndicator = normal
		blurred.FocusedButton = normal
		blurred.BlurredButton = dim
		blurred.Next = normal

		return &huh.Styles{
			Form: huh.FormStyles{Base: normal},
			Group: huh.GroupStyles{
				Base:        normal,
				Title:       focus,
				Description: dim,
			},
			FieldSeparator: normal.SetString("\n\n"),
			Focused:        focused,
			Blurred:        blurred,
		}
	})
}

func themedStyle(noColor bool, color string, bold bool) lipgloss.Style {
	style := lipgloss.NewStyle().Bold(bold)
	if noColor {
		return style
	}
	return style.Foreground(lipgloss.Color(color))
}
