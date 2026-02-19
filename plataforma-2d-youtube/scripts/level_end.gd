extends Area2D

# Variaveis constantes para construir o diretório da cena
const scenePath : String = "res://scene/"
const sceneExtension: String = ".tscn"

# exporta a variavel para ser alterada no inspector
# permitindo a customização de mudança de level por fases
@export var next_level: String = ""

# usamos o _ para dizer que o delta não é necessário ser usado mesmo.
func _on_body_entered(_body: Node2D) -> void:
	# encerra os sistema de fisica antes de trocar de cena
	call_deferred("load_next_scene")

# Muda de cena  para forest.tscn
func load_next_scene():
	get_tree().change_scene_to_file(scenePath + next_level + sceneExtension)
