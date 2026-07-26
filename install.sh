#!/usr/bin/env bash
# orcli installer — installs every tool in bin/ into ~/.local/bin.
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"
target="$HOME/.local/bin"
conf="${XDG_CONFIG_HOME:-$HOME/.config}/orcli"

# colors — only when stdout is a terminal (plain when piped/redirected)
if [ -t 1 ]; then
  BOLD=$'\033[1m'; DIM=$'\033[2m'; RST=$'\033[0m'
  CYAN=$'\033[36m'; YEL=$'\033[33m'; GRN=$'\033[32m'; MAG=$'\033[35m'
else
  BOLD=; DIM=; RST=; CYAN=; YEL=; GRN=; MAG=
fi

hr() { printf '   %s──────────────────────────────────%s\n' "$DIM" "$RST"; }

usage() {
  printf '\n'
  printf '   %s%sorcli%s %s· install%s\n\n' "$BOLD" "$MAG" "$RST" "$DIM" "$RST"
  printf '   %sUsage%s\n' "$BOLD" "$RST"
  hr
  printf '     %sinstall.sh%s              choose copy / link interactively\n' "$YEL" "$RST"
  printf '     %sinstall.sh %s--copy%s       copy tools into ~/.local/bin\n' "$YEL" "$CYAN" "$RST"
  printf '     %sinstall.sh %s--link%s       symlink tools into ~/.local/bin\n' "$YEL" "$CYAN" "$RST"
  printf '     %sinstall.sh %s-h%s|%s--help%s   show this help\n' "$YEL" "$CYAN" "$RST" "$CYAN" "$RST"
  printf '\n   %sModes%s\n' "$BOLD" "$RST"
  hr
  printf '     %scopy%s   standalone copy — repo may move or vanish;\n' "$GRN" "$RST"
  printf '            re-run install.sh after %sgit pull%s to update\n' "$DIM" "$RST"
  printf '     %slink%s   symlink — %sgit pull%s updates instantly;\n' "$GRN" "$RST" "$DIM" "$RST"
  printf '            the repo must stay put (re-run if you move it)\n'
  printf '\n'
  hr
  printf '   %sorcli · github.com/biyott/orcli%s\n\n' "$DIM" "$RST"
}

mode=""
case "${1:-}" in
  --copy) mode=copy ;;
  --link|--symlink) mode=link ;;
  -h|--help) usage; exit 0 ;;
  "") ;;
  *) printf '%sunknown option: %s%s  (use --copy | --link | -h)\n' "$YEL" "$1" "$RST" >&2; exit 1 ;;
esac

# no flag → ask (terminal) or default to copy
if [ -z "$mode" ]; then
  if [ -t 0 ]; then
    printf '\n   %sInstall mode%s\n' "$BOLD" "$RST"
    printf '     %s1)%s %scopy%s   standalone; repo may move/vanish; re-run to update\n' "$CYAN" "$RST" "$GRN" "$RST"
    printf '     %s2)%s %slink%s   symlink; instant %sgit pull%s updates; repo stays put\n' "$CYAN" "$RST" "$GRN" "$RST" "$DIM" "$RST"
    printf '   choose [1/2] (default 1): '
    read -r ans || ans=1
    case "$ans" in 2|link|l|L) mode=link ;; *) mode=copy ;; esac
    printf '\n'
  else
    mode=copy
  fi
fi

mkdir -p "$target"
n=0
for f in "$repo"/bin/*; do
  [ -f "$f" ] || continue
  name="$(basename "$f")"
  chmod +x "$f"
  rm -f "$target/$name"                 # drop any existing copy/symlink first
  if [ "$mode" = link ]; then
    ln -sf "$f" "$target/$name"
    printf '   %s✓%s linked  %s%s%s -> %s\n' "$GRN" "$RST" "$BOLD" "$target/$name" "$RST" "$f"
  else
    cp "$f" "$target/$name"
    chmod +x "$target/$name"
    printf '   %s✓%s copied  %s -> %s%s%s\n' "$GRN" "$RST" "$f" "$BOLD" "$target/$name" "$RST"
  fi
  n=$((n + 1))
done

# record repo root + mode so `orcli update`/`orcli list` can find the source
mkdir -p "$conf"
printf '%s\n' "$repo" > "$conf/root"
printf '%s\n' "$mode" > "$conf/mode"

if [ "$mode" = link ]; then
  printf '\n   %sorcli%s  %d tool(s) symlinked · %sgit pull%s updates them instantly\n' "$BOLD" "$RST" "$n" "$DIM" "$RST"
else
  printf '\n   %sorcli%s  %d tool(s) copied · re-run install.sh after %sgit pull%s\n' "$BOLD" "$RST" "$n" "$DIM" "$RST"
fi

# PATH check
case ":$PATH:" in
  *":$target:"*) ;;
  *)
    printf '\n   %s⚠ %s is not on your PATH. Add to your shell rc:%s\n' "$YEL" "$target" "$RST"
    printf '       export PATH="$HOME/.local/bin:$PATH"\n'
    ;;
esac

# optional deps
command -v gh  >/dev/null 2>&1 || printf '   %s· ghsw needs GitHub CLI (gh): https://cli.github.com%s\n' "$DIM" "$RST"
command -v fzf >/dev/null 2>&1 || printf '   %s· fzf enables fuzzy pickers across the pod (optional)%s\n' "$DIM" "$RST"
{ command -v lsof || command -v ss; } >/dev/null 2>&1 || printf '   %s· ports needs lsof or ss%s\n' "$DIM" "$RST"
printf '\n'
