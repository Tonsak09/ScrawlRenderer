extends Node

@export var world : Node3D
@export var mapList : ItemList
@export var height : float 
@export var renderedWorld : Node3D
#@export var meshRenderer : MeshInstance3D
@export var hasRoofCheckBox : CheckBox
@export var triangleCorners : Array[Node3D]

var meshRender = preload("res://Prefabs/SampleMesh.tscn")

var triangulation : Triangulation2D
var st : SurfaceTool


var meshPolygons : Array
var caps : Array


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
	meshPolygons.clear()
	caps.clear()
	
	# Access the file 
	var polyGroups = AccessFilePositionalData(path)
	
	ProcessPolyGroups(polyGroups)
	#TransferMeshDataToPeers.rpc(polyGroups)
	
	var json_as_text = FileAccess.get_file_as_string(path)
	TransferJsonAsText.rpc(json_as_text)

func ProcessPolyGroups(polyGroups):
	for polyGroup in polyGroups:
		# Create wall verticies 
		for polygon in polyGroup:
			meshPolygons.push_back(ExtrudePositions(polygon, height))
		
		# Triangulate top for an entire polygroup 
		var holes = polyGroup.slice(1, polyGroup.size())
		
		for hole in holes:
			triangulation.FuseHoleIntoPoints(polyGroup[0], hole) 
		
		polyGroup[0] = Array_No_Continous(polyGroup[0])
		var allPoints = polyGroup[0].duplicate()
		var corners = allPoints.size()
		triangulation.Triangulate(allPoints, polyGroup[0], holes, caps, corners, 0)
		
		#WriteToFile("./Output/" + name + ".obj", wallVerticies, cap)
	UpdateWorldMesh()

# Write array of 3D positions to a .obj file format 
func WriteToFile(path : String, polyGroups : Array, cap : Array):
	var file = FileAccess.open(path, FileAccess.WRITE)
	var content : String
	var counter = 1
	
	var verticies = ""
	var faces = ""
	
	for polygon in polyGroups:
		# Adding verticies 
		for objPos in polygon:
			verticies += "v " + str(objPos.x) + " " + str(objPos.y) + " " + str(objPos.z) + " 1\n"
		
		for triangle in cap:
			# TODO: Sort triangle points when adding face
			content += "v " + str(triangle.pointA.x) + " " + str(height) + " " + str(triangle.pointA.y) + " 1\n"
			content += "v " + str(triangle.pointB.x) + " " + str(height) + " " + str(triangle.pointB.y) + " 1\n"
			content += "v " + str(triangle.pointC.x) + " " + str(height) + " " + str(triangle.pointC.y) + " 1\n"
		
		# Faces must be made of PREVIOUSLY added indexes 
		for i in range(0, polygon.size() - 3):
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
	
	var polyGroups : Array
	
	var json_as_text = FileAccess.get_file_as_string(path)
	var json_as_dict = JSON.parse_string(json_as_text) 
	
	if !json_as_dict:
		return polyGroups
	
	# Each layer 
	for data in json_as_dict["data"]["geometry"]:
		# Don't try to read empty 
		if json_as_dict["data"]["geometry"][data]["polygons"].size() == 0:
			continue
		
		# Add vertex data to array 
		# NOTE: Polygons contain their main shape and then holes for the rest of
		#       the array 
		ProcessPloygons(json_as_dict["data"]["geometry"][data]["polygons"], polyGroups)
	
	return polyGroups

func AccessFilePositionalDataAsTextData(jsonAsText : String) -> Array:
	# NOTE: Withing the polygons sections there are two arrays, one for the 
	#       shape overall and then other for the shapes that make up and cutup
	#       the shape. The first enty in the polygon is the main shape while 
	#       the rest are used to make holes inside of it. 
	
	var polyGroups : Array
	
	var json_as_dict = JSON.parse_string(jsonAsText) 
	
	if !json_as_dict:
		return polyGroups
	
	# Each layer 
	for data in json_as_dict["data"]["geometry"]:
		# Don't try to read empty 
		if json_as_dict["data"]["geometry"][data]["polygons"].size() == 0:
			continue
		
		# Add vertex data to array 
		# NOTE: Polygons contain their main shape and then holes for the rest of
		#       the array 
		ProcessPloygons(json_as_dict["data"]["geometry"][data]["polygons"], polyGroups)
	
	return polyGroups

# Reads the polyGroup data and brings the main poly data into the shapes 
# Alters the data slightly, size and centering, then places it into a seperate
# array 
func ProcessPloygons(polyGroupsData : Array, polyGroups : Array):
	
	var sum : Vector2
	var count : int 
	
	# NOTE: A polygroup is an array of polygons where the first is the real shape
	#       and the rest are the holes within it 
	
	for polyGroup in polyGroupsData:
		#print_debug("This polygroup has " + str(polyGroup.size()) + " shapes")
		
		# Will hold the adjusted polygon and its holes 
		var polyGroupMain : Array
		
		var index = 0
		for polygon in polyGroup:
			# Verticies in the polygon 
			for v in polygon.size():
				# Reduce size slightly 
				var pos = Vector2(polygon[v][0], polygon[v][1]) / 10
				polygon[v][0] = pos.x
				polygon[v][1] = pos.y
				
				sum += pos
				count += 1
				index += 1
			
			polyGroupMain.push_back(polygon)
			#polyGroups.push_back(polygon)
		
		# Add the new set to polygroups 
		polyGroups.push_back(polyGroupMain)
	
	# Center the shapes 
	var avg = sum / count
	for polyGroup in polyGroups:
		for shape in polyGroup:
			for v in shape.size():
				shape[v][0] -= avg.x
				shape[v][1] -= avg.y

# Callable generation 
func UpdateWorldMesh():
	
	var children = renderedWorld.get_children()
	for child in children:
		child.queue_free()
	
	var meshes : Array
	
	var meshCounter = 0
	for polygon in meshPolygons:
		
		st.clear()
		st.begin(Mesh.PRIMITIVE_TRIANGLES) 
		
		meshes.push_back(meshRender.instantiate())
		
		for point in polygon:
			var p = Vector3(point[0], point[1], point[2])
			st.add_vertex(p)
		
		for triangle in caps:
			st.add_vertex(Vector3(triangle.pointA[0], 0, triangle.pointA[1]))
			st.add_vertex(Vector3(triangle.pointB[0], 0, triangle.pointB[1]))
			st.add_vertex(Vector3(triangle.pointC[0], 0, triangle.pointC[1]))
			
			if hasRoofCheckBox.button_pressed:
				st.add_vertex(Vector3(triangle.pointA.x, height, triangle.pointA.y))
				st.add_vertex(Vector3(triangle.pointB.x, height, triangle.pointB.y))
				st.add_vertex(Vector3(triangle.pointC.x, height, triangle.pointC.y))
		st.index()
		meshes[meshCounter].mesh = st.commit()
		renderedWorld.add_child(meshes[meshCounter])
		meshCounter += 1
	
	#var mesh = st.commit()
	#meshRenderer.mesh = mesh

# Sets the debug spheres to the current triangle 
func UpdateTriangleVisual():
	var tri = triangulation.currTriangle
	
	triangleCorners[0].global_position = Vector3(tri.pointA.x, height, tri.pointA.y)
	triangleCorners[1].global_position = Vector3(tri.pointB.x, height, tri.pointB.y)
	triangleCorners[2].global_position = Vector3(tri.pointC.x, height, tri.pointC.y)
	

# Removes items that repeat next to each other 
func Array_No_Continous(array: Array) -> Array:
	var unique: Array = []
	
	for item in array:
		
		var index = unique.size() - 1
		if index < 0:
			unique.push_back(item)
			continue
		
		if unique[index] != item:
			unique.push_back(item)
	
	return unique

@rpc("any_peer", "reliable", "call_remote")
func TransferMeshDataToPeers(polyGroups):
	meshPolygons.clear()
	caps.clear()
	
	#meshPolygons = polyGroups
	
	var children = renderedWorld.get_children()
	for child in children:
		child.queue_free()
	
	print_debug(renderedWorld.get_child_count())
	ProcessPolyGroups(polyGroups)
	print_debug(renderedWorld.get_child_count())

@rpc("any_peer", "reliable", "call_remote")
func TransferJsonAsText(jsonAstext : String):
	
	# Cleanup old
	meshPolygons.clear()
	caps.clear()
	
	# Access the file 
	var polyGroups = AccessFilePositionalDataAsTextData(jsonAstext)
	
	ProcessPolyGroups(polyGroups)
