extends Node
@export var health = 30;
@export var drain = 1;
@export var health_per_guy = 10;
@export var chosen = false;
@export var level = 1
@export var guyArr = []
@export var max_health = 30;
@export var paused = false
@export var thres = health_per_guy
@export var gameover = false

signal lose_guy

class Guy:
	var mods = []
	var name = ""
	var color
	var worth = 1
