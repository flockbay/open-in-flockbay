@tool
extends EditorPlugin

## Adds Project > Tools > Open this project in Flockbay.
##
## Flockbay is a free AI game maker built on the official Godot engine. This
## menu item hands the open project's folder to the Flockbay app, which adds
## the project and opens it, so Flockbay's AI (or your own Claude or ChatGPT)
## can build and play-test the same game. Nothing in the project changes until
## Flockbay asks.

const MENU_ITEM := "Open this project in Flockbay"
const APP_PATH_SETTING := "flockbay/app_path"
const DOWNLOAD_URL := "https://flockbay.com/get/"
const MAC_EXECUTABLE := "Contents/MacOS/flockbay-desktop"


func _enter_tree() -> void:
	var settings := EditorInterface.get_editor_settings()
	if not settings.has_setting(APP_PATH_SETTING):
		settings.set_setting(APP_PATH_SETTING, "")
	settings.add_property_info({
		"name": APP_PATH_SETTING,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_GLOBAL_FILE,
	})
	add_tool_menu_item(MENU_ITEM, _open_in_flockbay)


func _exit_tree() -> void:
	remove_tool_menu_item(MENU_ITEM)


func _open_in_flockbay() -> void:
	var app := _find_app()
	if app.is_empty():
		_offer_download()
		return
	var project := ProjectSettings.globalize_path("res://").trim_suffix("/")
	var pid := OS.create_process(app, PackedStringArray(["--open-game", project]))
	if pid == -1:
		push_error("Flockbay: could not start %s" % app)
	else:
		print("Flockbay: opening %s" % project)


## The Flockbay app: the path set in Editor Settings > Flockbay > App Path, or
## where its installer puts it. On macOS a path to Flockbay.app resolves to the
## executable inside the bundle.
func _find_app() -> String:
	var configured := str(EditorInterface.get_editor_settings().get_setting(APP_PATH_SETTING))
	if configured.ends_with(".app") or configured.ends_with(".app/"):
		configured = configured.path_join(MAC_EXECUTABLE)
	if not configured.is_empty() and FileAccess.file_exists(configured):
		return configured
	var candidates := PackedStringArray()
	match OS.get_name():
		"Windows":
			candidates.append(OS.get_environment("LOCALAPPDATA").path_join("Flockbay/flockbay-desktop.exe"))
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			var home := OS.get_environment("HOME")
			for dir in [home.path_join("Applications"), home.path_join(".local/bin"), home.path_join("Downloads"), home]:
				var found := _first_appimage(dir)
				if not found.is_empty():
					candidates.append(found)
		"macOS":
			for dir in ["/Applications", OS.get_environment("HOME").path_join("Applications")]:
				candidates.append(dir.path_join("Flockbay.app").path_join(MAC_EXECUTABLE))
	for candidate in candidates:
		if FileAccess.file_exists(candidate):
			return candidate
	return ""


func _first_appimage(dir: String) -> String:
	var access := DirAccess.open(dir)
	if access == null:
		return ""
	for file_name in access.get_files():
		var lower := file_name.to_lower()
		if lower.begins_with("flockbay") and lower.ends_with(".appimage"):
			return dir.path_join(file_name)
	return ""


func _offer_download() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "Flockbay is not installed"
	dialog.dialog_text = "Flockbay is a free AI game maker built on Godot, for Windows, macOS and Linux.\nInstall it, then choose this menu item again.\n\nIf it is installed somewhere else, set Editor Settings > Flockbay > App Path."
	dialog.ok_button_text = "Download Flockbay"
	dialog.confirmed.connect(func() -> void: OS.shell_open(DOWNLOAD_URL))
	dialog.visibility_changed.connect(func() -> void:
		if not dialog.visible:
			dialog.queue_free()
	)
	EditorInterface.get_base_control().add_child(dialog)
	dialog.popup_centered()
