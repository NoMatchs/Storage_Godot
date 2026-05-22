extends CharacterBody2D

var Input_Direction: Vector2 = Vector2.ZERO
var FacingDirection: String = "Down"
const SPEED = 200
const ACCELERATE = 15
var AnimationToPlay : String
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	Input_Direction = Input.get_vector("Left","Right","Up","Down")
	
	velocity = velocity.lerp(Input_Direction * SPEED,ACCELERATE * delta)
	
	move_and_slide()
	
	if velocity.length() > 20:
		AnimationToPlay = "Run_" + GetDirection()
	else:
		AnimationToPlay = "Idel_" + GetDirection()
	
	animated_sprite_2d.play(AnimationToPlay)
	#print(AnimationToPlay)

func GetDirection() -> String:
	if Input_Direction == Vector2.ZERO:
		return FacingDirection
	if Input_Direction.y > 0:
		FacingDirection = "Down"
	elif Input_Direction.y < 0:
		FacingDirection = "Up"
	else:
		if Input_Direction.x > 0:
			FacingDirection = "Right"
		elif Input_Direction.x < 0:
			FacingDirection = "Left"
	return FacingDirection
