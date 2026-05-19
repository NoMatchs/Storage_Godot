extends CharacterBody2D

const NORMAL_ANIMATION_PREFIX := &"normal"  # 修复：PRERFIX → PREFIX


@onready var armed: AnimatedSprite2D = $ArmedEffectSprite
@onready var shooting_timer: Timer = $ShootingTimer
@onready var armed_effect_sprite: AnimatedSprite2D = $ArmedEffectSprite  # 修复：新增缺失的节点引用

var rapid_fire_rate_multiplier: float = DEFAULT_FIRE_RATE_MULTIPLIER  # 修复：muLtipLier → multiplier
var form_fire_rate_multiplier: float = DEFAULT_FIRE_RATE_MULTIPLIER    # 修复：muLtipLier → multiplier
var current_form_mode: int = PLAYER_FORM_MODE_NORMAL
var current_shot_pattern: int = SHOT_PATTERN_NORMAL
var spiral_phase: float = 0.0

const BULLET_SCENE := preload("res://scene/bullets.tscn")
const ARMED_ANIMATION_PREFIX := &"armed"
const DEFAULT_FIRE_RATE_MULTIPLIER := 1.0
const SPIRAL_PHASE_STEP := PI / 12

const PLAYER_FORM_MODE_NORMAL := 0
const PLAYER_FORM_MODE_ARMED := 1
const SHOT_PATTERN_NORMAL := 0
const SHOT_PATTERN_SPIRAL := 1

@export var fire_interval: float = 0.18
@export var bullet_spawn_distance: float = 18.0
@onready var body_sprite: AnimatedSprite2D = $Bodysprite  # 修复：Bodysprite → body_sprite（统一命名）

var facing_suffix: StringName = &"right"
@export var move_speed: float = 120.0

func _ready() -> void:
	
	current_form_mode = PLAYER_FORM_MODE_ARMED
	current_shot_pattern = SHOT_PATTERN_SPIRALs
	form_fire_rate_multiplier = 20.0
	spiral_phase = 0.0
	
	shooting_timer.one_shot = true
	shooting_timer.wait_time = _get_effective_fire_interval()
	_update_animation()
	_update_armed_effect()

func _physics_process(_delta: float) -> void:
	var move_input := Input.get_vector("move_left","move_right","move_up","move_down")
	var shoot_input := Input.get_vector("shoot_left","shoot_right","shoot_up","shoot_down")
	
	velocity = move_speed * move_input
	move_and_slide()
	if current_shot_pattern == SHOT_PATTERN_SPIRAL:
		_try_auto_spiral_shoot()
	elif shoot_input != Vector2.ZERO:
		_try_shoot(shoot_input)
		
	_update_facing(move_input,shoot_input)
	_update_animation()
	_update_armed_effect()

func _update_facing(move_input: Vector2, shoot_input:Vector2) -> void:
	if current_shot_pattern == SHOT_PATTERN_SPIRAL:
		if move_input != Vector2.ZERO:
			facing_suffix = _vector_to_facing_suffix(move_input)
		return
	if shoot_input != Vector2.ZERO:
		facing_suffix = _vector_to_facing_suffix(shoot_input)
	elif move_input != Vector2.ZERO:
		facing_suffix = _vector_to_facing_suffix(move_input)

func _update_animation() -> void:
	# 修复：使用正确的前缀 + 统一变量名 body_sprite
	var animation_name := StringName("%s_%s" % [NORMAL_ANIMATION_PREFIX, facing_suffix])
	if not body_sprite.sprite_frames.has_animation(animation_name):
		push_warning("Missing player animation: %s" % animation_name)
		return
	if body_sprite.animation != animation_name:
		body_sprite.play(animation_name)

func _try_shoot(shoot_input:Vector2) -> void:
	if not shooting_timer.is_stopped():
		return
	var shoot_direction := shoot_input.normalized()
	var has_spawned_bullet := _fire_bullets(shoot_direction)
	if has_spawned_bullet:
		shooting_timer.start(_get_effective_fire_interval())  # 修复：删除错误的 O()

func _fire_bullets(base_direction:Vector2) -> bool:
	if current_shot_pattern == SHOT_PATTERN_SPIRAL:
		var has_spawned_forward_bullet := _spawn_bullet(base_direction)  # 修复：butlet → bullet
		var has_spawned_backward_bullet := _spawn_bullet(base_direction.rotated(PI))  # 修复：buLlet → bullet
		spiral_phase = wrapf(spiral_phase + SPIRAL_PHASE_STEP, 0.0, TAU)  # 修复：SpiraL、O.O → 正确写法
		return has_spawned_forward_bullet or has_spawned_backward_bullet
	return _spawn_bullet(base_direction)  # 修复：return_spawn → return + 空格

func _spawn_bullet(shoot_direction:Vector2) -> bool:
	var bullet := BULLET_SCENE.instantiate() as Bullet
	if bullet == null:  # 修复：butlet → bullet
		return false
	bullet.top_level = true
	bullet.setup(shoot_direction)
	# 子弹挂到当前主场景下，避免跟随玩家一起移动。
	var spawn_parent := get_tree().current_scene
	if spawn_parent == null:
		return false
	spawn_parent.add_child(bullet)  # 修复：butlet → bullet
	bullet.global_position = global_position + shoot_direction * bullet_spawn_distance
	return true

func _try_auto_spiral_shoot() -> void:
	if not shooting_timer.is_stopped():
		return
	var spiral_direction := Vector2.RIGHT.rotated(spiral_phase)
	var has_spawned_bullet := _fire_bullets(spiral_direction)  # 修复：buLlets → bullets
	if has_spawned_bullet:
		shooting_timer.start(_get_effective_fire_interval())

func _get_effective_fire_interval() -> float:
	return maxf(fire_interval / _get_effective_fire_rate_multiplier(), 0.01)

# 强化形态激活时优先使用形态自带的射速倍率，否则退回普通射速倍率。
func _get_effective_fire_rate_multiplier() -> float:
	if _has_active_form_override():
		return maxf(form_fire_rate_multiplier, 0.01)
	return maxf(rapid_fire_rate_multiplier, 0.01)  # 修复：muLtiplier → multiplier

func _has_active_form_override() -> bool:
	return (
	current_form_mode != PLAYER_FORM_MODE_NORMAL
	or current_shot_pattern != SHOT_PATTERN_NORMAL
	)

# 根据当前形态选择动画前缀。
func _get_animation_prefix() -> StringName:
	if current_form_mode == PLAYER_FORM_MODE_ARMED:
		return ARMED_ANIMATION_PREFIX
	return NORMAL_ANIMATION_PREFIX

func _update_armed_effect() -> void:
	var is_armed := current_form_mode == PLAYER_FORM_MODE_ARMED	
	
	if not is_armed:
		if armed_effect_sprite.visible:
			armed_effect_sprite.visible = false
		if armed_effect_sprite.is_playing():
			armed_effect_sprite.stop()
		return
	
	if not armed_effect_sprite.visible:
		armed_effect_sprite.visible = true
	if armed_effect_sprite.is_playing():
		return
	if armed_effect_sprite.sprite_frames == null:
		return
		
	if armed_effect_sprite.sprite_frames.has_animation(&"default"):
		armed_effect_sprite.play(&"default")

func _vector_to_facing_suffix(direction: Vector2) -> StringName:
	if abs(direction.x) >= abs(direction.y):
		return &"right" if direction.x > 0.0 else &"left"
		
	return &"down" if direction.y > 0.0 else &"up"
