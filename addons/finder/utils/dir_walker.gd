class_name DirWalker

var _path: String


func _init(path: String):
	_path = path


func walk(handler: FuncRef, args: Array = []):
	var dir := DirAccess.new()
	if dir.open(_path) != OK:
		return false

	dir.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			var file := File.new()

			if file.open("%s/%s" % [dir.get_current_dir(), file_name], File.READ) != OK:
				continue

			var arg_array = [dir, file]
			arg_array.append_array(args)
			handler.call_funcv(arg_array)

		file_name = dir.get_next()


static func delete_every_file(dir: DirAccess, file: File) -> void:
	dir.remove(file.get_path_absolute())
