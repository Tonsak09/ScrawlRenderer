class_name Triangulation2D


func Triangulate(points : Array[Vector2]) -> Array[Triangle2D]:
	var triangles : Array[Triangle2D]
	
	# TODO: Include checks for holes 
	
	var corners = points.size()
	
	var l = 0
	var i = 0
	while i < corners && corners >= 3:
		var j = (i + 1) % corners
		var k = (j + 1) % corners
		
		var pointI = points[i]
		var pointJ = points[j]
		var pointK = points[k]
		
		# Check if the current triangle is inside of polygon
		# ((X[i]!=X[j] || Y[i]!=Y[j]) && (Y[k]-Y[i])*(X[j]-X[i])>=(X[k]-X[i])*(Y[j]-Y[i]))
		if (pointI.x != pointJ.x || pointI.y != pointJ.y) && (pointK.y - pointI.y) * (pointJ.x - pointI.x) >= (pointK.x - pointI.x) * (pointJ.y - pointI.y):
			# Ensure that the triangle does not contain any corners of the 
			# polygon intersecting into it 
			for c in corners:
				if PointInsideTriangle(pointI, pointJ, pointK, points[c]):
					l = corners
			if l == corners: # Usable triangle found
				# Draw triangle? 
				triangles.push_back(Triangle2D.new(pointI, pointJ, pointK))
				
				# Remove the just created triangle 
				corners -= 1
				points.remove_at(l)
		
		# Move forward in the polygon
		i += 1
	
	if corners >= 3:
		assert("FAILED") 
	
	print_debug("Mesh triangulated successfulyl!")
	
	return triangles



func PointInsideTriangle(vertA : Vector2, vertB : Vector2, vertC : Vector2, pos : Vector2) -> bool:
	
	var inside = false 
	if  (pos.x != vertA.x && pos.y != vertA.y) && \
		(pos.x != vertB.x && pos.y != vertB.y) && \
		(pos.x != vertC.x && pos.y != vertC.y):
			
		if (vertA.y < pos.y && vertB.y >= pos.y) || (vertB.y < pos.y && vertA.y < pos.y) && (vertA.x + (pos.y - vertA.y) / (vertB.y - vertA.y) * (vertB.x - vertA.x) < pos.x):
			inside = !inside
		if (vertB.y < pos.y && vertC.y >= pos.y) || (vertC.y < pos.y && vertB.y < pos.y) && (vertB.x + (pos.y - vertB.y) / (vertC.y - vertB.y) * (vertC.x - vertB.x) < pos.x):
			inside = !inside
		if (vertC.y < pos.y && vertA.y >= pos.y) || (vertA.y < pos.y && vertC.y < pos.y) && (vertC.x + (pos.y - vertC.y) / (vertA.y - vertC.y) * (vertA.x - vertC.x) < pos.x):
			inside = !inside
	
	return false
