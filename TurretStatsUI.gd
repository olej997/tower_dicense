extends Control

@onready var targeting_mode_label = $VBoxContainer/TargetingModeLabel
@onready var targeting_mode_button = $VBoxContainer/ChangeTargetingModeButton

@onready var turret_name = $TurretStatsPanel/VBoxContainer/TurretName
@onready var damage_label = $TurretStatsPanel/VBoxContainer/DamageLabel
@onready var fire_rate_label = $TurretStatsPanel/VBoxContainer/FireRateLabel
@onready var range_label = $TurretStatsPanel/VBoxContainer/RangeLabel
@onready var crit_chance_label = $TurretStatsPanel/VBoxContainer/CritChanceLabel
@onready var turret_group_label = $TurretStatsPanel/VBoxContainer/TurretGroupLabel  # Nowy label


@onready var red_button = $TurretStatsPanel/VBoxContainer/HBoxContainer/UpgradeRed
@onready var green_button = $TurretStatsPanel/VBoxContainer/HBoxContainer/UpgradeGreen
@onready var yellow_button = $TurretStatsPanel/VBoxContainer/HBoxContainer/UpgradeYellow
@onready var blue_button = $TurretStatsPanel/VBoxContainer/HBoxContainer/UpgradeBlue
@onready var game_manager = get_tree().get_first_node_in_group("game_manager")
var selected_turret: StaticBody2D = null

func _ready():
	targeting_mode_button.pressed.connect(_on_targeting_mode_button_pressed)
	hide_stats()
	red_button.pressed.connect(func(): upgrade_turret("red"))
	green_button.pressed.connect(func(): upgrade_turret("green"))
	yellow_button.pressed.connect(func(): upgrade_turret("yellow"))
	blue_button.pressed.connect(func(): upgrade_turret("blue"))
func update_stats(turret):
	#print("📌 Aktualizacja statystyk dla:", turret.turret_name)
	#print("📌 Wywołano update_stats() dla:", turret)
	# Pobiera statystyki i aktualizuje UI
	if turret:
		selected_turret = turret
		#print("✅ Wybrano wieżyczkę:", selected_turret.name)
		turret_name.text = "Nazwa: " + str(turret.turret_name)
		targeting_mode_label.text = "Tryb: " + turret.get_targeting_mode_name()
		damage_label.text = "DMG: " + str(turret.damage)
		fire_rate_label.text = "Fire Rate: " + str(turret.fire_rate)
		range_label.text = "Range: " + str(turret.range_radius)
		crit_chance_label.text = "Crit Chance: " + str(turret.crit_chance) + "%"
		turret_group_label.text = "Grupa: " + turret.turret_group  # Nowe wyświetlanie grupy
		# Ukrywamy przyciski, jeśli wieżyczka została już ulepszona
		var show_upgrade = not turret.is_upgraded
		red_button.visible = show_upgrade
		green_button.visible = show_upgrade
		yellow_button.visible = show_upgrade
		blue_button.visible = show_upgrade
		visible = true
		#print("👀 UI ustawione na widoczne!")
	else:
		turret_name.text = "Brak wybranej wieżyczki"
func hide_stats():
	visible = false  # Ukrywa panel statystyk
	selected_turret = null
func upgrade_turret(color: String):
	if not game_manager:
		game_manager = get_tree().get_first_node_in_group("game_manager")  # 🔍 Spróbuj jeszcze raz pobrać GameManager
		if not game_manager:  # Jeśli dalej NULL, to zatrzymaj funkcję
			return

	if game_manager.score < game_manager.min_upgrade_points:
		return
	if selected_turret:
		selected_turret.upgrade(color)
		update_stats(selected_turret)
func _on_targeting_mode_button_pressed():
	if selected_turret:
		selected_turret.cycle_targeting_mode()
		targeting_mode_label.text = "Tryb: " + selected_turret.get_targeting_mode_name()
