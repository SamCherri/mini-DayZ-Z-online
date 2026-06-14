#!/usr/bin/env bash
set -euo pipefail

project_file="${1:-project.godot}"
backup_file="${OFFLINE_DEBUG_PROJECT_BACKUP:-${RUNNER_TEMP:-/tmp}/mini-dayz-project.godot.backup}"
normal_main_scene='run/main_scene="res://world.tscn"'
debug_main_scene='run/main_scene="res://debug/AndroidBootDebug.tscn"'

if [[ ! -f "${project_file}" ]]; then
  echo "Erro: ${project_file} não encontrado." >&2
  exit 1
fi

if [[ ! -f debug/AndroidBootDebug.tscn ]]; then
  echo "Erro: cena de boot debug não encontrada." >&2
  exit 1
fi

if ! grep -Fxq "${normal_main_scene}" "${project_file}"; then
  echo "Erro: main scene esperada não encontrada em ${project_file}." >&2
  exit 1
fi

mkdir -p "$(dirname "${backup_file}")"
cp "${project_file}" "${backup_file}"
sed -i "s|^${normal_main_scene}$|${debug_main_scene}|" "${project_file}"

if ! grep -Fxq "${debug_main_scene}" "${project_file}"; then
  echo "Erro: não foi possível ativar a cena de boot debug." >&2
  cp "${backup_file}" "${project_file}"
  exit 1
fi

echo "Backup salvo em ${backup_file}"
echo "Boot offline debug ativado em ${project_file}"
