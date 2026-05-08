extends CharacterBody2D

const JUMP_VELOCITY = - 500.00
const GRAVUTY = 1500

const HIT = preload("uid://d1goaqcrf0f7x")
const POINT = preload("uid://7vbm5mqn8uth")
const WING = preload("uid://bf40x7naobk6b")

var rot_degree = 0
var is_dead = true

@export var max_speed := 700
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var fly_sound: AudioStreamPlayer2D = $FlySound
@onready var score_sound: AudioStreamPlayer2D = $ScoreSound
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if not is_dead:
		velocity.y += GRAVUTY * delta
		
		if Input.is_action_just_pressed("fly"):
			velocity.y = JUMP_VELOCITY
			fly_sound.stream = WING
			fly_sound.play()
		rot_degree = clampf(-30 * velocity.y / JUMP_VELOCITY,-30,30)
		rotation_degrees = rot_degree
		
		velocity.y = clampf(velocity.y, -max_speed, max_speed)
		
		move_and_slide()
