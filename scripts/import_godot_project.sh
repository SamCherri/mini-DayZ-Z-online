#!/usr/bin/env bash
set -euo pipefail

GODOT_BIN="${GODOT_BIN:-godot}"
LOG_DIR="${LOG_DIR:-artifacts/godot-import}"
IMPORT_LOG="${LOG_DIR}/import.log"

mkdir -p "${LOG_DIR}"

if ! command -v "${GODOT_BIN}" >/dev/null 2>&1; then
	printf 'Erro: Godot não encontrado: %s\n' "${GODOT_BIN}" | tee "${IMPORT_LOG}" >&2
	exit 127
fi

set +e
"${GODOT_BIN}" --headless --path . --import --quit 2>&1 | tee "${IMPORT_LOG}"
godot_exit_code=${PIPESTATUS[0]}
set -e

if (( godot_exit_code == 0 )); then
	printf 'Importação Godot concluída com sucesso.\n'
	exit 0
fi

if ! grep -Fq '[ DONE ] reimport' "${IMPORT_LOG}"; then
	printf 'Erro: importação Godot não concluiu (código %d).\n' \
		"${godot_exit_code}" >&2
	exit "${godot_exit_code}"
fi

if (( godot_exit_code == 134 )) \
	&& grep -Fq 'double free or corruption' "${IMPORT_LOG}"; then
	printf '%s\n' \
		'Aviso: crash nativo do Godot após reimportação concluída; o smoke test runtime validará se o cache gerado é utilizável.'
fi

printf 'Aviso: Godot retornou %d após [ DONE ] reimport; continuando para o smoke test.\n' \
	"${godot_exit_code}"
