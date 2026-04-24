extends Node2D

@onready var left_raycast: RayCast2D = $leftRaycast
@onready var right_raycast: RayCast2D = $rightRaycast

func get_hit_direction() -> float:
	if left_raycast.is_colliding():
		return 1.0
	elif right_raycast.is_colliding():
		return -1.0
	else:
		return 0.0
