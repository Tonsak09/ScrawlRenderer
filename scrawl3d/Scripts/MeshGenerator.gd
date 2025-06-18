extends Node

@export var world : Node3D
@export var mapList : ItemList

func GenerateOBJ():
	
	# Ensure valid 
	if mapList.get_selected_items().size() == 0:
		return 
	var name = mapList.get_item_text(mapList.get_selected_items()[0])
	if !name:
		return
	
	var path = "./Maps/" + name + ".json"
	
	# Access the file 
	var positions2D  = AccessFilePositionalData(path)
	var objPositions = ExtrudePositions(positions2D, 1.0)
	
	WriteToFile("./Output/" + name + ".obj", objPositions)
	


# Write array of 3D positions to a .obj file format 
func WriteToFile(path : String, objPositions : Array[Vector3]):
	var file = FileAccess.open(path, FileAccess.WRITE)
	var content : String
	
	for objPos in objPositions:
		content += "v " + str(objPos.x) + " " + str(objPos.y) + " " + str(objPos.z) + " 1\n"
	print_debug(content)
	
	file.store_string(content)

# Extrudes 2D plane of points vertically into 3D space 
func ExtrudePositions(positions : Array[Vector2], extrudeHieght : float) -> Array[Vector3]:
	
	var objPositions : Array[Vector3]
	
	# For every point in A to there 3 points in B to make a triangle 
	# Original, vertical, neighbor 
	objPositions.resize(positions.size() * 3)
	
	var counter = 0
	for i in range(0, positions.size() - 2): 
		var pos = positions[i]
		var neighbor = positions[i + 1]
		
		objPositions[counter + 0] = Vector3(pos.x, 0.0, pos.y)
		objPositions[counter + 1] = Vector3(pos.x, extrudeHieght, pos.y)
		objPositions[counter + 2] = Vector3(neighbor.x, 0.0, neighbor.y)
		
		counter += 3
	
	return objPositions
	
# Reads map data to generate 2D polygon data 
func AccessFilePositionalData(path : String) -> Array[Vector2]:
	
	var positions : Array[Vector2]
	
	var json_as_text = FileAccess.get_file_as_string(path)
	var json_as_dict = JSON.parse_string(json_as_text) 
	
	if json_as_dict:
		# Each layer 
		for data in json_as_dict["data"]["geometry"]:
			
			# Don't try to read empty 
			if json_as_dict["data"]["geometry"][data]["polygons"].size() == 0:
				continue
			
			# Add vertex data to array 
			for vertex in json_as_dict["data"]["geometry"][data]["polygons"][0][0]:
				positions.push_back(Vector2(vertex[0], vertex[1]))
			
	
	return positions
