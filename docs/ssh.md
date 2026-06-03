# SSH config, multiplexing, and connecting to NCSU Hazel

hazsync runs `rsync` and `ssh` under the hood. It does **not** manage SSH keys,
hosts, or connection sharing itself — it leans on your `~/.ssh/config`. Setting
that up well means you authenticate **once** per work session instead of on every
single `push`/`pull`/`dry-*`, which matters a lot when the remote uses two-factor
auth (like NCSU Hazel and its Duo prompt).

## 1. The `~/.ssh/config` stanza

Create or edit `~/.ssh/config` (the file should be `chmod 600`) and add a `Host`
block for your remote:

```
Host hazel
    HostName login.hpc.ncsu.edu
    User your_unity_id
    ControlMaster auto
    ControlPath ~/.ssh/cm-%r@%h:%p
    ControlPersist 4h
```

- **`Host hazel`** — a short alias you can use anywhere (`ssh hazel`,
  `rsync ... hazel:...`). Point hazsync at it with `target = "hazel"` in your
  `hazsync.toml` (see below).
- **`HostName` / `User`** — the real host and your login name.
- **`ControlMaster auto`** — reuse a shared connection if one exists, otherwise
  open one. This is the heart of multiplexing.
- **`ControlPath`** — where the shared-connection socket lives. `%r@%h:%p`
  expands to `user@host:port`, keeping one socket per destination.
- **`ControlPersist 4h`** — keep the master connection alive in the background
  for 4 hours after the last use, so subsequent commands are instant.

Make sure the socket directory exists and is private:

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
```

## 2. What multiplexing buys you

Without it, every hazsync command opens a brand-new SSH connection — and on a
Duo-protected host that means a Duo push/prompt **every time**. With multiplexing,
the first connection authenticates once and every later `push`/`pull`/`dry-*`
silently rides the same socket.

hazsync cooperates with this automatically:

```bash
hazsync session start     # open the persistent master (authenticate once, incl. Duo)
hazsync session status    # is the master alive?
hazsync session new       # open an interactive shell on the remote (reuses master)
hazsync session end       # close the master
```

`push`/`pull`/`dry-*` check for a live master first; if none exists they offer to
start one. hazsync only *uses* the multiplexing you configure in `~/.ssh/config`
— it does not create its own socket settings.

## 3. Point hazsync at the alias

In your `hazsync.toml`, set `target` to the SSH alias so rsync uses your
`~/.ssh/config` block (and its multiplexing) verbatim:

```toml
[hazel]
user = "your_unity_id"
host = "login.hpc.ncsu.edu"
base = "/home/your_unity_id"     # or wherever your projects live on Hazel
target = "hazel"                 # <-- use the Host alias from ~/.ssh/config
```

When `target` is set, hazsync uses it directly instead of building
`user@host`, so all your `ssh` settings apply.

---

## Connecting to NCSU Hazel specifically

[Hazel](https://hpc.ncsu.edu/) is NC State's HPC cluster. To use hazsync against
it you need:

1. **An HPC account.** Request one through the
   [NC State HPC site](https://hpc.ncsu.edu/) (requires sponsorship by a faculty
   member / project). You log in with your **Unity ID** and password.

2. **Campus network or the VPN.** Off campus you generally must connect through
   the **NC State VPN** (Cisco Secure Client / AnyConnect) before SSH will reach
   the login node. On-campus wired/eduroam usually works directly.

3. **Duo two-factor.** Logins are protected by Duo. The first connection of a
   session triggers a Duo prompt — this is exactly why the multiplexing setup
   above is worth it: you clear Duo once, then work uninterrupted.

4. **The login node hostname:** `login.hpc.ncsu.edu`.

### Recommended Hazel `~/.ssh/config`

```
Host hazel
    HostName login.hpc.ncsu.edu
    User your_unity_id
    ControlMaster auto
    ControlPath ~/.ssh/cm-%r@%h:%p
    ControlPersist 8h
    ServerAliveInterval 60
    ServerAliveCountInterval 3
```

- `ServerAliveInterval` / `...CountInterval` send keepalives so long-idle
  sessions over VPN don't get silently dropped mid-transfer.
- A longer `ControlPersist` (e.g. `8h`) covers a full work day on one Duo auth.

### First-time flow

```bash
# 1. (off campus) connect the NC State VPN first
# 2. open the persistent session — approve the Duo prompt once:
hazsync session start
# 3. work normally; no further Duo prompts until the master expires:
cd ~/projects/my-sim
hazsync init           # one-time, marks the project root
hazsync dry-push       # preview
hazsync push           # upload to Hazel
```

> **Where do my files go on Hazel?** Set `[hazel].base` to the absolute path on
> Hazel where you keep projects (commonly under `/home/<unity_id>` or a shared
> `/share/<group>` directory your lab uses). Each project syncs to
> `<base>/<project-folder-name>/`.

### Notes / gotchas

- **Storage:** `/home` on Hazel has quotas; large datasets usually belong on
  scratch or a group `/share` path. Set `[hazel].base` accordingly and use
  `.hazignore` to keep big generated outputs from syncing back and forth.
- **Key-based auth:** Hazel still requires password + Duo at the login node even
  with a key, but a key plus multiplexing makes the single auth smoother. Add
  your public key via the HPC account tools if you use one.
- **Connection drops:** if a transfer dies after a VPN hiccup, just re-run the
  command — rsync syncs only what changed, so re-running is cheap and safe.
