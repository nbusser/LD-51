@tool
extends Control
class_name Finder

const MAX_RECENT_FILES := 5
const DELAY_BETWEEN_REPAINTS := 50  # ms

@onready var line_edit: LineEdit = $Window/VBoxContainer/HBoxContainer/LineEdit
@onready var file_item_list = $Window/VBoxContainer/FileItemList
@onready var texture_rect = $Window/VBoxContainer/HBoxContainer/MarginContainer/TextureRect
@onready var reload_button: Button = $Window/VBoxContainer/HBoxContainer/MarginContainer2/ReloadTextureRect
@onready var window_dialog = $Window
@onready var relevance_sorter: RelevanceSorter = RelevanceSorter.new()
@onready var tool_button = $Button

var _editor_interface: EditorInterface

var _current_search = ""
var _last_search = null
var _last_repaint := 0

var _files := []
var _recent_files := PackedStringArray()
var _is_last_control_focused = false

signal clicked(file)
signal clicked_property(file, property)
signal rebuild


func popup_centered():
	window_dialog.popup_centered()


func hide():
	window_dialog.hide()


func set_editor_interface(editor_interface: EditorInterface):
	_editor_interface = editor_interface


func set_files(files: Array) -> void:
	_files = files


func prepare():
	file_item_list.connect("clicked", Callable(self, "_on_clicked"))
	file_item_list.connect("clicked_property", Callable(self, "_on_clicked_property"))
	reload_button.connect("pressed", Callable(self, "_on_reload_button_pressed"))
	window_dialog.connect("about_to_popup", Callable(self, "_about_to_popup"))
	window_dialog.connect("popup_hide", Callable(self, "_popup_hide"))
	line_edit.connect("text_changed", Callable(self, "_on_finder_text_changed"))
	tool_button.connect("pressed", Callable(self, "popup_centered"))

	tool_button.icon = _editor_interface.get_base_control().get_icon("Search", "EditorIcons")


func finish():
	file_item_list.clear()
	_files = []


func _process(_delta):
	if (
		OS.get_system_time_msecs() - _last_repaint < DELAY_BETWEEN_REPAINTS
		or _last_search == _current_search
	):
		return

	_last_search = _current_search
	var matching_files: Array = _filter_files()
	file_item_list.clear()

	if matching_files.size() == 0:
		return

	matching_files.sort_custom(Callable(relevance_sorter, "sort"))
	for item in matching_files:
		item.sort_properties(relevance_sorter)
		file_item_list.add_item(item)


func _unhandled_key_input(event: InputEvent):
	if window_dialog.visible && event.keycode == KEY_F && Input.is_key_pressed(KEY_CTRL):
		line_edit.call_deferred("grab_focus")


func _filter_files() -> Array:
	var matching_files := []

	if not _current_search.is_empty():
		for file in _files:
			file.clear_matching_properties()

			if file.parsing_result() != null:
				for property in file.parsing_result().enumerate():
					property.score = 1.0

			if FuzzyMatching.classify(file, _current_search):
				var whole_path = file.whole_path()
				for recent_file in _recent_files:
					if recent_file == whole_path:
						file.set_is_recent(true)
						break

				matching_files.append(file)

	return matching_files


func _on_finder_text_changed(new_text):
	_last_repaint = OS.get_system_time_msecs()

	_current_search = new_text
	if _current_search.length() == 0:
		file_item_list.clear()


func _about_to_popup():
	file_item_list.set_editor_interface(_editor_interface)
	file_item_list.set_previous_focus(line_edit)
	file_item_list.set_active(true)
	line_edit.call_deferred("grab_focus")
	line_edit.select_all()
	texture_rect.texture = _editor_interface.get_base_control().get_icon("Search", "EditorIcons")
	reload_button.icon = _editor_interface.get_base_control().get_icon("Reload", "EditorIcons")


func _popup_hide():
	file_item_list.set_active(false)


func _on_clicked(file):
	if window_dialog.visible:
		emit_signal("clicked", file)
		file.set_is_recent(true)

		_recent_files.append(file.whole_path())

		if _recent_files.size() > MAX_RECENT_FILES:
			_recent_files.remove(0)


func _on_clicked_property(file, property):
	if window_dialog.visible:
		emit_signal("clicked_property", file, property)
		file.set_is_recent(true)

		_recent_files.append(file.whole_path())

		if _recent_files.size() > MAX_RECENT_FILES:
			_recent_files.remove(0)


func _on_reload_button_pressed():
	emit_signal("rebuild")
	if _current_search == null or _current_search.is_empty():
		return
