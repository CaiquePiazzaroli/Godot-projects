extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * delta
		
	if velocity.x != 0:
		anim.play("zombie_walk")
		if velocity.x > 0:
			anim.flip_h = true
		else:
			anim.flip_h = false
	else:
		anim.play("zombie_idle")
	
	velocity.x = 10
	
	
	move_and_slide()
