extends Node2D

func _ready():
	_loadData()

func _loadData(onlyPlacar=false):
	var level = Game.readData("level", "1")
	var pontos = Game.readData("pontos", 0)
	
	$placar/level.text = str(level)
	$placar/pontos.text = str(pontos)
	
	if onlyPlacar:
		$anim.play("placar")
	else:
		$anim.play("start")
		yield($anim, "animation_finished")
		$Control.show()
	
func _on_btnPlay_pressed():
	Sfx._play("button1")
	# inicia o jogo
	Loader.goto_scene("res://scenes/level.tscn")

func _on_btnReset_pressed():
	# reset game
	Game.deleteFileSave()
	# salva o jogo na variavel local
	Game.saveData({
		"level": 1,
		"pontos": 0
		}, "overwrite")
	
	# atualiza o arquivo do jogo com o save
	Game.onlySaveData()
	
	$anim.play("reset")
	
	# espera a animação acabar
	yield($anim, "animation_finished")
	_loadData(true)
	#Loader.goto_scene("res://scenes/main.tscn")
