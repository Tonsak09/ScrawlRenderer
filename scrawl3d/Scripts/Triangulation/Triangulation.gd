class_name Triangulation2D

signal TrianglesUpdated 
signal TriangleChecking

var currTriangle : Triangle2D


func Triangulate(recordOfAllPoints : Array, points : Array, holes : Array, triangles : Array, corners : int, start : int):
	
	# Triangles are of type Array[Triangle2D]
	
	var counter = 0
	while counter < points.size() && points.size() >= 3:
		var i = (start + counter) % corners
		var j = (i + 1) % corners
		var k = (j + 1) % corners
		
		var pointI = Vector2(points[i][0], points[i][1]) 
		var pointJ = Vector2(points[j][0], points[j][1]) 
		var pointK = Vector2(points[k][0], points[k][1]) 
		
		currTriangle = Triangle2D.new(pointI, pointJ, pointK)
		TriangleChecking.emit()
		
		# Check if the current triangle is inside of polygon
		# Make sure the triangle is organized correctly 
		if ((pointI.x != pointJ.x) || (pointI.y != pointJ.y)) and IsLeft(pointI, pointJ, pointK):
			# Ensure that the triangle does not contain any corners of the 
			# polygon intersecting into it 
			var hasInside = false 
			for point in recordOfAllPoints:
				
				var curr = Vector2(point[0], point[1])
				if curr == pointI || curr == pointJ || curr == pointK:
					continue
				
				if IsInside(pointI, pointJ, pointK, curr):
					hasInside = true
					break;
				
			# Usable triangle found
			if !hasInside:
				# Add triangle 
				triangles.push_back(Triangle2D.new(pointI, pointJ, pointK))
				TrianglesUpdated.emit()
				
				# Remove the just created triangle 
				points.remove_at(j)
				corners -= 1
				Triangulate(recordOfAllPoints, points, holes, triangles, corners, i)
				return
			
		# Move forward in the polygon
		counter += 1
		
	
	#if corners >= 3:
	#	assert("FAILED") 
	#print_debug("Mesh triangulated successfulyl!")

func FuseHoleIntoPoints(points : Array, hole : Array):
	# If there is no hole, skip step 2 and move on to step 3.
	
	# Set up arrays for a unified polygon (outer polygon and hole combined).
	
	var minDis = 99999999999
	var minHole
	var minPoint
	
	# Find closest pair of outer hull and hole that is valid 
	for i in hole.size():
		for j in points.size():
			
			var hI = Vector2(hole[i][0], hole[i][1])
			var pJ = Vector2(points[j][0], points[j][1])
			
			var diff = (hI - pJ).length_squared()
			
			# Shorter segement found! 
			if diff < minDis:
				
				# NOTE: The following function additional compares if the 
				#       second point in the line is in the polygon given and
				#       skips it 
				
				if DoesLineIntersectPolygon(hI, pJ, points):
					continue
				if DoesLineIntersectPolygon(pJ, hI, hole):
					continue
				
				# All good
				minDis   = diff
				minHole  = i
				minPoint = j
	
	var unified : Array
	unified.resize(points.size() + hole.size() + 2)
	for i in points.size() + 1:
		unified[i] = points[(minPoint + i) % points.size()]
	for i in hole.size() + 1:
		unified[points.size() + 1 + i] = hole[(minHole + i) % hole.size()]
	
	points.clear()
	points.append_array(unified)
	

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

func Area(vertA : Vector2, vertB : Vector2, vertC : Vector2) -> float:
	return abs((vertA.x*(vertB.y-vertC.y) + vertB.x*(vertC.y-vertA.y)+ vertC.x*(vertA.y-vertB.y))/2.0)
 
# A function to check whether point P(x, y) lies inside the triangle formed 
#  by A(x1, y1), B(x2, y2) and C(x3, y3) 
func IsInside(vertA : Vector2, vertB : Vector2, vertC : Vector2, pos : Vector2):
	#/* Calculate area of triangle ABC */
	var A = Area (vertA, vertB, vertC);
	
	var A1 = Area (pos, vertB, vertC);
	var A2 = Area (vertA, pos, vertC);
	var A3 = Area (vertA, vertB, pos);
	
	var diff = abs(A - (A1 + A2 + A3))
	
	#/* Check if sum of A1, A2 and A3 is same as A */
	return diff == 0

func DoesLineIntersectPolygon(pointA : Vector2, pointB : Vector2, polygon : Array) -> bool:
	for i in polygon.size():
		var j = (i + 1) % polygon.size()
		
		var polyPointA = Vector2(polygon[i][0], polygon[i][1])
		var polyPointB = Vector2(polygon[j][0], polygon[j][1])
		if polyPointA == pointB || polyPointB == pointB:
			continue
		
		#var pA = Vector2(polygon[i].x, polygon[i].y)
		#var pB = Vector2(polygon[j].x, polygon[j].y)
		
		if Geometry2D.segment_intersects_segment(pointA, pointB, polyPointA, polyPointB):
			return true
	
	return false 
