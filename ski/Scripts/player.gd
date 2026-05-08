extends CharacterBody2D

class_name Player

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var max_speed := 850.0
@export var gravity := 800.0
@export var friction := 100.0
@export var control :=500.0

var is_player_steering := false 
var move_direction = Vector2.RIGHT

func _process(delta: float) -> void:
	_update_visual()
	#print("ad")

func _physics_process(delta: float) -> void:
	if is_player_steering:
		_update_dirextion()
	_update_velocity(delta)
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		is_player_steering = true
	elif event.is_action_released("mouse_left"):
		is_player_steering = false

func _update_visual():
	_update_sprite_frame()

func _update_sprite_frame():
	var frame_index = max(0,move_direction.dot(Vector2.DOWN))*3
	
	if move_direction.dot(Vector2.LEFT) > 0:
		frame_index += 3
	sprite_2d.frame = int(frame_index) % 6

func _update_dirextion():
	var mouse_pos = get_global_mouse_position()
	var target_dir = (mouse_pos-global_position).normalized()
	
	move_direction = target_dir

func _update_velocity(delta):
	var downhill_dot = move_direction.dot(Vector2.DOWN)
	var downhill_multiplier = sign(downhill_dot)*sqrt(abs(downhill_dot))
	var friction_multiplier = 1.0 - max(0.0,downhill_dot)
	
	var max_speed_multipliter = (downhill_dot + 1.0) / 2.0
	var speed = velocity.length()
	var current_max_speed = max_speed * max_speed_multipliter
	speed += gravity*downhill_multiplier * delta
	
	speed = move_toward(speed,0,friction_multiplier * friction * delta)
	speed = clamp(speed,-current_max_speed,current_max_speed)
	
	velocity = velocity.move_toward(move_direction * speed,control * delta)
	
