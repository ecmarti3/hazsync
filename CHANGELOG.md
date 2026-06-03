# Changelog

All notable changes to hazsync are documented here.
This project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.0] — 2026-06-02

First public release.

### Features
- Project-aware sync via `.projectroot` markers.
- TOML configuration (`hazsync config-init`) with config lookup order.
- `push` / `pull` with `--delete` (confirmation-gated) and `--force`.
- `dry-push` / `dry-pull` previews.
- **Targeted sync**: `push`/`pull` accept project-relative `PATH` arguments to
  sync individual files/folders, bypassing exclude rules.
- Per-project `.hazignore` plus global excludes in config.
- SSH multiplexing helpers (`session start|status|end|new`).
- Path-escape guards (rejects absolute paths and `../` traversal in targeted
  paths and project-root resolution).
- `version` / `--version` command.

### Notes
- Windows is supported via WSL (see `docs/windows.md`).
- Remote bases on a Cygwin/MSYS host must use `/cygdrive/c/...` form, not `C:\`
  or `~`.
