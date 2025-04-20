extends Path2D
var choice = true
var firstNames = [
  'emily', 'liam', 'sophia', 'noah', 'olivia', 'james', 'ava', 'benjamin', 'mia', 'lucas',
  'charlotte', 'henry', 'amelia', 'alexander', 'harper', 'william', 'evelyn', 'michael', 'abigail', 'daniel',
  'ella', 'matthew', 'scarlett', 'sebastian', 'grace', 'jack', 'chloe', 'owen', 'victoria', 'samuel',
  'riley', 'jackson', 'aria', 'levi', 'lily', 'david', 'hannah', 'joseph', 'zoey', 'carter',
  'penelope', 'wyatt', 'layla', 'john', 'nora', 'luke', 'ellie', 'jayden', 'lillian', 'dylan',
  'addison', 'grayson', 'isaac', 'eleanor', 'gabriel', 'stella', 'julian', 'natalie', 'mateo', 'zoe',
  'anthony', 'leah', 'jason', 'hazel', 'lincoln', 'violet', 'joshua', 'aurora', 'christopher', 'savannah',
  'andrew', 'brooklyn', 'theodore', 'bella', 'caleb', 'claire', 'ryan', 'skylar', 'asher', 'lucy',
  'nathan', 'paisley', 'thomas', 'everly', 'leo', 'anna', 'isaiah', 'caroline', 'charles', 'nova',
  'josiah', 'genesis', 'hudson', 'emilia', 'christian', 'kennedy', 'hunter', 'samantha', 'connor', 'maya'
];

var mods = [
	'people pleaser', 'loyal friend', 'argumentative', 'inspiration', 'smelly', 'bad influence', 'good influence', 'flaker', 'role model', 'meanie'
];

signal guy_added

var dude
var modsOn = []
var guyAdded = false
var fallguy = true

func _ready():
	fallguy = true
	$PathFollow2D/guyspr.play("stand")
	choice = true
	guyAdded = false
	golb.chosen = false;
	randomize()
	var numMods = 0
	if (golb.level < 3):
		numMods = randi_range(0, golb.level)
	else:
		numMods = randi_range(0, 3)
	$PathFollow2D/ColorRect/Label.text = firstNames[randi() % firstNames.size()]
	$PathFollow2D/guyspr.material.set_shader_parameter("output_palette_array", PackedColorArray([Color(randf(), randf(), randf(), 1)]));
	for i in numMods:
		get_node("PathFollow2D/ColorRect/lab" + str(i+1)).text = mods[randi() % mods.size()]
		while modsOn.has(get_node("PathFollow2D/ColorRect/lab" + str(i+1)).text):
			get_node("PathFollow2D/ColorRect/lab" + str(i+1)).text = mods[randi() % mods.size()]
		get_node("PathFollow2D/ColorRect/lab" + str(i+1)).show()
		modsOn.append(get_node("PathFollow2D/ColorRect/lab" + str(i+1)).text)
	for i in modsOn.size():
		if modsOn[i] == ('flaker'):
			get_node("PathFollow2D/ColorRect/Sprite2D" + str(i+1) + "/det").text = "worth half"
		if modsOn[i] == ('people pleaser'):
			get_node("PathFollow2D/ColorRect/Sprite2D" + str(i+1) + "/det").text = "less strain"
		if modsOn[i] == ('loyal friend'):
			get_node("PathFollow2D/ColorRect/Sprite2D" + str(i+1) + "/det").text = "worth double"
		if modsOn[i] == ('argumentative'):
			get_node("PathFollow2D/ColorRect/Sprite2D" + str(i+1) + "/det").text = "more strain"
		if modsOn[i] == ('inspiration'):
			get_node("PathFollow2D/ColorRect/Sprite2D" + str(i+1) + "/det").text = "value more"
		if modsOn[i] == ('smelly'):
			get_node("PathFollow2D/ColorRect/Sprite2D" + str(i+1) + "/det").text = "value less"
		if modsOn[i] == ('bad influence'):
			get_node("PathFollow2D/ColorRect/Sprite2D" + str(i+1) + "/det").text = "more strain/lvl"
		if modsOn[i] == ('good influence'):
			get_node("PathFollow2D/ColorRect/Sprite2D" + str(i+1) + "/det").text = "less strain/lvl"
		if modsOn[i] == ('role model'):
			get_node("PathFollow2D/ColorRect/Sprite2D" + str(i+1) + "/det").text = "more value/lvl"
		if modsOn[i] == ('meanie'):
			get_node("PathFollow2D/ColorRect/Sprite2D" + str(i+1) + "/det").text = "less value/lvl"

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event.is_action_pressed("left_click") && !golb.chosen:
		golb.chosen = true
		choice = false;
		var newGuy = golb.Guy.new()
		newGuy.mods = modsOn
		newGuy.name = $PathFollow2D/ColorRect/Label.text
		newGuy.worth = 1
		newGuy.color = $PathFollow2D/guyspr.material.get_shader_parameter("output_palette_array")
		if newGuy.mods.has('flaker'):
			newGuy.worth *= .5
			golb.thres *= .5
		if newGuy.mods.has('loyal friend'):
			newGuy.worth *= 2
			golb.thres *= 2
		if newGuy.worth == 1:
			golb.thres = golb.health_per_guy
		if newGuy.mods.has('people pleaser'):
			golb.drain -= .3
		if newGuy.mods.has('argumentative'):
			golb.drain += .3
		if newGuy.mods.has('inspiration'):
			golb.health_per_guy += 1
		if newGuy.mods.has('smelly'):
			golb.health_per_guy -= 1
		if newGuy.mods.has('bad influence'):
			golb.drain += .1 * golb.level
		if newGuy.mods.has('good influence'):
			golb.drain -= .1 * golb.level
		if newGuy.mods.has('role model'):
			golb.health_per_guy += .1 * golb.level
		if newGuy.mods.has('meanie'):
			golb.health_per_guy -= .1 * golb.level
		golb.guyArr.append(newGuy)
		dude = newGuy
		stats.update_health()
		$PathFollow2D/ColorRect.hide()
		
func _physics_process(delta):
	if fallguy:
		position.y += delta * 1000
		if position.y >= 323.75 && fallguy:
			stats.apply_shake()
		if position.y >= 323.75:
			fallguy = false
	if !choice:
		$PathFollow2D/guyspr.play("run")
		$PathFollow2D/ColorRect.hide()
		if $PathFollow2D.global_position.x >= 730:
			$PathFollow2D/guyspr.play("jump")
			$PathFollow2D/guyspr.rotate(delta * 20)
			$PathFollow2D.progress_ratio += delta * 1.5
		else:
			$PathFollow2D.progress_ratio += delta * .6
	if $PathFollow2D.progress_ratio == 1:
		if (!guyAdded):
			guy_added.emit(dude)
			guyAdded = true
			$PathFollow2D/guyspr.hide()
		stats.cam.position = stats.cam.position.lerp(Vector2(2000, 320), 3 * delta)
		if stats.cam.position.distance_to(Vector2(2000, 320)) < 10.0:
			stats.cam.position = Vector2(576, 320)
			get_tree().change_scene_to_file("res://scenes/ocean.tscn")


func _on_area_2d_mouse_shape_entered(shape_idx):
	$PathFollow2D/ColorRect.scale = Vector2(2,2)
	$PathFollow2D/ColorRect.position += Vector2(-200,150)
	for i in modsOn.size():
		get_node("PathFollow2D/ColorRect/Sprite2D" + str(i + 1)).show()


func _on_area_2d_mouse_shape_exited(shape_idx):
	$PathFollow2D/ColorRect.scale = Vector2(1.5,1.5)
	$PathFollow2D/ColorRect.position += Vector2(200,-150)
	for i in modsOn.size():
		get_node("PathFollow2D/ColorRect/Sprite2D" + str(i + 1)).hide()
