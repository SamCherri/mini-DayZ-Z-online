#!/usr/bin/env bash
set -euo pipefail

GODOT_BIN="${GODOT_BIN:-godot}"
PORT="${PORT:-7000}"
TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-20}"
LOG_DIR="${LOG_DIR:-${PWD}/artifacts/godot-smoke-test}"

SERVER_LOG="${LOG_DIR}/server.log"
CLIENT_ONE_LOG="${LOG_DIR}/client-1.log"
CLIENT_TWO_LOG="${LOG_DIR}/client-2.log"

SERVER_PID=""
CLIENT_ONE_PID=""
CLIENT_TWO_PID=""

cleanup() {
	local exit_code=$?
	trap - EXIT INT TERM

	for pid in "${CLIENT_TWO_PID}" "${CLIENT_ONE_PID}" "${SERVER_PID}"; do
		if [[ -n "${pid}" ]] && kill -0 "${pid}" 2>/dev/null; then
			kill -TERM "${pid}" 2>/dev/null || true
		fi
	done

	wait "${CLIENT_TWO_PID}" 2>/dev/null || true
	wait "${CLIENT_ONE_PID}" 2>/dev/null || true
	wait "${SERVER_PID}" 2>/dev/null || true

	if [[ ${exit_code} -ne 0 ]]; then
		printf '\nSmoke test falhou. Logs coletados:\n'
		for log_file in "${SERVER_LOG}" "${CLIENT_ONE_LOG}" "${CLIENT_TWO_LOG}"; do
			printf '\n===== %s =====\n' "${log_file}"
			cat "${log_file}" 2>/dev/null || true
		done
	fi

	exit "${exit_code}"
}
trap cleanup EXIT INT TERM

wait_for_log() {
	local log_file=$1
	local expected=$2
	local deadline=$((SECONDS + TIMEOUT_SECONDS))

	while (( SECONDS < deadline )); do
		if grep -Fq "${expected}" "${log_file}" 2>/dev/null; then
			return 0
		fi
		sleep 0.25
	done

	printf 'Tempo esgotado aguardando "%s" em %s.\n' "${expected}" "${log_file}" >&2
	return 1
}

wait_for_count() {
	local log_file=$1
	local expected=$2
	local minimum_count=$3
	local deadline=$((SECONDS + TIMEOUT_SECONDS))

	while (( SECONDS < deadline )); do
		local count
		count=$(grep -Fc "${expected}" "${log_file}" 2>/dev/null || true)
		if (( count >= minimum_count )); then
			return 0
		fi
		sleep 0.25
	done

	printf 'Esperados ao menos %d registros de "%s" em %s.\n' \
		"${minimum_count}" "${expected}" "${log_file}" >&2
	return 1
}

if ! command -v "${GODOT_BIN}" >/dev/null 2>&1; then
	printf 'Godot não encontrado: %s\n' "${GODOT_BIN}" >&2
	exit 127
fi

mkdir -p "${LOG_DIR}"
: >"${SERVER_LOG}"
: >"${CLIENT_ONE_LOG}"
: >"${CLIENT_TWO_LOG}"

printf 'Iniciando servidor dedicado na porta %s...\n' "${PORT}"
"${GODOT_BIN}" --headless --path . server/server_main.tscn -- \
	--dedicated-server --port "${PORT}" >"${SERVER_LOG}" 2>&1 &
SERVER_PID=$!
wait_for_log "${SERVER_LOG}" "ServerMain: servidor dedicado iniciado"

printf 'Iniciando cliente 1...\n'
"${GODOT_BIN}" --headless --path . -- \
	--connect 127.0.0.1 --port "${PORT}" >"${CLIENT_ONE_LOG}" 2>&1 &
CLIENT_ONE_PID=$!
wait_for_count "${SERVER_LOG}" "conectado. Total conectado:" 1
wait_for_count "${CLIENT_ONE_LOG}" "SpawnProtocol: evento de spawn recebido" 1

printf 'Iniciando cliente 2...\n'
"${GODOT_BIN}" --headless --path . -- \
	--connect 127.0.0.1 --port "${PORT}" >"${CLIENT_TWO_LOG}" 2>&1 &
CLIENT_TWO_PID=$!
wait_for_count "${SERVER_LOG}" "conectado. Total conectado:" 2
wait_for_count "${CLIENT_ONE_LOG}" "SpawnProtocol: evento de spawn recebido" 2
wait_for_count "${CLIENT_TWO_LOG}" "SpawnProtocol: evento de spawn recebido" 2

printf 'Encerrando cliente 1 para validar desconexão e despawn...\n'
kill -TERM "${CLIENT_ONE_PID}"
wait "${CLIENT_ONE_PID}" 2>/dev/null || true
CLIENT_ONE_PID=""

wait_for_log "${SERVER_LOG}" "desconectado. Total conectado: 1."
wait_for_log "${CLIENT_TWO_LOG}" "SpawnProtocol: evento de despawn recebido"

if ! kill -0 "${SERVER_PID}" 2>/dev/null || ! kill -0 "${CLIENT_TWO_PID}" 2>/dev/null; then
	printf 'Servidor ou cliente restante encerrou inesperadamente.\n' >&2
	exit 1
fi

printf 'Smoke test concluído: servidor, dois clientes, spawn, desconexão e despawn validados.\n'
printf 'Logs disponíveis em %s\n' "${LOG_DIR}"
