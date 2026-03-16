extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

@export var velocity: int = 60
@export var direction: int = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += (velocity * delta) * direction 


func set_direction(skeleton_direction):
	self.direction = skeleton_direction
	anim.flip_h = direction < 0 # retorna true o false para o flip_h

func _on_self_destruction_timer_timeout() -> void:
	queue_free()

func _on_area_entered(_area: Area2D) -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	queue_free()
