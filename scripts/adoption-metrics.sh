#!/usr/bin/env bash
# adoption-metrics.sh — estado de adopción del framework en múltiples repos
#
# Uso:
#   bash scripts/adoption-metrics.sh --repos-file repos.txt
#   bash scripts/adoption-metrics.sh --repos-file repos.txt --csv  # exportar CSV

set -euo pipefail

REPOS_FILE=""
CSV_OUTPUT=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repos-file) REPOS_FILE="$2"; shift 2 ;;
    --csv)        CSV_OUTPUT=true; shift ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

if [[ -z "$REPOS_FILE" || ! -f "$REPOS_FILE" ]]; then
  echo "Uso: bash scripts/adoption-metrics.sh --repos-file repos.txt"
  exit 1
fi

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# ─── Métricas ─────────────────────────────────────────────────────────────────

TOTAL=0
HAS_FRAMEWORK=0
HAS_DOCS=0
HAS_HOOK=0
HAS_CI=0
HAS_P0_TESTS=0
FULL_ADOPTION=0

declare -a ROWS=()

check_repo() {
  local repo_path="$1"
  local repo_name
  repo_name="$(basename "$repo_path")"

  local framework="✗" docs="✗" hook="✗" ci="✗" p0_tests="✗" unknown_count="—" p0_count="—"

  # Framework instalado
  if [[ -f "$repo_path/.agent/GOVERNANCE_INSTALLED.md" ]]; then
    framework="✓"
    HAS_FRAMEWORK=$((HAS_FRAMEWORK + 1))
  fi

  # docs-system completo (mínimo 7 archivos requeridos)
  local docs_count=0
  for f in PRODUCT_SURFACE USER_FLOW_MATRIX ARCHITECTURE INTEGRATIONS OPERATIONS TECHNICAL_DEBT_ROADMAP GAPS; do
    [[ -f "$repo_path/docs-system/${f}.md" ]] && docs_count=$((docs_count + 1))
  done
  if [[ "$docs_count" -ge 7 ]]; then
    docs="✓ ($docs_count/7)"
    HAS_DOCS=$((HAS_DOCS + 1))

    # Campos UNKNOWN
    unknown_count=$(grep -rch "^UNKNOWN$\|: UNKNOWN$" "$repo_path/docs-system/" 2>/dev/null \
      | awk '{sum+=$1} END {print sum}' || echo "0")
  elif [[ "$docs_count" -gt 0 ]]; then
    docs="⚠ ($docs_count/7)"
  fi

  # pre-push hook activo
  if [[ -f "$repo_path/.git/hooks/pre-push" ]] && \
     grep -q "governance" "$repo_path/.git/hooks/pre-push" 2>/dev/null; then
    hook="✓"
    HAS_HOOK=$((HAS_HOOK + 1))
  fi

  # CI instalado
  local ci_count=0
  [[ -f "$repo_path/.github/workflows/quality-gate.yml" ]] && ci_count=$((ci_count + 1))
  [[ -f "$repo_path/.github/workflows/docs-validation.yml" ]] && ci_count=$((ci_count + 1))
  [[ -f "$repo_path/.github/workflows/release-readiness.yml" ]] && ci_count=$((ci_count + 1))
  if [[ "$ci_count" -gt 0 ]]; then
    ci="✓ ($ci_count jobs)"
    HAS_CI=$((HAS_CI + 1))
  fi

  # Flujos P0 con tests
  if [[ -f "$repo_path/docs-system/USER_FLOW_MATRIX.md" ]]; then
    local p0_total p0_covered=0
    p0_total=$(grep -cE "^\s*\|\s*UF-[0-9]+" "$repo_path/docs-system/USER_FLOW_MATRIX.md" 2>/dev/null \
      | grep -c "P0" 2>/dev/null || true)
    p0_total=$(grep -E "^\s*\|\s*UF-[0-9]+.*P0" "$repo_path/docs-system/USER_FLOW_MATRIX.md" 2>/dev/null | wc -l | tr -d ' ')

    if [[ "$p0_total" -gt 0 ]]; then
      local p0_flows
      p0_flows=$(grep -E "^\s*\|\s*UF-[0-9]+" "$repo_path/docs-system/USER_FLOW_MATRIX.md" \
        | grep "P0" | grep -oE "UF-[0-9]+" 2>/dev/null || true)
      for flow_id in $p0_flows; do
        find "$repo_path" -type f \( -name "*.spec.ts" -o -name "*.test.ts" -o -name "*.spec.js" \) \
          -not -path "*/node_modules/*" \
          | xargs grep -l "$flow_id" 2>/dev/null | grep -q . && p0_covered=$((p0_covered + 1)) || true
      done
      p0_count="${p0_covered}/${p0_total}"
      if [[ "$p0_covered" -eq "$p0_total" ]] && [[ "$p0_total" -gt 0 ]]; then
        p0_tests="✓"
        HAS_P0_TESTS=$((HAS_P0_TESTS + 1))
      else
        p0_tests="⚠ $p0_count"
      fi
    else
      p0_tests="— (sin P0)"
    fi
  fi

  # Adopción completa
  if [[ "$framework" == "✓" && "$docs" == ✓* && "$hook" == "✓" ]]; then
    FULL_ADOPTION=$((FULL_ADOPTION + 1))
  fi

  ROWS+=("$repo_name|$framework|$docs|$hook|$ci|$p0_tests|$unknown_count")
}

# ─── Procesar repos ───────────────────────────────────────────────────────────

while IFS= read -r repo_path || [[ -n "$repo_path" ]]; do
  [[ -z "$repo_path" || "$repo_path" == \#* ]] && continue
  repo_path="${repo_path%/}"
  [[ ! -d "$repo_path" ]] && continue
  TOTAL=$((TOTAL + 1))
  check_repo "$repo_path"
done < "$REPOS_FILE"

# ─── Output ───────────────────────────────────────────────────────────────────

if [[ "$CSV_OUTPUT" == "true" ]]; then
  echo "repo,framework,docs,hook,ci,p0_tests,unknown_fields"
  for row in "${ROWS[@]}"; do
    echo "$row"
  done
  exit 0
fi

echo ""
echo -e "${BLUE}══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Engineering Governance — Adoption Metrics${NC}"
echo -e "${BLUE}══════════════════════════════════════════════════${NC}"
echo ""

# Tabla
printf "%-30s %-12s %-10s %-8s %-12s %-12s %-10s\n" \
  "REPO" "FRAMEWORK" "DOCS" "HOOK" "CI" "P0 TESTS" "UNKNOWNS"
printf "%-30s %-12s %-10s %-8s %-12s %-12s %-10s\n" \
  "──────────────────────────────" "────────────" "──────────" "────────" "────────────" "────────────" "──────────"

for row in "${ROWS[@]}"; do
  IFS='|' read -r name fw docs hook ci p0 unk <<< "$row"
  printf "%-30s %-12s %-10s %-8s %-12s %-12s %-10s\n" \
    "$name" "$fw" "$docs" "$hook" "$ci" "$p0" "$unk"
done

echo ""
echo "──────────────────────────────────────────────────"

PCT_FRAMEWORK=$(( HAS_FRAMEWORK * 100 / (TOTAL > 0 ? TOTAL : 1) ))
PCT_DOCS=$(( HAS_DOCS * 100 / (TOTAL > 0 ? TOTAL : 1) ))
PCT_HOOK=$(( HAS_HOOK * 100 / (TOTAL > 0 ? TOTAL : 1) ))
PCT_FULL=$(( FULL_ADOPTION * 100 / (TOTAL > 0 ? TOTAL : 1) ))

echo "  Total repos:        $TOTAL"
echo "  Framework:          $HAS_FRAMEWORK/$TOTAL  (${PCT_FRAMEWORK}%)"
echo "  Docs completos:     $HAS_DOCS/$TOTAL  (${PCT_DOCS}%)"
echo "  Hook activo:        $HAS_HOOK/$TOTAL  (${PCT_HOOK}%)"
echo "  CI instalado:       $HAS_CI/$TOTAL"
echo "  P0 cubiertos:       $HAS_P0_TESTS/$TOTAL"
echo -e "  ${GREEN}Adopción completa:  $FULL_ADOPTION/$TOTAL  (${PCT_FULL}%)${NC}"
echo "──────────────────────────────────────────────────"
echo ""
