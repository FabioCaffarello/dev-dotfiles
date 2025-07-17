# dev-dotfiles

> A fully automated, OS-aware dotfiles and tooling provisioner using Bash, Ansible, and role-based modular configuration — designed for power users and software engineers.

---

## Overview

This repository provides a **declarative**, **modular**, and **secure** way to bootstrap your development environment. Whether you're running **macOS** or **Ubuntu**, you get:

- Smart OS detection and setup
- Secure SSH key generation
- Automated provisioning via [Ansible](https://docs.ansible.com/)
- Modular roles for tools like Neovim, Docker, ZSH, Tmux, Kubernetes, Rust, Go, and more
- Custom ZSH themes, aliases, completions, and keybindings
- Docker support for ephemeral testing environments

---

## Repository Structure

```sh
dev-dotfiles/
├── bin/ # Shell entrypoint script (dotfiles.sh)
├── roles/ # Modular Ansible roles per tool/config (OS-aware)
├── pre_tasks/ # OS/WSL detection, secret management, etc.
├── requirements/ # Ansible Galaxy dependencies (per OS)
├── group_vars/ # Global Ansible variables
├── Dockerfile # Dockerfile for testing in containers
├── docker-compose.yml # Compose config to bootstrap Docker environment
├── main.yml # Main Ansible playbook
└── ansible.cfg

```

---

## Features

| Feature                 | Description                                                                               |
| ----------------------- | ----------------------------------------------------------------------------------------- |
| OS Detection            | Automatically detects `macOS` or `Ubuntu`, and runs the correct setup steps               |
| First-Run Setup         | Generates `ed25519` SSH key, adds GitHub to known hosts, and sets up a secure environment |
| Role-Based Provisioning | Each tool or config is encapsulated in a reusable Ansible role (OS-specific when needed)  |
| Secure Defaults         | Secrets are never committed; public SSH keys can be pushed via CI pipeline if integrated  |
| Docker Support          | Use `docker-compose` to test provisioning in an isolated container (Ubuntu only)          |
| Easily Extendable       | Add new tools (e.g., PostgreSQL, AWS CLI) by simply dropping a new role                   |

---

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/FabioCaffarello/dev-dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 2. Run the Setup Script

```bash
./bin/dotfiles.sh
```

This will:

- Detect your OS (Ubuntu or macOS)
- Install core dependencies (`brew`, `git`, `ansible`, etc.)
- Generate SSH keys (if missing)
- Run Ansible roles to configure your tools and dotfiles

---

## Docker (Ubuntu Only)

To test your provisioning setup in a containerized Ubuntu environment:

```bash
docker compose up -d --build
```

This is useful for isolated testing or for replicating the dev setup on ephemeral machines.

---

## Supported Tools (via Roles)

- **Shell/Terminal**: `zsh`, `tmux`, `fzf`, `wezterm`, `yazi`, `zoxide`
- **Development**: `neovim`, `git`, `lazygit`, `go`, `rust`, `lua`, `nvm`, `npm`, `python`
- **DevOps & Cloud**: `docker`, `k8s`, `helm`, `terraform`, `k9s`
- **Utilities & Extras**: `obsidian`, `spotify`, `raycast`, `nordvpn`, `karabiner`, `fonts`

---

## Customization

To add your own tool or configuration:

```bash
mkdir -p roles/mytool/tasks
touch roles/mytool/tasks/main.yml
```

Then define installation steps in `main.yml`, and reference it in `main.yml` at the root level.

You can also extend with:

- Platform-specific logic (`MacOSX.yml`, `Ubuntu.yml`)
- Custom files, handlers, and templates

---

## 🙋 FAQ

**Q: Will this overwrite my current dotfiles?**
A: No. All setup is idempotent and cautious. You can review or customize roles before applying them.

**Q: Can I use this on cloud/dev containers?**
A: Yes. As long as it's Ubuntu-based or macOS, it should work out of the box.
