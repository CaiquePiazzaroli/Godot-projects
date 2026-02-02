extends CharacterBody3D

# Assign value to this variables when de node is ready
@onready var head: Node3D = $Head
@onready var eyes: Node3D = $Head/Eyes
@onready var camera_3d: Camera3D = $Head/Eyes/Camera3D
@onready var standing_collision_shape: CollisionShape3D = $StandingCollisionShape
@onready var crouching_collision_shape: CollisionShape3D = $CrouchingCollisionShape
@onready var sandup_check: RayCast3D = $SandupCheck

#Movement Variables
const walking_speed: float = 3.0
const sprinting_speed: float = 5.0
const crouching_speed: float = 1.0
var current_speed: float = 0.0
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

# From Node Clas: Called when there is an input event.
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
	
# From Node Clas: Called once per frame
func _physics_process(delta: float) -> void:
	# updatePlayerState()
	# updateCamera()
	
	# Falling
	if not is_on_floor():
		if velocity.y >= 0: # Jumping Upwards
			velocity += get_gravity() * delta
		else: # falling down
			velocity += get_gravity() * delta * 2.0 
	else: #jumping
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity	 # add velocity on Y 
	move_and_slide()
