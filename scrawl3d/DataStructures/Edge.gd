class_name Edge2D

@export var pointA : Vector2
@export var pointB : Vector2

func _init(a : Vector2, b : Vector2) -> void:
	pointA = a
	pointB = b 

func GetMidpoint() -> Vector2:
	return (pointA + pointB) / 2.0

func GetDir() -> Vector2:
	return (pointA - pointB).normalized()
