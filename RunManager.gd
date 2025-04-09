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


func _ready():
	add_to_group("run_manager")  # 📌 Dodanie RunManager do grupy

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

# 📌 Ustawienie wybranej mapy
func set_selected_map(map_id):
	selected_maps.append(map_id)
	# Jeśli to ostatnia mapa → gracz wygrał run
	if current_tier >= MAX_TIERS:
		finish_run()


# 📌 Sprawdzenie, czy run został ukończony
func finish_run():
	print("🎉 Run zakończony! Gratulacje!")
	# Możemy tu dodać podsumowanie, ekran zwycięstwa itp.
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
var available_maps = []  # Lista dostępnych map

# 📌 Wczytanie map z pliku JSON
func load_map_data():
	var file = FileAccess.open("res://DataMaps/MapData.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		available_maps = JSON.parse_string(content).maps
		print("📜 Wczytano mapy:", available_maps)
	else:
		print("❌ Błąd: Nie można wczytać MapData.json")
# 📌 Przejście do kolejnego tieru
func advance_tier():
	if current_tier < MAX_TIERS:
		current_tier += 1
		print("📢 Przechodzimy do tieru:", current_tier)
	else:
		print("🎉 Run zakończony! Gratulacje!")
		finish_run()  # Jeśli to był ostatni tier, kończymy run
