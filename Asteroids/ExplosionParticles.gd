extends Particles2D


var source


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node(".").emitting = true
	get_node(".").process_material.scale = source.scale.x * source.scale_multi * 2
	get_parent().remove_child(source)
	print(source.scale * source.scale_multi * 2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	get_parent().remove_child(self)
