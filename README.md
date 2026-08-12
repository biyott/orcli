<div align="center">

# orcli 🐋

**개인용 CLI 도구 모음** — `~/.local/bin`으로 복사 설치하는 작고 단일 목적인 셸 도구들.
이름은 **orca + cli**. 도구 하나하나가 pod(고래 떼)의 한 마리다.

[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)&nbsp;&nbsp;[![shell](https://img.shields.io/badge/shell-bash%203.2%2B-89e051.svg)](#)

**한국어** · [English](README.en.md)

</div>

---

## Install

```bash
git clone https://github.com/biyott/orcli.git ~/dev/orcli
~/dev/orcli/install.sh
```

`install.sh`가 `bin/` 안의 모든 실행파일을 `~/.local/bin`에 설치한다. 방식은 **선택**한다:

```bash
install.sh --copy    # 복사본 설치 — repo 이동/삭제 무관, 갱신은 재실행 필요
install.sh --link    # 심링크 설치 — git pull 로 즉시 반영, repo 위치 고정
install.sh           # 터미널이면 물어봄(기본 복사), 비대화형이면 복사
```

| 방식 | repo 이동/삭제 | 갱신 |
|------|----------------|------|
| `--copy` | 자유(독립 복사본) | `git pull` 후 `install.sh` 재실행 (또는 `orcli update`) |
| `--link` | repo 위치 고정 | `git pull` 즉시 반영 |

`~/.local/bin`이 `PATH`에 없으면 셸 설정에 추가하라고 안내한다:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

제거: `rm ~/.local/bin/<tool>`.

## Tools

| Tool | 설명 | 의존성 |
|------|------|--------|
| [`ghsw`](bin/ghsw) | GitHub CLI 계정 전환 + git 커밋 신원 동시 설정 | `gh`, `git`, `fzf`(선택) |
| [`wt`](bin/wt) | git worktree 를 골라서 진입/생성/삭제 | `git`, `fzf`(선택) |
| [`ports`](bin/ports) | 리스닝 포트 점유 프로세스 조회·종료 | `lsof` 또는 `ss` |
| [`gitundo`](bin/gitundo) | 자주 하는 git 되돌리기를 안전한 메뉴로 | `git`, `fzf`(선택) |
| [`brsw`](bin/brsw) | git 로컬 브랜치 전환 + 머지된 브랜치 정리 | `git`, `fzf`(선택) |
| [`prco`](bin/prco) | 열린 PR 골라 체크아웃 (`-w` 로 worktree) | `gh`, `git`, `fzf`(선택) |
| [`sshsw`](bin/sshsw) | `~/.ssh/config` Host 골라서 접속 (WSL이면 Windows 것도 병합) | `ssh`, `fzf`(선택) |
| [`scratch`](bin/scratch) | 임시 작업 폴더 만들어 진입/정리 | — |
| [`orcli`](bin/orcli) | 이 도구 모음 자체 관리 (list·update·doctor) | `git` |

> **대화형 선택은 `fzf`가 있으면 fuzzy 선택기, 없으면 번호 메뉴로 폴백한다.** `fzf`를 깔면 `ghsw`·`wt`·`brsw`·`ports`·`prco`·`sshsw`·`scratch`가 모두 같은 fuzzy 화면이 된다 — 기능은 동일하고 고르는 UI만 달라진다. 설치: `brew install fzf` (macOS) / `sudo apt install fzf` (Debian·Ubuntu·WSL).

### `ghsw`

```
ghsw            대화형 선택기로 전환
ghsw <번호>     목록 번호로 바로 전환   (예: ghsw 2)
ghsw <이름>     계정명으로 바로 전환    (예: ghsw smnoh)
ghsw --local    이 전환의 git 신원을 repo-local로 적용 (기본: --global)
ghsw --edit     신원 매핑 파일 편집
ghsw -h|help    도움말 + 계정 목록
```

계정 목록은 `gh auth status`에서 실시간으로 읽는다 — 계정 추가/삭제는 `gh auth login`/`gh auth logout`으로 하면 자동 반영된다.

**git 신원 동시 전환.** gh 계정만 바꾸면 커밋은 이전 신원으로 찍히는 함정이 있다. `ghsw`는 계정 전환 직후 매핑된 `git config user.name`/`user.email`(및 선택 `signingkey`)을 자동으로 설정한다. 매핑은 `~/.config/orcli/ghsw.conf`에 둔다:

```
# gh계정[:태그] | 이름 | 이메일 | signingkey(선택)
smnoh_gsenc | Chris Noh | platdev@gsenc.com
biyott      | biyott    | 12345+biyott@users.noreply.github.com
```

**한 계정에 신원 여러 개.** 계정명 뒤에 `:태그`를 붙여 줄을 나누면 각 줄이 목록에 따로 뜬다.

```
smnoh_gsenc:work     | Chris Noh | platdev@gsenc.com
smnoh_gsenc:personal | Chris Noh | chris@example.com
```

`ghsw smnoh_gsenc:personal`로 바로 고르고, 태그 없이 `ghsw smnoh_gsenc`면 그 계정의 첫 줄이 쓰인다. gh 계정이 같으면 `gh auth switch`는 건너뛰고 git 신원만 갈린다. 목록의 `● 현재`는 gh 활성 계정 + 현재 `git config user.email`이 둘 다 맞는 줄에 붙는다.

`ghsw --edit`로 이 파일을 만들고 편집한다. 매핑이 없는 계정은 gh만 전환하고 안내만 한다. 기본 scope는 `--global`(gh 계정이 머신 전역이라 결이 맞음), 특정 repo에만 적용하려면 `--local`.

### `wt`

```
wt              골라서 진입(새 셸, exit 로 복귀)
wt <검색어>     이름/브랜치/경로 매칭 worktree 로 진입
wt ls           worktree 목록
wt new <브랜치>  새 worktree 를 형제 폴더에 만들고 진입
wt rm [검색어]   worktree 제거(대화형 확인)
wt path <검색어> 경로만 출력  (cd "$(wt path foo)")
```

진입은 그 worktree 안에서 **새 셸을 띄우는 방식**이라 셸 설정 없이 동작한다 — `exit` 하면 원래 자리로 돌아온다.

### `ports`

```
ports           대화형으로 골라서 종료
ports <포트>    그 포트 점유 프로세스 종료
ports ls        목록만
ports -9        SIGKILL (기본 SIGTERM)
ports -y        확인 없이 종료
```

`lsof` 우선, 없으면 `ss` 로 대체. 종료는 확인을 받는다(`-y` 로 건너뜀).

### `gitundo`

현재 상태를 보여주고 되돌리기 항목을 메뉴로 고른다 — soft/mixed/hard reset, 스테이징 해제, 워킹트리 폐기, `--amend`, merge/rebase abort, reflog 보기. 변경을 지우는 항목은 `yes` 확인을 받는다.

### `brsw`

```
brsw            골라서 전환 (최근 커밋순, 현재 ● 표시)
brsw <검색어>   매칭 브랜치로 바로 전환
brsw ls         목록
brsw clean      이미 머지된 로컬 브랜치를 골라서(다중) 삭제
```

`clean`은 `git branch --merged`로 안전 대상만 후보에 올리고(현재·main/master/develop 제외), 삭제 전 `yes` 확인을 받는다. 미머지 브랜치는 `-d`가 거부하므로 실수로 지워지지 않는다.

### `prco`

```
prco            열린 PR 목록에서 골라 체크아웃 (번호·제목·브랜치·작성자)
prco <번호>     그 PR 바로 체크아웃
prco -w [번호]  PR 을 새 worktree 로 가져와 진입 (현재 브랜치 안 건드림)
```

목록·체크아웃은 `gh`가 처리한다(내장 jq 로 TSV 파싱 — 외부 `jq` 불필요). `-w`는 `pull/<N>/head`를 `origin`에서 받아 형제 폴더에 worktree 로 열어 — 리뷰 후 `exit` 하면 원래 브랜치 그대로. (같은 저장소 GitHub PR 기준.)

### `sshsw`

```
sshsw            골라서 접속
sshsw <검색어>   매칭 Host 로 접속
sshsw ls         Host 목록 (출처 태그)
sshsw --wsl|--win  한쪽 config 만 사용
```

`~/.ssh/config`의 `Host` 별칭을 읽어 고른 뒤 `ssh`로 접속한다(와일드카드 `*`·`?` 제외). `sshsw <검색어> -- <ssh 인자>`로 뒤 인자를 그대로 넘긴다. `Include`는 따라가지 않는다.

**WSL 자동 병합.** WSL에서 실행하면 Windows 사용자의 `~/.ssh/config`를 **자동으로 찾아**(NTUSER.DAT로 실사용자 판별, interop 있으면 `%USERPROFILE%`로 정확히) 같은 목록에 합친다 — 설정 파일에 손댈 필요 없다. 출처가 둘이면 그룹으로 구분해 보여준다:

```
───── wsl ─────
  devbox
───── win ─────
  web-prod
  db-1
```

출처가 하나뿐이면(맥·리눅스, 또는 WSL이지만 Windows config 없음) **구분선·태그 없이 평범한 단일 목록**이다. 접속은 출처에 맞는 ssh로: `wsl`→`ssh`, `win`→`ssh.exe`(interop 있을 때) / 없으면 `ssh -F <win config>`로 시도하며 키 경로·권한 문제 가능성을 안내한다. 자동탐색이 어긋나면 `SSHSW_WIN_CONFIG`로 지정할 수 있다(예비수단).

### `scratch`

```
scratch          타임스탬프 폴더 만들어 진입 (~/.scratch/<날짜시각>)
scratch <이름>   이름 붙인 스크래치로 진입/재진입
scratch --git    진입 시 git init
scratch ls       목록
scratch rm       오래된/고른 스크래치 정리(확인)
```

`wt`처럼 그 폴더 안에서 새 셸을 띄운다 — `exit` 하면 복귀. 잠깐 뭔가 시험할 폴더가 필요할 때. 위치는 `SCRATCH_DIR` 환경변수로 바꾼다.

### `orcli`

```
orcli list       설치된 툴 + 한 줄 설명
orcli update     git pull 후 install.sh 재실행(설치 방식 유지)
orcli doctor     PATH·의존성·설치 상태 점검
orcli root       repo 위치 출력
```

`install.sh` 가 repo 위치·설치 방식을 `~/.config/orcli/` 에 기록해 두므로 복사 설치에서도 `orcli update` 가 원본을 찾아 갱신한다.

## Add a tool

1. 스크립트를 `bin/`에 넣는다 (shebang + 실행권한). 2번째 줄 `# name — 설명` 주석은 `orcli list` 에 표시된다.
2. `./install.sh` 다시 실행 → 설치(복사 또는 심링크).
3. 위 표에 한 줄 추가.

`bin/*`는 언어 무관(bash·python·node 등 shebang만 맞으면 됨). 공용 헬퍼는 `lib/`.

## License

[MIT](LICENSE)
