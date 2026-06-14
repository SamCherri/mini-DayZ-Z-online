#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="${LOG_DIR:-artifacts/godot-import}"
DIAGNOSTICS_LOG="${LOG_DIR}/csv-diagnostics.log"
mkdir -p "${LOG_DIR}"

{
	printf '%s\n' '=== Diagnóstico de tabelas CSV do Godot ==='
	printf 'Diretório do projeto: %s\n' "$(pwd)"
	printf '\nArquivos com extensão .CSV/.csv (não devem existir):\n'
	find . -type f \( -name '*.CSV' -o -name '*.csv' \) -print | sort

	printf '\nMetadados .CSV.import/.csv.import:\n'
	find . -type f \( -name '*.CSV.import' -o -name '*.csv.import' \) -print | sort

	printf '\nTabelas protegidas da importação automática (*.csv.txt):\n'
	find dev_res/data -maxdepth 1 -type f -name '*.csv.txt' -print | sort

	printf '\nPrimeiras 3 linhas das tabelas CSV e CSV-texto:\n'
	while IFS= read -r table; do
		printf '\n--- %s ---\n' "${table}"
		sed -n '1,3p' "${table}"
		if command -v file >/dev/null 2>&1; then
			file "${table}"
		else
			printf '%s\n' 'file: comando indisponível neste ambiente'
		fi
	done < <(find dev_res/data -maxdepth 1 -type f \( -name '*.CSV' -o -name '*.csv' -o -name '*.csv.txt' \) -print | sort)

	printf '\nMetadados configurados como csv_translation:\n'
	translation_imports="$(find . -type f -name '*.import' -exec grep -l 'importer="csv_translation"' {} + 2>/dev/null || true)"
	if [[ -n "${translation_imports}" ]]; then
		printf '%s\n' "${translation_imports}"
	else
		printf '%s\n' 'Nenhum encontrado.'
	fi

	printf '\nUIDs duplicados entre arquivos .import:\n'
	duplicate_uids="$({
		find . -type f -name '*.import' -print0 \
			| xargs -0 -r awk -F= '/^uid=/{gsub(/"/, "", $2); print $2 "\t" FILENAME}'
	} | sort -k1,1 | awk -F '\t' '
		$1 == previous_uid {
			if (!reported) print previous_line
			print
			reported = 1
		}
		$1 != previous_uid { reported = 0 }
		{ previous_uid = $1; previous_line = $0 }
	' || true)"
	if [[ -n "${duplicate_uids}" ]]; then
		printf '%s\n' "${duplicate_uids}"
	else
		printf '%s\n' 'Nenhum encontrado.'
	fi
} 2>&1 | tee "${DIAGNOSTICS_LOG}"
