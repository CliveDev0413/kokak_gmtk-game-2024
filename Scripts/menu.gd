extends Node2D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("space"):
		Transition.transition();
		await Transition.on_transition_finished;
		get_tree().change_scene_to_file("res://Scenes/tadpole.tscn");
		pass;
