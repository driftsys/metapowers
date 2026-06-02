#!/usr/bin/env bash
# Detect → install via the available package manager → signal fallback.
# Never sudo blindly; never mutate global shell config; never hard-fail.
# Phase 1: renderers only (PlantUML[+Java+Graphviz], D2). draw.io handled separately.
set -uo pipefail

ensure_tool() {  # ensure_tool <cmd> <macos-install> <debian-install>
  local cmd="$1" mac="$2" deb="$3"
  command -v "$cmd" >/dev/null 2>&1 && return 0
  case "$(uname -s)" in
    Darwin) command -v brew >/dev/null 2>&1 && [ -n "$mac" ] && eval "$mac" >&2 || true ;;
    Linux)
      local SUDO=""
      if [ "$(id -u)" -ne 0 ]; then command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null && SUDO="sudo"; fi
      if [ "$(id -u)" -eq 0 ] || [ -n "$SUDO" ]; then
        command -v apt-get >/dev/null 2>&1 && [ -n "$deb" ] && { $SUDO apt-get update -qq; eval "${deb/sudo /$SUDO }" >&2; } || true
      else echo "ensure_tool: no root/sudo; cannot install '$cmd' — will use fallback." >&2; fi ;;
  esac
  command -v "$cmd" >/dev/null 2>&1 && return 0
  echo "ensure_tool: '$cmd' unavailable — fallback (emit source / WSL2 / web editor)." >&2
  return 1
}

# Each tool degrades on its own: ensure_tool logs the fallback to stderr and
# returns non-zero. Phase 1 has no downstream consumer of the result, so we just
# let it continue (the renderers' skills handle a missing renderer by emitting
# source). D2 has no apt package, so on Linux it falls back to the install script.
ensure_tool plantuml "brew install plantuml" "apt-get install -y plantuml default-jre graphviz" || true
ensure_tool dot      "brew install graphviz"  "apt-get install -y graphviz"                      || true
ensure_tool d2       "brew install d2"         ""  || curl -fsSL https://d2lang.com/install.sh | sh -s -- || true
