#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

error() {
    echo -e "${RED}Error:${RESET} $1" >&2
    exit 1
}

info() {
    echo -e "${GREEN}→${RESET} $1"
}

warn() {
    echo -e "${YELLOW}Warning:${RESET} $1"
}

if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "Not a git repository. Please run this script from the repository root."
fi

UPSTREAM_VERSION="${1:-}"
PATCH_LEVEL="${2:-0}"

if [[ -z "$UPSTREAM_VERSION" ]]; then
    echo "Usage: $0 <upstream-version> [patch-level]"
    echo ""
    echo "Arguments:"
    echo "  upstream-version   arkenfox version to target (e.g., 144.0)"
    echo "  patch-level        local patch level (default: 0)"
    echo ""
    echo "Examples:"
    echo "  $0 144.0           # creates tag v144.0"
    echo "  $0 144.0 1         # creates tag v144.0-1"
    exit 1
fi

if [[ ! "$UPSTREAM_VERSION" =~ ^[0-9]+\.[0-9]+$ ]]; then
    error "Invalid upstream version format: '$UPSTREAM_VERSION'. Expected format: NNN.N (e.g., 144.0)"
fi

if [[ ! "$PATCH_LEVEL" =~ ^[0-9]+$ ]]; then
    error "Invalid patch level: '$PATCH_LEVEL'. Must be a non-negative integer."
fi

TAG_NAME="v${UPSTREAM_VERSION}"
if [[ "$PATCH_LEVEL" != "0" ]]; then
    TAG_NAME="${TAG_NAME}-${PATCH_LEVEL}"
fi

info "Preparing signed tag: ${TAG_NAME}"

if git rev-parse "$TAG_NAME" > /dev/null 2>&1; then
    error "Tag '${TAG_NAME}' already exists. To remove it locally: git tag -d ${TAG_NAME}"
fi

if [[ -n "$(git status --porcelain)" ]]; then
    warn "Working directory has uncommitted changes:"
    git status --short
    echo ""
    read -r -p "Continue anyway? [y/N] " confirm_dirty
    if [[ "$confirm_dirty" != "y" && "$confirm_dirty" != "Y" ]]; then
        info "Aborted."
        exit 0
    fi
fi

SIGNING_KEY=$(git config user.signingkey || echo "")
USE_GPG=false

if [[ -n "$SIGNING_KEY" ]]; then
    if gpg --list-secret-keys "$SIGNING_KEY" > /dev/null 2>&1; then
        USE_GPG=true
        info "GPG signing key found: ${SIGNING_KEY}"
    else
        warn "Git user.signingkey (${SIGNING_KEY}) not found in GPG keyring."
    fi
else
    warn "Git user.signingkey not set."
fi

if [[ "$USE_GPG" == false ]]; then
    warn "GPG signing is not configured."
    echo "  To configure: git config user.signingkey <KEY-ID>"
    echo "  To generate a key: gpg --full-generate-key"
    echo ""
    read -r -p "Create an UNSIGNED tag instead? [y/N] " confirm_unsigned
    if [[ "$confirm_unsigned" != "y" && "$confirm_unsigned" != "Y" ]]; then
        info "Aborted."
        exit 0
    fi
fi

LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [[ -n "$LAST_TAG" ]]; then
    CHANGES=$(git log --oneline --no-decorate "${LAST_TAG}..HEAD" -- . 2>/dev/null || true)
    if [[ -z "$CHANGES" ]]; then
        CHANGES="(No commits since ${LAST_TAG})"
    fi
else
    CHANGES=$(git log --oneline --no-decorate HEAD -- . 2>/dev/null | head -20 || true)
    if [[ -z "$CHANGES" ]]; then
        CHANGES="(Initial release)"
    fi
fi

TAG_MESSAGE="arkenfox override recipes ${TAG_NAME}

Upstream: arkenfox/user.js v${UPSTREAM_VERSION}
Patch Level: ${PATCH_LEVEL}
Date: $(date -u +%Y-%m-%d)

## Changes since ${LAST_TAG:-initial}
${CHANGES}

## Checklist
- [ ] user-overrides.js is up-to-date
- [ ] README updated (if needed)
- [ ] Version compatibility verified with arkenfox v${UPSTREAM_VERSION}"

echo ""
echo "=================================="
echo "Tag:        ${TAG_NAME}"
echo "Upstream:   arkenfox/user.js v${UPSTREAM_VERSION}"
echo "Patch:      ${PATCH_LEVEL}"
echo "Signed:     ${USE_GPG}"
echo "Last tag:   ${LAST_TAG:-(none)}"
echo "=================================="
echo ""
echo "Tag message preview:"
echo "---"
echo "$TAG_MESSAGE"
echo "---"
echo ""

read -r -p "Edit tag message before creating? [y/N] " confirm_edit
TAG_MESSAGE_FILE=""
if [[ "$confirm_edit" == "y" || "$confirm_edit" == "Y" ]]; then
    TAG_MESSAGE_FILE=$(mktemp)
    echo "$TAG_MESSAGE" > "$TAG_MESSAGE_FILE"
    ${EDITOR:-vim} "$TAG_MESSAGE_FILE"
    info "Tag message updated from editor."
    echo ""
    echo "Updated tag message:"
    echo "---"
    cat "$TAG_MESSAGE_FILE"
    echo "---"
    echo ""
fi

read -r -p "Create and push this tag? [y/N] " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    if [[ -n "$TAG_MESSAGE_FILE" ]]; then
        rm -f "$TAG_MESSAGE_FILE"
    fi
    info "Aborted. No tag was created."
    exit 0
fi

if [[ "$USE_GPG" == true ]]; then
    if [[ -n "$TAG_MESSAGE_FILE" ]]; then
        git tag -s "$TAG_NAME" -F "$TAG_MESSAGE_FILE"
    else
        git tag -s "$TAG_NAME" -m "$TAG_MESSAGE"
    fi
else
    if [[ -n "$TAG_MESSAGE_FILE" ]]; then
        git tag -a "$TAG_NAME" -F "$TAG_MESSAGE_FILE"
    else
        git tag -a "$TAG_NAME" -m "$TAG_MESSAGE"
    fi
fi

if [[ -n "$TAG_MESSAGE_FILE" ]]; then
    rm -f "$TAG_MESSAGE_FILE"
fi

info "Tag '${TAG_NAME}' created."

read -r -p "Push tag to origin? [y/N] " confirm_push
if [[ "$confirm_push" == "y" || "$confirm_push" == "Y" ]]; then
    git push origin "$TAG_NAME"
    info "Tag '${TAG_NAME}' pushed to origin."
else
    info "Tag '${TAG_NAME}' created locally but not pushed."
    echo "  To push later: git push origin ${TAG_NAME}"
fi

echo ""
if command -v gh > /dev/null 2>&1; then
    read -r -p "Create GitHub Release for '${TAG_NAME}'? [y/N] " confirm_release
    if [[ "$confirm_release" == "y" || "$confirm_release" == "Y" ]]; then
        gh release create "$TAG_NAME" \
            --title "arkenfox override recipes ${TAG_NAME}" \
            --notes "$(git tag -l --format='%(contents)' "$TAG_NAME")" \
            || warn "GitHub release creation failed."
    fi
else
    info "GitHub CLI (gh) not found. Install it to create releases automatically:"
    echo "  https://cli.github.com/"
    echo ""
    echo "Manual release URL:"
    echo "  https://github.com/$(git remote get-url origin | sed 's/.*github.com[:\/]//;s/\.git$//')/releases/new?tag=${TAG_NAME}"
fi

echo ""
echo "Done."
