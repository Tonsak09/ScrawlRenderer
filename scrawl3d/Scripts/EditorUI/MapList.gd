extends ItemList


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RefreshMaps()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func RefreshMaps():
	var folder = DirAccess.open("Maps")
	clear()
	
	for file in folder.get_files():
		var split = file.rsplit(".", false, 0)
		
		if split.size() != 2:
			continue
		
		if split[1] != "json":
			continue
		
		add_item(split[0])
