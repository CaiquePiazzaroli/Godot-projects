extends RigidBody2D

var move_force: float = 100

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	apply_force(Vector2(move_force, 0.0))
