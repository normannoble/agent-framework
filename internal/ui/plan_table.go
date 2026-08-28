package ui

import (
	"charm.land/bubbles/v2/table"
	"charm.land/lipgloss/v2"
	"github.com/normannoble/agent-framework/internal/installer"
)

const planTableWidth = 90

func planTable(plan *installer.InstallPlan, noColor bool) string {
	rows := planTableRows(plan, noColor)
	styles := planTableStyles(noColor)
	model := table.New(
		table.WithColumns([]table.Column{
			{Title: "Action", Width: 11},
			{Title: "Path", Width: 42},
			{Title: "Details", Width: 31},
		}),
		table.WithRows(rows),
		table.WithHeight(max(2, len(rows)+1)),
		table.WithWidth(planTableWidth),
		table.WithFocused(false),
		table.WithStyles(styles),
	)
	return model.View()
}

func planTableRows(plan *installer.InstallPlan, noColor bool) []table.Row {
	rows := make([]table.Row, 0, len(plan.Files)+len(plan.Directories))
	for _, change := range plan.Files {
		rows = append(rows, table.Row{
			planActionStyle(change.Status, noColor).Render(statusLabel(change.Status)),
			change.RelativePath,
			change.Label,
		})
	}
	for _, directory := range plan.Directories {
		if directory.Create {
			rows = append(rows, table.Row{
				planActionStyle(installer.ChangeAdd, noColor).Render("Add"),
				directory.RelativePath + "/",
				"Directory",
			})
		}
	}
	return rows
}

func planTableStyles(noColor bool) table.Styles {
	cell := lipgloss.NewStyle().PaddingRight(2)
	header := themedStyle(noColor, dimColor, true).PaddingRight(2)
	if noColor {
		header = cell
	}
	return table.Styles{
		Header:   header,
		Cell:     cell,
		Selected: lipgloss.NewStyle(),
	}
}

func planActionStyle(status installer.ChangeStatus, noColor bool) lipgloss.Style {
	if noColor {
		return lipgloss.NewStyle()
	}
	switch status {
	case installer.ChangeAdd:
		return themedStyle(noColor, answerColor, true)
	case installer.ChangeUpdate:
		return themedStyle(noColor, focusColor, true)
	case installer.ChangeUnchanged, installer.ChangeKeep:
		return themedStyle(noColor, dimColor, false)
	case installer.ChangeConflict, installer.ChangeBlocked:
		return themedStyle(noColor, errorColor, true)
	default:
		return lipgloss.NewStyle()
	}
}
