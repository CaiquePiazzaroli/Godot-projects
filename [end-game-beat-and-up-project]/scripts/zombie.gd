extends CharacterBody2D

@onready var zombie_animation: AnimatedSprite2D = $ZombieAnimation
@onready var zombie_walk_timer: Timer = $ZombieWalkTimer
@onready var zombie_attack: RayCast2D = $ZombieAttackRayCast2D
@export var zombie_velocity: int = -10
@onready var zombie_hit_area_collision: CollisionShape2D = $ZombieHitArea/ZombieHitAreaCollision
@onready var zombie_vision: RayCast2D = $ZombieVision

var direction: float = 0.0
var state: ZombieState

enum ZombieState {
	idle,
	walk,
	attack,
	chaseState,
}

func _ready() -> void:
	go_to_walk_state()
	zombie_walk_timer.start()

func _physics_process(delta: float) -> void:
	match state:
		ZombieState.idle:
			idle_state(delta)
		ZombieState.walk:
			walk_state(delta)
		ZombieState.attack:
			attack_state(delta)
		ZombieState.chaseState:
			chase_state(delta)
			
func go_to_idle_state() -> void:
	zombie_animation.play("zombie_idle")
	state = ZombieState.idle

func go_to_walk_state() -> void:
	zombie_animation.play("zombie_walk")
	state = ZombieState.walk

func go_to_attack_state() -> void: 
	zombie_animation.play("attack")
	state = ZombieState.attack

func go_to_chase_state() -> void:
	zombie_animation.play("chase")
	state = ZombieState.chaseState

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
	
	if !zombie_animation.is_playing():
		zombie_hit_area_collision.disabled = true #Desativa a colisão do hit
		go_to_walk_state()
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
		ZombieState.chaseState:
			velocity.x = zombie_velocity * 1.8
	move_and_slide()

func invertZombieDirection():
	zombie_velocity *= -1
	scale.x *= -1

func _on_hit_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		var player: CharacterBody2D = body
		player.call_deferred("go_to_death_state") # Muda o player para death
		player.collision_layer = 0 # Altera a camada de colisão para nao colidir mais
		
