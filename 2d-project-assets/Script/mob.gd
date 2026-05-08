extends CharacterBody2D

var Player

var hp = 3

func _ready() -> void:
	Player = get_node("/root/Game/Player")
	%Slime.play_walk()

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(Player
.global_position)
	velocity = direction * 300
	move_and_slide()

func take_damege():
	hp -= 1
	%Slime.play_hurt()
	if hp == 0:
		queue_free()
		
		const SMOKE = preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke = SMOKE.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = global_position
