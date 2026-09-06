# file-keeper

A small tool to track and quickly access important config files on a machine. Built for managing services on Proxmox containers where keeping track of config file locations becomes tedious.

Designed for setups with a handful of files per container — not a full-scale config management system.

## Installation

```bash
curl -sSL https://raw.githubusercontent.com/AlexAuragan/file-keeper/main/install.sh | bash
```

The script installs both `fk` and `fkg` to `/usr/local/bin`, using `sudo` only if needed. Running it again will update them if a newer version is available.

## How it works

`fk` maintains a plain-text database at `~/.file_keeper`. Each entry is a file path paired with a description, stored as `path|description`.

Files are split into two categories based on their path:

- **Config files** — any tracked file not under a `systemd` directory. Indexed by number (`1`, `2`, ...).
- **Service files** — files under a `systemd` directory. Indexed by letter (`a`, `b`, ...).

Running `fk` with no arguments shows the list and prompts for a selection. Selecting a config file opens it in `nano`. Selecting a service file supports additional actions by appending a suffix to the letter:

| Input | Action |
|-------|--------|
| `a`   | Edit the service file in nano |
| `ar`  | Restart the service |
| `as`  | Start the service |
| `ai`  | Show service status |
| `aj`  | View journalctl logs |
| `ajf` | Follow journalctl logs |

Prefixing a number with `c` (e.g. `c1`) prints the file contents instead of opening it.

## Commands

```
fk                          Open the interactive file list
fk --add <path> <desc>      Track a new file
fk --edit                   Edit the description of a tracked file
fk --delete                 Remove a file from tracking
fk --cat <number|letter>    Print a file's contents
fk <selection>              Jump directly to a selection (e.g. fk 1, fk ar)
```

## File Keeper Gatherer (`fkg`)

`fkg` gathers the files tracked by `fk` across Proxmox LXC containers into a central directory.

Each container already maintains its own `/root/.file_keeper` database through `fk`. `fkg` uses that database to discover which files should be collected, then copies them while preserving their original path.

The default cache layout is:

```text
/cache/file_keeper/<node>/CT<id>/<original/path>
```

For example, if CT `101` on `pve1` tracks:

```text
/etc/nginx/nginx.conf
```

it will be gathered to:

```text
/cache/file_keeper/pve1/CT101/etc/nginx/nginx.conf
```

### Proxmox nodes

Nodes are configured in `~/.fkg_nodes`, one per line:

```text
<name> [ip-or-hostname]
```

For example:

```text
pve1
pve2 192.168.1.12
pve3 192.168.1.13
```

A node can also be registered from the CLI:

```bash
fkg proxmox --add pve2 192.168.1.12
```

If a node name matches the current machine's hostname, `fkg` accesses it locally using `pct`.

Other nodes are accessed over SSH using their configured IP or hostname.

### Gathering

Gather files from every configured node:

```bash
fkg proxmox
```

Gather only specific nodes:

```bash
fkg proxmox pve1 pve2
```

For each node, `fkg`:

1. Lists its LXC containers.
2. Reads `/root/.file_keeper` from each container.
3. Copies every file registered with `fk` into the central cache.
4. Preserves the node, container ID, and original filesystem path.

Running containers are accessed using `pct exec`.

Stopped containers are read directly from their root filesystem under `/var/lib/lxc/<id>/rootfs`.

Containers without `fk` installed or without tracked files are skipped.

### Git history

The gathered directory can optionally be managed as a Git repository, providing history for configuration files across all containers.

Initialize Git:

```bash
fkg git --init
```

Or initialize it with a remote:

```bash
fkg git --init <remote_url>
```

Gather files and push any changes:

```bash
fkg proxmox
fkg git --push
```

A custom commit message can be provided:

```bash
fkg git --push "update configs"
```

View the history:

```bash
fkg git --log
```

Or the history of a specific gathered file:

```bash
fkg git --log pve1/CT101/etc/nginx/nginx.conf
```

Restore a file from a previous commit:

```bash
fkg git --restore pve1/CT101/etc/nginx/nginx.conf <commit>
```

The restored version is written back to both the local `fkg` cache and the original container.

If no commit is provided, `HEAD` is used.

> Gathered configuration files may contain passwords, API keys, certificates, or other secrets. Use an appropriately protected Git repository if the cache is pushed to a remote.

### Configuration

The default paths can be overridden with environment variables:

| Variable | Default | Description |
|---|---|---|
| `FK_NODES_FILE` | `~/.fkg_nodes` | Proxmox node configuration |
| `FK_CACHE_DIR` | `/cache/file_keeper` | Gathered file cache |

### Commands

```text
fkg proxmox                       Gather from all configured nodes
fkg proxmox <node...>             Gather from specific nodes
fkg proxmox --add <name> [ip]     Register a Proxmox node

fkg git --init [remote_url]       Initialize Git in the cache
fkg git --push ["message"]        Commit and push gathered changes
fkg git --log [file]              Show Git history
fkg git --restore <file> [commit] Restore a file from history to its container

fkg --update                      Update fk and fkg
fkg --help                        Show help
`
