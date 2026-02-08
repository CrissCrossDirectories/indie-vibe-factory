#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Indie Vibe HQ Factory v9.1 — spawn.sh
# Spawns a fully-configured Next.js project with overlay injection.
# ============================================================

FACTORY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECTS_DIR="${FACTORY_DIR}/projects"
OPS_LOG="${FACTORY_DIR}/OPS_LOG.md"
TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

# --- Logging ---
log() {
  echo "[spawn] $*"
  echo "- ${TIMESTAMP} | spawn | $*" >> "${OPS_LOG}"
}

die() {
  echo "[spawn] ❌ ERROR: $*" >&2
  echo "- ${TIMESTAMP} | spawn | ❌ ERROR: $*" >> "${OPS_LOG}"
  exit 1
}

# --- Preflight checks ---
preflight() {
  log "Preflight checks..."
  command -v node  >/dev/null 2>&1 || die "node is not installed"
  command -v npm   >/dev/null 2>&1 || die "npm is not installed"
  command -v npx   >/dev/null 2>&1 || die "npx is not installed"
  log "Preflight passed: node=$(node --version), npm=$(npm --version)"
}

# --- Parse arguments ---
PROJECT_NAME=""
TESTING="jest"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --testing=*)
      TESTING="${1#*=}"
      shift
      ;;
    --testing)
      TESTING="${2:-jest}"
      shift 2
      ;;
    -*)
      die "Unknown flag: $1"
      ;;
    *)
      if [[ -z "$PROJECT_NAME" ]]; then
        PROJECT_NAME="$1"
      else
        die "Unexpected argument: $1"
      fi
      shift
      ;;
  esac
done

# --- Validate project name ---
[[ -n "$PROJECT_NAME" ]] || die "Usage: spawn.sh <project-name> [--testing=jest|vitest]"

if ! echo "$PROJECT_NAME" | grep -qE '^[a-z0-9-]+$'; then
  die "Invalid project name '$PROJECT_NAME'. Must match ^[a-z0-9-]+$ (lowercase, numbers, hyphens only)"
fi

# --- Validate testing flag ---
case "$TESTING" in
  jest|vitest) ;;
  *) die "Invalid testing option '$TESTING'. Must be 'jest' or 'vitest'" ;;
esac

# --- Select overlay ---
if [[ "$TESTING" == "vitest" ]]; then
  OVERLAY_DIR="${FACTORY_DIR}/_overlay-vitest"
else
  OVERLAY_DIR="${FACTORY_DIR}/_overlay"
fi

log "Project: ${PROJECT_NAME} | Testing: ${TESTING} | Overlay: $(basename "$OVERLAY_DIR")"

# --- Create projects dir if missing ---
mkdir -p "${PROJECTS_DIR}"

# --- Check if project already exists ---
PROJECT_PATH="${PROJECTS_DIR}/${PROJECT_NAME}"
if [[ -d "$PROJECT_PATH" ]]; then
  die "Project '${PROJECT_NAME}' already exists at ${PROJECT_PATH}"
fi

# --- Integrity checks on overlay ---
check_overlay_integrity() {
  local overlay="$1"
  local testing="$2"

  # Common files that must exist
  local common_files=(
    "AI_RULES.md"
    "components.json"
    "README.md"
    "src/lib/utils.ts"
    "src/__tests__/smoke.test.tsx"
    "docs/ARCHITECTURE.md"
    "docs/DECISIONS.md"
    "docs/VISION.md"
    "docs/CHANGELOG.md"
  )

  for f in "${common_files[@]}"; do
    [[ -f "${overlay}/${f}" ]] || die "Overlay missing common file: ${f}"
  done

  # Testing-specific files
  if [[ "$testing" == "jest" ]]; then
    [[ -f "${overlay}/jest.config.ts" ]] || die "Overlay missing: jest.config.ts"
    [[ -f "${overlay}/jest.setup.ts" ]] || die "Overlay missing: jest.setup.ts"
  elif [[ "$testing" == "vitest" ]]; then
    [[ -f "${overlay}/vitest.config.ts" ]] || die "Overlay missing: vitest.config.ts"
    [[ -f "${overlay}/vitest.setup.ts" ]] || die "Overlay missing: vitest.setup.ts"
  fi

  log "Overlay integrity check passed"
}

check_overlay_integrity "$OVERLAY_DIR" "$TESTING"

# --- Schema verification for components.json ---
verify_schema() {
  local cjson="$1"

  # MUST contain the raw schema URL
  if ! grep -q '"https://ui.shadcn.com/schema.json"' "$cjson"; then
    die "components.json missing required \$schema URL"
  fi

  # MUST NOT contain markdown link syntax for schema
  if grep -qE '\[.*\]\(https://ui\.shadcn\.com/schema\.json\)' "$cjson"; then
    die "components.json contains markdown link syntax for schema — must be raw URL"
  fi

  log "Schema verification passed"
}

verify_schema "${OVERLAY_DIR}/components.json"

# --- Create Next.js app ---
log "Creating Next.js app with create-next-app..."
npx create-next-app@latest "${PROJECT_PATH}" \
  --typescript \
  --tailwind \
  --eslint \
  --app \
  --src-dir \
  --import-alias "@/*" \
  --disable-git \
  --use-npm \
  --yes

log "Next.js app created at ${PROJECT_PATH}"

# --- Overlay injection ---
log "Injecting overlay files..."

# Use rsync if available (with itemize), else fall back to cp
if command -v rsync >/dev/null 2>&1; then
  rsync -av --itemize-changes "${OVERLAY_DIR}/" "${PROJECT_PATH}/"
  log "Overlay injected via rsync"
else
  cp -R "${OVERLAY_DIR}/"* "${PROJECT_PATH}/"
  # Also copy hidden files if any
  cp -R "${OVERLAY_DIR}/".[!.]* "${PROJECT_PATH}/" 2>/dev/null || true
  log "Overlay injected via cp"
fi

# --- Install dependencies ---
log "Installing dependencies..."
cd "${PROJECT_PATH}"

# Common shadcn/ui deps
npm install clsx tailwind-merge lucide-react class-variance-authority

# Testing dependencies (conditional)
if [[ "$TESTING" == "jest" ]]; then
  npm install --save-dev jest @jest/types ts-jest @types/jest \
    jest-environment-jsdom @testing-library/react @testing-library/jest-dom \
    @testing-library/user-event
  log "Jest testing dependencies installed"
elif [[ "$TESTING" == "vitest" ]]; then
  npm install --save-dev vitest @vitejs/plugin-react jsdom \
    @testing-library/react @testing-library/jest-dom @testing-library/user-event
  log "Vitest testing dependencies installed"
fi

# --- Patch package.json scripts ---
log "Patching package.json scripts..."

# Read current package.json
PACKAGE_JSON="${PROJECT_PATH}/package.json"

if [[ "$TESTING" == "jest" ]]; then
  # Add jest test script
  node -e "
    const pkg = require('./package.json');
    pkg.scripts.test = 'jest';
    pkg.scripts['test:watch'] = 'jest --watch';
    pkg.scripts['test:coverage'] = 'jest --coverage';
    require('fs').writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
  "
  log "package.json patched with Jest scripts"
elif [[ "$TESTING" == "vitest" ]]; then
  # Add vitest test script
  node -e "
    const pkg = require('./package.json');
    pkg.scripts.test = 'vitest run';
    pkg.scripts['test:watch'] = 'vitest';
    pkg.scripts['test:coverage'] = 'vitest run --coverage';
    require('fs').writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
  "
  log "package.json patched with Vitest scripts"
fi

# --- Verification gate ---
log "Running verification gates..."

log "Gate 1/3: npm run lint"
npm run lint || die "Lint gate FAILED"
log "✅ Lint passed"

log "Gate 2/3: npm test"
npm test || die "Test gate FAILED"
log "✅ Tests passed"

log "Gate 3/3: npm run build"
npm run build || die "Build gate FAILED"
log "✅ Build passed"

# --- Finalize: .env.local + .gitignore ---
log "Finalizing project..."

# Create .env.local
cat > "${PROJECT_PATH}/.env.local" << 'EOF'
# Environment Variables
# Add your secrets and config here. This file is gitignored.
# NEXT_PUBLIC_API_URL=http://localhost:3000/api
EOF

# Ensure .env.local is in .gitignore
if ! grep -q '.env.local' "${PROJECT_PATH}/.gitignore" 2>/dev/null; then
  echo -e "\n# Local env\n.env.local" >> "${PROJECT_PATH}/.gitignore"
fi

# --- Git init + commit ---
log "Initializing git repository..."
cd "${PROJECT_PATH}"
git init
git add -A
git commit -m "feat: initial scaffold via Indie Vibe HQ Factory v9.1 (${TESTING})"
log "Git repository initialized with initial commit"

# --- Done ---
echo ""
echo "============================================================"
echo "🎉 Project '${PROJECT_NAME}' created successfully!"
echo "============================================================"
echo ""
echo "  Path:    ${PROJECT_PATH}"
echo "  Testing: ${TESTING}"
echo "  Status:  ✅ lint | ✅ test | ✅ build"
echo ""
echo "  cd ${PROJECT_PATH} && npm run dev"
echo ""

log "Project '${PROJECT_NAME}' spawned and verified successfully at ${PROJECT_PATH}"
