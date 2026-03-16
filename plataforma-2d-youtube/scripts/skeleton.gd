extends CharacterBody2D

enum SkeletonState {
	walk,
	attack,
	hurt
}

# Referenciando um SPINNING_BONE no código
const SPINNING_BONE = preload("uid://bnk6d6t5x8n7r")

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var player_detector: RayCast2D = $PlayerDetector
@onready var bone_start_position: Node2D = $BoneStartPosition

const SPEED = 10
const JUMP_VELOCITY = -400.0

var status: SkeletonState

var direction = 1
var can_throw = true

func _ready() -> void:
	go_to_walk_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match status:
		SkeletonState.walk:
			walk_state(delta)
		SkeletonState.attack:
			attack_state(delta)
		SkeletonState.hurt:
			hurt_state(delta)	

	move_and_slide()

func go_to_walk_state():
	status = SkeletonState.walk
	anim.play("walk")
	
func go_to_attack_state():
	status = SkeletonState.attack
	anim.play("attack")
	velocity = Vector2.ZERO # para o inimigo na hora de atacar
	can_throw = true
	
func go_to_hurt_state():
	status = SkeletonState.hurt
	anim.play("hurt")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED #Desabilita o Hitbox, ja que o esqueleto morreu
	velocity = Vector2.ZERO
	
	
func walk_state(_delta):
	# se velocity.x for positivo, anda para direita, se negativo, esquerda
	velocity.x = SPEED * direction
	
	if wall_detector.is_colliding():
		# Muda a direção do esqueleto e do Raycast para o lado oposto
		scale.x *= -1
		direction *= -1
	
	if !ground_detector.is_colliding():
		# Muda a direção do esqueleto e do Raycast para o lado oposto
		scale.x *= -1
		direction *= -1
		
	if player_detector.is_colliding():
		go_to_attack_state()
		return
	
func hurt_state(_delta):
	pass

func attack_state(_delta):
	if anim.frame == 2 && can_throw: # Executa a função throw_bone() quando a animação estiver no frame 2
		throw_bone()
		can_throw = false

func take_damage():
	go_to_hurt_state()
	
func throw_bone():
	var new_bone: Node = SPINNING_BONE.instantiate() #Instanciando o Spinning_bone
	add_sibling(new_bone) # Adiciona o projetil como IRMÃO na arvore de nodes
	new_bone.position = bone_start_position.global_position # Coloca o projetil na mesma posição do nó bone_start_position
	new_bone.set_direction(self.direction) # Define para qual direção o projetil será lançado

# Função executada toda vez que uma animação termina
func _on_animated_sprite_2d_animation_finished() -> void:
	# Se a animação que terminou for de ataque, volta para o walk state
	if anim.animation == "attack":
		go_to_walk_state()
		return
