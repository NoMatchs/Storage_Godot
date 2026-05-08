extends Line2D

# 自定义轨迹点数组，避免和Line2D内置的points属性冲突
var track_points: Array[Vector2] = []

func _process(_delta: float) -> void:
	# 获取父节点的全局坐标（比如Player的位置）
	var parent_pos = get_parent().global_position
	# 将父节点坐标添加到自定义数组
	track_points.append(parent_pos)
	# 更新Line2D的点集
	set_points(track_points)
	
	# 限制轨迹点数量，避免内存占用过大
	if track_points.size() > 50:
		track_points.remove_at(0)
