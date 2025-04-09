extends Control
var map_data = []  # Lista mapek do wyboru (z JSON)
var selected_tier = 1  # Domyślny tier mapek

@onready var map1_info = $VBoxContainer/Map1Container/Map1Info
@onready var map2_info = $VBoxContainer/Map2Container/Map2Info
@onready var map_button_1 = $VBoxContainer/Map1Container/MapButton1
@onready var map_button_2 = $VBoxContainer/Map2Container/MapButton2
@onready var return_button = $VBoxContainer/ReturnButton

func _ready():
	print("🌀 MapSelection załadowana jako:" + str(self))
	load_map_data()
	
	var run_manager = get_tree().get_first_node_in_group("run_manager")
	if run_manager:
		selected_tier = run_manager.current_tier
		print("📢 Wybór mapy dla tieru:", selected_tier)

	display_map_choices()
	
# Najpierw rozłączamy, jeśli już podłączone
	if map_button_1.is_connected("pressed", Callable(self, "_on_map1_pressed")):
		map_button_1.pressed.disconnect(Callable(self, "_on_map1_pressed"))
	map_button_1.pressed.connect(_on_map1_pressed)

	if map_button_2.is_connected("pressed", Callable(self, "_on_map2_pressed")):
		map_button_2.pressed.disconnect(Callable(self, "_on_map2_pressed"))
	map_button_2.pressed.connect(_on_map2_pressed)

	if return_button.is_connected("pressed", Callable(self, "_on_return_pressed")):
		return_button.pressed.disconnect(Callable(self, "_on_return_pressed"))
	return_button.pressed.connect(_on_return_pressed)

	print("✅ Sygnały zostały podłączone ponownie")
	#await get_tree().create_timer(2.0).timeout
	#print("🧪 Testowe kliknięcie...")
	#map_button_1.emit_signal("pressed")

func _on_map1_pressed():
	print("📌 Wybrano mapę: 0")
	select_map(0)

func _on_map2_pressed():
	print("📌 Wybrano mapę: 1")
	select_map(1)
	


func load_map_data():
	print("wczytano json")
	var file = FileAccess.open("res://DataWaves/MapData.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var parsed_data = JSON.parse_string(content)
		if parsed_data is Dictionary and parsed_data.has("maps"):
			# Tworzymy pusty słownik dla tierów
			map_data = {}
			
			# Grupujemy mapy według poziomu trudności (tier)
			for map_entry in parsed_data["maps"]:
				var tier = str(int(map_entry["tier"]))  # Klucz jako string
				if not map_data.has(tier):
					map_data[tier] = []  # Tworzymy listę dla tieru
				map_data[tier].append(map_entry)  # Dodajemy mapę do tieru
		else:
			map_data = {}
		file.close()


# 🎲 Losowanie dwóch map do wyboru dla gracza
func display_map_choices():
	print("📌 selected_tier:", selected_tier, "| Typ:", typeof(selected_tier))
	print("📌 Dostępne tiery w map_data:", map_data.keys())

	if not map_data.has(str(selected_tier)):
		print("❌ Brak map dla tieru:", selected_tier)  # ✅ Debug
		return  # Jeśli nie ma map dla tego tieru, wyjdź

	var tier_maps = map_data[str(selected_tier)]
	tier_maps.shuffle()  # Losujemy kolejność mapek

	# Pobieramy 2 pierwsze losowe mapki
	var map1 = tier_maps[0]
	var map2 = tier_maps[1]
	
	# Wyświetlamy informacje o mapach
	map1_info.text = "🌍 Mapa: " + map1.name + "\n👾 Wrogowie: " + str(map1.enemies) 
	map2_info.text = "🌍 Mapa: " + map2.name + "\n👾 Wrogowie: " + str(map2.enemies) 

	# Przypisujemy ID mapek do przycisków
	map_button_1.set_meta("map_id", map1.map_id)
	map_button_2.set_meta("map_id", map2.map_id)
		# ✅ Debugowanie – sprawdzamy, czy ID się przypisały
		# Debugowanie
	print("✅ map_button_1 przypisano map_id:", map1.map_id)
	print("✅ map_button_2 przypisano map_id:", map2.map_id)

# 🎯 Gracz wybiera mapę → przejście do poziomu
func select_map(map_index):
	print("📌 Wybrano mapę:", map_index)
	var chosen_map_id = get_node("VBoxContainer/Map" + str(map_index + 1) + "Container/MapButton" + str(map_index + 1)).get_meta("map_id")

	# Przechodzimy do poziomu, zapisując ID mapy
	var run_manager = get_tree().get_first_node_in_group("run_manager")
	if run_manager:
		run_manager.set_selected_map(chosen_map_id)
	
	# Ładujemy scenę poziomu
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

# ⏪ Powrót do menu głównego
func _on_return_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
