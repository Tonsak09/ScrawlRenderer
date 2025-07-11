class_name Triangulation2D

signal TrianglesUpdated 
signal TriangleChecking

var currTriangle : Triangle2D


func Triangulate(allPoints : Array, points : Array, triangles : Array[Triangle2D], corners : int) -> Array[Triangle2D]:
	
	# TODO: Include checks for holes 
	
	var i = 0
	while i < points.size() && points.size() >= 3:
		
		if points.size() == 4:
			print_debug("Hehe")
		
		var j = (i + 1) % corners
		var k = (j + 1) % corners
		
		
		var pointI = Vector2(points[i][0], points[i][1]) 
		var pointJ = Vector2(points[j][0], points[j][1]) 
		var pointK = Vector2(points[k][0], points[k][1]) 
		
		currTriangle = Triangle2D.new(pointI, pointJ, pointK)
		TriangleChecking.emit()
		
		# Check if the current triangle is inside of polygon
		# ((X[i]!=X[j] || Y[i]!=Y[j]) && (Y[k]-Y[i])*(X[j]-X[i])>=(X[k]-X[i])*(Y[j]-Y[i]))
		 # Make sure the triangle is organized correctly 
		if ((pointI.x != pointJ.x) || (pointI.y != pointJ.y)) and IsLeft(pointI, pointJ, pointK):
			# Ensure that the triangle does not contain any corners of the 
			# polygon intersecting into it 
			var hasInside = false 
			for point in allPoints:
				
				var curr = Vector2(point[0], point[1])
				if curr == pointI || curr == pointJ || curr == pointK:
					continue
				
				if isInside(pointI, pointJ, pointK, curr):
					hasInside = true
					break;
				
			#if l == corners: # Usable triangle found
			if !hasInside:
				# Add triangle 
				triangles.push_back(Triangle2D.new(pointI, pointJ, pointK))
				TrianglesUpdated.emit()
				
				# Remove the just created triangle 
				points.remove_at(j)
				corners -= 1
				return Triangulate(allPoints, points, triangles, corners)
			
		# Move forward in the polygon
		i += 1
	
	# It may need to cycle again
	#if points.size() >= 3:
		#return Triangulate(allPoints, points, triangles, corners)
	
	if corners >= 3:
		assert("FAILED") 
	
	print_debug("Mesh triangulated successfulyl!")
	print_debug(points.size())
	
	return triangles



func IsLeft(a: Vector2, b: Vector2, c: Vector2) -> bool:
	return (c.y - a.y) * (b.x - a.x) >= (c.x - a.x) * (b.y - a.y)


#function pointInsideTriangle(Ax, Ay, Bx, By, Cx, Cy, x, y) {
#
  #var inside=false;
#
  #if ((x!=Ax || y!=Ay)
  #&&  (x!=Bx || y!=By)
  #&&  (x!=Cx || y!=Cy)) {
	#if ((Ay<y && By>=y || By<y && Ay>=y) && Ax+(y-Ay)/(By-Ay)*(Bx-Ax)<x) inside=!inside;
	#if ((By<y && Cy>=y || Cy<y && By>=y) && Bx+(y-By)/(Cy-By)*(Cx-Bx)<x) inside=!inside;
	#if ((Cy<y && Ay>=y || Ay<y && Cy>=y) && Cx+(y-Cy)/(Ay-Cy)*(Ax-Cx)<x) inside=!inside; }
#
  #return inside; }


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


func Area(vertA : Vector2, vertB : Vector2, vertC : Vector2) -> float:
	return abs((vertA.x*(vertB.y-vertC.y) + vertB.x*(vertC.y-vertA.y)+ vertC.x*(vertA.y-vertB.y))/2.0)
 
# A function to check whether point P(x, y) lies inside the triangle formed 
#  by A(x1, y1), B(x2, y2) and C(x3, y3) 
func isInside(vertA : Vector2, vertB : Vector2, vertC : Vector2, pos : Vector2):
	#/* Calculate area of triangle ABC */
	var A = Area (vertA, vertB, vertC);
	
	var A1 = Area (pos, vertB, vertC);
	var A2 = Area (vertA, pos, vertC);
	var A3 = Area (vertA, vertB, pos);
	
	var diff = abs(A - (A1 + A2 + A3))
	
	#/* Check if sum of A1, A2 and A3 is same as A */
	return diff == 0
