extends SceneTree


func _init() -> void:
	var sdk_path := OS.get_environment("ANDROID_HOME")
	if sdk_path.is_empty():
		sdk_path = OS.get_environment("ANDROID_SDK_ROOT")

	var java_path := OS.get_environment("JAVA_HOME")
	var home := OS.get_environment("HOME")
	var keystore_path := home.path_join(".android/debug.keystore")

	if sdk_path.is_empty():
		push_error("ANDROID_HOME/ANDROID_SDK_ROOT não configurado.")
		quit(1)
		return

	if java_path.is_empty():
		push_error("JAVA_HOME não configurado.")
		quit(1)
		return

	if home.is_empty():
		push_error("HOME não configurado.")
		quit(1)
		return

	if not FileAccess.file_exists(keystore_path):
		push_error("Debug keystore não encontrada: %s" % keystore_path)
		quit(1)
		return

	var editor_settings := EditorSettings.get_singleton()
	if editor_settings == null:
		push_error("Não foi possível acessar EditorSettings.")
		quit(1)
		return

	editor_settings.set_setting("export/android/android_sdk_path", sdk_path)
	editor_settings.set_setting("export/android/java_sdk_path", java_path)
	editor_settings.set_setting("export/android/debug_keystore", keystore_path)
	editor_settings.set_setting("export/android/debug_keystore_user", "androiddebugkey")
	editor_settings.set_setting("export/android/debug_keystore_pass", "android")
	editor_settings.save()

	print("Android export settings configuradas.")
	print("SDK: %s" % sdk_path)
	print("Java: %s" % java_path)
	print("Keystore: %s" % keystore_path)

	quit(0)
