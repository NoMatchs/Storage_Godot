extends Area2D

@export
var enemy_speed : float = 50

var is_dead : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not is_dead:
		position += Vector2(-enemy_speed,0) * delta
	if position.x < -267:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not is_dead:
		body.game_over()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		$AnimatedSprite2D.play("Death")
		is_dead = true
		area.queue_free()
		$Enemy_dead_sound.play()
		get_tree().current_scene.score += 1
		await get_tree().create_timer(0.3).timeout
		queue_free()
