extends CharacterBody2D

@onready var zombie_animation: AnimatedSprite2D = $ZombieAnimation
@onready var zombie_walk_timer: Timer = $ZombieWalkTimer
@onready var zombie_attack: RayCast2D = $ZombieAttackRayCast2D
@export var zombie_velocity: int = -10
@onready var zombie_hit_area_collision: CollisionShape2D = $ZombieAttackHitbox/ZombieHitAreaCollision
@onready var zombie_vision: RayCast2D = $ZombieVision
@onready var zombie_back_detector: RayCast2D = $ZombieBackDetectorRayCast2D
@onready var zombie_take_damage_collision: CollisionShape2D = $ZombieTakeDamageHitbox/ZombieTakeDamageCollision
@onready var health_bar: Node2D = $HealthBarMain
@onready var direction_hit_detector: Node2D = $directionHitDetector

var state: ZombieState
@export var max_health: int = 2
@export var isHealthVisible = false
var knockback_direction: float = 0.0

enum ZombieState {
	idle,
	walk,
	attack,
	chase,
	takeDamage,
	death
}

func _ready() -> void:
	go_to_walk_state()
	zombie_walk_timer.start()
	zombie_back_detector.enabled = false

func _physics_process(delta: float) -> void:
	match state:
		ZombieState.idle:
			idle_state(delta)
		ZombieState.walk:
			walk_state(delta)
		ZombieState.attack:
			attack_state(delta)
		ZombieState.chase:
			chase_state(delta)
		ZombieState.takeDamage:
			take_damage_state(delta)
		ZombieState.death:
			death_state(delta)
			
func go_to_idle_state() -> void:
	zombie_animation.play("zombie_idle")
	state = ZombieState.idle

func go_to_walk_state() -> void:
	zombie_animation.play("zombie_walk")
	state = ZombieState.walk

func go_to_attack_state() -> void: 
	zombie_animation.play("attack")
	zombie_back_detector.enabled = true
	state = ZombieState.attack

func go_to_chase_state() -> void:
	zombie_animation.play("chase")
	state = ZombieState.chase
	
func go_to_take_damage_state() -> void:
	zombie_animation.play("take_damage")
	state = ZombieState.takeDamage

func go_to_death_state() -> void:
	zombie_animation.play("death")
	zombie_take_damage_collision.disabled = true
	state = ZombieState.death

func idle_state(delta: float):
	apply_gravity(delta)
	apply_velocity()
	
	if velocity.x != 0:
		go_to_walk_state()
		return

func walk_state(delta: float):
	apply_gravity(delta)
	apply_velocity()
	
	if zombie_attack.is_colliding():
		go_to_attack_state()
		return
	
	if zombie_vision.is_colliding():
		go_to_chase_state()
		return
	
	if velocity.x == 0:
		go_to_idle_state()
		return

func attack_state(delta:float):
	apply_gravity(delta)
	apply_velocity()
	
	if zombie_animation.frame == 1: # Ativa colisão do hit
		zombie_hit_area_collision.disabled = false
	else:
		zombie_hit_area_collision.disabled = true

	if !zombie_animation.is_playing():
		zombie_hit_area_collision.disabled = true
		if zombie_back_detector.is_colliding(): # Verifica se o player está nas costas
			invertZombieDirection()
		zombie_back_detector.enabled = false # Desativa o detector das costas
		go_to_walk_state() # Muda para o walk
		return

func chase_state(delta:float) -> void: 
	apply_gravity(delta)
	apply_velocity()
	
	if zombie_attack.is_colliding(): 
		go_to_attack_state()
		return
	
	if !zombie_vision.is_colliding():
		go_to_walk_state()
		return

func take_damage_state(delta: float) -> void:
	apply_gravity(delta)
	apply_velocity()
	
	if !zombie_animation.is_playing():
		go_to_walk_state()
		return

func death_state(_delta: float):
	if !zombie_animation.is_playing():
		$".".queue_free()

func _on_zombie_walk_timer_timeout() -> void:
	set_opposite_state()

func set_opposite_state() -> void:
	if state == ZombieState.walk:
		go_to_idle_state()
	elif state == ZombieState.idle: 
		go_to_walk_state()
		invertZombieDirection()

func apply_gravity(delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * delta

func apply_velocity():
	match state:
		ZombieState.idle:
			velocity.x = 0
		ZombieState.walk:
			velocity.x = zombie_velocity
		ZombieState.attack:
			velocity.x = 0
		ZombieState.chase:
			velocity.x = zombie_velocity * 1.8
		ZombieState.takeDamage:
			velocity.x = knockback_direction * 10
		ZombieState.death:
			velocity.x = 0
		
	move_and_slide()

func invertZombieDirection():
	zombie_velocity *= -1
	scale.x *= -1
	direction_hit_detector.scale.x *= -1
	
func take_damage() -> void:
	knockback_direction = direction_hit_detector.get_hit_direction()
	health_bar.take_damage()
