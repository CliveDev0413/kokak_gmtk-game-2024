extends Control

@export var pics_to_show: Array[TextureRect];
@export var next_scene_path: String;
var slide;

func _ready() -> void:
	for pic in pics_to_show:
		pic.visible = false;
		
	slide = 0;
	display_slide(0);

func _process(delta: float) -> void:
	
	if slide == pics_to_show.size() - 1:
		print("u can transition!");
		if Input.is_action_just_pressed("space"):
			change_scene();
	elif slide != pics_to_show.size() - 1:
		if Input.is_action_just_pressed("space"):
			next_slide();
	pass;

func next_slide() -> void:
	slide += 1;
	display_slide(slide);
	
func display_slide(slide: int) -> void:
	for pic in pics_to_show:
		pic.visible = false;
		
	pics_to_show[slide].visible = true;

func change_scene() -> void:
	Transition.transition();
	await Transition.on_transition_finished;
	get_tree().change_scene_to_file(next_scene_path);
