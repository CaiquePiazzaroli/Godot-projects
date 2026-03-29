extends CharacterBody2D


@export var acceleration = 400
@export var max_speed = 100
@export var jump_velocity = -300
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# direção do player
var direction: float = 0.0

# Possíveis estados do player e variavel state inicial
enum PlayerState {
	idle,
	walk,
	jump
}
var state : PlayerState

# Movimenta o player quando pressionado o botao
func move(delta : float) -> void:
	update_direction() # Atualiza direção 
	if direction: # acelera até a velocidade 100
		velocity.x = move_toward(velocity.x, max_speed * direction, acceleration * delta)

	else: # Desacelera até a velocidade 0
		velocity.x = move_toward(velocity.x, 0, acceleration * delta) #zera a velocidade em x

# Atualiza a var direction e flipa o sprite
func update_direction():
	direction = Input.get_axis("left", "right")
	if direction > 0:
		anim.flip_h = false
	elif direction < 0:
		anim.flip_h = true

# Inicia o player com estado idle
func _ready() -> void:
	go_to_idle_state()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _physics_process(delta: float) -> void:

	match state:
		PlayerState.idle:
			idle_state(delta)
		PlayerState.walk:
			walk_state(delta)
		PlayerState.jump:
			jump_state(delta)
	

func go_to_idle_state():
	state = PlayerState.idle #altera estado para idle
	anim.play("idle") # muda anim para idle
	

func go_to_walk_state():
	state = PlayerState.walk # altera estado para walk
	anim.play("walk") # muda anim para walk
	

func go_to_jump_state():
	state = PlayerState.jump #altera estado para jump
	anim.play("jump") # Muda animação
	velocity.y = jump_velocity # atribui velocidade de pular
	

func idle_state(delta:float) -> void:
	apply_gravity(delta) # Permite ação da gravidade
	move(delta) # Permite movimentação
	
	if Input.is_action_just_pressed("jump"): # Pular
		go_to_jump_state()
		return
		
	if direction != 0: # Andar
		go_to_walk_state()
		return
	
func walk_state(delta: float) -> void:
	apply_gravity(delta)
	move(delta)
	
	if Input.is_action_just_pressed("jump"): # pular
		go_to_jump_state()
		return
	
	if direction == 0: # Idle
		go_to_idle_state()
		return

func jump_state(delta: float):
	apply_gravity(delta) # permite ação da gravidade
	move(delta) # pemite movimentação
	
	if is_on_floor(): # Caiu no chao, volta para idle
		go_to_idle_state()
		return


# Gravidade - Atribui uma velocidade positiva no eixo Y fazendo o player cair
func apply_gravity(delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * delta
	
	## Necessário para atualizar velocity
	move_and_slide()
