class_name GdUnitContextMenuItem


var command_id: String:
	set(value):
		command_id = value
	get:
		return command_id

var name: StringName:
	set(value):
		name = value
	get:
		return name

var command: GdUnitCommand:
	set(value):
		command = value
	get:
		return command

var visible: Callable:
	set(value):
		visible = value
	get:
		return visible

var icon: Texture2D:
	get:
		return GdUnitCommandHandler.instance().command_icon(command_id)


func _init(p_command_id: String, p_name: StringName, p_is_visible: Callable, p_command: GdUnitCommand) -> void:
	assert(p_command_id != null and not p_command_id.is_empty(), "(%s) missing command id " % p_command_id)
	assert(p_is_visible != null, "(%s) missing parameter 'GdUnitCommand'" % p_name)

	self.command_id = p_command_id
	self.name = p_name
	self.command = p_command
	self.visible = p_is_visible


func shortcut() -> Shortcut:
	if command == null:
		return GdUnitCommandHandler.instance().command_shortcut(command_id)
	else:
		return GdUnitCommandHandler.instance().get_shortcut(command.shortcut)


func is_enabled(script: Script) -> bool:
	return command.is_enabled.call(script)


func is_visible(...args: Array) -> bool:
	return visible.callv(args)


func execute(...args: Array) -> void:
	if command == null:
		GdUnitCommandHandler.instance().command_execute(command_id, args)
	else:
		command.runnable.callv(args)
