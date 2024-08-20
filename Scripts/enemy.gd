extends "res://Scripts/edible_object.gd"

enum EnemyStates {
	IDLE,
	CHASE,
}

var state: EnemyStates;

@export var MOVE_SPEED: float = 100.0;
@export var CHASE_ANIM: String;
@export var NOTICE_ANIM: String;
@export var ENEMY_SOUND: AudioStream;

@onready var animationPlayer = $AnimationPlayer;
@onready var sprite = $Sprite2D;

var is_active: bool = false;

func _ready() -> void:
	state = EnemyStates.IDLE;
	frog = get_tree().get_first_node_in_group("player");

func _physics_process(delta: float) -> void:
	super(delta);
	
	if eaten:
		if $Hitbox != null:
			$Hitbox.queue_free();
		eaten = false;
	
	match state:
		EnemyStates.IDLE:
			idle();
			pass;
		EnemyStates.CHASE:
			chase_player();
			pass;
	pass;

func idle():
	pass;

func chase_player() -> void:
	if CHASE_ANIM:
		animationPlayer.play(CHASE_ANIM);
	
	var direction = (frog.global_position - global_position).normalized();
	
	sprite.flip_h = (direction.x > 0);
	
	var object = self;
	
	var random_num = rng.randi();
	
	if (random_num % 200) == (200 - 1):
		audioPlayer.stream = ENEMY_SOUND;
		audioPlayer.pitch_scale = rng.randf_range(0.7, 1.3);
		audioPlayer.play();
	
	if self.is_class("CharacterBody2D"):
		(object as CharacterBody2D).velocity = direction * MOVE_SPEED;
		(object as CharacterBody2D).move_and_slide();
	
	pass;

func _on_visible_on_screen() -> void:
	if !is_active:
		is_active = true;
		$VisibleOnScreenEnabler2D.queue_free();
		
		audioPlayer.stream = ENEMY_SOUND;
		audioPlayer.pitch_scale = rng.randf_range(0.7, 1.3);
		audioPlayer.play();
		
		if NOTICE_ANIM:
			animationPlayer.play(NOTICE_ANIM);
			await animationPlayer.animation_finished;
		else:
			await get_tree().create_timer(2).timeout;
			
		
		state = EnemyStates.CHASE;
