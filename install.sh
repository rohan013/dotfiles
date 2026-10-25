#!/usr/bin/env bash
# Sets up a fresh Mac: Claude Code rules, oh-my-zsh, iTerm2, key repeat.
# No sudo. Each step is independent; a failed step is reported and the rest still run.
#
#   ./install.sh [work-dir]            run everything (work-dir defaults to ~/work)
#   ./install.sh --dry-run [work-dir]  print what would happen

set -u

DIR="$(cd "$(dirname "$0")" && pwd)"
DRY=0
WORK="$HOME/work"
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY=1 ;;
    *) WORK="$arg" ;;
  esac
done

STAMP="$(date +%Y%m%d-%H%M%S)"
RESULTS=()
TODO=()

run() {
  if [ "$DRY" = 1 ]; then
    echo "  [dry-run] $*"
  else
    "$@"
  fi
}

backup() {
  if [ -e "$1" ]; then
    run cp -R "$1" "$1.bak-$STAMP"
    echo "  backed up $1 -> $1.bak-$STAMP"
  fi
}

step() {
  local name="$1"
  shift
  echo "==> $name"
  if "$@"; then
    RESULTS+=("ok    $name")
  else
    RESULTS+=("FAIL  $name")
  fi
}

# Claude Code reads CLAUDE.md from every parent of the directory it starts in, so this
# applies to any session under the work directory and nowhere else.
claude_md() {
  run mkdir -p "$WORK/notes"
  backup "$WORK/CLAUDE.md"
  run cp "$DIR/claude/CLAUDE.md" "$WORK/CLAUDE.md"
}

oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "  already installed"
    return 0
  fi
  # The installer moves an existing ~/.zshrc to ~/.zshrc.pre-oh-my-zsh and writes its
  # template (robbyrussell theme, git plugin).
  local installer="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
  if [ "$DRY" = 1 ]; then
    echo "  [dry-run] RUNZSH=no CHSH=no sh -c \"\$(curl -fsSL $installer)\""
  else
    ZSH="$HOME/.oh-my-zsh" RUNZSH=no CHSH=no sh -c "$(curl -fsSL "$installer")" || return 1
  fi

  # Keep whatever the machine's original .zshrc set up (PATH, node, etc.).
  if [ -f "$HOME/.zshrc.pre-oh-my-zsh" ]; then
    if [ "$DRY" = 1 ]; then
      echo "  [dry-run] append 'source ~/.zshrc.pre-oh-my-zsh' to ~/.zshrc"
    else
      printf '\n# Original shell config from before oh-my-zsh\n[ -f ~/.zshrc.pre-oh-my-zsh ] && source ~/.zshrc.pre-oh-my-zsh\n' >>"$HOME/.zshrc"
    fi
  fi

  case "${SHELL:-}" in
    */zsh) ;;
    *) TODO+=("Login shell is ${SHELL:-unknown}; switch with: chsh -s /bin/zsh") ;;
  esac
}

iterm2() {
  local app=""
  for candidate in /Applications/iTerm.app "$HOME/Applications/iTerm.app"; do
    [ -d "$candidate" ] && app="$candidate"
  done

  if [ -z "$app" ]; then
    local tmp
    tmp="$(mktemp -d)"
    run curl -fsSL -o "$tmp/iterm2.zip" https://iterm2.com/downloads/stable/latest || return 1
    run mkdir -p "$HOME/Applications"
    run unzip -q "$tmp/iterm2.zip" -d "$HOME/Applications" || return 1
    run rm -rf "$tmp"
    echo "  installed to ~/Applications/iTerm.app"
  else
    echo "  already installed at $app"
  fi

  # Dynamic profile with the font, set as the default profile.
  local profiles="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
  run mkdir -p "$profiles"
  run cp "$DIR/iterm2/profile.json" "$profiles/dotfiles.json"
  run defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "6B2C0F1E-9A4D-4C35-8E2F-D0F1A7C3B901"
}

key_repeat() {
  # Fastest repeat rate and shortest delay the System Settings sliders allow.
  run defaults write -g KeyRepeat -int 2
  run defaults write -g InitialKeyRepeat -int 15
  run defaults write -g ApplePressAndHoldEnabled -bool false
  TODO+=("Key repeat only applies after logout. To apply now, drag both sliders to the right end in the Keyboard settings window that just opened.")
  run open "x-apple.systempreferences:com.apple.Keyboard-Settings.extension" || true
}

step "Claude Code rules ($WORK/CLAUDE.md)" claude_md
step "oh-my-zsh" oh_my_zsh
step "iTerm2 + Menlo 15 profile" iterm2
step "Key repeat" key_repeat

echo
echo "Summary"
for r in "${RESULTS[@]}"; do echo "  $r"; done
if [ "${#TODO[@]}" -gt 0 ]; then
  echo
  echo "Manual steps"
  for t in "${TODO[@]}"; do echo "  - $t"; done
fi
echo
echo "Open a new terminal (or iTerm2) to pick up the shell changes."
