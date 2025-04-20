extends CanvasLayer
@export var cam = null

func _ready():
	for i in range(1,4):
		var newGuy = golb.Guy.new()
		newGuy.mods = []
		newGuy.name = "john" + str(i)
		newGuy.color = PackedColorArray([Color(randf(), randf(), randf(), 1)])
		golb.guyArr.append(newGuy)
		cam = $Camera2D
	update_health()
	

func _physics_process(delta):
	$ProgressBar.max_value = golb.max_health
	$ProgressBar.value = golb.health
	$Label2/guyval.text = str(golb.health_per_guy)
	$Label/drspeed.text = str(golb.drain)
	$health.text = "%.0f" % golb.health
	if golb.drain <= .1:
		golb.drain = .1
	if golb.health_per_guy <= 1:
		golb.health_per_guy = 1

@export var randomStrength: float = 20.0
@export var shakeFade: float = 5.0

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0

func apply_shake():
	shake_strength = randomStrength

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shakeFade * delta)
		$Camera2D.offset = randomOffset()

func randomOffset() -> Vector2:
	return Vector2(
		rng.randf_range(-shake_strength, shake_strength),
		rng.randf_range(-shake_strength, shake_strength)
	)

func update_health():
	var children = $ProgressBar.get_children()
	for child in children:
		child.free()
	var heal = 0
	var totworth = 0
	for guy in golb.guyArr:
		heal += guy.worth * golb.health_per_guy
		totworth += guy.worth
	golb.max_health = heal
	golb.health = heal
	golb.thres = golb.health_per_guy * golb.guyArr[golb.guyArr.size() - 1].worth
	var i = 0
	var f = 0
	while f < golb.guyArr.size():
		var sprite = Sprite2D.new()
		sprite.texture = load("res://sprites/face.png")
		var shader_resource = load("res://addons/eye_dropper/eye_dropper.gdshader")
		var shader_material = ShaderMaterial.new()
		shader_material.shader = shader_resource
		var mat = shader_material.duplicate()
		sprite.material = mat
		sprite.material.set_shader_parameter("palette_array_size", 1);
		sprite.material.set_shader_parameter("input_palette_array", PackedColorArray([Color8(133, 133, 133, 255)]));
		sprite.material.set_shader_parameter("output_palette_array", golb.guyArr[f].color)
		sprite.scale = Vector2(.35, .35)
		sprite.position = Vector2(($ProgressBar.size.x) * (i / float(totworth)) - 25, 25)
		$ProgressBar.add_child(sprite)
		i += golb.guyArr[f].worth
		f += 1
