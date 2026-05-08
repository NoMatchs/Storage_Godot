extends CharacterBody2D

signal hp_depleted
var hp = 100.0

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	velocity = direction * 600
	move_and_slide()
	if velocity.length() > 0.0:
		%HappyBoo.play_walk_animation()
	else:
		%HappyBoo.play_idle_animation()
	const DAMAGE_RATE = 20.0
	var overlapping_mobs = %HeadBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		hp -= DAMAGE_RATE * overlapping_mobs.size() * delta
		%ProgressBar.value = hp 
		if hp <= 0.0:
			hp_depleted.emit()
