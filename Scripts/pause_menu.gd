extends Control

func _ready():
	hide()


func _on_resume_pressed():
	get_parent().get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hide()

func _on_quit_pressed():
	get_tree().quit()


