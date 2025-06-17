extends Control


@export var mapData : String

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

var SampleMap : Array = [
	[ 720.01, 414.01],
	[ 792.01, 414.01 ],
	[ 792.01, 324.01 ],
	[ 1043.99, 324.01],
	[ 1043.99, 468.01],
	[ 1079.99, 468.01],
	[ 1079.99, 540.01],
	[ 1133.99, 540.01],
	[ 1133.99, 683.99],
	[ 900.01, 683.99 ],
	[ 900.01, 503.99 ],
			  [
				863.99,
				503.99
			  ],
			  [
				863.99,
				557.99
			  ],
			  [
				809.99,
				557.99
			  ],
			  [
				809.99,
				575.99
			  ],
			  [
				756.01,
				575.99
			  ],
			  [
				756.01,
				557.99
			  ],
			  [
				720.01,
				557.99
			  ],
			  [
				720.01,
				414.01
			  ]
]

var shapes : Array[PackedVector2Array]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#shapes.push_back(float_array_to_Vector2Array(SampleMap))
	parse_json()


func _draw():
	# We are going to paint with this color.
	var godot_blue : Color = Color("478cbf")
	# We pass the PackedVector2Array to draw the shape.
	#draw_polygon(head, [ godot_blue ])
	for shape in shapes:
		draw_polygon(shape, [ Color.WHITE ])

func parse_json():
	#print_debug(FileAccess.file_exists(mapData))
	var json_as_text = FileAccess.get_file_as_string(mapData)
	var json_as_dict = JSON.parse_string(json_as_text)
	if json_as_dict:
		#print_debug(json_as_dict["data"]["geometry"][0])
		
		# Each layer 
		for data in json_as_dict["data"]["geometry"]:
			
			var array : PackedVector2Array = []
			
			# Each vertex 
			for vertex in json_as_dict["data"]["geometry"][data]["polygons"][0][0]:
				#print_debug(Vector2(vertex[0], vertex[1]))
				array.append(Vector2(vertex[0], vertex[1]))
			
			# Add loaded data to be rendered 
			shapes.push_back(array)
		

func float_array_to_Vector2Array(coords : Array) -> PackedVector2Array:
	# Convert the array of floats into a PackedVector2Array.
	var array : PackedVector2Array = []
	for coord in coords:
		array.append(Vector2(coord[0] / 1.0, coord[1] / 1.0))
	return array
