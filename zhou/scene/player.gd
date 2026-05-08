extends CharacterBody2D

const NORMAL_ANIMATION_PRERFIX := &"normal"

@onready var Bodysprite: AnimatedSprite2D = $Bodysprite

var facing_suffix: StringName = &"right"

@export var move_speed: float = 120.0

func _ready() -> void:
	_update_animation()

func _physics_process(delta: float) -> void:
	var move_input := Input.get_vector("move_left","move_right","move_up","move_down")
	
	velocity = move_speed * move_input
	move_and_slide()
	if move_input != Vector2.ZERO:
		facing_suffix = _vector_to_facing_suffix(move_input)
	
	_update_animation()

func _update_animation() -> void:
	var animation_name := StringName("%s_%s" % [NORMAL_ANIMATION_PRERFIX,facing_suffix])
	
	if not Bodysprite.sprite_frames.has_animation(animation_name):
		push_warning("Missing Player animation: %s" % animation_name)
		return 
		
	if Bodysprite.animation != animation_name:
		Bodysprite.play(animation_name)

func _vector_to_facing_suffix(direction: Vector2) -> StringName:
	if abs(direction.x) >= abs(direction.y):
		return &"right" if direction.x > 0.0 else &"left"
		
	return &"down" if direction.y > 0.0 else &"up"
