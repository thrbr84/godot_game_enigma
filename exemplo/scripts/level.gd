extends Node2D

var level = 1
var pontos = 0
var done = false
var correct = null
var time_old = 0
var enigma = {}

func _ready():
	# ao abrir, carrega o jogo atual de onde o jogador estava
	# ou inicia uma nova partida
	_loadGame()

func _nextLevel(pular=false):
	# tenta carregar o próximo level
	var	next_enigma = Game._findEnigma(level + 1)
	
	# esconde o teclado do celular
	if OS.has_virtual_keyboard():
		OS.hide_virtual_keyboard()
		

	level += 1 # incrementa o level
	
	# se não está pulando então soma os pontos
	if !pular:
		pontos += (enigma.pontos * correct) #incrementa os pontos
		
		if pontos < 0:
			pontos = 0
		
	done = false # reset para conseguir responder novamente
	
	# salva o jogo na variavel local
	Game.saveData({
		"level": level,
		"pontos": pontos
		}, "overwrite")
	
	# atualiza o arquivo do jogo com o save
	Game.onlySaveData()

	# se o próximo level existe
	if next_enigma != null:
		# carrega o jogo com o novo level
		_loadGame()
	else:
		# não existe mais level, retorna para o menu
		Loader.goto_scene("res://scenes/main.tscn")
		
		# poderia mostrar uma tela final de sucesso
		# Loader.goto_scene("res://scenes/win.tscn")
	
func _loadGame():
	# carrega os dados do level em que o jogador está
	level = Game.readData("level", null)
	pontos = Game.readData("pontos", 0)
	
	# carrega o jogo atual
	enigma = Game._findEnigma(level)
	if enigma == null: # se não existir
		# volta para o menu
		Loader.goto_scene("res://scenes/main.tscn")
		return
	
	# atualiza o placar
	$CanvasLayer/HBoxContainer/placar/level.text = str("Level: ",level)
	$CanvasLayer/HBoxContainer/placar/pontos.text = str("Pontos: ", pontos)
	
	# zera todos os textos da tela
	$Control/resposta.text = ""
	$CanvasLayer/nextLevelInfo.text = ""
	
	# coloca a imagem do level atual
	var background_image = load(str("res://assets/enigmas/",level,".jpg"))
	$enigma.texture = background_image
	
	# play na animação de start
	$enigma/anim.play("start")
	
	# atualiza a variavel done para o jogador conseguir responder
	done = false
	
func _checkAnswer():
	if done: return
	# marca como respondido o level atual
	done = true
	
	# esconde o teclado do celular
	if OS.has_virtual_keyboard():
		OS.hide_virtual_keyboard()
	
	# pega o texto que o jogador digitou, e deixa em caixa baixa
	var answer = str($Control/resposta.text).to_lower()
	
	# se o jogador não respondeu nada, então não faz nada
	if answer == "": return
	
	# se a resposta do jogador está entre as alternativas do level
	if answer in enigma.resposta:
		$enigma/anim.play("correct") # acertou
		Sfx._play("correct")
		correct = 1
	else:
		$enigma/anim.play("incorrect") # errou
		Sfx._play("incorrect")
		correct = -1
	
	# dá um start no timer para seguir para o próximo level
	# aguarda 1 segundos pra iniciar o timer
	yield(get_tree().create_timer(1), "timeout")
	$TimerNextLevel.start()
	
func _on_close_pressed():
	# esconde o teclado do celular
	if OS.has_virtual_keyboard():
		OS.hide_virtual_keyboard()
		
	# se o jogador clicar em fechar, volta para o menu
	Loader.goto_scene("res://scenes/main.tscn")

func _unhandled_key_input(event):
	# se já respondeu então sai
	if done: return
	
	# se ainda não respondeu, e apertou a tecla ENTER
	if event is InputEventKey:
		if event.is_pressed() and event.scancode in [KEY_ENTER, KEY_KP_ENTER]:
			# verifica a resposta
			_checkAnswer()

func _process(delta):
	# se o timer não estiver iniciado então sai
	if $TimerNextLevel.is_stopped(): return
	
	# se o timer está ativo, então pega o tempo que falta
	var time = int($TimerNextLevel.time_left) + 1
	
	if time != time_old:
		time_old = time
		Sfx._play("time_left")
	
	$CanvasLayer/nextLevelInfo.text = str("Próximo em ", time, "s")

func _on_TimerNextLevel_timeout():
	# acabou o tempo do timer, avança para o próximo level
	time_old = null
	_nextLevel()

func _on_pular_pressed():
	if done: return
	
	# avança pulando a verificação de resposta
	_nextLevel(true)

func _on_btnCheck_pressed():
	# se já respondeu então sai
	if done: return
	
	# se ainda não respondeu, verifica a resposta
	_checkAnswer()
