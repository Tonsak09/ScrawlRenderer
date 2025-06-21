class_name Triangle2D

var edgeA : Edge2D
var edgeB : Edge2D
var edgeC : Edge2D

var pointA : Vector2
var pointB : Vector2
var pointC : Vector2

func _init(pA : Vector2, pB : Vector2, pC : Vector2) -> void:
	edgeA = Edge2D.new(pA, pB)
	edgeB = Edge2D.new(pA, pC)
	edgeC = Edge2D.new(pB, pC)
	
	pointA = pA
	pointB = pB
	pointC = pC

func GetCircumCircleCenter() -> Vector2:
	# Find intersection of lines created at the center of 
	# each edge 
	
	var centerA = edgeA.GetMidpoint()
	var centerB = edgeB.GetMidpoint()
	var dirA = -edgeA.GetDir()
	var dirB = -edgeB.GetDir()
	
	var center = Geometry2D.line_intersects_line(centerA, dirA, centerB, dirB)
	return center
