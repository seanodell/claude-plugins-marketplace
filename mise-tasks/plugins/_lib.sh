#!/usr/bin/env zsh
# Shared helpers for the plugins:* tasks. Not a task itself (leading underscore).

[[ -n "${MISE_ORIGINAL_CWD}" ]] && cd "$MISE_ORIGINAL_CWD"

header()  { print -P "\n%B$*%b"; }
success() { print -P "%F{green}✓%f $*"; }
info()    { print -P "%F{cyan}•%f $*"; }
warn()    { print -P "%F{yellow}!%f $*"; }
error()   { print -P "%F{red}✗%f $*" >&2; }
dim()     { print -P "%F{8}$*%f"; }

ask() {
    local prompt="$1" default="${2:-}"
    [[ -n "$default" ]] && prompt="$prompt [$default]"
    print -Pn "%B${prompt}:%b " >&2
    read -r REPLY
    [[ -z "$REPLY" && -n "$default" ]] && REPLY="$default"
}

confirm() {
    print -Pn "%B$1%b [Y/n] " >&2
    read -r REPLY
    [[ "${REPLY:l}" != n* ]]
}

# Guard: the plugins tasks shell out to the Claude CLI. Fail clearly before
# mutating any marketplace/plugin state if it isn't available.
need_claude() {
    if ! command -v claude &>/dev/null; then
        error "The 'claude' CLI is not on PATH — install Claude Code and try again."
        exit 1
    fi
}

# Guard: name detection parses `claude ... --json` with jq (mise-provisioned).
need_jq() {
    if ! command -v jq &>/dev/null; then
        error "'jq' is not on PATH — run 'mise install' to provision it, then retry."
        exit 1
    fi
}

# True if a marketplace with this exact name is registered.
marketplace_registered() {
    claude plugin marketplace list --json 2>/dev/null \
        | jq -e --arg m "$1" 'any(.[]; .name == $m)' >/dev/null 2>&1
}

# True if a plugin with this exact id (<plugin>@<marketplace>) is installed.
plugin_installed() {
    claude plugin list --json 2>/dev/null \
        | jq -e --arg id "$1" 'any(.[]; .id == $id)' >/dev/null 2>&1
}
