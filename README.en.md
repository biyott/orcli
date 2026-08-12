<div align="center">

# orcli 🐋

**A pod of personal CLI tools** — small, single-purpose shell scripts, copy-installed into `~/.local/bin`.
The name is **orca + cli**; each tool is one whale in the pod.

[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)&nbsp;&nbsp;[![shell](https://img.shields.io/badge/shell-bash%203.2%2B-89e051.svg)](#)

[한국어](README.md) · **English**

</div>

---

## Install

```bash
git clone https://github.com/biyott/orcli.git ~/dev/orcli
~/dev/orcli/install.sh
```

`install.sh` installs every executable in `bin/` into `~/.local/bin`. You **choose** how:

```bash
install.sh --copy    # copy — repo may move/vanish; re-run to update
install.sh --link    # symlink — git pull updates instantly; repo stays put
install.sh           # asks if interactive (default copy); copies if non-interactive
```

| Mode | Move/delete repo | Update |
|------|------------------|--------|
| `--copy` | free (standalone copy) | re-run `install.sh` after `git pull` (or `orcli update`) |
| `--link` | repo must stay put | reflected instantly on `git pull` |

If `~/.local/bin` is not on your `PATH`, it tells you to add it:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Uninstall: `rm ~/.local/bin/<tool>`.

## Tools

| Tool | Description | Deps |
|------|-------------|------|
| [`ghsw`](bin/ghsw) | Switch GitHub CLI account **and** git commit identity together | `gh`, `git`, `fzf`(opt) |
| [`wt`](bin/wt) | Pick a git worktree to enter / create / remove | `git`, `fzf`(opt) |
| [`ports`](bin/ports) | Inspect & kill processes holding listening ports | `lsof` or `ss` |
| [`gitundo`](bin/gitundo) | Common git "undo" actions in a safe menu | `git`, `fzf`(opt) |
| [`brsw`](bin/brsw) | Switch local branches + prune merged ones | `git`, `fzf`(opt) |
| [`prco`](bin/prco) | Pick an open PR to check out (`-w` for a worktree) | `gh`, `git`, `fzf`(opt) |
| [`sshsw`](bin/sshsw) | Pick a `~/.ssh/config` host to connect (merges Windows on WSL) | `ssh`, `fzf`(opt) |
| [`scratch`](bin/scratch) | Make a throwaway working dir, enter / clean up | — |
| [`orcli`](bin/orcli) | Manage the pod itself (list · update · doctor) | `git` |

> **Interactive selection uses `fzf` when present (fuzzy picker), else falls back to a numbered menu.** Install `fzf` and `ghsw`·`wt`·`brsw`·`ports`·`prco`·`sshsw`·`scratch` all get the same fuzzy UI — same behavior, nicer picker. Install: `brew install fzf` (macOS) / `sudo apt install fzf` (Debian·Ubuntu·WSL).

### `ghsw`

```
ghsw            switch via interactive picker
ghsw <n>        switch to list item N        (e.g. ghsw 2)
ghsw <name>     switch to that account       (e.g. ghsw smnoh)
ghsw --local    apply the git identity repo-local for this switch (default: --global)
ghsw --edit     edit the identity mapping file
ghsw -h|help    help + account list
```

The account list is read live from `gh auth status` — add/remove accounts with `gh auth login`/`gh auth logout` and it updates automatically.

**Switch git identity too.** Switching only the gh account is a trap: commits still get stamped with the previous identity. Right after switching, `ghsw` sets the mapped `git config user.name`/`user.email` (and optional `signingkey`). The mapping lives in `~/.config/orcli/ghsw.conf`:

```
# gh-account[:tag] | name | email | signingkey(optional)
smnoh_gsenc | Chris Noh | platdev@gsenc.com
biyott      | biyott    | 12345+biyott@users.noreply.github.com
```

**Several identities on one account.** Append `:tag` to the account name to split it across lines; each line shows up as its own entry.

```
smnoh_gsenc:work     | Chris Noh | platdev@gsenc.com
smnoh_gsenc:personal | Chris Noh | chris@example.com
```

Pick one directly with `ghsw smnoh_gsenc:personal`; without a tag, `ghsw smnoh_gsenc` uses that account's first line. Since the gh account is the same, `gh auth switch` is a no-op and only the git identity changes. The `● 현재` marker goes on the line whose account is active in gh *and* whose email matches the current `git config user.email`.

`ghsw --edit` creates and edits this file. Accounts with no mapping just switch gh and print a note. Default scope is `--global` (a gh account is machine-wide, so it fits); use `--local` to apply to one repo only.

### `wt`

```
wt              pick and enter (new shell; exit to return)
wt <query>      enter the worktree matching name/branch/path
wt ls           list worktrees
wt new <branch> create a worktree in a sibling dir and enter it
wt rm [query]   remove a worktree (interactive confirm)
wt path <query> print the path only  (cd "$(wt path foo)")
```

Entering **spawns a new shell** inside the worktree, so it works with no shell integration — `exit` drops you back where you were.

### `ports`

```
ports           pick and kill (interactive)
ports <port>    kill the process on that port
ports ls        list only
ports -9        SIGKILL (default SIGTERM)
ports -y        skip confirmation
```

Prefers `lsof`, falls back to `ss`. Killing asks for confirmation (skip with `-y`).

### `gitundo`

Shows the current state, then lets you pick an undo from a menu — soft/mixed/hard reset, unstage, discard working tree, `--amend`, merge/rebase abort, view reflog. Anything that discards changes requires a `yes` confirmation.

### `brsw`

```
brsw            pick and switch (recent-commit order, current marked ●)
brsw <query>    switch to the matching branch
brsw ls         list
brsw clean      pick (multi) already-merged local branches to delete
```

`clean` only offers safe candidates via `git branch --merged` (excludes current, main/master/develop) and asks `yes` before deleting. Unmerged branches are refused by `-d`, so nothing is lost by accident.

### `prco`

```
prco            pick an open PR to check out (number·title·branch·author)
prco <n>        check out that PR
prco -w [n]     fetch the PR into a new worktree and enter it (leaves current branch)
```

Listing/checkout is handled by `gh` (its built-in jq emits TSV — no external `jq`). `-w` fetches `pull/<N>/head` from `origin` into a sibling worktree — `exit` after review and your branch is untouched. (Same-repo GitHub PRs.)

### `sshsw`

```
sshsw            pick and connect
sshsw <query>    connect to the matching host
sshsw ls         list hosts (with source tag)
sshsw --wsl|--win  use only one config
```

Reads `Host` aliases from `~/.ssh/config`, then connects with `ssh` (wildcard `*`·`?` patterns excluded). `sshsw <query> -- <ssh args>` forwards trailing args to ssh. `Include` is not followed.

**Auto-merge on WSL.** When run under WSL, it **automatically finds** the Windows user's `~/.ssh/config` (real user via NTUSER.DAT, or exactly via `%USERPROFILE%` when interop is available) and merges it into the same list — no config needed. With two sources it groups them:

```
───── wsl ─────
  devbox
───── win ─────
  web-prod
  db-1
```

With a single source (macOS/Linux, or WSL without a Windows config) it's just a **plain list, no separators or tags**. It connects with the ssh matching the source: `wsl`→`ssh`, `win`→`ssh.exe` (when interop is present) / otherwise `ssh -F <win config>`, warning that key path/permission issues are possible. Override auto-detection with `SSHSW_WIN_CONFIG` if needed.

### `scratch`

```
scratch          make a timestamped dir and enter (~/.scratch/<datetime>)
scratch <name>   enter/create a named scratch
scratch --git    git init on entry
scratch ls       list
scratch rm       clean up old/chosen scratches (confirm)
```

Like `wt`, it spawns a new shell inside the dir — `exit` to return. For when you need a throwaway folder to try something. Change the location with `SCRATCH_DIR`.

### `orcli`

```
orcli list       installed tools + one-line descriptions
orcli update     git pull, then re-run install.sh (keeps install mode)
orcli doctor     check PATH · deps · install status
orcli root       print the repo location
```

`install.sh` records the repo location and install mode under `~/.config/orcli/`, so `orcli update` can find the source even for copy installs.

## Add a tool

1. Drop a script in `bin/` (shebang + executable bit). The 2nd-line `# name — description` comment shows up in `orcli list`.
2. Re-run `./install.sh` → installs (copy or symlink).
3. Add a row to the table above.

`bin/*` is language-agnostic (bash·python·node — anything with a valid shebang). Shared helpers go in `lib/`.

## License

[MIT](LICENSE)
