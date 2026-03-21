extends AnimatableBody2D

@onready var target: Sprite2D = $Sprite2DTarget

@export var time = 2

func _ready() -> void:
	
	# Deixa o bloco target invisível na hora que o jogo começa a rodar
	target.visible = false
	
	# Serve para dar movimento ao objeto
	var tween = create_tween()
	
	# Suavisa o movimento por meio de uma função quadratica
	tween.set_trans(Tween.TRANS_QUAD)
	
	# Suavisa o movimento do começo e fim da animação
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Vai até a posição do target
	tween.tween_property(self, "global_position", target.global_position, time)
	
	# Volta para a posição inicial
	tween.tween_property(self, "global_position", global_position, time)
	
	# Coloca o tween em loop. Sem argumento = infinito
	tween.set_loops()
