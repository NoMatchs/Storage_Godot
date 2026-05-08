extends Area2D

signal hit  # 碰撞后发出的信号，给Main脚本做游戏结束逻辑

@export var speed: int = 400  # 玩家移动速度
var screen_size: Vector2      # 屏幕尺寸，限制玩家移动范围

# 节点进入场景树时执行，初始化屏幕尺寸+隐藏玩家
func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()

# 每一帧执行，处理玩家移动、动画、位置限制
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	# 检测方向输入
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	# 处理移动和动画
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed  # 归一化避免斜向移动更快
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	# 更新玩家位置并限制在屏幕内
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	# 处理动画方向（左右/上下）
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0

# 修复拼写错误！碰撞到物体时执行（核心：玩家消失+发信号）
func _on_body_entered(_body: Node2D) -> void:
	print("玩家被碰撞了！触发_on_body_entered") 
	hide()  # 玩家视觉上消失
	hit.emit()  # 发出hit信号，通知Main脚本游戏结束
	# 延迟禁用碰撞形状，避免重复触发碰撞
	$CollisionShape2D.set_deferred("disabled", true)
	

# 重新开始游戏时，Main脚本调用此函数初始化玩家
func start(pos: Vector2) -> void:
	position = pos  # 设置玩家初始位置
	show()  # 显示玩家
	$CollisionShape2D.disabled = false  # 启用碰撞形状
