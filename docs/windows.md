# Running hazsync on Windows (via WSL)

hazsync is a bash tool and uses `rsync`, which Windows does not ship natively.
The supported way to run it on Windows is **WSL** (Windows Subsystem for Linux),
which gives you a real Linux environment where everything just works.

## 1. Install WSL (one time)

Open **PowerShell as Administrator** and run:

```powershell
wsl --install
```

Reboot if prompted. This installs Ubuntu by default. Launch **Ubuntu** from the
Start menu and create your Linux username/password when asked.

## 2. Install the dependencies inside WSL

In the Ubuntu shell:

```bash
sudo apt update
sudo apt install -y rsync openssh-client python3
```

## 3. Install hazsync inside WSL

```bash
curl -fsSL https://raw.githubusercontent.com/ecmarti3/hazsync/main/install.sh | bash
```

If `~/.local/bin` isn't on your PATH, add it:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## 4. Configure and use

```bash
hazsync config-init
nano ~/.config/hazsync/hazsync.toml
```

Set `[local].base` to a path **inside WSL** (e.g. `~/projects`). You *can* point
at Windows files under `/mnt/c/...`, but rsync is much faster and avoids
permission quirks when your projects live in the Linux home directory.

> Note: this is about running hazsync *as a client* on Windows. If your **remote**
> is a Windows machine running Cygwin/MSYS rsync, see the "Remote path
> conventions" section of the main README for the `/cygdrive/c/...` path rule.
