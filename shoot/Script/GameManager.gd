extends Node2D

@export
var enemy_scene : PackedScene
@export
var spawn_time : Timer
@export 
var score : int = 0
@export 
var score_label : Label 
@export 
var game_over_label : Label 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	spawn_time.wait_time -= 0.2 * delta
	spawn_time.wait_time = clamp(spawn_time.wait_time,1,3)
	
	score_label.text = "Score: " + str(score)


func _on_timer_timeout() -> void:
	var enemy_node = enemy_scene.instantiate()
	enemy_node.position = Vector2(260,randf_range(10,80))
	get_tree().current_scene.add_child(enemy_node)

func show_game_over():
	game_over_label.visible = true
