extends Node2D

var logs = ['one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten']

func _ready():
	DialogueManager.dialogue_ended.connect(restart_timer)
	golb.lose_guy.connect(guy_go)
	redraw_guys()
	if get_tree().get_current_scene().get_name() == "Ocean":
		$animPlay.play("floatin")
	if get_tree().get_current_scene().get_name() == "Main":
		$animPlay.play("floatinland")
	
var guyfallin = false
var pos_temp
var going = false

func _physics_process(delta):
	if golb.gameover:
		golb.paused = true
		stats.cam.position = stats.cam.position.lerp(Vector2(576, 960), 3 * delta)
		if !stats.cam.position.is_equal_approx(Vector2(576,960)):
			get_tree().change_scene_to_file("res://scenes/gameover.tscn")
		stats.hide()
		
	if (get_tree().get_current_scene().get_name() == "Ocean") && golb.health > 0 && !going && !golb.paused:
		golb.health -= golb.drain * delta
		$Timer.set_paused(false)
		$actionTimer.set_paused(false)
	if (golb.max_health - golb.health >= golb.thres):
		guy_go()
	if guyfallin && get_node("animPlay/RigidBody2D" + str(golb.guyArr.size() + 1)).position.y >= 800:
		stats.apply_shake()
		get_node("animPlay/RigidBody2D" + str(golb.guyArr.size() + 1) + "/john" + str(golb.guyArr.size() + 1)).hide()
		get_node("animPlay/RigidBody2D" + str(golb.guyArr.size() + 1)).set_freeze_enabled(true)
		get_node("animPlay/RigidBody2D" + str(golb.guyArr.size() + 1)).position = pos_temp
		redraw_guys()
		guyfallin = false
		$animPlay.play()
	if going:
		$actionTimer.set_paused(true)
		stats.cam.position = stats.cam.position.lerp(Vector2(2000, 320), 3 * delta)
		if stats.cam.position.distance_to(Vector2(2000, 320)) < 10.0:
			stats.cam.position = Vector2(576, 320)
			going = false
			get_tree().change_scene_to_file("res://scenes/island.tscn")

func redraw_guys():
	if golb.guyArr.size() <= 20:
		for i in range(1, golb.guyArr.size() + 1):
			get_node("animPlay/RigidBody2D" + str(i) + "/john" + str(i)).material.set_shader_parameter("output_palette_array", golb.guyArr[i - 1].color)
			get_node("animPlay/RigidBody2D" + str(i) + "/john" + str(i)).show()

func _on_timer_timeout():
	golb.level += 1
	for guy in golb.guyArr:
		if guy.mods.has('bad influence'):
			golb.drain += 0.1 * golb.level
		if guy.mods.has('good influence'):
			golb.drain -= 0.1 * golb.level
		if guy.mods.has('role model'):
			golb.health_per_guy += .1 * golb.level
		if guy.mods.has('meanie'):
			golb.health_per_guy -= .1 * golb.level
	going = true

func _on_action_timer_timeout():
	golb.paused = true
	$Timer.set_paused(true)
	DialogueManager.show_dialogue_balloon(load("res://dialogue/testoid.dialogue"), logs[randi_range(0, logs.size() - 1)])

func restart_timer(resource):
	$actionTimer.wait_time = randi_range(6, 11)
	$actionTimer.start()

func guy_go():
	$animPlay.pause()
	if golb.guyArr.size() == 1:
		$actionTimer.set_paused(true)
		golb.gameover = true
	else:
		pos_temp = get_node("animPlay/RigidBody2D" + str(golb.guyArr.size())).position
		get_node("animPlay/RigidBody2D" + str(golb.guyArr.size())).set_freeze_enabled(false)
		get_node("animPlay/RigidBody2D" + str(golb.guyArr.size())).apply_impulse(Vector2(randf_range(-400, 400), -randf_range(400, 700)), Vector2.ZERO)
		golb.guyArr.pop_back()
		stats.update_health()
		guyfallin = true

func _on_guy_2_guy_added(newGuy):
	stats.apply_shake()
	redraw_guys()

func _on_guy_1_guy_added(newGuy):
	stats.apply_shake()
	redraw_guys()


func _on_anim_play_animation_finished(anim_name):
	if anim_name == "floatin":
		$animPlay.play("wave")
	if anim_name == "floatinland":
		$animPlay.play("waveland")
