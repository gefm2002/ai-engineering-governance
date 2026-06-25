#!/usr/bin/env bash
# .governance/jira-config.sh — configuración de Jira para este repo
#
# Copiar a .governance/jira-config.sh en el repo objetivo.
# IMPORTANTE: agregar .governance/jira-config.sh a .gitignore
# (contiene el API token — no commitear)

JIRA_BASE_URL="https://tu-empresa.atlassian.net"
JIRA_PROJECT_KEY="PROJ"       # clave del proyecto en Jira (ej: STOCK, DSS, MKP)
JIRA_TOKEN=""                  # https://id.atlassian.com/manage-profile/security/api-tokens
JIRA_EMAIL="tu@cencosud.com"

# Opcional: epic donde agrupar todos los tickets de governance de este repo
JIRA_EPIC_KEY=""               # ej: PROJ-100

# Tipos de issue (ajustar según la configuración de tu instancia de Jira)
ISSUE_TYPE_P0="Bug"            # P0 gaps = bugs críticos
ISSUE_TYPE_P1="Story"          # P1 gaps = stories
ISSUE_TYPE_P2="Task"           # P2 gaps = tasks
ISSUE_TYPE_DEBT="Task"         # deuda técnica = tasks
