#!/usr/bin/env bash
# orcli installer — copies every tool in bin/ into ~/.local/bin
# 복사 방식이라 repo가 외장/이동/삭제돼도 설치된 도구는 독립적으로 동작한다.
# 대신 repo 갱신(git pull) 뒤엔 이 스크립트를 다시 실행해야 최신본이 반영된다.
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"
target="$HOME/.local/bin"
mkdir -p "$target"

n=0
for f in "$repo"/bin/*; do
  [ -f "$f" ] || continue
  name="$(basename "$f")"
  chmod +x "$f"
  rm -f "$target/$name"          # 기존 복사본/심링크 제거 후
  cp "$f" "$target/$name"        # 독립 복사본으로 설치
  chmod +x "$target/$name"
  echo "  copied  $f  ->  $target/$name"
  n=$((n + 1))
done
echo "orcli: ${n}개 도구를 ~/.local/bin 에 복사했습니다."
echo "       (repo 갱신 후엔 install.sh 를 다시 실행해 재복사하세요)"

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
