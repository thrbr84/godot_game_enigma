extends Node

# nome do arquivo
var save_path = "user://game_0.0.0.1.data"

# todos os levels do jogo
# sempre incremente os levels
# pode colocar quantos pontos quiser em cada level
# coloque sempre várias respostas possíveis dentro do array para cada level
var enigmas: Array = [
	{ "level": 1, "pontos": 10, "resposta": ["2","segunda", "de roxo", "cabelo marrom", "de bolsa", "b"] },
	{ "level": 2, "pontos": 10, "resposta": ["43", "quarenta e três"] },
	{ "level": 3, "pontos": 10, "resposta": ["5", "5 centavos"] },
	{ "level": 4, "pontos": 10, "resposta": ["5", "5 minutos"] },
]

# modelo base que será o save do jogador inicialmente
var base_data: Dictionary = {
	"level": 1,
	"pontos": 0,
}

# variável local, o jogo ficará trabalhando com ela e não com o arquivo
var user_data: Dictionary = base_data

func _ready() -> void:
	# Cria um arquivo se não existir, ou carrega o existente
	newOrLoadFile(save_path, user_data)

# procura pelo level informado como parâmetro
func _findEnigma(_level):
	var found = null
	for e in enigmas:
		if e.level == _level: # se for o level procurado
			found = e
			break
	return found

# salva a variavel user_data no disco do jogador (arquivo)
func onlySaveData(forceSave = false) -> void:
	if !user_data.has("saved"): return
	# Se a variavel local já está salva então sai, e também se não é pra forçar o save
	if user_data["saved"] == 1 and !forceSave: return
	
	# Se a variável está modificada
	# Ou o forceSave é TRUE
	var fl = File.new()
	fl.open(save_path, File.WRITE)
	fl.store_var(user_data)
	fl.close()
	user_data["saved"] = 1 # coloca a variável local como salva
	
# cria ou carrega um arquivo de save
func newOrLoadFile(_path, _data) -> void:
	user_data = _data
	var fl = File.new()
	# Se não existe um arquivo de save, cria
	if not fl.file_exists(_path):
		fl.open(_path, File.WRITE)
		fl.store_var(_data)
		fl.close()
	else:
		# Se existe carrega o arquivo
		loadSavedGame()

# carrega o arquivo de save
func loadSavedGame() -> Dictionary:
	var fl = File.new()
	# Carrega os dados que estão no arquivo para a variavél local
	if fl.file_exists(save_path):
		fl.open(save_path, File.READ)
		user_data = fl.get_var()
		user_data["saved"] = 1 # controle para saber se a variável está modificada
		fl.close()
	return user_data

# procura por uma informação salva
func readData(campo, notExistsReturn = 0):
	var ret = notExistsReturn
	# Obtém algum valor da variável local, se não existir retorna a variavel informada no parâmetro
	if user_data != null:
		if user_data.has(str(campo)):
			ret = user_data[str(campo)]
	return ret

# salva os dados do jogo
func saveData(campos, type = "overwrite") -> void:
	if user_data != null: # Se a variável não for null
		for campo in campos.keys(): # procura todas as chaves informadas no parâmetro
			if type == "increment": # se for um campo que é para incrementar, pega o valor que tinha antes e incrementa
				if user_data.has(str(campo)):
					user_data[str(campo)] = int(user_data[str(campo)]) + int(campos[campo])
				else: # Se for para sobrescrever, então coloca o valor enviado no dicionario
					user_data[str(campo)] = campos[campo]
			else: # Se a chave não existe no dicionario local, então cria
				user_data[str(campo)] = campos[campo]
				
		user_data["saved"] = 0 # marca a variável como salva

# exclui o arquivo de save
func deleteFileSave() -> void:
	var fl = File.new()
	# Se o arquivo existe, exclui
	if fl.file_exists(save_path):
		var dir = Directory.new()
		if !dir.current_is_dir():
			dir.remove(save_path)
			user_data = base_data
