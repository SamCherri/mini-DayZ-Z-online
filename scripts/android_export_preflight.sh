#!/usr/bin/env bash
set -euo pipefail

required_files=(
  "project.godot"
  "export_presets.cfg"
  "world.tscn"
  "debug/AndroidBootDebug.gd"
  "debug/AndroidBootDebug.tscn"
)

for required_file in "${required_files[@]}"; do
  if [[ ! -f "${required_file}" ]]; then
    echo "Erro: arquivo obrigatório para a exportação não encontrado: ${required_file}" >&2
    exit 1
  fi
done

if ! grep -Fxq 'run/main_scene="res://world.tscn"' project.godot; then
  echo "Erro: project.godot não aponta para a main scene normal res://world.tscn." >&2
  exit 1
fi

if ! grep -Fq 'name="Android Offline Debug"' export_presets.cfg; then
  echo "Erro: preset Android Offline Debug não encontrado." >&2
  exit 1
fi

echo "Preflight Android offline debug concluído."
