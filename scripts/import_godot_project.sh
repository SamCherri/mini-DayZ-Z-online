#!/usr/bin/env bash
set -euo pipefail

GODOT_BIN="${GODOT_BIN:-godot}"
LOG_DIR="${LOG_DIR:-artifacts/godot-import}"
IMPORT_LOG="${LOG_DIR}/import.log"
NORMALIZED_IMPORT_LOG="${LOG_DIR}/import.normalized.log"

mkdir -p "${LOG_DIR}"

normalize_import_log() {
	tr '\r' '\n' < "${IMPORT_LOG}" \
		| sed -E $'s/\033\\[[0-9;]*[A-Za-z]//g' \
		> "${NORMALIZED_IMPORT_LOG}"
}

import_finished_successfully() {
	grep -Eq \
		'\[ *DONE *\][[:space:]]+(reimport|loading_editor_layout)' \
		"${NORMALIZED_IMPORT_LOG}"
}

if ! command -v "${GODOT_BIN}" >/dev/null 2>&1; then
	printf 'Erro: Godot não encontrado: %s\n' "${GODOT_BIN}" | tee "${IMPORT_LOG}" >&2
	normalize_import_log
	exit 127
fi

set +e
"${GODOT_BIN}" --headless --path . --import --quit 2>&1 | tee "${IMPORT_LOG}"
godot_exit_code=${PIPESTATUS[0]}
set -e

normalize_import_log

if (( godot_exit_code == 0 )); then
	printf 'Importação Godot concluída com sucesso.\n'
	exit 0
fi

if import_finished_successfully; then
	printf '%s\n' \
		'Aviso: marcador seguro de conclusão encontrado no log normalizado.'
	printf 'Aviso: Godot retornou %d após concluir a importação; continuando.\n' \
		"${godot_exit_code}"
	exit 0
fi

printf 'Erro: nenhum marcador seguro de conclusão foi encontrado no log normalizado.\n' >&2
printf 'Erro: importação Godot não concluiu (código %d).\n' \
	"${godot_exit_code}" >&2
printf '%s\n' 'Últimas 120 linhas do log normalizado:' >&2
tail -n 120 "${NORMALIZED_IMPORT_LOG}" >&2
exit "${godot_exit_code}"
