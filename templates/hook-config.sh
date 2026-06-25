#!/usr/bin/env bash
# .governance/hook-config.sh — configuración del pre-push hook
#
# Copiar a .governance/hook-config.sh en el repo objetivo.
# Este archivo sobreescribe la auto-detección del hook.
# Commitear este archivo junto con el código del repo.

# ─── Comandos de test ─────────────────────────────────────────────────────────

# Comando para correr el test suite completo
# El hook lo corre antes de cada push — debe terminar con exit 0 si pasan
TEST_CMD="npm test"

# Comando que genera el reporte de coverage
# Si es el mismo que TEST_CMD con flags adicionales, especificarlo acá
COVERAGE_CMD="npm run test:ci -- --coverage"

# Ruta al archivo de reporte de coverage generado por COVERAGE_CMD
# Jest:    coverage/coverage-summary.json
# pytest:  coverage.json
# go:      coverage.out
COVERAGE_FILE="coverage/coverage-summary.json"

# ─── Umbrales ─────────────────────────────────────────────────────────────────

# Coverage mínimo total para permitir el push (%)
# P0 flows sin este coverage → push bloqueado
COVERAGE_THRESHOLD=80

# ─── Ejemplos por stack ───────────────────────────────────────────────────────

# Node.js / TypeScript (Jest)
# TEST_CMD="npm test"
# COVERAGE_CMD="npm run test:ci -- --coverage --coverageReporters=json-summary"
# COVERAGE_FILE="coverage/coverage-summary.json"

# Python (pytest)
# TEST_CMD="pytest"
# COVERAGE_CMD="pytest --cov=src --cov-report=json"
# COVERAGE_FILE="coverage.json"

# Go
# TEST_CMD="go test ./..."
# COVERAGE_CMD="go test -coverprofile=coverage.out ./..."
# COVERAGE_FILE="coverage.out"

# Ruby (RSpec)
# TEST_CMD="bundle exec rspec"
# COVERAGE_CMD="bundle exec rspec --format progress"
# COVERAGE_FILE="coverage/.last_run.json"
