#!/usr/bin/env bash
# Executa o fluxo End-to-End: o app conclui a vistoria e, em seguida,
# o aprovar_transacao.robot aprova a transação no sistema WEB.
#
# Uso: ./run_e2e.sh
set -euo pipefail

cd "$(dirname "$0")"

OUTPUT_DIR="${OUTPUT_DIR:-results}"

echo "==> 1/2 Concluindo vistoria no app e aprovando no WEB (fluxo E2E único)"
robot --outputdir "${OUTPUT_DIR}" tests/e2e/vistoria_e2e.robot

echo "==> 2/2 Executando o aprovar_transacao.robot isolado"
robot --outputdir "${OUTPUT_DIR}/aprovar_transacao" tests/e2e/aprovar_transacao.robot

echo "==> Concluído. Relatórios em ${OUTPUT_DIR}"
