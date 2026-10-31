extends Node3D

signal target_clicked(position: Vector3)
signal target_hovered
signal start_pressed
signal jumped

const SPEED := 5.0
const JUMP_VELOCITY := 4.5

@onready var _player: CharacterBody3D = $Player
@onready var _target: Area3D = $Target
@onready var _start_button: Button = $HUD/StartButton


func _ready() -> void:
	_target.input_event.connect(_on_target_input_event)
	_target.mouse_entered.connect(target_hovered.emit)
	_start_button.pressed.connect(start_pressed.emit)


func _physics_process(delta: float) -> void:
	if not _player.is_on_floor():
		_player.velocity += _player.get_gravity() * delta
	if Input.is_action_just_pressed("ui_accept") and _player.is_on_floor():
		_player.velocity.y = JUMP_VELOCITY
		jumped.emit()
	_player.velocity.x = Input.get_axis("ui_left", "ui_right") * SPEED
	_player.move_and_slide()


func _on_target_input_event(_camera: Node, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	var mouse_button := event as InputEventMouseButton
	if mouse_button != null and mouse_button.pressed and mouse_button.button_index == MOUSE_BUTTON_LEFT:
		target_clicked.emit(event_position)
