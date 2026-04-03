# file-keeper

A small tool to track and quickly access important config files on a machine. Built for managing services on Proxmox containers where keeping track of config file locations becomes tedious.

Designed for setups with a handful of files per container — not a full-scale config management system.

## Installation

```bash
curl -sSL https://raw.githubusercontent.com/AlexAuragan/file-keeper/main/install.sh | bash
```

The script downloads the `fk` binary to `/usr/local/bin/fk`, using `sudo` only if needed. Running it again will update `fk` if a newer version is available.

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
