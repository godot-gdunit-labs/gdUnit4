extends Node2D

@onready var _cursor: Sprite2D = $Cursor


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(_delta: float) -> void:
	_cursor.position = get_viewport().get_mouse_position()
