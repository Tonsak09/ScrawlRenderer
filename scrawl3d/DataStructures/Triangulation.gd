class_name Triangulation2D


func Triangulate(points : Array[Vector2]) -> Array[Triangle2D]:
	
	# Generate super triangle 
	#    Go through each point to generate a quad that
	#    has all the points in it and geneate a triangle
	#    based on the corners 
	var superTriangle = Triangle2D.new(Vector2(-10000,-10000), Vector2(0,10000), Vector2(10000,-10000)) 
	
	var triangles : Array[Triangle2D]
	triangles.push_back(superTriangle)
	
	# TODO: When recieving a set of points for each duplicate point
	#       consider it a complete polygon
	
	var dupesRemoved : Array[Vector2]
	
	# Remove duplicate points and handle accordingly 
	for point in points:
		if point not in dupesRemoved:
			dupesRemoved.push_back(point)
		else:
			print_debug("Duplicate Found: " + str(point))
	
	
	for point in dupesRemoved:
		
		var collTriangles : Array[int] 
		
		# Check all circumcircles
		# NOTE: This has to be done for each point since the triangles 
		#		are manipulated after each point pass
		var counter = 0;
		for triangle in triangles:
			
			var center = triangle.GetCircumCircleCenter()
			var radius = (center - triangle.pointA).length()
			var triAP = triangle.pointA
			
			# Find out which triangles are being collided with 
			if Geometry2D.is_point_in_circle(point, center, radius):
				collTriangles.push_back(counter)
			
			counter += 1
		
		# Subdivide these triangles that the points exist in 
		var reduced = 0
		for i in collTriangles:
			# Generate new triangles based on old corners
			
			var triangle = triangles[i - reduced]
			SubdivideTriangle(point, triangle, triangles)
			
			# NOTE: Everytime we remove a value from the triangles array
			#		the collTriangles values are out of date by one so 
			#		we simply shift them down by one 
			triangles.remove_at(i - reduced)
			reduced += 1
	
	return triangles

# Creates three new triangles all of which connect to the given point
func SubdivideTriangle(point : Vector2, triangle : Triangle2D, triangles : Array[Triangle2D]):
	# TODO: Figure the correct order to create the triangles.
	#       There are more than three possible combinations, many of which are
	#       incorrect! 
	
	if (triangle.pointA == triangle.pointB || triangle.pointA == triangle.pointB || triangle.pointB == triangle.pointC):
		print_debug("Duplicate found!")
	
	if point == triangle.pointB || point == triangle.pointB || point == triangle.pointC:
		print_debug("Point already equals a corner")
	
	var nextTriA = Triangle2D.new(point, triangle.pointA, triangle.pointB)
	var nextTriB = Triangle2D.new(point, triangle.pointA, triangle.pointC)
	var nextTriC = Triangle2D.new(point, triangle.pointB, triangle.pointC)
	triangles.push_back(nextTriA)
	triangles.push_back(nextTriB)
	triangles.push_back(nextTriC)
