extends CharacterBody3D


@export var  playerVelocity = 100
@export var jumpVelocity = 40

func _process(delta: float) -> void:
	var direction = Input.get_axis("left", "right")

	velocity.x = playerVelocity * delta * direction
	
	move_and_slide()


func  _physics_process(delta: float) -> void:
	# Falling
	if not is_on_floor():
		velocity += get_gravity() * delta
	else: #jumping
		if Input.is_action_just_pressed("jump"):
			velocity.y = jumpVelocity * delta * 10 # add velocity on Y 
