extends Camera3D

@export var speed = 0.01
@export var mouseSpeed = 0.01

var rotX = 0
var rotY = 0

var rayOrigin : Vector3
var rayEnd : Vector3

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	if !is_multiplayer_authority():
		return
	
	current = true

func _process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	
	
	if Input.is_action_pressed("Forward"):
		translate(Vector3.FORWARD * speed * delta)
	elif Input.is_action_pressed("Backward"):
		translate(Vector3.FORWARD * -speed * delta)
	elif Input.is_action_pressed("Left"):
		translate(Vector3.LEFT * speed * delta)
	elif Input.is_action_pressed("Right"):
		translate(Vector3.RIGHT * speed * delta)
	elif Input.is_action_pressed("Up"):
		translate(Vector3.UP * speed * delta)
	elif Input.is_action_pressed("Down"):
		translate(Vector3.DOWN * speed * delta)

func _physics_process(delta: float) -> void:
	var spaceState = get_world_3d().direct_space_state
	var mousePos = get_viewport().get_mouse_position()
	rayOrigin = project_ray_origin(mousePos)
	rayEnd = rayOrigin + project_ray_normal(mousePos) * 2000
	var query = PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd)
	var intersection = spaceState.intersect_ray(query)
	
	if !intersection.is_empty():
		var pos = intersection.position
		print_debug(intersection.values())
		#look_at()
		#$Mesh.global_position = pos 

func _unhandled_input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_RIGHT: 
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		# modify accumulated mouse rotation
		rotX += event.relative.x * mouseSpeed
		rotY += event.relative.y * mouseSpeed
		transform.basis = Basis() # reset rotation
		rotate_object_local(Vector3(0, 1, 0), -rotX) # first rotate in Y
		rotate_object_local(Vector3(1, 0, 0), -rotY) # then rotate in X
	
	if Input.is_action_just_released("Click"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func UpdateMoveSpeed(value: float):
	if !is_multiplayer_authority():
		return
	speed = value
