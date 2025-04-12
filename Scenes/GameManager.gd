extends Node2D

# 🔢 Zmienne globalne
var score: int = 0  # Aktualny wynik gracza
var enemies_alive: int = 0  # Liczba żywych wrogów

# 📌 UI i elementy gry
@export var score_label: Label  
@export var pause_label: Label  
@export var victory_label: Label  
@export var turret_scene: PackedScene  
@export var upgrade_cost: int = 10  
@export var min_upgrade_points: int = 10 

@onready var enemy_path: Path2D = $EnemyPath  # Ścieżka wrogów
@onready var hero: CharacterBody2D = $Hero  # Bohater
@onready var next_tier_button = $VictoryLabel/NextTierButton

var temp_turret: StaticBody2D = null  # Tymczasowa wieżyczka podążająca za kursorem
var is_placing_turret: bool = false  # Czy gracz jest w trybie stawiania wieżyczki?
var is_paused: bool = false  # Czy gra jest zapauzowana?
var stats_ui  # Interfejs statystyk wieżyczek

# 📌 Inicjalizacja gry
func _ready():
	add_to_group("game_manager")
	next_tier_button.pressed.connect(_on_next_tier_pressed)
	stats_ui = get_tree().get_first_node_in_group("stats_ui")
	
	if victory_label:
		victory_label.visible = false
	if next_tier_button:
		next_tier_button.visible = false
		
	update_score_label()
	DisplayServer.window_set_size(Vector2(1920, 1080))
	set_process_input(true)
	
	if pause_label:
		pause_label.visible = false
		
	if enemy_path and hero:
		var last_point = enemy_path.curve.get_point_position(enemy_path.curve.point_count - 1)
		hero.global_position = enemy_path.global_position + last_point

func show_victory_message():
	if victory_label:
		victory_label.visible = true
		get_tree().paused = true
		# 📌 Pokazujemy przycisk do kolejnej mapy
		next_tier_button.visible = true

func _on_next_tier_pressed():
	print("\n🔄 Przechodzenie do następnego tieru...")
	
	# Najpierw wyłączamy pauzę
	get_tree().paused = false
	
	# Pobieramy run_manager
	var run_manager = get_tree().get_first_node_in_group("run_manager")
	if not run_manager:
		print("❌ Nie znaleziono run_manager!")
		return
		
	print("✅ Znaleziono run_manager")
	print("📊 Aktualny tier przed zmianą:", run_manager.current_tier)
	
	# Zwiększamy tier i pozwalamy RunManager zająć się zmianą sceny
	run_manager.advance_tier()  # Ta funkcja sama zmieni scenę
	print("✅ Przekazano kontrolę do RunManager")

func _unhandled_input(_event):
	if temp_turret:
		temp_turret.global_position = get_global_mouse_position()

func _input(event):
	if event.is_action_pressed("pause_game"):
		toggle_pause()
	if event.is_action_pressed("pause_game_menu"):
		toggle_pause_menu()
	if is_placing_turret and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		place_turret(event.position)

func toggle_pause():
	is_paused = !is_paused
	if pause_label:
		pause_label.visible = is_paused
	# Pauzowanie wrogów, wieżyczek i pocisków
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("toggle_pause"):
			enemy.toggle_pause()
	for turret in get_tree().get_nodes_in_group("turrets"):
		if turret.has_method("toggle_pause"):
			turret.toggle_pause()
	for bullet in get_tree().get_nodes_in_group("bullets"):
		if bullet.has_method("toggle_pause"):
			bullet.toggle_pause()

func toggle_pause_menu():
	if get_tree().paused:
		get_tree().paused = false
		var menu = get_tree().get_nodes_in_group("pause_menu")
		if menu.size() > 0:
			menu[0].queue_free()
	else:
		get_tree().paused = true
		var pause_menu_scene = load("res://Scenes/MainMenu.tscn")
		if pause_menu_scene:
			var pause_menu = pause_menu_scene.instantiate()
			pause_menu.is_pause_menu = true
			add_child(pause_menu)
			pause_menu.add_to_group("pause_menu")

func _on_enemy_died():
	enemies_alive -= 1
	print("💀 Wróg zginął! Pozostało wrogów:", enemies_alive)
	add_score(10)
	if enemies_alive <= 0:
		show_victory_message()

func add_score(points: int):
	score += points
	update_score_label()

func update_score_label():
	if score_label:
		score_label.text = "Hajs: %d" % score

func set_total_enemies(total: int):
	enemies_alive = total
	print("📢 GameManager: Ustawiono enemies_alive na:", enemies_alive)

func _on_button_pressed():
	if temp_turret == null:
		spawn_temp_turret()
		is_placing_turret = true

func place_turret(_target_position: Vector2):
	if temp_turret:
		temp_turret.get_node("RangeIndicator").visible = false
		temp_turret = null
		is_placing_turret = false
	if stats_ui:
		stats_ui.update_stats(temp_turret)

func spawn_temp_turret():
	temp_turret = turret_scene.instantiate()
	add_child(temp_turret)
	temp_turret.get_node("RangeIndicator").visible = true

func on_game_lost():
	if victory_label:
		victory_label.text = "❌ PRZEGRAŁEŚ!"
		victory_label.visible = true
	get_tree().paused = true 