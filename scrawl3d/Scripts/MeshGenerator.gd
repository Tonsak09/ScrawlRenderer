extends Node

@export var world : Node3D
@export var mapList : ItemList
@export var height : float 
@export var meshRenderer : MeshInstance3D
@export var hasRoofCheckBox : CheckBox
@export var triangleCorners : Array[Node3D]

var triangulation : Triangulation2D
var st : SurfaceTool


var wallVerticies : Array
var cap : Array[Triangle2D]


func _ready() -> void:
	triangulation = Triangulation2D.new()
	st = SurfaceTool.new()
	
	triangulation.TrianglesUpdated.connect(UpdateWorldMesh)
	triangulation.TriangleChecking.connect(UpdateTriangleVisual)

func GenerateOBJ():
	
	# Ensure valid 
	if mapList.get_selected_items().size() == 0:
		return 
	var name = mapList.get_item_text(mapList.get_selected_items()[0])
	if !name:
		return
	
	var path = "./Maps/" + name + ".json"
	
	# Cleanup old
	wallVerticies.clear()
	cap.clear()
	
	# Access the file 
	var walls = AccessFilePositionalData(path)
	var combined : Array
	
	for wall in walls:
		wallVerticies.push_back(ExtrudePositions(wall,height))
		#combined.append_array(wall)
		
		# Triangulate top
		var allPoints = wall.duplicate()
		var corners = wall.size()
		triangulation.Triangulate(allPoints, wall, cap, corners)
		
		WriteToFile("./Output/" + name + ".obj", wallVerticies, cap)
		UpdateWorldMesh()

# Write array of 3D positions to a .obj file format 
func WriteToFile(path : String, polyGroups : Array, cap : Array):
	var file = FileAccess.open(path, FileAccess.WRITE)
	var content : String
	var counter = 1
	
	var verticies = ""
	var faces = ""
	
	for objShape in polyGroups:
		# Adding verticies 
		for objPos in objShape:
			verticies += "v " + str(objPos.x) + " " + str(objPos.y) + " " + str(objPos.z) + " 1\n"
		
		for triangle in cap:
			# TODO: Sort triangle points when adding face
			content += "v " + str(triangle.pointA.x) + " " + str(height) + " " + str(triangle.pointA.y) + " 1\n"
			content += "v " + str(triangle.pointB.x) + " " + str(height) + " " + str(triangle.pointB.y) + " 1\n"
			content += "v " + str(triangle.pointC.x) + " " + str(height) + " " + str(triangle.pointC.y) + " 1\n"
		
		# Faces must be made of PREVIOUSLY added indexes 
		for i in range(0, objShape.size() - 3):
			faces += "f " + str(counter) + " " + str(counter + 1) + " " + str(counter + 2) + "\n"
			#topFace += str(counter + 1) + " "
			counter += 3
		
		# f 1//1 2//4 5//11
		for i in range(0, cap.size()):
			content += "f " + str(counter) + " " + str(counter + 1) + " " + str(counter + 2) + "\n"
			counter += 3
			content += "f " + str(counter) + " " + str(counter + 1) + " " + str(counter + 2) + "\n"
			counter += 3
			content += "f " + str(counter) + " " + str(counter + 1) + " " + str(counter + 2) + "\n"
			counter += 3
			
			
	
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
	
	# NOTE: Withing the polygons sections there are two arrays, one for the 
	#       shape overall and then other for the shapes that make up and cutup
	#       the shape. The first enty in the polygon is the main shape while 
	#       the rest are used to make holes inside of it. 
	
	var walls : Array
	
	var json_as_text = FileAccess.get_file_as_string(path)
	var json_as_dict = JSON.parse_string(json_as_text) 
	
	if !json_as_dict:
		return walls
	
	# Each layer 
	for data in json_as_dict["data"]["geometry"]:
		# Don't try to read empty 
		if json_as_dict["data"]["geometry"][data]["polygons"].size() == 0:
			continue
		
		# Add vertex data to array 
		# NOTE: Polygons contain their main shape and then holes for the rest of
		#       the array 
		ProcessPloygons(json_as_dict["data"]["geometry"][data]["polygons"], walls)
	
	return walls

# Reads the polyGroup data and brings the main poly data into the shapes 
func ProcessPloygons(polyGroup, shapes : Array):
	
	var sum : Vector2
	var count : int 
	
	for major in polyGroup:
		print_debug("This polygon has " + str(major.size()) + " shapes")
		
		var index = 0
		for polygon in major:
			
			# TODO: If more than one shape, any shape after the first
			#       should be a hole that cuts out the main polygon 
			
			# Skip hole polygons 
			if index > 0:
				continue
			
			# Verticies in the polygon 
			for v in polygon.size():
				var pos = Vector2(polygon[v][0], polygon[v][1]) / 10
				polygon[v][0] = pos.x
				polygon[v][1] = pos.y
				sum += pos
				count += 1
				index += 1
			
			shapes.push_back(polygon)
	
	var avg = sum / count
	for shape in shapes:
		for v in shape.size():
			shape[v][0] -= avg.x
			shape[v][1] -= avg.y

# Callable generation 
func UpdateWorldMesh():
	
	st.clear()
	st.begin(Mesh.PRIMITIVE_TRIANGLES) 
	
	for wall in wallVerticies:
		
		var counter = 1
		
		for point in wall:
			var p = Vector3(point[0], point[1], point[2])
			st.add_vertex(p)
			counter += 1
		
		if hasRoofCheckBox.button_pressed:
			for triangle in cap:
				st.add_vertex(Vector3(triangle.pointA.x, height, triangle.pointA.y))
				st.add_vertex(Vector3(triangle.pointB.x, height, triangle.pointB.y))
				st.add_vertex(Vector3(triangle.pointC.x, height, triangle.pointC.y))
		for triangle in cap:
			st.add_vertex(Vector3(triangle.pointA.x, 0, triangle.pointA.y))
			st.add_vertex(Vector3(triangle.pointB.x, 0, triangle.pointB.y))
			st.add_vertex(Vector3(triangle.pointC.x, 0, triangle.pointC.y))
		st.index()
	
	var mesh = st.commit()
	meshRenderer.mesh = mesh

# Sets the debug spheres to the current triangle 
func UpdateTriangleVisual():
	var tri = triangulation.currTriangle
	
	triangleCorners[0].global_position = Vector3(tri.pointA.x, height, tri.pointA.y)
	triangleCorners[1].global_position = Vector3(tri.pointB.x, height, tri.pointB.y)
	triangleCorners[2].global_position = Vector3(tri.pointC.x, height, tri.pointC.y)
	
