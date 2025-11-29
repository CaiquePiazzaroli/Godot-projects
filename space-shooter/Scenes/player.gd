extends Node2D

# Variável do tipo int 
@export var speed: int = 500

# Também funcionaria e o tipo seria definido pelo valor atribuido na primeira vez
# @export var speed := 500;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(200, 500) 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Input é a classe que gerencia inputs 
	# Is_action_pressed retorna true ou false se um botao tive sido pressionado
	# left (argumento) foi a action criado em Project > project Settings > input map
	# if Input.is_action_pressed("left"):
		#position += Vector2(1,0) * 50 * delta  
		# Pega um nó pelo seu nome
		# get_node("PlayerSprite").rotation += 0.1 * delta
		#$PlayerSprite.rotation += 1.0 * delta
		
	# Input.get_vector retorna um vetor x y com valores de -1 até 1
	# Como o AWSD está mapeado para as ações left, up, down, right respectitivamente
	# Quando apertamos os botoes awsd no teclado, um vetor é retornado
	# Ex: se apertar A, o argumento negative_x é acionado e o vetor retornado é (-1, 0)
	# Isso permite o movimento dentro do jogo
	var direction = Input.get_vector("left", "right", "up", "down")
	
	# printando o vetor no console 
	print(direction)
		
	# Adiciona à posição atual do jogador
	position += direction * speed * delta;
	
	
