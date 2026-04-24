extends CharacterBody2D

enum PlayerState {
	idle,
	walk,
	jump,
	attack,
	takeDamage,
	death
}

enum WeaponState {
	fist,
	fixedKey
}

@export var life: int = 100
@export var acceleration = 400
@export var max_speed = 50
@export var jump_velocity = -180
@onready var player_animation: AnimatedSprite2D = $PlayerAnimation
@onready var player_collision: CollisionShape2D = $PlayerTerrainColision
@onready var player_attack_hitbox_collision: CollisionShape2D = $PlayerAttackHitbox/PlayerAttackHitboxCollision
@onready var health_player_bar: CanvasLayer
@onready var player_take_damage_hitbox: CollisionShape2D = $PlayerTakeDamageHitbox/CollisionShape2D


var direction: float = 0.0
var state : PlayerState
var weapon : WeaponState
var max_health : int = 10
var health: int = 6

func _ready() -> void:
	get_health_player_bar()
	weapon = WeaponState.fist
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	match state:
		PlayerState.idle:
			idle_state(delta)
		PlayerState.walk:
			walk_state(delta)	
		PlayerState.jump:
			jump_state(delta)
		PlayerState.death:
			death_state(delta)
		PlayerState.attack:
			attack_state(delta)
		PlayerState.takeDamage:
			take_damage_state(delta)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		return
	
	if Input.is_action_just_pressed("attack"):
		go_to_attack_state()
		
	if Input.is_action_just_pressed("death"):
		set_weapon("fist")

func get_health_player_bar() -> void:
	if get_tree().get_nodes_in_group("health_player_bar")[0] is CanvasLayer:
		health_player_bar = get_tree().get_nodes_in_group("health_player_bar")[0]
	else:
		print("não foi possivel encontrar a hud")
		get_tree().quit()

func go_to_idle_state():
	player_take_damage_hitbox.disabled = false
	state = PlayerState.idle #altera estado para idle
	player_animation.play(get_base_animation() + get_weapon_animation()) # muda anim para idle

func go_to_walk_state():
	state = PlayerState.walk # altera estado para walk
	player_animation.play(get_base_animation() + get_weapon_animation()) # muda anim para walk

func go_to_jump_state():
	state = PlayerState.jump #altera estado para jump
	player_animation.play(get_base_animation() + get_weapon_animation()) # Muda animação
	velocity.y = jump_velocity # atribui velocidade de pular

func go_to_attack_state():
	state = PlayerState.attack
	player_animation.play(get_base_animation() + get_weapon_animation())

func go_to_take_damage():
	player_take_damage_hitbox.disabled = true
	state = PlayerState.takeDamage
	player_animation.play(get_base_animation() + get_weapon_animation())

func go_to_death_state():
	state = PlayerState.death
	player_animation.play(get_base_animation() + get_weapon_animation())
	velocity.x = 0


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

func attack_state(delta: float) -> void:
	# move(delta)
	apply_gravity(delta)
	velocity.x = 0
	
	if player_animation.frame == 1: # Ativa colisão do hit
		player_attack_hitbox_collision.disabled = false
		return
	else:
		player_attack_hitbox_collision.disabled = true
	
	if !player_animation.is_playing():
		player_attack_hitbox_collision.disabled = true
		go_to_idle_state()
		return

func take_damage_state(delta: float) -> void:
	apply_gravity(delta)
	move(delta)
	
	if !player_animation.is_playing():
		go_to_idle_state()

func jump_state(delta: float):
	apply_gravity(delta) # permite ação da gravidade
	move(delta) # pemite movimentação
	
	if is_on_floor(): # Caiu no chao, volta para idle
		go_to_idle_state()
		return

func death_state(delta:float):
	apply_gravity(delta)
	pass

# Gravidade - Atribui uma velocidade positiva no eixo Y fazendo o player cair
func apply_gravity(delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * delta
	
	## Necessário para atualizar velocity
	move_and_slide()

# Movimenta o player quando pressionado o botao
func move(delta : float) -> void:
	update_direction() # Atualiza direção 
	
	if direction: # acelera até a velocidade 50
		velocity.x = move_toward(velocity.x, max_speed * direction, acceleration * delta)
	else: # Desacelera até a velocidade 0
		velocity.x = move_toward(velocity.x, 0, acceleration * delta) #zera a velocidade em x

# Atualiza a var direction e flipa o sprite
func update_direction():
	direction = Input.get_axis("left", "right")
	if direction > 0: 
		player_animation.flip_h = false
		player_attack_hitbox_collision.position.x = 10
	elif direction < 0:
		player_animation.flip_h = true
		player_attack_hitbox_collision.position.x = -10

func get_base_animation() -> String:
	match state:
		PlayerState.idle:
			return "idle"
		PlayerState.walk:
			return "walk"
		PlayerState.jump:
			return "jump"
		PlayerState.death:
			return "death"
		PlayerState.attack:
			return "attack"
		PlayerState.takeDamage:
			return "take-damage"
		_:
			return "idle"

func get_weapon_animation() -> String:
	match weapon:
		WeaponState.fist:
			return "-fist"
		WeaponState.fixedKey:
			return "-fixed-key"
		_:
			return "-"

# Setting a weapon
func set_weapon(weaponString: String) -> void:
	match weaponString:
		"fist":
			weapon = WeaponState.fist
			go_to_walk_state()
			return
		"fixedKey":
			weapon = WeaponState.fixedKey
			go_to_walk_state()
			return
		_:
			print("Weapon not found")
			weapon = WeaponState.fist
			go_to_walk_state()
			return

func set_hit_area_disabled() -> void:
	player_attack_hitbox_collision.disabled = true

func take_damage() -> void:
	go_to_take_damage()
	health -= 1
	if health == 0:
		go_to_death_state()
	health_player_bar.update_value(health)
