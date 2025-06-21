class_name Triangulation2D


func Triangulate(points : Array[Vector2]) -> Array[Triangle2D]:
	
	# Generate super triangle 
	#    Go through each point to generate a quad that
	#    has all the points in it and geneate a triangle
	#    based on the corners 
	var superTriangle = Triangle2D.new(Vector2(-100,-100), Vector2(0,100), Vector2(100,-100)) 
	
	var triangles : Array[Triangle2D]
	triangles.push_back(superTriangle)
	
	for point in points:
		
		var collTriangles : Array[int] 
		
		# Check all circumcircles
		# NOTE: This has to be done for each point since the triangles 
		#		are manipulated after each point pass
		var counter = 0;
		for triangle in triangles:
			
			var center = triangle.GetCircumCircleCenter()
			var radius = (center - triangle.pointA).length()
			
			if Geometry2D.is_point_in_circle(point, center, radius):
				collTriangles.push_back(counter)
			
			counter += 1
		
		# Subdivide these triangles that the points exist in 
		var reduced = 0
		for i in collTriangles:
			# Generate new triangles based on old corners
			
			var triangle = triangles[i]
			var nextTriA = Triangle2D.new(point, triangle.pointA, triangle.pointB)
			var nextTriB = Triangle2D.new(point, triangle.pointA, triangle.pointC)
			var nextTriC = Triangle2D.new(point, triangle.pointB, triangle.pointC)
			
			# NOTE: Everytime we remove a value from the triangles array
			#		the collTriangles values are out of date by one so 
			#		we simply shift them down by one 
			collTriangles.remove_at(i - reduced)
			reduced += 1
	
	return triangles
