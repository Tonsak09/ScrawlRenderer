extends Control

@export var environmentGizmos : Control 
@export var characterGizmos : Control 

func UpdateStyleInspector(type : int, data : Node):
	match type:
		0: # Environment 
			pass
		1: # Character 
			pass
