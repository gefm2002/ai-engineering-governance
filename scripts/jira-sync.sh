#!/usr/bin/env bash
# jira-sync.sh — Sincroniza GAPS.md y TECHNICAL_DEBT_ROADMAP.md con Jira
#
# Uso:
#   bash scripts/jira-sync.sh                    # crea tickets nuevos, skipea existentes
#   bash scripts/jira-sync.sh --dry-run          # muestra qué crearía sin ejecutar
#   bash scripts/jira-sync.sh --source gaps      # solo GAPS.md
#   bash scripts/jira-sync.sh --source debt      # solo TECHNICAL_DEBT_ROADMAP.md
#
# Config requerida en .governance/jira-config.sh:
#   JIRA_BASE_URL="https://tu-empresa.atlassian.net"
#   JIRA_PROJECT_KEY="PROJ"
#   JIRA_TOKEN="tu-api-token"   # https://id.atlassian.com/manage-profile/security/api-tokens
#   JIRA_EMAIL="tu@email.com"

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log()     { echo -e "${BLUE}[jira-sync]${NC} $*"; }
success() { echo -e "${GREEN}[jira-sync]${NC} $*"; }
warn()    { echo -e "${YELLOW}[jira-sync]${NC} $*"; }
fail()    { echo -e "${RED}[jira-sync]${NC} $*"; }

DRY_RUN=false
SOURCE="all"  # all | gaps | debt

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)        DRY_RUN=true;    shift ;;
    --source)         SOURCE="$2";     shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ─── Config ───────────────────────────────────────────────────────────────────

JIRA_BASE_URL=""
JIRA_PROJECT_KEY=""
JIRA_TOKEN=""
JIRA_EMAIL=""
JIRA_EPIC_KEY=""           # opcional: epic para agrupar todos los tickets de governance

# Tipos de issue por criticidad (ajustar según configuración de tu Jira)
ISSUE_TYPE_P0="Bug"        # P0 gaps = bugs críticos
ISSUE_TYPE_P1="Story"
ISSUE_TYPE_P2="Task"
ISSUE_TYPE_DEBT="Task"

# Labels para identificar tickets creados por governance
GOVERNANCE_LABEL="governance-framework"

if [[ -f ".governance/jira-config.sh" ]]; then
  # shellcheck disable=SC1091
  source ".governance/jira-config.sh"
fi

if [[ -z "$JIRA_BASE_URL" ]] || [[ -z "$JIRA_PROJECT_KEY" ]] || [[ -z "$JIRA_TOKEN" ]] || [[ -z "$JIRA_EMAIL" ]]; then
  fail "Configuración de Jira incompleta."
  echo ""
  echo "  Crear .governance/jira-config.sh con:"
  echo "    JIRA_BASE_URL=\"https://tu-empresa.atlassian.net\""
  echo "    JIRA_PROJECT_KEY=\"PROJ\""
  echo "    JIRA_TOKEN=\"tu-api-token\""
  echo "    JIRA_EMAIL=\"tu@email.com\""
  echo ""
  echo "  Generar API token: https://id.atlassian.com/manage-profile/security/api-tokens"
  exit 1
fi

JIRA_AUTH=$(echo -n "${JIRA_EMAIL}:${JIRA_TOKEN}" | base64)
REPO_NAME=$(basename "$PWD")
CREATED=0
SKIPPED=0
FAILED=0

# ─── Función: verificar si ya existe un ticket con este ID de governance ──────

ticket_exists() {
  local governance_id="$1"
  # Buscar por label + summary que contenga el ID
  local response
  response=$(curl -s \
    -H "Authorization: Basic ${JIRA_AUTH}" \
    -H "Content-Type: application/json" \
    "${JIRA_BASE_URL}/rest/api/3/search?jql=project=${JIRA_PROJECT_KEY}+AND+labels=${GOVERNANCE_LABEL}+AND+summary~\"${governance_id}\"&maxResults=1" \
    2>/dev/null || echo '{"total":0}')

  local total
  total=$(echo "$response" | grep -o '"total":[0-9]*' | head -1 | grep -o '[0-9]*' || echo "0")
  [[ "$total" -gt 0 ]]
}

# ─── Función: crear ticket en Jira ────────────────────────────────────────────

create_ticket() {
  local summary="$1"
  local description="$2"
  local issue_type="$3"
  local priority="$4"      # Highest | High | Medium | Low
  local governance_id="$5" # ej: GAP-001 o TD-01
  local human_only="$6"    # true | false

  local labels="[\"${GOVERNANCE_LABEL}\", \"${REPO_NAME}\"]"
  [[ "$human_only" == "true" ]] && labels="[\"${GOVERNANCE_LABEL}\", \"${REPO_NAME}\", \"human-only\"]"

  local epic_field=""
  [[ -n "$JIRA_EPIC_KEY" ]] && epic_field="\"customfield_10014\": \"${JIRA_EPIC_KEY}\","

  local payload
  payload=$(cat <<EOF
{
  "fields": {
    "project": { "key": "${JIRA_PROJECT_KEY}" },
    "summary": "[${governance_id}][${REPO_NAME}] ${summary}",
    "description": {
      "type": "doc",
      "version": 1,
      "content": [{
        "type": "paragraph",
        "content": [{ "type": "text", "text": ${description@Q} }]
      }, {
        "type": "paragraph",
        "content": [{ "type": "text", "text": "Repo: ${REPO_NAME} | ID: ${governance_id} | Generado por Engineering Governance Framework" }]
      }]
    },
    "issuetype": { "name": "${issue_type}" },
    "priority": { "name": "${priority}" },
    "labels": ${labels}
    ${epic_field}
  }
}
EOF
)

  if [[ "$DRY_RUN" == "true" ]]; then
    log "[dry-run] Crearía ticket: [${governance_id}] ${summary} (${issue_type}, ${priority})"
    [[ "$human_only" == "true" ]] && warn "          → HUMAN_ONLY: requiere decisión humana antes de ejecutarse"
    return 0
  fi

  local response
  response=$(curl -s -X POST \
    -H "Authorization: Basic ${JIRA_AUTH}" \
    -H "Content-Type: application/json" \
    -d "$payload" \
    "${JIRA_BASE_URL}/rest/api/3/issue" 2>/dev/null)

  local ticket_key
  ticket_key=$(echo "$response" | grep -o '"key":"[^"]*"' | head -1 | grep -o '[A-Z]*-[0-9]*' || echo "")

  if [[ -n "$ticket_key" ]]; then
    success "Creado: ${ticket_key} — [${governance_id}] ${summary}"
    echo "    ${JIRA_BASE_URL}/browse/${ticket_key}"
    CREATED=$((CREATED + 1))
    # Escribir el ticket key de vuelta al doc (se hace en la función caller)
    echo "$ticket_key"
  else
    fail "Error creando ticket para ${governance_id}:"
    echo "$response" | grep -o '"errorMessages":\[[^]]*\]' | head -1 || echo "$response" | head -c 200
    FAILED=$((FAILED + 1))
    echo ""
  fi
}

# ─── Parsear y sincronizar GAPS.md ────────────────────────────────────────────

sync_gaps() {
  local gaps_file="docs-system/GAPS.md"

  if [[ ! -f "$gaps_file" ]]; then
    warn "docs-system/GAPS.md no encontrado — saltando"
    return
  fi

  log "Procesando GAPS.md..."
  echo ""

  # Extraer bloques de gaps: ### GAP-XXX hasta el próximo ### o fin de sección
  local current_id="" current_title="" current_priority="" current_human_only="false"
  local in_gap=false

  while IFS= read -r line; do
    # Detectar inicio de un gap
    if echo "$line" | grep -qE "^### (GAP-[0-9]+)"; then
      # Procesar el gap anterior si existe
      if [[ "$in_gap" == "true" ]] && [[ -n "$current_id" ]]; then
        _process_gap "$current_id" "$current_title" "$current_priority" "$current_human_only"
      fi
      current_id=$(echo "$line" | grep -oE "GAP-[0-9]+")
      current_title=$(echo "$line" | sed "s/### ${current_id}[[:space:]]*//" | sed "s/^[[:space:]]*//" | sed "s/ \[HUMAN_ONLY\]//")
      current_priority="P2"
      current_human_only="false"
      in_gap=true
    fi

    # Detectar criticidad
    if [[ "$in_gap" == "true" ]]; then
      if echo "$line" | grep -qiE "\bP0\b"; then current_priority="P0"; fi
      if echo "$line" | grep -qiE "\bP1\b"; then current_priority="P1"; fi
      if echo "$line" | grep -qiE "\bP2\b"; then current_priority="P2"; fi
      if echo "$line" | grep -qiE "\bP3\b"; then current_priority="P3"; fi
      if echo "$line" | grep -qi "HUMAN_ONLY"; then current_human_only="true"; fi
    fi

    # Fin de sección de gaps abiertos
    if echo "$line" | grep -qiE "^## (Cerrados|Closed|Resueltos)"; then
      in_gap=false
    fi
  done < "$gaps_file"

  # Procesar el último gap
  if [[ "$in_gap" == "true" ]] && [[ -n "$current_id" ]]; then
    _process_gap "$current_id" "$current_title" "$current_priority" "$current_human_only"
  fi
}

_process_gap() {
  local gap_id="$1" title="$2" priority="$3" human_only="$4"

  # Mapear criticidad a tipo de issue y prioridad Jira
  local issue_type priority_jira
  case "$priority" in
    P0) issue_type="$ISSUE_TYPE_P0"; priority_jira="Highest" ;;
    P1) issue_type="$ISSUE_TYPE_P1"; priority_jira="High" ;;
    P2) issue_type="$ISSUE_TYPE_P2"; priority_jira="Medium" ;;
    *)  issue_type="$ISSUE_TYPE_P2"; priority_jira="Low" ;;
  esac

  # Verificar si ya tiene ticket
  if ticket_exists "$gap_id" 2>/dev/null; then
    warn "SKIP ${gap_id} — ya existe ticket en Jira"
    SKIPPED=$((SKIPPED + 1))
    return
  fi

  local desc="Gap identificado en ${REPO_NAME} por Engineering Governance Framework (Phase 0)."
  [[ "$human_only" == "true" ]] && desc="${desc} HUMAN_ONLY: este item requiere decisión humana antes de poder ejecutarse."

  create_ticket "$title" "$desc" "$issue_type" "$priority_jira" "$gap_id" "$human_only" > /dev/null
}

# ─── Parsear y sincronizar TECHNICAL_DEBT_ROADMAP.md ─────────────────────────

sync_debt() {
  local debt_file="docs-system/TECHNICAL_DEBT_ROADMAP.md"

  if [[ ! -f "$debt_file" ]]; then
    warn "docs-system/TECHNICAL_DEBT_ROADMAP.md no encontrado — saltando"
    return
  fi

  log "Procesando TECHNICAL_DEBT_ROADMAP.md..."
  echo ""

  local current_id="" current_title="" current_human_only="false"
  local in_debt=false

  while IFS= read -r line; do
    if echo "$line" | grep -qE "^### (TD-[0-9]+)"; then
      if [[ "$in_debt" == "true" ]] && [[ -n "$current_id" ]]; then
        _process_debt "$current_id" "$current_title" "$current_human_only"
      fi
      current_id=$(echo "$line" | grep -oE "TD-[0-9]+")
      current_title=$(echo "$line" | sed "s/### ${current_id}[[:space:]]*//" | sed "s/^[[:space:]]*//" | sed "s/ \[HUMAN_ONLY\]//")
      current_human_only="false"
      in_debt=true
    fi

    if [[ "$in_debt" == "true" ]]; then
      if echo "$line" | grep -qi "HUMAN_ONLY"; then current_human_only="true"; fi
    fi

    if echo "$line" | grep -qiE "^## (Cerrada|Closed|Resuelta)"; then
      in_debt=false
    fi
  done < "$debt_file"

  if [[ "$in_debt" == "true" ]] && [[ -n "$current_id" ]]; then
    _process_debt "$current_id" "$current_title" "$current_human_only"
  fi
}

_process_debt() {
  local td_id="$1" title="$2" human_only="$3"

  if ticket_exists "$td_id" 2>/dev/null; then
    warn "SKIP ${td_id} — ya existe ticket en Jira"
    SKIPPED=$((SKIPPED + 1))
    return
  fi

  local desc="Deuda técnica identificada en ${REPO_NAME} por Engineering Governance Framework (Phase 0)."
  [[ "$human_only" == "true" ]] && desc="${desc} HUMAN_ONLY: requiere decisión humana antes de poder resolverse."

  create_ticket "$title" "$desc" "$ISSUE_TYPE_DEBT" "Medium" "$td_id" "$human_only" > /dev/null
}

# ─── Main ─────────────────────────────────────────────────────────────────────

echo ""
log "Jira Sync — Engineering Governance Framework"
log "Proyecto: ${JIRA_PROJECT_KEY} | Repo: ${REPO_NAME}"
[[ "$DRY_RUN" == "true" ]] && warn "MODO DRY-RUN — no se creará nada"
echo ""

[[ "$SOURCE" == "all" || "$SOURCE" == "gaps" ]] && sync_gaps
[[ "$SOURCE" == "all" || "$SOURCE" == "debt" ]] && sync_debt

echo ""
echo "────────────────────────────────────────────"
echo "  Creados:  $CREATED"
echo "  Salteados (ya existen): $SKIPPED"
echo "  Fallidos: $FAILED"
echo "────────────────────────────────────────────"
echo ""
