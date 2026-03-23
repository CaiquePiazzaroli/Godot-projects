extends CharacterBody3D

# Assign value to this variables when de node is ready
@onready var head: Node3D = $Head
@onready var eyes: Node3D = $Head/Eyes
@onready var camera_3d: Camera3D = $Head/Eyes/Camera3D
@onready var standing_collision_shape: CollisionShape3D = $StandingCollisionShape
@onready var crouching_collision_shape: CollisionShape3D = $CrouchingCollisionShape
@onready var standup_check: RayCast3D = $StandupCheck

#Movement Variables
const walking_speed: float = 3.0
const sprinting_speed: float = 5.0
const crouching_speed: float = 1.0
var current_speed: float = 3.0
var moving: bool = false
var input_dir: Vector2 = Vector2.ZERO #Instances a Vector 2 With (0, 0)
var direction: Vector3 = Vector3.ZERO #Instances a Vector 2 With (0, 0, 0)
const crouching_depth: float = -0.65
const jump_velocity: float = 4.0

var mouse_sensitivity: float = 0.2

# State Machine
enum PlayerState {
	IDLE_STAND,
	IDLE_CROUCH,
	CROUCHING,
	WALKING,
	SPRINTING,
	AIR
}

var player_state: PlayerState = PlayerState.IDLE_STAND

# From Node Class: Runs when both the node and its children have entered the scene tree
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) #Hide cursor

# From Node Class: Called when there is an input event.
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit();
	
	if event is InputEventMouseMotion:
		# event is the mouse motion that player do
		# relative X is how much the position of mouse change in the x 
		# rorate_y rotate de player on Y (In this case the entire player will rotate)
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		
		# here, just the head will move because we are using the head const reference
		# Just the values of Y have importance in this case
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		
		# Limiting the head movement
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-85), deg_to_rad(85))
	
# From Node Class: Called once per frame
func _physics_process(delta: float) -> void:
	
	updatePlayerState()
	# updateCamera()
	
	# Falling
	if not is_on_floor():
		if velocity.y >= 0: # Jumping Upwards
			velocity += get_gravity() * delta
		else: # falling down
			velocity += get_gravity() * delta
	else: #jumping
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity	 # add velocity on Y 
			
			
	# Movement Logic
	input_dir = Input.get_vector("left","right","forward","backward");
	
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*10.0)
	
	if(direction):
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else: #player wants to stop moving
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	
	move_and_slide()
	
func updatePlayerState() -> void:
	moving = (input_dir != Vector2.ZERO)
	if not is_on_floor():
		player_state = PlayerState.AIR
	else:
		if Input.is_action_pressed("crouch"):
			if not moving:
				player_state = PlayerState.IDLE_CROUCH
			else:
				player_state = PlayerState.CROUCHING
		elif !standup_check.is_colliding():
			if not moving:
				player_state = PlayerState.IDLE_STAND
			elif Input.is_action_pressed("sprint"):
				player_state = PlayerState.SPRINTING
			else:
				player_state = PlayerState.WALKING
