#!/usr/bin/env bash
set -euo pipefail

GODOT_BIN="${GODOT_BIN:-godot}"
SERVER_ADDRESS="${SERVER_ADDRESS:-127.0.0.1}"
PORT="${PORT:-7000}"
SESSION_NAME="${SESSION_NAME:-SessionOne}"
FIRST_NAME="${FIRST_NAME:-Client}"
LAST_NAME="${LAST_NAME:-One}"

if ! command -v "${GODOT_BIN}" >/dev/null 2>&1; then
	printf 'Erro: Godot não encontrado: %s\n' "${GODOT_BIN}" >&2
	exit 127
fi

if [[ ! "${PORT}" =~ ^[0-9]+$ ]] || (( 10#${PORT} < 1 || 10#${PORT} > 65535 )); then
	printf 'Erro: PORT deve ser um número inteiro entre 1 e 65535 (recebido: %s).\n' \
		"${PORT}" >&2
	exit 2
fi

printf 'Iniciando cliente dedicado para %s:%s como %s (%s %s).\n' \
	"${SERVER_ADDRESS}" "${PORT}" "${SESSION_NAME}" "${FIRST_NAME}" "${LAST_NAME}"

exec "${GODOT_BIN}" --path . -- \
	--connect "${SERVER_ADDRESS}" --port "${PORT}" --dedicated-client \
	--test-name "${SESSION_NAME}" \
	--test-first-name "${FIRST_NAME}" \
	--test-last-name "${LAST_NAME}"
