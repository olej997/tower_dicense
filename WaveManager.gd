extends Node


@export var enemy_path: Path2D  # Ścieżka, po której poruszają się wrogowie

@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer  # Timer spawnu


var current_wave = 0  # Indeks aktualnej fali
var enemies_spawned: int = 0  
var enemies_remaining = 0  # Liczba żywych wrogów
var is_paused: bool = false  


var map_data = {}  # Dane mapy, którą wybrał gracz


func _ready():
	var run_manager = get_tree().get_first_node_in_group("run_manager")
	print("📜 Lista wybranych map:", run_manager.selected_maps)
	if run_manager and run_manager.selected_maps.size() > 0:
		set_map_data(run_manager.selected_maps[-1])  # Pobieramy ostatnią wybraną mapę
	else:
		print("⚠️ Brak wybranych map w RunManager!")

	await get_tree().process_frame  
	notify_game_manager()  
# 📌 Ustawienie przeciwników dla wybranej mapy

func set_map_data(selected_map_id):
	# Wczytaj plik JSON, aby pobrać pełne dane mapy
	var file = FileAccess.open("res://DataWaves/MapData.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var parsed_data = JSON.parse_string(content)
		
		if parsed_data is Dictionary and parsed_data.has("maps"):
			# Szukamy mapy o podanym `map_id`
			for map_entry in parsed_data["maps"]:
				if map_entry["map_id"] == selected_map_id:
					map_data = map_entry  # Przypisujemy pełne dane mapy
					start_wave()  # Automatycznie rozpoczynamy falę
					return  # Zatrzymujemy dalsze przeszukiwanie
					
		print("❌ Nie znaleziono mapy o ID:", selected_map_id)
	else:
		print("❌ Błąd: Nie udało się otworzyć MapData.json")

		
		
func notify_game_manager():
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.set_total_enemies(enemies_remaining)
		print("📢 WaveManager: Wysłano enemies_remaining =", enemies_remaining, "do GameManager")  # ✅ Debugowanie
		
# 📌 Rozpoczyna falę przeciwników zgodnie z konfiguracją mapy
func start_wave():
	if map_data.is_empty():
		print("❌ Brak danych mapy – nie można rozpocząć fali!")
		return  
	# 🔄 Resetowanie liczników fali
	enemies_spawned = 0
	enemies_remaining = 0

	# Pobieramy przeciwników dla mapy

	for enemy in map_data["enemies"]:
		enemies_remaining += enemy["count"]  # Zliczamy przeciwników

	print("🌊 Start fali na mapie:", map_data["name"], "| Łączna liczba wrogów:", enemies_remaining)



	# Rozpoczynamy spawn przeciwników
	start_spawning_enemies()

# 📌 Spawning przeciwników w odstępach czasu
func start_spawning_enemies():
	if map_data.is_empty():
		return  
	var enemy_list = map_data["enemies"]
	var enemy_index = 0
	for enemy_data in enemy_list:
		for i in range(enemy_data["count"]):
			await get_tree().create_timer(enemy_index).timeout  # Dodajemy delikatny odstęp między spawnami
			spawn_enemy(enemy_data["type"])
			enemy_index += 1  # Każdy kolejny wróg spawnowany z odstępem
# 📌 Spawn pojedynczego przeciwnika
func spawn_enemy(enemy_type: String):
	if is_paused:
		return  
	var enemy_follower = load("res://Scenes/Enemy_Follower.tscn").instantiate()
	enemy_follower.progress = 0  
	enemy_follower.enemy_type = enemy_type  
	enemy_path.add_child(enemy_follower)  
	# 📌 Aktualizacja liczby wrogów po spawnie
	enemies_spawned += 1  
# ⏸️ Pauzowanie fal
func toggle_pause():
	is_paused = !is_paused
	if is_paused:
		enemy_spawn_timer.stop()
	else:
		enemy_spawn_timer.start()
