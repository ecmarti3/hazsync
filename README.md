# hazsync

A small, safe `rsync`-over-SSH wrapper for syncing project directories between
your local machine and a remote host. Run it from anywhere inside a project and
it figures out the rest — no long `rsync` incantations, no accidental deletes.

Originally built for syncing work to an HPC login node, but it works against any
host you can reach over SSH (Linux, macOS, or Windows running Cygwin/MSYS rsync).

## Features

- **Project-aware** — mark a project root once (`hazsync init`); every command
  works from anywhere inside it.
- **Config-driven** — one TOML file holds your remote/local bases and exclude
  rules. No editing the script.
- **Safe by default** — `--delete` is gated behind a confirmation prompt and
  refuses to run unattended without `--force`; paths are validated before any
  rsync touches the remote.
- **Dry-run previews** — `dry-push` / `dry-pull` show exactly what would move.
- **Targeted sync** — `hazsync pull PATH` grabs a single file or folder _even if
  it is normally excluded_ — handy for fetching one big ignored output file.
- **SSH multiplexing** — reuses a persistent SSH master so you authenticate once
  per work session.

## Requirements

- `bash`, `rsync`, `ssh`, and `python3` (3.11+, or `pip install tomli`).
- **Windows users:** run hazsync inside **WSL** (Windows Subsystem for Linux).
  See [docs/windows.md](docs/windows.md). (Native Windows has no built-in rsync.)
- **macOS users:** see [docs/macos.md](docs/macos.md) (usually just
  `brew install rsync`).
- **SSH setup, multiplexing, and NCSU Hazel:** see [docs/ssh.md](docs/ssh.md) —
  recommended reading; it's how you avoid re-authenticating (and re-doing Duo)
  on every command.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/ecmarti3/hazsync/main/install.sh | bash
```

Or clone and run the installer:

```bash
git clone https://github.com/ecmarti3/hazsync.git
cd hazsync
./install.sh          # installs to ~/.local/bin/hazsync
```

If on windows first install WSL:

```bash
wsl --install
```

After wsl has finished installing restart computer before proceeding to next steps

## Quickstart

```bash
hazsync config-init                 # scaffold ~/.config/hazsync/hazsync.toml
$EDITOR ~/.config/hazsync/hazsync.toml   # set [hazel] user/host/base and [local] base

cd ~/projects/my-project
hazsync init                        # drop a .projectroot marker

hazsync dry-push                    # preview what would upload
hazsync push                        # upload local -> remote
hazsync pull                        # download remote -> local
```

## Commands

| Command                                        | Description                                              |
| ---------------------------------------------- | -------------------------------------------------------- |
| `init`                                         | Create a `.projectroot` marker in the current directory. |
| `push [--delete] [--force] [PATH...]`          | Sync local project → remote.                             |
| `pull [--delete] [--force] [PATH...]`          | Sync remote project → local.                             |
| `dry-push` / `dry-pull` `[--delete] [PATH...]` | Preview a push/pull; transfers nothing.                  |
| `status`                                       | Show project name and sync targets (no network call).    |
| `session <start\|status\|end\|new>`            | Manage the multiplexed SSH session.                      |
| `config-init`                                  | Write a default config if none exists.                   |
| `version` / `help`                             | Show version / usage.                                    |

### Targeted sync (bypasses excludes)

Pass one or more **project-relative** paths to grab only those — and the exclude
rules are skipped, so you can fetch something that's normally ignored:

```bash
hazsync pull results/run42.nc      # one normally-ignored output file
hazsync pull data/raw/             # a whole ignored folder
hazsync push logs/job.out          # send an excluded file
```

### Deletions

`--delete` mirrors deletions to the destination. It is **destructive** — preview
first and only `--force` past the prompt when you're sure:

```bash
hazsync dry-push --delete
hazsync push --delete
```

## Remote path conventions

`[hazel].base` must be a path the **remote** understands:

| Remote OS                   | Example `base`                   |
| --------------------------- | -------------------------------- | --------------- |
| Linux                       | `/home/you/projects`             |
| macOS                       | `/Users/you/projects`            |
| Windows (Cygwin/MSYS rsync) | `/cygdrive/c/Users/you/projects` | \* Not prefered |

> **Windows gotcha:** do not use `C:\...` and do not rely on a bare `~` — Cygwin
> rsync will not expand `~` and creates a literal `~` folder. Always spell out
> the `/cygdrive/c/...` form.

## License

MIT — see [LICENSE](LICENSE).
