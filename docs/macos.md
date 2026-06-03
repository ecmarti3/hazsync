# Running hazsync on macOS

macOS ships with `bash`, `ssh`, and (an older) `rsync`, so hazsync works almost
out of the box. Two small recommendations:

## 1. Install a current rsync

The system `rsync` on older macOS releases is ancient. Install a modern one with
[Homebrew](https://brew.sh):

```bash
brew install rsync
```

`python3` is also available via `brew install python` if you don't already have a
3.11+ interpreter (needed for TOML config parsing; otherwise `pip install tomli`).

## 2. Install hazsync

```bash
curl -fsSL https://raw.githubusercontent.com/USER/hazsync/main/install.sh | bash
```

If `~/.local/bin` isn't on your PATH, add it to `~/.zshrc`:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## 3. SSH multiplexing (optional but recommended)

Add a stanza to `~/.ssh/config` for your remote so `hazsync session` can keep a
warm connection (one auth per work session):

```
Host myremote
    HostName remote.example.com
    User your_user
    ControlMaster auto
    ControlPath ~/.ssh/cm-%r@%h:%p
    ControlPersist 4h
```

Then set `target = "myremote"` in your `hazsync.toml`.
