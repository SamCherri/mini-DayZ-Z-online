#!/usr/bin/env bash
set -euo pipefail

SDK_PATH="${ANDROID_HOME:-}"
if [[ -z "${SDK_PATH}" ]]; then
  SDK_PATH="${ANDROID_SDK_ROOT:-}"
fi

JAVA_PATH="${JAVA_HOME:-}"
KEYSTORE_PATH="${HOME}/.android/debug.keystore"
SETTINGS_DIR="${HOME}/.config/godot"
SETTINGS_FILE="${SETTINGS_DIR}/editor_settings-4.tres"

if [[ -z "${SDK_PATH}" || ! -d "${SDK_PATH}" ]]; then
  echo "Erro: Android SDK não encontrado: ${SDK_PATH}" >&2
  exit 1
fi

if [[ -z "${JAVA_PATH}" || ! -d "${JAVA_PATH}" ]]; then
  echo "Erro: JAVA_HOME não encontrado: ${JAVA_PATH}" >&2
  exit 1
fi

if [[ ! -f "${KEYSTORE_PATH}" ]]; then
  echo "Erro: debug.keystore não encontrada: ${KEYSTORE_PATH}" >&2
  exit 1
fi

mkdir -p "${SETTINGS_DIR}"

cat > "${SETTINGS_FILE}" <<EOF_SETTINGS
[gd_resource type="EditorSettings" format=3]

[resource]
export/android/android_sdk_path = "${SDK_PATH}"
export/android/java_sdk_path = "${JAVA_PATH}"
export/android/debug_keystore = "${KEYSTORE_PATH}"
export/android/debug_keystore_user = "androiddebugkey"
export/android/debug_keystore_pass = "android"
EOF_SETTINGS

echo "EditorSettings Android configurado em: ${SETTINGS_FILE}"
echo "SDK: ${SDK_PATH}"
echo "Java: ${JAVA_PATH}"
echo "Keystore: ${KEYSTORE_PATH}"
