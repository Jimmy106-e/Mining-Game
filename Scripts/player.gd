extends CharacterBody3D

#Walking Export Value
@export_range(1, 35, 1) var speed: float = 10 # m/s
@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2

#Player/Camera Export Value
@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m
@export_range(0.1, 20, 0.05, "or_greater") var camera_sens: float = 10

#States
var jumping: bool = false
var mouse_captured: bool = false

#Settings
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

#Direction
var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

#Physics
var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity

#Camera
@onready var camera: Camera3D = $Camera3D

var firstPerson = Vector3(0,1.5,0)
var thirdPerson = Vector3(0,3.5,2)
var camera_perspective_state = 0

#Raycast
@onready var raycast = $Camera3D/RayCast3D

@export_range(1,5,0.1) var raycast_distance: float = 2

#GridMap
@onready var gridmap = $"../GridMap"

func _ready() -> void:
	capture_mouse()
	raycast.scale = Vector3(0.5,raycast_distance,0.5)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: look_dir = event.relative * 0.01
	if Input.is_action_just_pressed("jump"): jumping = true
	if Input.is_action_just_pressed("exit"): get_tree().quit()
	_change_zoom()

func _physics_process(delta: float) -> void:
	if mouse_captured: _rotate_camera(delta)
	velocity = _walk(delta) + _gravity(delta) + _jump(delta)
	move_and_slide()
	_handle_block_changes()

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _rotate_camera(delta: float, sens_mod: float = 1.0) -> void:
	look_dir += Input.get_vector("look_left","look_right","look_up","look_down")
	camera.rotation.y -= look_dir.x * camera_sens * sens_mod * delta
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod * delta, -1.5, 1.5)
	look_dir = Vector2.ZERO

func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector("left", "right", "forward", "backward")
	var _forward: Vector3 = camera.transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return walk_vel

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel

func _change_zoom():
	if Input.is_action_just_pressed("perspective_change"):
		if camera_perspective_state == 0:
			camera.position = firstPerson
			camera_perspective_state = 1
		else:
			camera.position = thirdPerson
			camera_perspective_state = 0

func _handle_block_changes():
	var raycast_position = raycast.get_collision_point()
	var normal = raycast.get_collision_normal()
	var _selected_block = -1
	
	if raycast.is_colliding():
		var breaking = Input.is_action_just_pressed("break")
		var placing = Input.is_action_just_pressed("place")
		var picking = Input.is_action_just_pressed("pick_block")
		# Either both buttons were pressed or neither are, so stop.
		if breaking == picking:
			return
		
		if picking:
			# Block picking.
			var block_global_position = (raycast_position - normal / 2).floor()
			block_global_position = gridmap.local_to_map(block_global_position)
			_selected_block = gridmap.get_cell_item(block_global_position)
			print("Block Selected: ")
			print(_selected_block)
		
		if breaking:
			var block_global_position = (raycast_position - normal / 2).floor()
			block_global_position = gridmap.local_to_map(block_global_position)
			gridmap.set_cell_item(block_global_position, -1)
			print("Broke block: ")
			print(gridmap.get_cell_item(gridmap.local_to_map(block_global_position)))
			print("At: ")
			print(block_global_position)
		
#		if placing:
#			var block_global_position = (raycast_position - normal / 2).floor()
#			block_global_position = gridmap.local_to_map(block_global_position)
#			gridmap.set_cell_item(block_global_position, _selected_block)
