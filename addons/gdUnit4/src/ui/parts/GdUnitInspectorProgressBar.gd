@tool
extends ProgressBar


@onready var status: Label = $Label
@onready var style: StyleBoxFlat = get("theme_override_styles/fill")

var _state: GdUnitInspectorTreeConstants.STATE

func _ready() -> void:
	style.bg_color = GdUnitEditorColorTheme.state_initial
	status.add_theme_color_override("font_color", Color.DIM_GRAY)
	value = 0
	max_value = 0
	update_text()


func update_text() -> void:
	status.text = "%d:%d" % [value, max_value]


func _on_test_counter_changed(index: int, total: int, state: GdUnitInspectorTreeConstants.STATE) -> void:
	value = index
	max_value = total
	update_text()

	# inital state
	if index == 0:
		_state = GdUnitInspectorTreeConstants.STATE.INITIAL

	# do only update the state is higher prio than current state
	if state <= _state:
		return
	_state = state

	if is_failed(state):
		style.bg_color = GdUnitEditorColorTheme.state_failure
	else:
		style.bg_color = GdUnitEditorColorTheme.state_success


func is_failed(state: GdUnitInspectorTreeConstants.STATE) -> bool:
	return state in [
		GdUnitInspectorTreeConstants.STATE.FAILED,
		GdUnitInspectorTreeConstants.STATE.ERROR,
		GdUnitInspectorTreeConstants.STATE.ABORDED]


func is_flaky(state: GdUnitInspectorTreeConstants.STATE) -> bool:
	return state == GdUnitInspectorTreeConstants.STATE.FLAKY
