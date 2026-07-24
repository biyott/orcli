# orcli 🐋

> A small pod of personal command-line tools & configs. Symlink-install, `git pull` to update.
>
> 개인용 CLI 도구·설정 모음. 심링크로 설치하고 `git pull`로 갱신한다. 이름은 **orca + cli**.

## Install

```bash
git clone https://github.com/biyott/orcli.git ~/dev/orcli
~/dev/orcli/install.sh
```

`install.sh`가 `bin/` 안의 모든 실행파일을 `~/.local/bin`에 심링크한다.
`~/.local/bin`이 `PATH`에 없으면 셸 설정에 추가하라고 안내한다:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Update: `cd ~/dev/orcli && git pull` (심링크라 즉시 반영).
Uninstall: `rm ~/.local/bin/<tool>`.

## Tools

| Tool | 설명 | 의존성 |
|------|------|--------|
| [`ghsw`](bin/ghsw) | GitHub CLI 계정을 골라서 전환 (번호·이름·대화형·fzf) | `gh`, `fzf`(선택) |

### `ghsw`

```
ghsw            대화형 선택기로 전환
ghsw <번호>     목록 번호로 바로 전환   (예: ghsw 2)
ghsw <이름>     계정명으로 바로 전환    (예: ghsw smnoh)
ghsw -h|help    도움말 + 계정 목록
```

계정 목록은 `gh auth status`에서 실시간으로 읽는다 — 계정 추가/삭제는 `gh auth login`/`gh auth logout`으로 하면 자동 반영된다.

## Add a tool

1. 스크립트를 `bin/`에 넣는다 (shebang + 실행권한).
2. `./install.sh` 다시 실행 → 심링크 생성.
3. 위 표에 한 줄 추가.

`bin/*`는 언어 무관(bash·python·node 등 shebang만 맞으면 됨). 공용 헬퍼는 `lib/`.

## License

[MIT](LICENSE)
