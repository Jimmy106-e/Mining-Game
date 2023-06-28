extends CanvasLayer

@onready var pauseMenu = $PauseMenu
@onready var player = $"../Player"
@onready var crosshair = $"../Player/Camera3D/CanvasLayer/Sprite2D"

func _process(delta):
	if Input.is_action_just_pressed("pause_menu"):
		var paused_state = get_tree().paused
		get_tree().paused = !paused_state
		pauseMenu.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		crosshair.hide()
	else: crosshair.show()
