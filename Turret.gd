extends StaticBody2D  

# 🏰 Podstawowe parametry wieżyczki
@export var bullet_scene: PackedScene  
@export var fire_rate: float = 0.5  
@export var range_radius: float = 300.0  
@export var damage: int = 1  
@export var crit_chance: float = 0.1


@onready var detection_area = $DetectionArea  
@onready var range_indicator = $RangeIndicator  
@onready var turret_sprite = $TurretSprite  # Nowa referencja do Sprite2D

var is_upgraded: bool = false  # Czy wieżyczka została ulepszona?
var turret_group: String = "default"  # Domyślna grupa
# 📌 Tekstury ulepszonych wieżyczek
var textures = {
	"red": preload("res://assets/Turret_czerwony.png"),
	"green": preload("res://assets/turret_zielony.png"),
	"yellow": preload("res://assets/turret_zolty.png"),
	"blue": preload("res://assets/turret_niebieski.png")
}
# ⚙️ Stan wieżyczki
var target: Node2D = null  # Aktualny cel (wróg w zasięgu)
var can_shoot = true  # Czy może strzelać (kontroluje cooldown)
var is_paused: bool = false  # Czy gra jest zapauzowana
var is_selected: bool = false  # Czy wieżyczka jest aktualnie wybrana przez gracza?
var turret_id: int = 0
var turret_name: String = ""
var stats_ui  # 📌 Przechowujemy referencję do UI

# 🔄 Inicjalizacja wieżyczki
func _ready():
	add_to_group("turrets")
	stats_ui = get_tree().get_first_node_in_group("stats_ui")  
	turret_id = get_tree().get_nodes_in_group("turrets").size() + 1
	turret_name = "Turret" + str(turret_id)
	$RangeIndicator.visible = false  
	update_range()  # Aktualizujemy wszystko od razu po starcie

func update_range():
	# Pobieramy rzeczywisty rozmiar tekstury RangeIndicator
	var base_size = range_indicator.texture.get_size().x  # Zakładamy, że tekstura jest kwadratowa
	# Jeśli tekstura istnieje, poprawnie skalujemy
	if base_size > 0:
		range_indicator.scale = Vector2(range_radius * 2 / base_size, range_radius * 2 / base_size)

	# Aktualizujemy DetectionArea
	if detection_area and detection_area.has_method("update_range"):
		detection_area.update_range(range_radius)
# Umożliwia DetectionArea pobranie rzeczywistego zasięgu
func get_range_radius():
	return range_radius
func upgrade(color: String):
	if is_upgraded:
		return 
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager and game_manager.score >= game_manager.upgrade_cost:
		game_manager.score -= game_manager.upgrade_cost  # Odejmujemy punkty
		game_manager.update_score_label()
		match color:
			"red":
				damage += 1
				turret_group = "red_turrets"
			"green":
				fire_rate = max(0.1, fire_rate - 0.3)
				turret_group = "green_turrets"
			"yellow":
				crit_chance += 0.2
				turret_group = "yellow_turrets"
			"blue":
				range_radius *= 1.2
				update_range()
				turret_group = "blue_turrets"
			# 🖼️ Zmiana tekstury na nową
		if textures.has(color):
			turret_sprite.texture = textures[color]
		# 📌 Dodajemy wieżyczkę do odpowiedniej grupy
		add_to_group(turret_group)
		is_upgraded = true  # Blokujemy kolejne ulepszenia

		#print("🔧 Wieżyczka", turret_name, "ulepszona:", stat)
# 🎯 Obsługa kliknięcia na wieżyczkę
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var clicked_turret = false  # Flaga, czy kliknięto na wieżyczkę
		# Sprawdzamy, czy kliknięto na którąś z wieżyczek
		var turrets = get_tree().get_nodes_in_group("turrets")
		for turret in turrets:
			var turret_shape = turret.get_node("CollisionShape2D").shape  # Pobieramy CollisionShape2D każdej wieżyczki
			if turret_shape is RectangleShape2D:
				var rect = Rect2(turret.get_node("CollisionShape2D").to_global(Vector2()) - turret_shape.extents, turret_shape.extents * 2)
				if rect.has_point(mouse_pos):
					turret.toggle_selection()
					clicked_turret = true  # Kliknięto na wieżyczkę
					break  # Kończymy pętlę, bo znaleźliśmy klikniętą wieżyczkę
		# ❌ Jeśli kliknięto w puste miejsce – odznaczamy wszystkie wieżyczki i chowamy UI
		if not clicked_turret:
			deselect_all_turrets()

func deselect_all_turrets():
	var turrets = get_tree().get_nodes_in_group("turrets")
	for turret in turrets:
		turret.is_selected = false
		$RangeIndicator.visible = false  # Ukrywamy zasięg
	# 📌 Pobieramy UI i ukrywamy tylko, jeśli wcześniej coś było zaznaczone
	if stats_ui:
		#print("🔴 Ukrywamy UI po kliknięciu poza wieżyczkę!")
		stats_ui.hide_stats()
func toggle_selection():
	# 📌 Najpierw odznaczamy wszystkie inne wieżyczki
	deselect_all_turrets()
	is_selected = !is_selected  # ON/OFF przełącznik wyboru
	$RangeIndicator.visible = is_selected  # Pokaż lub ukryj wskaźnik zasięgu
	# 📌 Pobierz UI i aktualizuj dla tej wieżyczki
	if stats_ui:
		if is_selected:
			stats_ui.update_stats(self)  # Aktualizujemy panel UI
		else:
			stats_ui.hide_stats()  # Ukrywamy UI, jeśli odznaczono wieżyczkę
	#print("🎯 Zasięg aktywowany:", is_selected)
# 🔄 Główna pętla wieżyczki
func _process(_delta):
	if is_paused:
		return  # 🛑 Pauza - wieżyczka nic nie robi
	detection_area.update_target()  # Aktualizacja celu
	target = detection_area.current_target  # 🔄 Pobieramy cel na bieżąco
	if target and can_shoot:
		shoot()  # 🚀 Strzał do celu
# 🔫 Funkcja strzelania
func shoot():
	if not can_shoot:
		return  # Jeśli wieżyczka jest na cooldownie, kończymy funkcję

	# ❌ Jeśli nadal nie mamy celu, kończymy funkcję
	if target == null or not is_instance_valid(target):
		return 
	can_shoot = false  # 🔒 Blokujemy możliwość strzału, dopóki cooldown się nie skończy
		
	# Tworzymy nowy pocisk i ustawiamy jego pozycję oraz kierunek lotu
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	
	if is_instance_valid(target):
		bullet.direction = (target.global_position - global_position).normalized()
		bullet.target = target  # 📌 Przypisujemy cel do pocisku!

		var final_damage = damage
		
		# 🔥 Obliczamy obrażenia krytyczne
		if randf() < crit_chance:  
			final_damage *= 2  
			print("💥 Krytyczny strzał!")
		
		bullet.damage = final_damage  # Przekazujemy obrażenia do pocisku
		get_parent().add_child(bullet)  # Dodajemy pocisk do sceny
	# ⏳ Oczekiwanie na koniec cooldownu (czas między strzałami)
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true  # Wieżyczka znów może strzelać
func toggle_pause():
	is_paused = !is_paused  # Przełącza stan pauzy
	
	
var targeting_mode = 2  # Najdalej na ścieżce

func cycle_targeting_mode():
	targeting_mode += 1
	if targeting_mode > 3:
		targeting_mode = 1  # Reset cyklu
	print("🎯 Nowy tryb targetowania:", get_targeting_mode_name())
	detection_area.set_targeting_mode(targeting_mode)

func get_targeting_mode_name():
	match targeting_mode:
		1: return "Największe HP"
		2: return "Najdalej na ścieżce"
		3: return "Najmniejsze HP"
	return "Nieznany"
