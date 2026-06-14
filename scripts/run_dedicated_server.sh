#!/usr/bin/env bash
set -euo pipefail

GODOT_BIN="${GODOT_BIN:-godot}"
PORT="${PORT:-7000}"
MAX_CLIENTS="${MAX_CLIENTS:-8}"
LOG_DIR="${LOG_DIR:-logs}"

if ! command -v "${GODOT_BIN}" >/dev/null 2>&1; then
	printf 'Erro: Godot não encontrado: %s\n' "${GODOT_BIN}" >&2
	exit 127
fi

if [[ ! "${PORT}" =~ ^[0-9]+$ ]] || (( 10#${PORT} < 1 || 10#${PORT} > 65535 )); then
	printf 'Erro: PORT deve ser um número inteiro entre 1 e 65535 (recebido: %s).\n' \
		"${PORT}" >&2
	exit 2
fi

if [[ ! "${MAX_CLIENTS}" =~ ^[0-9]+$ ]] || (( 10#${MAX_CLIENTS} < 1 )); then
	printf 'Erro: MAX_CLIENTS deve ser um número inteiro positivo (recebido: %s).\n' \
		"${MAX_CLIENTS}" >&2
	exit 2
fi

mkdir -p "${LOG_DIR}"

printf 'Iniciando servidor dedicado Mini DayZ Z Online RP.\n'
printf 'Porta UDP: %s | Limite de clientes: %s\n' "${PORT}" "${MAX_CLIENTS}"
printf 'Diretório de logs preparado: %s\n' "${LOG_DIR}"

exec "${GODOT_BIN}" --headless --path . server/server_main.tscn -- \
	--dedicated-server --port "${PORT}" --max-clients "${MAX_CLIENTS}"
