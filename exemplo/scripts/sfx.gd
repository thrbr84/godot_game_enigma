extends CanvasLayer

func _play(node_name):
	if has_node(node_name):
		if get_node(node_name) is AudioStreamPlayer:
			get_node(node_name).play()
