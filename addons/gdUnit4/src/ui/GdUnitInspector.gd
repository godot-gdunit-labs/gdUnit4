@tool
class_name GdUnitInspecor
extends Control


func _ready() -> void:
	@warning_ignore("return_value_discarded")
	GdUnitSignals.instance().gdunit_event.connect(func(event: GdUnitEvent) -> void:
		if event.type() != GdUnitEvent.SESSION_START:
			return

		var control: Control = get_parent_control()
		# if the tab is floating we dont need to set as current
		if control is TabContainer:
			var tab_container :TabContainer = control
			for tab_index in tab_container.get_tab_count():
				if tab_container.get_tab_title(tab_index) == "GdUnit":
					tab_container.set_current_tab(tab_index)
	)

	# Register for editor theme updates
	add_child(GdUnitEditorColorTheme.new(), true, Node.INTERNAL_MODE_BACK)
	# Add command handler
	add_child(GdUnitCommandHandler.instance(), true, Node.INTERNAL_MODE_BACK)
