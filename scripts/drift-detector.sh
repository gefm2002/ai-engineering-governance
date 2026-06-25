#!/usr/bin/env bash
# drift-detector.sh — detecta divergencia entre docs-system/ y el código real
#
# Uso:
#   bash scripts/drift-detector.sh
#   bash scripts/drift-detector.sh --fix    # abre un issue en GitHub con el reporte

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${BLUE}[drift]${NC} $*"; }
ok()   { echo -e "${GREEN}[drift]${NC} $*"; }
warn() { echo -e "${YELLOW}[drift]${NC} $*"; }
fail() { echo -e "${RED}[drift]${NC} $*"; }

CREATE_ISSUE=false
[[ "${1:-}" == "--fix" ]] && CREATE_ISSUE=true

DRIFT_FOUND=false
REPORT=()

echo ""
log "Drift Detector — Engineering Governance Framework"
echo ""

# ─── CHECK 1: env vars documentadas vs reales ────────────────────────────────

if [[ -f "docs-system/INTEGRATIONS.md" ]]; then
  log "CHECK 1 — Variables de entorno..."

  # Extraer env vars documentadas en INTEGRATIONS.md (columna de tabla con formato ALL_CAPS)
  DOCUMENTED_VARS=$(grep -oE '\b[A-Z][A-Z0-9_]{2,}\b' docs-system/INTEGRATIONS.md \
    | grep -v "UNKNOWN\|TODO\|P0\|P1\|P2\|P3\|NULL\|TRUE\|FALSE\|HTTP\|HTTPS\|AWS\|SQS\|SNS\|API\|URL\|SQL\|CI\|CD\|PR\|MKP\|VP\|ID\|DB" \
    | sort -u || true)

  # Buscar en el código fuente real
  MISSING_IN_CODE=()
  for var in $DOCUMENTED_VARS; do
    if ! grep -r "$var" src/ --include="*.ts" --include="*.js" --include="*.py" \
         --include="*.go" -q 2>/dev/null; then
      MISSING_IN_CODE+=("$var")
    fi
  done

  # Buscar env vars usadas en código pero no documentadas
  CODE_VARS=$(grep -roh 'process\.env\.\([A-Z][A-Z0-9_]*\)\|os\.environ\[.\([A-Z][A-Z0-9_]*\).\]\|os\.getenv(.\([A-Z][A-Z0-9_]*\)' \
    src/ 2>/dev/null \
    | grep -oE '[A-Z][A-Z0-9_]{2,}' | sort -u || true)

  UNDOCUMENTED_VARS=()
  for var in $CODE_VARS; do
    if ! grep -q "$var" docs-system/INTEGRATIONS.md 2>/dev/null; then
      UNDOCUMENTED_VARS+=("$var")
    fi
  done

  if [[ ${#MISSING_IN_CODE[@]} -gt 0 ]]; then
    warn "  Variables en INTEGRATIONS.md pero no en el código:"
    for v in "${MISSING_IN_CODE[@]}"; do echo "    - $v (¿eliminada o renombrada?)"; done
    DRIFT_FOUND=true
    REPORT+=("Env vars en docs pero no en código: ${MISSING_IN_CODE[*]}")
  fi

  if [[ ${#UNDOCUMENTED_VARS[@]} -gt 0 ]]; then
    warn "  Variables en el código pero no documentadas en INTEGRATIONS.md:"
    for v in "${UNDOCUMENTED_VARS[@]}"; do echo "    - $v"; done
    DRIFT_FOUND=true
    REPORT+=("Env vars en código sin documentar: ${UNDOCUMENTED_VARS[*]}")
  fi

  [[ ${#MISSING_IN_CODE[@]} -eq 0 && ${#UNDOCUMENTED_VARS[@]} -eq 0 ]] && ok "  CHECK 1 OK — env vars sincronizadas"
fi

# ─── CHECK 2: docs más viejos que el código ───────────────────────────────────

log "CHECK 2 — Antigüedad de docs vs código..."

if [[ -d "docs-system" ]] && [[ -d "src" || -d "lib" || -d "app" ]]; then
  CODE_DIR="src"
  [[ ! -d "src" ]] && [[ -d "lib" ]] && CODE_DIR="lib"
  [[ ! -d "src" ]] && [[ -d "app" ]] && CODE_DIR="app"

  LAST_CODE_CHANGE=$(git log -1 --format="%ct" -- "$CODE_DIR/" 2>/dev/null || echo "0")
  LAST_DOCS_CHANGE=$(git log -1 --format="%ct" -- "docs-system/" 2>/dev/null || echo "0")

  if [[ "$LAST_CODE_CHANGE" -gt 0 && "$LAST_DOCS_CHANGE" -gt 0 ]]; then
    DIFF_DAYS=$(( (LAST_CODE_CHANGE - LAST_DOCS_CHANGE) / 86400 ))

    if [[ "$DIFF_DAYS" -gt 30 ]]; then
      warn "  El código fue modificado hace $DIFF_DAYS días más que los docs"
      warn "  Último cambio código: $(git log -1 --format='%ar' -- "$CODE_DIR/" 2>/dev/null)"
      warn "  Último cambio docs:   $(git log -1 --format='%ar' -- "docs-system/" 2>/dev/null)"
      DRIFT_FOUND=true
      REPORT+=("docs-system con ${DIFF_DAYS} días de atraso respecto al código")
    elif [[ "$DIFF_DAYS" -gt 7 ]]; then
      warn "  Posible drift: docs con $DIFF_DAYS días de atraso (umbral de alerta: 30)"
    else
      ok "  CHECK 2 OK — docs actualizados recientemente"
    fi
  fi
fi

# ─── CHECK 3: flujos P0 en USER_FLOW_MATRIX con tests ────────────────────────

if [[ -f "docs-system/USER_FLOW_MATRIX.md" ]]; then
  log "CHECK 3 — Flujos P0 vs archivos de test..."

  P0_FLOWS=$(grep -E "^\s*\|\s*UF-[0-9]+" docs-system/USER_FLOW_MATRIX.md \
    | grep "P0" | grep -oE "UF-[0-9]+" || true)

  P0_NO_TEST=()
  for flow_id in $P0_FLOWS; do
    TEST_FILE=$(find . -type f \( -name "*.spec.ts" -o -name "*.test.ts" \
      -o -name "*.spec.js" -o -name "*.test.js" -o -name "*.spec.py" \) \
      -not -path "*/node_modules/*" \
      | xargs grep -l "$flow_id" 2>/dev/null || true)
    [[ -z "$TEST_FILE" ]] && P0_NO_TEST+=("$flow_id")
  done

  if [[ ${#P0_NO_TEST[@]} -gt 0 ]]; then
    warn "  Flujos P0 sin archivo de test:"
    for f in "${P0_NO_TEST[@]}"; do echo "    - $f"; done
    DRIFT_FOUND=true
    REPORT+=("P0 flows sin test: ${P0_NO_TEST[*]}")
  else
    ok "  CHECK 3 OK — todos los flujos P0 tienen tests"
  fi
fi

# ─── CHECK 4: campos UNKNOWN en docs requeridos ───────────────────────────────

log "CHECK 4 — Campos UNKNOWN en docs requeridos..."

REQUIRED_DOCS=(PRODUCT_SURFACE.md USER_FLOW_MATRIX.md ARCHITECTURE.md INTEGRATIONS.md OPERATIONS.md)
HIGH_UNKNOWN=()

for doc in "${REQUIRED_DOCS[@]}"; do
  if [[ -f "docs-system/$doc" ]]; then
    COUNT=$(grep -c "^UNKNOWN$\|: UNKNOWN$\|UNKNOWN$" "docs-system/$doc" 2>/dev/null || echo 0)
    if [[ "$COUNT" -gt 5 ]]; then
      HIGH_UNKNOWN+=("$doc ($COUNT campos sin completar)")
    fi
  fi
done

if [[ ${#HIGH_UNKNOWN[@]} -gt 0 ]]; then
  warn "  Docs con muchos campos UNKNOWN (posible Phase 0 incompleta):"
  for d in "${HIGH_UNKNOWN[@]}"; do echo "    - $d"; done
  DRIFT_FOUND=true
  REPORT+=("Docs incompletos: ${HIGH_UNKNOWN[*]}")
else
  ok "  CHECK 4 OK — docs dentro del umbral de completitud"
fi

# ─── Resultado ────────────────────────────────────────────────────────────────

echo ""
echo "────────────────────────────────────────────"

if [[ "$DRIFT_FOUND" == "true" ]]; then
  fail "DRIFT DETECTADO — docs-system diverge del código real"
  echo ""
  echo "  Opciones:"
  echo "  1. Ejecutar Momento 4 (re-sync): pedirle al agente que actualice los docs"
  echo "  2. Crear issue para registrarlo: bash scripts/drift-detector.sh --fix"
  echo ""

  if [[ "$CREATE_ISSUE" == "true" ]] && command -v gh &>/dev/null; then
    BODY="## Drift detectado — docs-system desactualizado"$'\n\n'
    for item in "${REPORT[@]}"; do
      BODY+="- $item"$'\n'
    done
    BODY+=$'\n'"Ejecutar Momento 4 del Engineering Governance Framework para re-sincronizar."

    gh issue create \
      --title "docs: drift detectado — docs-system desactualizado" \
      --body "$BODY" \
      --label "documentation,governance-framework" 2>/dev/null && \
      success "Issue creado en GitHub" || warn "No se pudo crear el issue (verificar gh auth)"
  fi

  exit 1
else
  ok "SIN DRIFT — docs-system sincronizado con el código"
fi

echo "────────────────────────────────────────────"
echo ""
