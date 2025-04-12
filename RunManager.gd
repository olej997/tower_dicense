extends Node

# 📌 Liczba poziomów w runie (Tier I → Tier V)
const MAX_TIERS = 5

# 📌 Aktualny tier (numer poziomu)
var current_tier = 1

# 📌 Lista wybranych map
var selected_maps = []

# 📌 Przechowuje ulepszenia wieżyczek (skille + przedmioty)
var turret_upgrades = {}

# 📌 Przechowuje XP wieżyczek
var turret_xp = {}

# 📌 Informacje o bohaterze
var hero_data = {
	"selected_hero": null,  # Wybór bohatera na początku runu
	"level": 1,
	"max_turrets": 5,  # Ilość możliwych do postawienia wieżyczek
	"skills": []  # Skille zdobyte podczas runu
}

# 📌 Dane map dla każdego tieru
var tier_maps = {}

func _ready():
	add_to_group("run_manager")  # 📌 Dodanie RunManager do grupy
	load_map_data()

# 📌 Start nowego runa
func start_new_run(selected_hero):
	current_tier = 1
	selected_maps.clear()
	turret_upgrades.clear()
	turret_xp.clear()
	
	hero_data["selected_hero"] = selected_hero
	hero_data["level"] = 1
	hero_data["max_turrets"] = 5
	hero_data["skills"].clear()
	
	# Przejdź do wyboru pierwszej mapy
	get_tree().change_scene_to_file("res://Scenes/MapSelection.tscn")

# 📌 Wczytanie map z pliku JSON
func load_map_data():
	var file = FileAccess.open("res://DataWaves/MapData.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var parsed_data = JSON.parse_string(content)
		if parsed_data is Dictionary and parsed_data.has("maps"):
			# Grupujemy mapy według tierów
			tier_maps.clear()
			for map_data in parsed_data["maps"]:
				var tier = str(int(map_data["tier"]))  # Konwertujemy na int i z powrotem na string
				if not tier_maps.has(tier):
					tier_maps[tier] = []
				tier_maps[tier].append(map_data)
			print("📌 Wczytano mapy dla tierów:", tier_maps.keys())
		else:
			print("❌ Błąd: Nieprawidłowy format JSON")
	else:
		print("❌ Błąd: Nie można wczytać pliku JSON")

# 📌 Pobranie map dla aktualnego tieru
func get_current_tier_maps():
	var tier_str = str(current_tier)
	if tier_maps.has(tier_str):
		return tier_maps[tier_str]
	return []

# 📌 Ustawienie wybranej mapy
func set_selected_map(map_id):
	print("📌 Wybrano mapę:", map_id, "dla tieru:", current_tier)
	selected_maps.append(map_id)
	print("📌 Historia wybranych map:", selected_maps)
	
	# Załaduj i zmień scenę
	var next_scene = load("res://Scenes/Main.tscn")
	if next_scene:
		print("✅ Scena Main.tscn załadowana")
		var result = get_tree().change_scene_to_packed(next_scene)
		if result == OK:
			print("✅ Zmiana sceny powiodła się")
		else:
			print("❌ Błąd podczas zmiany sceny:", result)
	else:
		print("❌ Nie można załadować sceny Main.tscn")

# 📌 Przejście do kolejnego tieru
func advance_tier():
	if current_tier < MAX_TIERS:
		current_tier += 1
		print("📢 Przechodzimy do tieru:", current_tier)
		
		# Załaduj i zmień scenę
		var next_scene = load("res://Scenes/MapSelection.tscn")
		if next_scene:
			print("✅ Scena MapSelection.tscn załadowana")
			call_deferred("_do_change_scene", next_scene)
		else:
			print("❌ Nie można załadować sceny MapSelection.tscn")
	else:
		print("🎉 Run zakończony! Gratulacje!")
		finish_run()

func _do_change_scene(packed_scene):
	print("🔄 Wykonuję zmianę sceny...")
	var tree = get_tree()
	if tree:
		var result = tree.change_scene_to_packed(packed_scene)
		if result == OK:
			print("✅ Zmiana sceny powiodła się")
		else:
			print("❌ Błąd podczas zmiany sceny:", result)
	else:
		print("❌ Nie można uzyskać dostępu do SceneTree podczas zmiany sceny!")

# 📌 Zakończenie runu
func finish_run():
	print("🎉 Podsumowanie runu:")
	print("- Przebyte mapy:", selected_maps)
	print("- Poziom bohatera:", hero_data["level"])
	print("- Zdobyte skille:", hero_data["skills"])
	get_tree().change_scene_to_file("res://Scenes/VictoryScreen.tscn")

# 📌 Aktualizacja ulepszeń wieżyczek
func upgrade_turret(turret_id, upgrade_type, value):
	if not turret_id in turret_upgrades:
		turret_upgrades[turret_id] = {}
	turret_upgrades[turret_id][upgrade_type] = value

# 📌 Aktualizacja XP wieżyczek
func add_turret_xp(turret_id, xp):
	if not turret_id in turret_xp:
		turret_xp[turret_id] = 0
	turret_xp[turret_id] += xp

# 📌 Zdobywanie skilli bohatera
func add_hero_skill(skill):
	hero_data["skills"].append(skill)

# 📌 Powiększanie limitu wieżyczek bohatera
func increase_max_turrets(amount):
	hero_data["max_turrets"] += amount
