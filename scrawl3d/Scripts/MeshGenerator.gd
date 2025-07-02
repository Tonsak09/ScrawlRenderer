extends Node

@export var world : Node3D
@export var mapList : ItemList
@export var height : float 

var triangulation : Triangulation2D

func _ready() -> void:
	triangulation = Triangulation2D.new()

func GenerateOBJ():
	
	# Ensure valid 
	if mapList.get_selected_items().size() == 0:
		return 
	var name = mapList.get_item_text(mapList.get_selected_items()[0])
	if !name:
		return
	
	var path = "./Maps/" + name + ".json"
	
	# Access the file 
	var walls = AccessFilePositionalData(path)
	var extrudedWalls : Array
	
	for wall in walls:
		extrudedWalls.push_back(ExtrudePositions(wall,height))
	
	WriteToFile("./Output/" + name + ".obj", extrudedWalls)
	
	
	#var positions2D  = AccessFilePositionalData(path)
	
	# Triangulate top
	#var cap = triangulation.Triangulate(positions2D)
	


# Write array of 3D positions to a .obj file format 
func WriteToFile(path : String, polyGroups : Array):
	var file = FileAccess.open(path, FileAccess.WRITE)
	var content : String
	var counter = 1
	
	var verticies = ""
	var faces = ""
	
	for objPositions in polyGroups:
		# Adding verticies 
		for objPos in objPositions:
			verticies += "v " + str(objPos.x) + " " + str(objPos.y) + " " + str(objPos.z) + " 1\n"
		
		# Faces must be made of PREVIOUSLY added indexes 
		for i in range(0, objPositions.size() - 3):
			faces += "f " + str(counter) + " " + str(counter + 1) + " " + str(counter + 2) + "\n"
			#topFace += str(counter + 1) + " "
			counter += 3
		
		#print_debug(content)
		
		#for triangle in cap:
			## TODO: Sort triangle points when adding face
			#content += "v " + str(triangle.pointA.x) + " " + str(height) + " " + str(triangle.pointA.y) + " 1\n"
			#content += "v " + str(triangle.pointB.x) + " " + str(height) + " " + str(triangle.pointB.y) + " 1\n"
			#content += "v " + str(triangle.pointC.x) + " " + str(height) + " " + str(triangle.pointC.y) + " 1\n"
		#
		#for i in range(0, cap.size()):
			#content += "f " + str(counter) + " " + str(counter + 1) + " " + str(counter + 2) + "\n"
			#content += "f " + str(counter) + " " + str(counter + 1) + " " + str(counter + 2) + "\n"
			#content += "f " + str(counter) + " " + str(counter + 1) + " " + str(counter + 2) + "\n"
			#
			##topFace += str(counter + 1) + " "
			#counter += 9
	
	content += verticies + faces
	file.store_string(content)

# Extrudes 2D plane of points vertically into 3D space 
func ExtrudePositions(positions : Array, extrudeHieght : float) -> Array[Vector3]:
	
	var objPositions : Array[Vector3]
	
	# For every point in A to there 3 points in B to make a triangle, there 
	# are two triangles for each point 
	# Original, vertical, neighbor 
	# Vertical, neighbor vertical, neighbor 
	objPositions.resize((positions.size() - 1) * 6)
	
	var counter = 0
	for i in range(0, positions.size() - 1): 
		var pos = Vector2(positions[i][0], positions[i][1]) 
		var neighbor = Vector2(positions[i + 1][0], positions[i + 1][1]) 
		
		# First triangle of the quad 
		objPositions[counter + 0] = Vector3(pos.x, 0.0, pos.y)
		objPositions[counter + 1] = Vector3(pos.x, extrudeHieght, pos.y)
		objPositions[counter + 2] = Vector3(neighbor.x, 0.0, neighbor.y)
		
		# Second triangle of the quad 
		objPositions[counter + 3] = Vector3(pos.x, extrudeHieght, pos.y)
		objPositions[counter + 4] = Vector3(neighbor.x, extrudeHieght, neighbor.y)
		objPositions[counter + 5] = Vector3(neighbor.x, 0.0, neighbor.y)
		
		counter += 6
	
	return objPositions
	
# Reads map data to generate 2D polygon data 
func AccessFilePositionalData(path : String) -> Array:
	
	var walls : Array
	
	var json_as_text = FileAccess.get_file_as_string(path)
	var json_as_dict = JSON.parse_string(json_as_text) 
	
	if json_as_dict:
		# Each layer 
		for data in json_as_dict["data"]["geometry"]:
			
			# Don't try to read empty 
			if json_as_dict["data"]["geometry"][data]["polygons"].size() == 0:
				continue
			
			# Add vertex data to array 
			print_debug("There are " + str(json_as_dict["data"]["geometry"][data]["polygons"].size()) + " major sections")
			
			ProcessMajorPolysections(json_as_dict["data"]["geometry"][data]["polygons"], walls)
			
			
			#for major in json_as_dict["data"]["geometry"][data]["polygons"]:
			#	print_debug("There are " + str(major.size()) + " minor sections")
			
			#var wallsImport = json_as_dict["data"]["geometry"][data]["polygons"][0]
			#for wall in wallsImport:
				#var positions : Array[Vector2]
				#for vertex in wall:
					#positions.push_back(Vector2(vertex[0], vertex[1]) / 100)
				#
				#walls.push_back(wall)
	
	return walls

func ProcessMajorPolysections(majors, walls : Array):
	for major in majors:
		for wall in major:
			var positions : Array[Vector2]
			for vertex in wall:
				positions.push_back(Vector2(vertex[0], vertex[1]) / 100)
			
			walls.push_back(wall)
