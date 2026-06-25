#!/usr/bin/env bash
# install.sh — Engineering Governance Framework
#
# Uso:
#   bash install.sh                        # instala todo
#   bash install.sh --update               # actualiza adapters, hooks y CI sin tocar docs-system
#   bash install.sh --help                 # muestra ayuda completa
#   bash install.sh --status               # muestra qué está instalado en este repo
#   bash install.sh --tool cursor          # solo el adapter de Cursor
#   bash install.sh --tool claude          # solo Claude Code
#   bash install.sh --tool codex           # solo OpenAI Codex
#   bash install.sh --tool copilot         # solo GitHub Copilot
#   bash install.sh --tool windsurf        # solo Windsurf
#   bash install.sh --tool cline           # solo Cline / Roo
#   bash install.sh --tool aider           # solo Aider
#   bash install.sh --no-docs              # no crear /docs-system
#   bash install.sh --dry-run              # mostrar qué haría sin ejecutar

set -euo pipefail

# ─── Config ───────────────────────────────────────────────────────────────────

REPO_URL="https://raw.githubusercontent.com/gefm2002/ai-engineering-governance/main"
REPO_BASE="https://github.com/gefm2002/ai-engineering-governance"
FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${PWD}"
DRY_RUN=false
INSTALL_DOCS=true
TOOL=""
MODE="install"  # install | update | help | status

# ─── Args ─────────────────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tool)    TOOL="$2";       shift 2 ;;
    --no-docs) INSTALL_DOCS=false;      shift ;;
    --dry-run) DRY_RUN=true;            shift ;;
    --update)  MODE="update";           shift ;;
    --status)  MODE="status";           shift ;;
    --help|-h) MODE="help";             shift ;;
    *) echo "Unknown option: $1. Run with --help for usage." >&2; exit 1 ;;
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
    "DIAGRAMS.md"
    "ONBOARDING.md"
    "CHANGELOG.md"
  )

  log "Creating optional docs (fill if relevant to your project)..."
  for file in "${optional_files[@]}"; do
    local template_key="${file%.md}"
    get_file "templates/${template_key}.template.md" "${docs_dir}/${file}"
  done

  # Carpeta de propuestas de ticket para el PO
  mkdir -p "${docs_dir}/Tickets"
  if [[ ! -f "${docs_dir}/Tickets/.gitkeep" ]]; then
    printf "# Propuestas de ticket\n\nGeneradas por el agente durante Phase 0 / Phase 5.\nCada archivo es una propuesta para que el PO decida si crear el ticket en Jira.\n" \
      > "${docs_dir}/Tickets/README.md"
  fi
}

# ─── Instalar git hooks ───────────────────────────────────────────────────────

install_hooks() {
  local hooks_dir="${TARGET_DIR}/.git/hooks"

  if [[ ! -d "$hooks_dir" ]]; then
    warn "No .git/hooks directory found — skipping hooks install."
    return
  fi

  log "Installing pre-push hook..."
  get_file "hooks/pre-push" "${hooks_dir}/pre-push"

  if [[ "$DRY_RUN" == "false" && -f "${hooks_dir}/pre-push" ]]; then
    chmod +x "${hooks_dir}/pre-push"
    success "pre-push hook installed and made executable."
  fi
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

# ─── Help ─────────────────────────────────────────────────────────────────────

show_help() {
  echo ""
  echo -e "${GREEN}Engineering Governance Framework${NC}"
  echo "  Repositorio: ${REPO_BASE}"
  echo ""
  echo "COMANDOS:"
  echo ""
  echo "  bash install.sh                    Instalación completa"
  echo "  bash install.sh --update           Actualizar framework existente"
  echo "  bash install.sh --status           Ver qué está instalado"
  echo "  bash install.sh --help             Esta ayuda"
  echo ""
  echo "OPCIONES:"
  echo ""
  echo "  --tool <nombre>    Instalar solo el adapter para una herramienta:"
  echo "                       cursor | copilot | claude | codex | windsurf | cline | aider"
  echo "  --no-docs          No crear /docs-system (solo adapters y hooks)"
  echo "  --dry-run          Mostrar qué haría sin ejecutar nada"
  echo ""
  echo "HERRAMIENTAS SOPORTADAS:"
  echo ""
  echo "  cursor     →  .cursor/rules/engineering-governance.mdc"
  echo "  copilot    →  .github/copilot-instructions.md"
  echo "  claude     →  CLAUDE.md"
  echo "  codex      →  AGENTS.md"
  echo "  windsurf   →  .windsurfrules"
  echo "  cline      →  .clinerules"
  echo "  aider      →  .agent/adapters/aider.md"
  echo ""
  echo "QUÉ HACE --update:"
  echo ""
  echo "  • Actualiza adapters (sobreescribe con la versión más reciente)"
  echo "  • Actualiza la regla core (.agent/rules/engineering-governance.md)"
  echo "  • Actualiza el pre-push hook (.git/hooks/pre-push)"
  echo "  • NO toca /docs-system/ — tu documentación queda intacta"
  echo "  • NO toca CLAUDE.md, AGENTS.md ni otros archivos del repo"
  echo "    si ya existen — solo actualiza la sección de governance"
  echo ""
  echo "EJEMPLOS:"
  echo ""
  echo "  # Primera instalación desde internet"
  echo "  curl -fsSL ${REPO_URL}/install.sh | bash"
  echo ""
  echo "  # Actualizar a la última versión"
  echo "  curl -fsSL ${REPO_URL}/install.sh | bash -s -- --update"
  echo ""
  echo "  # Ver qué hay instalado"
  echo "  curl -fsSL ${REPO_URL}/install.sh | bash -s -- --status"
  echo ""
  echo "  # Instalar solo el adapter de Claude Code"
  echo "  curl -fsSL ${REPO_URL}/install.sh | bash -s -- --tool claude"
  echo ""
  echo "  # Simular instalación sin ejecutar"
  echo "  curl -fsSL ${REPO_URL}/install.sh | bash -s -- --dry-run"
  echo ""
}

# ─── Status ───────────────────────────────────────────────────────────────────

show_status() {
  echo ""
  echo -e "${GREEN}Engineering Governance Framework — Estado de instalación${NC}"
  echo "  Directorio: ${TARGET_DIR}"
  echo ""

  check_file() {
    local label="$1"
    local path="$2"
    if [[ -f "${TARGET_DIR}/${path}" ]]; then
      echo -e "  ${GREEN}✓${NC} ${label}"
      echo "      ${path}"
    else
      echo -e "  ${YELLOW}✗${NC} ${label} — no instalado"
      echo "      (esperado en: ${path})"
    fi
  }

  check_section() {
    local label="$1"
    local path="$2"
    local keyword="$3"
    if [[ -f "${TARGET_DIR}/${path}" ]] && grep -q "$keyword" "${TARGET_DIR}/${path}" 2>/dev/null; then
      echo -e "  ${GREEN}✓${NC} ${label}"
      echo "      ${path} (contiene sección governance)"
    elif [[ -f "${TARGET_DIR}/${path}" ]]; then
      echo -e "  ${YELLOW}⚠${NC}  ${label} — archivo existe pero sin sección governance"
      echo "      ${path}"
    else
      echo -e "  ${YELLOW}✗${NC} ${label} — no instalado"
    fi
  }

  echo "REGLA CORE:"
  check_file "Core rule" ".agent/rules/engineering-governance.md"
  check_file "Agent bootstrap" ".agent/AGENT_BOOTSTRAP.md"
  echo ""

  echo "ADAPTERS:"
  check_file "Cursor" ".cursor/rules/engineering-governance.mdc"
  check_file "GitHub Copilot" ".github/copilot-instructions.md"
  check_section "Claude Code" "CLAUDE.md" "Engineering Governance"
  check_section "OpenAI Codex" "AGENTS.md" "Engineering Governance"
  check_file "Windsurf" ".windsurfrules"
  check_file "Cline / Roo" ".clinerules"
  check_file "Aider" ".agent/adapters/aider.md"
  echo ""

  echo "HOOKS:"
  if [[ -f "${TARGET_DIR}/.git/hooks/pre-push" ]]; then
    echo -e "  ${GREEN}✓${NC} pre-push hook"
    echo "      .git/hooks/pre-push"
  else
    echo -e "  ${YELLOW}✗${NC} pre-push hook — no instalado"
    echo "      Sin este hook el push no valida docs-system"
  fi
  echo ""

  echo "DOCS-SYSTEM:"
  local docs_dir="${TARGET_DIR}/docs-system"
  if [[ ! -d "$docs_dir" ]]; then
    echo -e "  ${YELLOW}✗${NC} /docs-system no existe"
    echo "      Ejecutar: bash install.sh (sin --no-docs)"
  else
    local required=(00_INDEX.md PRODUCT_SURFACE.md USER_FLOW_MATRIX.md ARCHITECTURE.md INTEGRATIONS.md OPERATIONS.md TECHNICAL_DEBT_ROADMAP.md GAPS.md)
    local optional=(PLATFORM_STATE.md PRODUCT_ROADMAP.md PERFORMANCE_REPORT.md TESTING_STRATEGY.md DIAGRAMS.md ONBOARDING.md CHANGELOG.md)
    local missing_req=0

    echo "  Requeridos:"
    for f in "${required[@]}"; do
      if [[ -f "${docs_dir}/${f}" ]]; then
        local unknowns
        unknowns=$(grep -c "^UNKNOWN$\|: UNKNOWN$" "${docs_dir}/${f}" 2>/dev/null || echo 0)
        if [[ "$unknowns" -gt 5 ]]; then
          echo -e "  ${YELLOW}⚠${NC}  ${f} (${unknowns} campos UNKNOWN sin completar)"
        else
          echo -e "  ${GREEN}✓${NC} ${f}"
        fi
      else
        echo -e "  ${YELLOW}✗${NC} ${f} — falta"
        missing_req=$((missing_req + 1))
      fi
    done

    echo ""
    echo "  Opcionales:"
    for f in "${optional[@]}"; do
      if [[ -f "${docs_dir}/${f}" ]]; then
        echo -e "  ${GREEN}✓${NC} ${f}"
      else
        echo -e "  —  ${f} (no creado)"
      fi
    done

    if [[ "$missing_req" -gt 0 ]]; then
      echo ""
      echo -e "  ${YELLOW}⚠${NC}  Faltan $missing_req archivo(s) requeridos. Ejecutar: bash install.sh"
    fi
  fi

  echo ""
  echo "CI:"
  local ci_files=(".github/workflows/docs-validation.yml" ".github/workflows/quality-gate.yml" ".github/workflows/release-readiness.yml")
  local ci_found=false
  for f in "${ci_files[@]}"; do
    if [[ -f "${TARGET_DIR}/${f}" ]]; then
      echo -e "  ${GREEN}✓${NC} ${f}"
      ci_found=true
    fi
  done
  if [[ "$ci_found" == "false" ]]; then
    echo -e "  ${YELLOW}✗${NC} Sin CI de governance instalado"
    echo "      Copiar desde ci/ del framework y adaptar al stack del proyecto"
  fi

  local installed_file="${TARGET_DIR}/.agent/GOVERNANCE_INSTALLED.md"
  if [[ -f "$installed_file" ]]; then
    echo ""
    echo "INSTALACIÓN:"
    grep -E "^Fecha|^Herramienta" "$installed_file" | sed 's/^/  /'
  fi

  echo ""
}

# ─── Update ───────────────────────────────────────────────────────────────────

run_update() {
  echo ""
  log "Engineering Governance Framework — Update"
  log "Target: ${TARGET_DIR}"
  echo ""
  log "Qué se actualiza: adapters, regla core, pre-push hook"
  log "Qué NO se toca: /docs-system/, CLAUDE.md, AGENTS.md (contenido existente)"
  echo ""

  # Función de update: sobreescribe siempre (a diferencia de install que skipea)
  update_file() {
    local relative_path="$1"
    local dst="$2"

    if [[ "$DRY_RUN" == "true" ]]; then
      log "[dry-run] Would update: $dst"
      return
    fi

    if [[ ! -f "$dst" ]]; then
      warn "No existe, instalando por primera vez: $dst"
    fi

    mkdir -p "$(dirname "$dst")"

    if [[ "$USE_LOCAL" == "true" ]]; then
      cp "${FRAMEWORK_DIR}/${relative_path}" "$dst"
    else
      if command -v curl &>/dev/null; then
        curl -fsSL "${REPO_URL}/${relative_path}" -o "$dst"
      else
        wget -q "${REPO_URL}/${relative_path}" -O "$dst"
      fi
    fi
    success "Updated: $dst"
  }

  # Regla core
  log "Actualizando regla core..."
  update_file "rules/engineering-governance.md" "${TARGET_DIR}/.agent/rules/engineering-governance.md"
  update_file "AGENT_BOOTSTRAP.md" "${TARGET_DIR}/.agent/AGENT_BOOTSTRAP.md"

  # Adapters (solo los que ya están instalados)
  log "Actualizando adapters instalados..."

  [[ -f "${TARGET_DIR}/.cursor/rules/engineering-governance.mdc" ]] && \
    update_file "adapters/cursor.mdc" "${TARGET_DIR}/.cursor/rules/engineering-governance.mdc"

  [[ -f "${TARGET_DIR}/.github/copilot-instructions.md" ]] && \
    update_file "adapters/copilot.md" "${TARGET_DIR}/.github/copilot-instructions.md"

  [[ -f "${TARGET_DIR}/.windsurfrules" ]] && \
    update_file "adapters/windsurf.md" "${TARGET_DIR}/.windsurfrules"

  [[ -f "${TARGET_DIR}/.clinerules" ]] && \
    update_file "adapters/cline.md" "${TARGET_DIR}/.clinerules"

  [[ -f "${TARGET_DIR}/.agent/adapters/aider.md" ]] && \
    update_file "adapters/aider.md" "${TARGET_DIR}/.agent/adapters/aider.md"

  # CLAUDE.md y AGENTS.md: actualizar solo la sección de governance
  for file in "CLAUDE.md:adapters/claude.md" "AGENTS.md:adapters/codex.md"; do
    local dst_file="${file%%:*}"
    local src_file="${file##*:}"
    local dst="${TARGET_DIR}/${dst_file}"

    if [[ -f "$dst" ]] && grep -q "Engineering Governance" "$dst" 2>/dev/null; then
      if [[ "$DRY_RUN" == "false" ]]; then
        log "Actualizando sección governance en ${dst_file}..."
        # Remover sección anterior y re-agregar
        # Marcadores: línea "---" seguida de "# Engineering Governance"
        python3 - "$dst" "$src_file" "$REPO_URL" "$USE_LOCAL" "$FRAMEWORK_DIR" <<'PYEOF'
import sys, re, subprocess, urllib.request

dst, src_rel, repo_url, use_local, fw_dir = sys.argv[1:]

with open(dst) as f:
    content = f.read()

# Remover sección anterior de governance (desde "---\n\n# Engineering Governance" hasta el final o siguiente "---")
content = re.sub(r'\n---\n\n# Engineering Governance.*', '', content, flags=re.DOTALL)

# Obtener nuevo contenido del adapter
if use_local == "true":
    with open(f"{fw_dir}/{src_rel}") as f:
        new_section = f.read()
else:
    with urllib.request.urlopen(f"{repo_url}/{src_rel}") as r:
        new_section = r.read().decode()

content = content.rstrip() + "\n\n---\n\n" + new_section

with open(dst, 'w') as f:
    f.write(content)
print(f"Updated governance section in {dst}")
PYEOF
        success "Updated governance section in: ${dst}"
      else
        log "[dry-run] Would update governance section in: ${dst}"
      fi
    fi
  done

  # Hook
  local hooks_dir="${TARGET_DIR}/.git/hooks"
  if [[ -d "$hooks_dir" ]]; then
    log "Actualizando pre-push hook..."
    update_file "hooks/pre-push" "${hooks_dir}/pre-push"
    [[ "$DRY_RUN" == "false" ]] && chmod +x "${hooks_dir}/pre-push"
  fi

  # Nuevos templates opcionales en docs-system (sin sobreescribir los existentes)
  if [[ -d "${TARGET_DIR}/docs-system" ]]; then
    log "Verificando nuevos templates opcionales en docs-system..."
    local new_optionals=("TESTING_STRATEGY.md" "DIAGRAMS.md" "ONBOARDING.md" "CHANGELOG.md")
    for f in "${new_optionals[@]}"; do
      local dst="${TARGET_DIR}/docs-system/${f}"
      if [[ ! -f "$dst" ]]; then
        local template_key="${f%.md}"
        get_file "templates/${template_key}.template.md" "$dst"
        warn "Nuevo template opcional añadido: docs-system/${f}"
      fi
    done

    # Crear carpeta Tickets si no existe
    if [[ ! -d "${TARGET_DIR}/docs-system/Tickets" ]]; then
      [[ "$DRY_RUN" == "false" ]] && mkdir -p "${TARGET_DIR}/docs-system/Tickets"
      [[ "$DRY_RUN" == "false" ]] && printf "# Propuestas de ticket\n\nGeneradas por el agente durante Phase 0 / Phase 5.\nCada archivo es una propuesta para que el PO decida si crear el ticket en Jira.\n" \
        > "${TARGET_DIR}/docs-system/Tickets/README.md"
      warn "Carpeta docs-system/Tickets/ creada"
    fi
  fi

  echo ""
  success "Update completo."
  echo ""
  echo "  Verificar estado con:"
  echo "  bash install.sh --status"
  echo ""
}

# ─── Main ─────────────────────────────────────────────────────────────────────

# Modos que no necesitan detectar local/remoto ni el resto del setup
case "$MODE" in
  help)   show_help;   exit 0 ;;
  status) show_status; exit 0 ;;
  update) run_update;  exit 0 ;;
esac

# Modo install (default)
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
    echo "Unknown tool: $TOOL. Run with --help for valid options." >&2
    exit 1
    ;;
esac

install_docs_system
install_hooks
mark_installed

echo ""
success "Instalación completa."
echo ""
echo "  Verificar estado:  bash install.sh --status"
echo "  Ayuda:             bash install.sh --help"
echo ""
echo "  Próximo paso — pedirle al agente:"
echo "  ┌─────────────────────────────────────────────────────────────────┐"
echo "  │ Ejecutá la Fase 0 del Engineering Governance Framework.         │"
echo "  │ No modifiques código.                                           │"
echo "  │ Leé /docs-system y generá un Repository Summary.               │"
echo "  └─────────────────────────────────────────────────────────────────┘"
echo ""
