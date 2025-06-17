extends Control


@export var mapData : String
@export var colors : Array[Color]

var coords_head : Array = [
	[ 22.952, 83.271 ],  [ 28.385, 98.623 ],
	[ 53.168, 107.647 ], [ 72.998, 107.647 ],
	[ 99.546, 98.623 ],  [ 105.048, 83.271 ],
	[ 105.029, 55.237 ], [ 110.740, 47.082 ],
	[ 102.364, 36.104 ], [ 94.050, 40.940 ],
	[ 85.189, 34.445 ],  [ 85.963, 24.194 ],
	[ 73.507, 19.930 ],  [ 68.883, 28.936 ],
	[ 59.118, 28.936 ],  [ 54.494, 19.930 ],
	[ 42.039, 24.194 ],  [ 42.814, 34.445 ],
	[ 33.951, 40.940 ],  [ 25.637, 36.104 ],
	[ 17.262, 47.082 ],  [ 22.973, 55.237 ]
]

var shapes : Array[PackedVector2Array]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#shapes.push_back(float_array_to_Vector2Array(SampleMap))
	parse_json()


func _draw():
	#var godot_blue : Color = Color("478cbf")
	
	#draw_polygon(head, [ godot_blue ])
	var counter = 1
	for shape in shapes:
		draw_polygon(shape, [ Color.ANTIQUE_WHITE ])
		counter += 1

func parse_json():
	
	# TODO: Find the largest negative for both the x and y axis, 
	#		then add the positive value for each of those so that
	#		the entire image begins from the top left 
	
	
	#print_debug(FileAccess.file_exists(mapData))
	var json_as_text = FileAccess.get_file_as_string(mapData)
	var json_as_dict = JSON.parse_string(json_as_text)
	if json_as_dict:
		#print_debug(json_as_dict["data"]["geometry"])
		
		# Each layer 
		for data in json_as_dict["data"]["geometry"]:
			var array : PackedVector2Array = []
			
			# Don't try to read empty 
			if json_as_dict["data"]["geometry"][data]["polygons"].size() == 0:
				continue
			
			var smallest = Vector2(0, 0)
			
			# Each vertex 
			for vertex in json_as_dict["data"]["geometry"][data]["polygons"][0][0]:
				#print_debug(Vector2(vertex[0], vertex[1]))
				if vertex[0] < smallest.x:
					smallest.x = vertex[0]
				if vertex[1] < smallest.y:
					smallest.y = vertex[1]
			
			print_debug(smallest)
			for vertex in json_as_dict["data"]["geometry"][data]["polygons"][0][0]:
				array.append(Vector2(vertex[0] / 3, vertex[1] / 3) + Vector2(-500, 300))
			
			print_debug(array)
			
			# Add loaded data to be rendered 
			shapes.push_back(array)
		

func float_array_to_Vector2Array(coords : Array) -> PackedVector2Array:
	# Convert the array of floats into a PackedVector2Array.
	var array : PackedVector2Array = []
	for coord in coords:
		array.append(Vector2(coord[0], coord[1]))
	return array
