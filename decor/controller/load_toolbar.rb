module Decor_Standards
	TITLE = 'Decor - Standards'
	toolbar = UI::Toolbar.new TITLE
	cmd = UI::Command.new("Create Wall") { self.decor_create_wall }
	cmd.small_icon = "icons/wall.png"
	cmd.large_icon = "icons/wall.png"
	cmd.tooltip = "Create Wall"
	cmd.status_bar_text = "Create a Rectangle wall"
	toolbar.add_item cmd
	
	toolbar = toolbar.add_separator	
	cmd = UI::Command.new("Get Standards") { self.decor_import_comp }
	cmd.small_icon = "icons/import.png"
	cmd.large_icon = "icons/import.png"
	cmd.tooltip = "Import Standards"
	cmd.status_bar_text = "Import Standards Components"
	toolbar.add_item cmd

	toolbar = toolbar.add_separator
	cmd = UI::Command.new("Configuration") { self.load_dynamic_config }
	cmd.small_icon = "icons/config.png"
	cmd.large_icon = "icons/config.png"
	cmd.tooltip = "Standards Configuration"
	cmd.status_bar_text = "Edit Standards Configuration"
	toolbar.add_item cmd

	toolbar = toolbar.add_separator
	cmd = UI::Command.new("Working Drawing") { UI.messagebox 'Working Drawing' }
	cmd.small_icon = "icons/pdf.png"
	cmd.large_icon = "icons/pdf.png"
	cmd.tooltip = "Working Drawing"
	cmd.status_bar_text = "Export Working Drawing as PDF"
	toolbar.add_item cmd

	toolbar = toolbar.add_separator
	cmd = UI::Command.new("Export") { self.export_report_xls }
	cmd.small_icon = "icons/excel.png"
	cmd.large_icon = "icons/excel.png"
	cmd.tooltip = "Excel Report"
	cmd.status_bar_text = "Export as XLS Report"
	toolbar.add_item cmd

	toolbar.show
	toolbar.each {|item|}
end