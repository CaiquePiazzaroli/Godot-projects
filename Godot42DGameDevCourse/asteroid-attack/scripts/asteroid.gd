extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var random_force_x := get_random_force(100)
	var random_force_y := get_random_force()
	var my_vector := Vector2(random_force_x, random_force_y)
	apply_impulse(my_vector)



func get_random_force(force_range : float = 50) -> float:
		return randf_range(-force_range, force_range)
