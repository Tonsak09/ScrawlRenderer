class_name Triangulation2D


func Triangulate(points : Array, triangles : Array[Triangle2D], corners : int) -> Array[Triangle2D]:
	
	# TODO: Include checks for holes 
	
	
	var i = 0
	while i < corners && corners >= 3:
		var j = (i + 1) % corners
		var k = (j + 1) % corners
		
		var pointI = Vector2(points[i][0], points[i][1]) 
		var pointJ = Vector2(points[j][0], points[j][1]) 
		var pointK = Vector2(points[k][0], points[k][1]) 
		
		# Check if the current triangle is inside of polygon
		# ((X[i]!=X[j] || Y[i]!=Y[j]) && (Y[k]-Y[i])*(X[j]-X[i])>=(X[k]-X[i])*(Y[j]-Y[i]))
		if pointI != pointJ and IsLeft(pointI, pointJ, pointK):
			# Ensure that the triangle does not contain any corners of the 
			# polygon intersecting into it 
			
			var l = 0
			while l < corners:
				if PointInsideTriangle(pointI, pointJ, pointK, Vector2(points[l][0], points[l][1])):
					break
				l += 1
			if l == corners: # Usable triangle found
				# Add triangle 
				triangles.push_back(Triangle2D.new(pointI, pointJ, pointK))
				
				# Remove the just created triangle 
				corners -= 1
				for p in range(j, corners):
					points[p] = points[p + 1]
				return Triangulate(points, triangles, corners)
			
		# Move forward in the polygon
		i += 1
	
	if corners >= 3:
		assert("FAILED") 
	
	print_debug("Mesh triangulated successfulyl!")
	
	return triangles



func IsLeft(a: Vector2, b: Vector2, c: Vector2) -> bool:
	return (c.y - a.y) * (b.x - a.x) >= (c.x - a.x) * (b.y - a.y)

func PointInsideTriangle(vertA : Vector2, vertB : Vector2, vertC : Vector2, pos : Vector2) -> bool:
	
	var inside = false 
	if  (pos.x != vertA.x && pos.y != vertA.y) && \
		(pos.x != vertB.x && pos.y != vertB.y) && \
		(pos.x != vertC.x && pos.y != vertC.y):
		
		if (vertA.y < pos.y && vertB.y >= pos.y) || (vertB.y < pos.y && vertA.y >= pos.y) && (vertA.x + (pos.y - vertA.y) / (vertB.y - vertA.y) * (vertB.x - vertA.x) < pos.x):
			inside = !inside
		if (vertB.y < pos.y && vertC.y >= pos.y) || (vertC.y < pos.y && vertB.y >= pos.y) && (vertB.x + (pos.y - vertB.y) / (vertC.y - vertB.y) * (vertC.x - vertB.x) < pos.x):
			inside = !inside
		if (vertC.y < pos.y && vertA.y >= pos.y) || (vertA.y < pos.y && vertC.y >= pos.y) && (vertC.x + (pos.y - vertC.y) / (vertA.y - vertC.y) * (vertA.x - vertC.x) < pos.x):
			inside = !inside
	
	return inside
