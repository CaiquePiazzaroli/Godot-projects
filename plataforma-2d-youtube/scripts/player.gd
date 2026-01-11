extends CharacterBody2D

# Faz uma referencia ao nó da arvore que se chama AnimatedSprite2D 
# Atribuindo a uma variável chamada anim do tipo AnimetadesSprite2D
@onready var  anim: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 70.0
const JUMP_VELOCITY = -300
# _physics_process roda em todos os frames do jogo
func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# get_axis retorna 1.0 se o player estvier indo para direita 
	# get_axis retorna -1.0 se o player estvier indo para esquerda 
	var direction := Input.get_axis("left", "right")
	
	# If só é verdadeiro quando o valor do direction for != 0 (quando há o input do jogador)
	if direction:
		# se direction é positivo, o boneco anda para frente
		# se directioné é negativo, o boneco anda para trás
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Se estiver no chao
	if is_on_floor():
		# Se direction > 0 o sprite vira para a direita
		# se direction < 0 o sprite vira para a esquerda
		if direction > 0:
			anim.flip_h = false
			# Dando play na animação de andar
			anim.play("walk")
		elif direction < 0:
			anim.flip_h = true
			# Dando play na animação de andar
			anim.play("walk")
		else:
			# Se não tiver andando nem para a direita e nem para esquerda
			# Ativa a animação idle
			anim.play("idle")
	else:
		anim.play("jump")

	move_and_slide()
