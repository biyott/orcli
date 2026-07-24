#!/usr/bin/env bash
# orcli installer — installs every tool in bin/ into ~/.local/bin
#
#   install.sh [--copy|--link] [-h]
#     --copy   복사본 설치. repo가 외장/이동/삭제돼도 도구는 독립 동작.
#              (갱신은 git pull 후 install.sh 재실행 필요)
#     --link   심링크 설치. git pull 만으로 즉시 반영.
#              (repo 위치가 고정돼야 하고, 옮기면 재설치 필요)
#     플래그 없으면: 터미널이면 물어보고, 아니면 --copy 기본.
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"
target="$HOME/.local/bin"

mode=""
case "${1:-}" in
  --copy) mode=copy ;;
  --link|--symlink) mode=link ;;
  -h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  "") ;;
  *) echo "알 수 없는 옵션: $1 (--copy | --link | -h)" >&2; exit 1 ;;
esac

# 방식 미지정 → 대화형(터미널) 또는 기본 copy
if [ -z "$mode" ]; then
  if [ -t 0 ]; then
    echo "설치 방식 선택:"
    echo "  1) 복사(copy)   — repo 이동/삭제 무관, 갱신은 install.sh 재실행"
    echo "  2) 심링크(link) — git pull 로 즉시 반영, repo 위치 고정 필요"
    printf "선택 [1/2] (기본 1): "
    read -r ans || ans=1
    case "$ans" in 2|link|l|L) mode=link ;; *) mode=copy ;; esac
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
  rm -f "$target/$name"                 # 기존 복사본/심링크 제거 후 재설치
  if [ "$mode" = link ]; then
    ln -sf "$f" "$target/$name"
    echo "  linked  $target/$name -> $f"
  else
    cp "$f" "$target/$name"
    chmod +x "$target/$name"
    echo "  copied  $f -> $target/$name"
  fi
  n=$((n + 1))
done

if [ "$mode" = link ]; then
  echo "orcli: ${n}개 도구를 심링크로 설치했습니다. (git pull 로 즉시 갱신)"
else
  echo "orcli: ${n}개 도구를 복사 설치했습니다. (갱신 후엔 install.sh 재실행)"
fi

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
