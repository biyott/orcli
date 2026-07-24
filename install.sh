#!/usr/bin/env bash
# orcli installer — symlinks every tool in bin/ into ~/.local/bin
# 심링크라 이후 `git pull`만으로 모든 도구가 최신으로 갱신된다.
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"
target="$HOME/.local/bin"
mkdir -p "$target"

n=0
for f in "$repo"/bin/*; do
  [ -f "$f" ] || continue
  name="$(basename "$f")"
  chmod +x "$f"
  ln -sf "$f" "$target/$name"
  echo "  installed  $target/$name -> $f"
  n=$((n + 1))
done
echo "orcli: ${n}개 도구 설치 완료."

# PATH 확인
case ":$PATH:" in
  *":$target:"*) ;;
  *)
    echo
    echo "⚠ PATH에 $target 가 없습니다. 셸 설정(~/.zshrc 등)에 추가하세요:"
    echo '    export PATH="$HOME/.local/bin:$PATH"'
    ;;
esac

# 선택 의존성 안내
command -v gh  >/dev/null 2>&1 || echo "· ghsw는 GitHub CLI(gh)가 필요합니다: https://cli.github.com"
command -v fzf >/dev/null 2>&1 || echo "· fzf가 있으면 ghsw가 fuzzy 선택기를 씁니다(선택)."
