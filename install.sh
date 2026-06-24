#!/usr/bin/env bash
# install.sh — Engineering Governance Framework
#
# Instala el framework en el repositorio actual.
# Uso:
#   bash install.sh                      # instala todo
#   bash install.sh --tool cursor        # solo el adapter de Cursor
#   bash install.sh --tool copilot       # solo GitHub Copilot
#   bash install.sh --tool claude        # solo Claude Code
#   bash install.sh --tool windsurf      # solo Windsurf
#   bash install.sh --tool cline         # solo Cline / Roo
#   bash install.sh --tool aider         # solo Aider
#   bash install.sh --no-docs            # no crear /docs-system
#   bash install.sh --dry-run            # mostrar qué haría sin hacer nada

set -euo pipefail

# ─── Config ───────────────────────────────────────────────────────────────────

REPO_URL="https://raw.githubusercontent.com/gefm2002/ai-engineering-governance/main"
FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${PWD}"
DRY_RUN=false
INSTALL_DOCS=true
TOOL=""

# ─── Args ─────────────────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tool)    TOOL="$2";    shift 2 ;;
    --no-docs) INSTALL_DOCS=false;   shift ;;
    --dry-run) DRY_RUN=true;         shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ─── Helpers ──────────────────────────────────────────────────────────────────

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()     { echo -e "${BLUE}[governance]${NC} $*"; }
success() { echo -e "${GREEN}[governance]${NC} $*"; }
warn()    { echo -e "${YELLOW}[governance]${NC} $*"; }

copy_file() {
  local src="$1"
  local dst="$2"

  if [[ "$DRY_RUN" == "true" ]]; then
    log "[dry-run] Would create: $dst"
    return
  fi

  mkdir -p "$(dirname "$dst")"

  if [[ -f "$dst" ]]; then
    warn "Already exists, skipping: $dst"
  else
    cp "$src" "$dst"
    success "Created: $dst"
  fi
}

fetch_file() {
  local path="$1"
  local dst="$2"

  if [[ "$DRY_RUN" == "true" ]]; then
    log "[dry-run] Would fetch: $path → $dst"
    return
  fi

  mkdir -p "$(dirname "$dst")"

  if [[ -f "$dst" ]]; then
    warn "Already exists, skipping: $dst"
    return
  fi

  if command -v curl &>/dev/null; then
    curl -fsSL "${REPO_URL}/${path}" -o "$dst"
  elif command -v wget &>/dev/null; then
    wget -q "${REPO_URL}/${path}" -O "$dst"
  else
    echo "Error: curl or wget is required." >&2
    exit 1
  fi

  success "Created: $dst"
}

# ─── Detectar si estamos dentro del framework o instalando desde remoto ───────

if [[ -f "${FRAMEWORK_DIR}/rules/engineering-governance.md" ]]; then
  USE_LOCAL=true
  log "Using local framework at: $FRAMEWORK_DIR"
else
  USE_LOCAL=false
  log "Fetching framework from: $REPO_URL"
fi

# ─── Función: obtener archivo (local o remoto) ────────────────────────────────

get_file() {
  local relative_path="$1"
  local dst="$2"

  if [[ "$USE_LOCAL" == "true" ]]; then
    copy_file "${FRAMEWORK_DIR}/${relative_path}" "$dst"
  else
    fetch_file "$relative_path" "$dst"
  fi
}

# ─── Instalar regla genérica ──────────────────────────────────────────────────

install_core_rule() {
  log "Installing core rule..."
  get_file "rules/engineering-governance.md" "${TARGET_DIR}/.agent/rules/engineering-governance.md"
  get_file "AGENT_BOOTSTRAP.md" "${TARGET_DIR}/.agent/AGENT_BOOTSTRAP.md"
}

# ─── Instalar adapters ────────────────────────────────────────────────────────

install_cursor() {
  log "Installing Cursor adapter..."
  get_file "adapters/cursor.mdc" "${TARGET_DIR}/.cursor/rules/engineering-governance.mdc"
}

install_copilot() {
  log "Installing GitHub Copilot adapter..."
  get_file "adapters/copilot.md" "${TARGET_DIR}/.github/copilot-instructions.md"
}

install_claude() {
  log "Installing Claude Code adapter..."
  local dst="${TARGET_DIR}/CLAUDE.md"

  if [[ -f "$dst" ]]; then
    warn "CLAUDE.md already exists."
    if [[ "$DRY_RUN" == "false" ]]; then
      warn "Appending governance section to existing CLAUDE.md..."
      echo "" >> "$dst"
      echo "---" >> "$dst"
      echo "" >> "$dst"
      if [[ "$USE_LOCAL" == "true" ]]; then
        cat "${FRAMEWORK_DIR}/adapters/claude.md" >> "$dst"
      else
        curl -fsSL "${REPO_URL}/adapters/claude.md" >> "$dst"
      fi
      success "Appended to: $dst"
    else
      log "[dry-run] Would append governance section to existing CLAUDE.md"
    fi
  else
    get_file "adapters/claude.md" "$dst"
  fi
}

install_windsurf() {
  log "Installing Windsurf adapter..."
  get_file "adapters/windsurf.md" "${TARGET_DIR}/.windsurfrules"
}

install_cline() {
  log "Installing Cline/Roo adapter..."
  get_file "adapters/cline.md" "${TARGET_DIR}/.clinerules"
}

install_aider() {
  log "Installing Aider adapter..."
  get_file "adapters/aider.md" "${TARGET_DIR}/.agent/adapters/aider.md"
}

install_codex() {
  log "Installing OpenAI Codex adapter..."
  local dst="${TARGET_DIR}/AGENTS.md"

  if [[ -f "$dst" ]]; then
    warn "AGENTS.md already exists."
    if [[ "$DRY_RUN" == "false" ]]; then
      warn "Appending governance section to existing AGENTS.md..."
      echo "" >> "$dst"
      echo "---" >> "$dst"
      echo "" >> "$dst"
      if [[ "$USE_LOCAL" == "true" ]]; then
        cat "${FRAMEWORK_DIR}/adapters/codex.md" >> "$dst"
      else
        curl -fsSL "${REPO_URL}/adapters/codex.md" >> "$dst"
      fi
      success "Appended to: $dst"
    else
      log "[dry-run] Would append governance section to existing AGENTS.md"
    fi
  else
    get_file "adapters/codex.md" "$dst"
  fi
}

# ─── Instalar docs-system ─────────────────────────────────────────────────────

install_docs_system() {
  if [[ "$INSTALL_DOCS" == "false" ]]; then
    return
  fi

  local docs_dir="${TARGET_DIR}/docs-system"

  if [[ -d "$docs_dir" ]]; then
    warn "/docs-system already exists, skipping."
    return
  fi

  log "Creating /docs-system with blank templates..."

  # Documentos requeridos (todos los proyectos)
  local required_files=(
    "PRODUCT_SURFACE.md"
    "USER_FLOW_MATRIX.md"
    "ARCHITECTURE.md"
    "INTEGRATIONS.md"
    "OPERATIONS.md"
    "TECHNICAL_DEBT_ROADMAP.md"
    "GAPS.md"
  )

  # 00_INDEX se genera desde examples
  get_file "examples/docs-system/00_INDEX.md" "${docs_dir}/00_INDEX.md"

  for file in "${required_files[@]}"; do
    local template_key="${file%.md}"
    get_file "templates/${template_key}.template.md" "${docs_dir}/${file}"
  done

  # Documentos opcionales (se crean vacíos para que el agente los complete si aplica)
  local optional_files=(
    "PLATFORM_STATE.md"
    "PRODUCT_ROADMAP.md"
    "PERFORMANCE_REPORT.md"
    "TESTING_STRATEGY.md"
  )

  log "Creating optional docs (fill if relevant to your project)..."
  for file in "${optional_files[@]}"; do
    local template_key="${file%.md}"
    get_file "templates/${template_key}.template.md" "${docs_dir}/${file}"
  done
}

# ─── Crear GOVERNANCE_INSTALLED.md ───────────────────────────────────────────

mark_installed() {
  local dst="${TARGET_DIR}/.agent/GOVERNANCE_INSTALLED.md"
  local date_now
  date_now="$(date '+%Y-%m-%d')"

  if [[ "$DRY_RUN" == "true" ]]; then
    log "[dry-run] Would create: $dst"
    return
  fi

  mkdir -p "$(dirname "$dst")"
  cat > "$dst" <<EOF
# Governance Framework — Instalado

Fecha de instalación: ${date_now}
Herramienta configurada: ${TOOL:-all}
docs-system creado: ${INSTALL_DOCS}

## Próximo paso

Pedirle al agente activo:

\`\`\`
Ejecutá la Fase 0 del Engineering Governance Framework.
No modifiques código.
Leé la documentación disponible en /docs-system y generá un Repository Summary.
\`\`\`
EOF
  success "Created: $dst"
}

# ─── Main ─────────────────────────────────────────────────────────────────────

echo ""
log "Engineering Governance Framework — Installer"
log "Target: ${TARGET_DIR}"
echo ""

install_core_rule

case "$TOOL" in
  cursor)   install_cursor ;;
  copilot)  install_copilot ;;
  claude)   install_claude ;;
  windsurf) install_windsurf ;;
  cline)    install_cline ;;
  aider)    install_aider ;;
  codex)    install_codex ;;
  "")
    install_cursor
    install_copilot
    install_claude
    install_codex
    install_windsurf
    install_cline
    install_aider
    ;;
  *)
    echo "Unknown tool: $TOOL" >&2
    echo "Valid options: cursor, copilot, claude, codex, windsurf, cline, aider" >&2
    exit 1
    ;;
esac

install_docs_system
mark_installed

echo ""
success "Installation complete."
echo ""
echo "  Next step: ask your AI agent to execute Phase 0."
echo ""
echo "  Prompt:"
echo "  ┌─────────────────────────────────────────────────────────────────┐"
echo "  │ Ejecutá la Fase 0 del Engineering Governance Framework.         │"
echo "  │ No modifiques código.                                           │"
echo "  │ Leé /docs-system y generá un Repository Summary.               │"
echo "  └─────────────────────────────────────────────────────────────────┘"
echo ""
