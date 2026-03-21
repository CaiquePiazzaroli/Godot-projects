extends CharacterBody2D

enum PlayerState {
	idle,
	walk,
	jump,
	fall,
	duck,
	slide,
	wall,
	swimming,
	hurt
}

# Faz uma referencia ao nó da arvore que se chama AnimatedSprite2D 
# Atribuindo a uma variável chamada anim do tipo AnimetadesSprite2D
@onready var  anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hitbox_collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var left_wall_detector: RayCast2D = $LeftWallDetector
@onready var right_wall_detector: RayCast2D = $RightWallDetector

@onready var reload_timer: Timer = $ReloadTimer

var direction: float = 0.0
@export var max_speed = 180
@export var acceleration  = 400
@export var deceleration = 400
@export var slide_deceleration = 100
@export var wall_acceleration = 40
@export var wall_jump_velocity = 240
@export var max_water_speed = 100
@export var water_acceleration = 200
@export var jump_force = -100

const JUMP_VELOCITY = -280
var status: PlayerState
var jump_count: int = 0
@export var max_jump_count: int = 2

func move(delta: float):
	update_direction()
	if direction: # se direction != 0 atualizar posicao (para esquerda ou direita)
		# atualiza a posição em função da var SPEED
		velocity.x = move_toward(velocity.x, max_speed * direction, acceleration * delta) # para o player devagar (não bruscamente)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta) # para o player devagar (não bruscamente)

func apply_gravity(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

func _ready() -> void:
	go_to_idle_state()

# Função chamada 60x por segundo
func _physics_process(delta: float) -> void:
	match status:
		PlayerState.idle:
			idle_state(delta)
		PlayerState.walk:
			walk_state(delta)
		PlayerState.jump:
			jump_state(delta)
		PlayerState.fall:
			fall_state(delta)
		PlayerState.duck:
			duck_state(delta)
		PlayerState.slide:
			slide_state(delta)
		PlayerState.wall:
			wall_state(delta)
		PlayerState.swimming:
			swimming_state(delta)
		PlayerState.hurt:
			hurt_state(delta)
	
	move_and_slide()

func go_to_idle_state():
	set_large_collider()
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
	
func go_to_fall_state():
	status = PlayerState.fall
	anim.play("fall")
	
func go_to_duck_state():
	status = PlayerState.duck
	set_small_collider()
	anim.play("duck")
	
func exit_from_duck_state():
	set_large_collider()

func go_to_slide_state():
	status = PlayerState.slide
	set_small_collider()
	anim.play("slide")

func exit_from_slide_state():
	set_large_collider()

func go_to_wall_state():
	status = PlayerState.wall
	anim.play("wall")
	velocity = Vector2.ZERO
	jump_count = 0

func go_to_swimming_state():
	status = PlayerState.swimming
	anim.play("swimming")
	
	# min = retorna o menor valor entre os numeros passados
	# se a velocidade em y é maior que 100, então a velocidade se torna 100
	# se for menor, a velocidade se mantem
	velocity.y = min(velocity.y, 100) 

func go_to_hurt_state():
	if status == PlayerState.hurt:
		return
	set_hurt_collider()
	status = PlayerState.hurt
	anim.play("hurt")
	velocity.x = 0
	reload_timer.start() # Inicia um contador para resetar acena quando o player morrer

func idle_state(delta: float):
	apply_gravity(delta)
	move(delta)
	if velocity.x != 0:
		go_to_walk_state()
		return
		
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if Input.is_action_pressed("duck"):
		go_to_duck_state()
		return
	
func walk_state(delta: float):
	apply_gravity(delta)
	move(delta)
	
	if(velocity.x == 0):
		go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if Input.is_action_just_pressed("duck"):
		go_to_slide_state()

	if !is_on_floor():
		jump_count += 1
		go_to_fall_state()

func jump_state(delta: float):
	apply_gravity(delta)
	move(delta)
	
	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return
		
	if velocity.y > 0: # Y > 0 indica que o player está caindo e < 0 que esta subindo
		go_to_fall_state()
		return
		
func fall_state(delta: float):
	apply_gravity(delta)
	move(delta)
	
	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return
	
	if is_on_floor():
		jump_count = 0
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return
	
	# Is on wall é o metodo para não deslisar em plataforma, mas apenas paredes
	if (left_wall_detector.is_colliding() or right_wall_detector.is_colliding()) && is_on_wall_only():
		go_to_wall_state()
		return

func duck_state(delta):
	apply_gravity(delta)
	update_direction()
	
	if Input.is_action_just_released("duck"):
		exit_from_duck_state()
		go_to_idle_state()
		return

func slide_state(delta):
	apply_gravity(delta)
	velocity.x = move_toward(velocity.x, 0, slide_deceleration * delta)
	
	if Input.is_action_just_released("duck"):
		exit_from_slide_state()
		go_to_walk_state()	
		return
		
	if velocity.x == 0:
		exit_from_slide_state()
		go_to_duck_state()
		return

func wall_state(delta):
	
	# Define uma aceleração mais lenta para o state wall
	velocity.y += wall_acceleration * delta 
	
	if left_wall_detector.is_colliding():
		anim.flip_h = false
		direction = 1
	elif right_wall_detector.is_colliding():
		anim.flip_h = true
		direction = -1
	else:
		go_to_fall_state()
		return	
	
	if is_on_floor():
		go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("jump"):
		velocity.x = wall_jump_velocity * direction
		go_to_jump_state()	
		return

func swimming_state(delta):
	update_direction()
	
	if direction:
		velocity.x = move_toward(velocity.x, max_water_speed * direction, water_acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, water_acceleration * delta)
		
	velocity.y += water_acceleration * delta # define uma aceleração para baixo enquanto estiver na agua
	velocity.y = min(velocity.y, max_water_speed) # limita a velocidade embaixo da agua
	
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump_force

func hurt_state(delta):
	apply_gravity(delta)

func update_direction():
	direction = Input.get_axis("left", "right") # retorna -1 ou 1 
	# flipando o sprite
	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false

func can_jump() -> bool: 
	return jump_count < max_jump_count;

func set_small_collider():
	collision_shape_2d.shape.height = 10.0
	collision_shape_2d.position.y = 3
	
	hitbox_collision_shape.shape.size.y = 10
	hitbox_collision_shape.position.y = 3
	
func set_large_collider():
	collision_shape_2d.shape.height = 16.0
	collision_shape_2d.position.y = 0
	
	hitbox_collision_shape.shape.size.y = 15
	hitbox_collision_shape.shape.size.x = 13
	hitbox_collision_shape.position.y = 0.5
	
func set_hurt_collider():
	hitbox_collision_shape.shape.size = Vector2.ZERO

# Sinal que roda quando uma area Area2D colide 
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		hit_enemy(area)
	elif area.is_in_group("LethalArea"):
		hit_lethal_area()
		
# Sinal que roda quando um corpo Node2D colide 
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("LethalArea"):
		go_to_hurt_state()
	elif body.is_in_group("Water"):
		print(status)
		go_to_swimming_state()

func hit_enemy(area: Area2D):
	if velocity.y > 0: # se o player estiver caindo e se as areas se encontrarem
		# area.get_parent().queue_free() #exclui o inimigo
		area.get_parent().take_damage() # Chama a função take_damage() no script do esqueleto
		go_to_jump_state()
	else:
		go_to_hurt_state()

func hit_lethal_area():
	go_to_hurt_state()

# Executada quando o tempo reload_timer acaba (1.5s)
func _on_reload_timer_timeout() -> void:
	get_tree().reload_current_scene() # Reseta a cena atual

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("Water"):
		jump_count = 0
		go_to_jump_state()
