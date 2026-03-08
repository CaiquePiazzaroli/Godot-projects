extends Area2D

@export var velocity: int = 10
@export var direction: int = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += (velocity * delta) * direction 
