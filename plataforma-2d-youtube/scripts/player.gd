extends CharacterBody2D

enum PlayerState {
	idle,
	walk,
	jump,
	duck
}

# Faz uma referencia ao nó da arvore que se chama AnimatedSprite2D 
# Atribuindo a uma variável chamada anim do tipo AnimetadesSprite2D
@onready var  anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
var direction: float = 0.0
const SPEED = 70.0
const JUMP_VELOCITY = -300
var status: PlayerState
var jump_count: int = 0
@export var max_jump_count: int = 2


func _ready() -> void:
	go_to_idle_state()

# Função chamada 60x por segundo
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match status:
		PlayerState.idle:
			idle_state()
		PlayerState.walk:
			walk_state()
		PlayerState.jump:
			jump_state()
		PlayerState.duck:
			duck_state()
	
	move_and_slide()

func go_to_idle_state():
	status = PlayerState.idle
	anim.play("idle")

func go_to_walk_state():
	status = PlayerState.walk
	anim.play("walk")

func go_to_jump_state():
	status = PlayerState.jump
	anim.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1
	
func go_to_duck_state():
	status = PlayerState.duck
	collision_shape_2d.shape.height = 10.0
	collision_shape_2d.position.y = 3
	anim.play("duck")

func idle_state():
	move()
	if velocity.x != 0:
		go_to_walk_state()
		return
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if Input.is_action_pressed("duck"):
		go_to_duck_state()
		return
	
func walk_state():
	move()
	if(velocity.x == 0):
		go_to_idle_state()
		return
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return

func jump_state():
	move()
	
	if Input.is_action_just_pressed("jump") && jump_count < max_jump_count:
		go_to_jump_state()
	
	if is_on_floor():
		jump_count = 0
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return

func duck_state():
	update_direction()
	if Input.is_action_just_released("duck"):
		exit_from_duck_state()
		go_to_idle_state()
		return
		
func exit_from_duck_state():
	collision_shape_2d.shape.height = 16.0
	collision_shape_2d.position.y = 0

func move():
	update_direction()
	if direction: # se direction != 0 atualizar posicao (para esquerda ou direita)
		velocity.x = direction * SPEED # atualiza a posição em função da var SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED) # para o player devagar (não bruscamente)

func update_direction():
	direction = Input.get_axis("left", "right") # retorna -1 ou 1 
	# flipando o sprite
	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false
