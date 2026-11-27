# Agent OS Quick Start Guide

This guide will help you get started with Agent OS quickly. For more detailed documentation, visit [buildermethods.com/agent-os](https://buildermethods.com/agent-os).

## Overview

Agent OS is a system that helps AI coding assistants follow your project standards and best practices. It works in two steps:

1. **Base Installation**: Install Agent OS to `~/agent-os` (one-time setup)
2. **Project Installation**: Install Agent OS into your project(s)

## Prerequisites

- Bash shell (macOS, Linux, or WSL on Windows)
- The Agent OS source code at `/path/to/agent-os-source/`

---

## Step 1: Base Installation

The base installation creates the Agent OS system at `~/agent-os` with all profiles, scripts, and configuration.

### Basic Usage

```bash
cd /path/to/agent-os-source/
./scripts/base-install.sh
```

This installs Agent OS with the **default** profile.

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `--profile NAME` | Install and set specific profile as default | `default` |
| `-v, --verbose` | Show detailed output during installation | (off) |
| `-h, --help` | Show help message and available profiles | - |

### Available Profiles

Run `./scripts/base-install.sh --help` to see all available profiles. Current profiles:
- **default**: General-purpose standards and commands
- **saas**: Optimized for SaaS application development

### Examples

```bash
# Install with default profile
./scripts/base-install.sh

# Install with saas profile
./scripts/base-install.sh --profile saas

# Install with verbose output
./scripts/base-install.sh --profile saas --verbose

# Show help and available profiles
./scripts/base-install.sh --help
```

### What Gets Installed

```
~/agent-os/
├── config.yml          # Base configuration
├── profiles/           # All available profiles
│   ├── default/
│   └── saas/
├── scripts/            # Installation and utility scripts
├── CHANGELOG.md
└── README.md
```

### Updating Base Installation

If Agent OS is already installed at `~/agent-os`, running base-install.sh again will prompt you with update options:

1. **Full update** - Updates profiles/default, scripts, CHANGELOG.md, and version
2. **Update default profile only** - Only updates the default profile
3. **Update scripts only** - Only updates the scripts
4. **Update config.yml only** - Only updates the config file
5. **Delete & reinstall fresh** - Backs up and reinstalls everything
6. **Cancel and abort** - Exit without changes

---

## Step 2: Project Installation

After base installation, install Agent OS into each project where you want to use it.

### Basic Usage

```bash
cd /path/to/your-project/
~/agent-os/scripts/project-install.sh
```

This installs Agent OS using settings from `~/agent-os/config.yml`.

### Options

#### Profile Selection

| Option | Description | Default |
|--------|-------------|---------|
| `--profile PROFILE` | Use specified profile | From `config.yml` |

#### Tool Integration

| Option | Description | Default |
|--------|-------------|---------|
| `--claude-code-commands [true\|false]` | Install Claude Code commands in `.claude/commands/agent-os/` | From `config.yml` |
| `--use-claude-code-subagents [true\|false]` | Enable Claude Code subagents (requires claude-code-commands) | From `config.yml` |
| `--agent-os-commands [true\|false]` | Install commands in `agent-os/commands/` for other AI tools | From `config.yml` |
| `--standards-as-claude-code-skills [true\|false]` | Use Claude Code Skills for standards | From `config.yml` |

#### Installation Control

| Option | Description |
|--------|-------------|
| `--re-install` | Delete and reinstall Agent OS completely |
| `--overwrite-all` | Overwrite all existing files during update |
| `--overwrite-standards` | Overwrite only existing standards during update |
| `--overwrite-workflows` | Overwrite only existing workflows during update |
| `--overwrite-commands` | Overwrite only existing commands during update |
| `--overwrite-agents` | Overwrite only existing agents during update |
| `--dry-run` | Preview what would be installed without actually installing |
| `--verbose` | Show detailed output during installation |
| `-h, --help` | Show help message |

**Note**: Flags accept both hyphens and underscores (e.g., `--use-claude-code-subagents` or `--use_claude_code_subagents`)

### Examples

```bash
# Basic installation (uses config.yml defaults)
~/agent-os/scripts/project-install.sh

# Install with saas profile
~/agent-os/scripts/project-install.sh --profile saas

# Install for Claude Code with subagents
~/agent-os/scripts/project-install.sh --claude-code-commands true --use-claude-code-subagents true

# Install for other AI tools (Cursor, Windsurf, etc.)
~/agent-os/scripts/project-install.sh --agent-os-commands true

# Preview installation without making changes
~/agent-os/scripts/project-install.sh --dry-run

# Reinstall from scratch
~/agent-os/scripts/project-install.sh --re-install

# Use verbose output for debugging
~/agent-os/scripts/project-install.sh --verbose
```

### What Gets Installed

The installation depends on your configuration. Here's what can be installed:

#### Always Installed
```
your-project/
└── agent-os/
    ├── config.yml       # Project configuration
    ├── standards/       # Project standards files
    └── workflows/       # Project workflows files
```

#### With Claude Code Commands (--claude-code-commands true)
```
your-project/
└── .claude/
    └── commands/
        └── agent-os/    # Claude Code commands
```

#### With Claude Code Subagents (--use-claude-code-subagents true)
```
your-project/
└── .claude/
    ├── commands/
    │   └── agent-os/    # Commands that delegate to agents
    └── agents/
        └── agent-os/    # Specialized agents
```

#### With Agent OS Commands (--agent-os-commands true)
```
your-project/
└── agent-os/
    └── commands/        # Commands for other AI tools
```

---

## Common Workflows

### Workflow 1: First-Time Setup with Claude Code

```bash
# Step 1: Base installation with default profile
cd /path/to/agent-os-source/
./scripts/base-install.sh

# Step 2: Install into your project
cd /path/to/your-project/
~/agent-os/scripts/project-install.sh --claude-code-commands true --use-claude-code-subagents true
```

### Workflow 2: SaaS Project Setup

```bash
# Step 1: Base installation with saas profile
cd /path/to/agent-os-source/
./scripts/base-install.sh --profile saas

# Step 2: Install into your SaaS project
cd /path/to/your-saas-project/
~/agent-os/scripts/project-install.sh --profile saas
```

### Workflow 3: Multi-Tool Setup (Claude Code + Cursor/Windsurf)

```bash
# Install for both Claude Code and other AI tools
cd /path/to/your-project/
~/agent-os/scripts/project-install.sh \
  --claude-code-commands true \
  --use-claude-code-subagents true \
  --agent-os-commands true
```

### Workflow 4: Preview Before Installing

```bash
# See what would be installed without making changes
cd /path/to/your-project/
~/agent-os/scripts/project-install.sh --dry-run

# Review the output, then install for real
~/agent-os/scripts/project-install.sh
```

### Workflow 5: Switch Profiles in Existing Project

```bash
# Switch from default to saas profile
cd /path/to/your-project/
~/agent-os/scripts/project-install.sh --profile saas --overwrite-all
```

---

## Configuration

After base installation, you can customize defaults in `~/agent-os/config.yml`:

```yaml
version: 2.1.1
base_install: true

# Default profile for new projects
profile: default

# Tool integration defaults
claude_code_commands: true
use_claude_code_subagents: true
agent_os_commands: false
standards_as_claude_code_skills: false
```

These defaults are used by `project-install.sh` unless overridden with command-line flags.

---

## Updating Projects

If Agent OS is already installed in a project, running `project-install.sh` again will update it:

```bash
# Update with current settings
cd /path/to/your-project/
~/agent-os/scripts/project-install.sh

# Update and overwrite all files
~/agent-os/scripts/project-install.sh --overwrite-all

# Update only standards
~/agent-os/scripts/project-install.sh --overwrite-standards

# Update only workflows
~/agent-os/scripts/project-install.sh --overwrite-workflows

# Update only commands
~/agent-os/scripts/project-install.sh --overwrite-commands

# Reinstall completely
~/agent-os/scripts/project-install.sh --re-install
```

---

## Customizing Standards and Workflows

After installation, you can customize standards and workflows for your project:

### For Default Profile
```bash
# Edit standards and workflows in your project
cd /path/to/your-project/
# Standards are in: agent-os/standards/
# Workflows are in: agent-os/workflows/
```

### For Custom Profiles
```bash
# Edit base profile standards and workflows
cd ~/agent-os/profiles/saas/standards/
cd ~/agent-os/profiles/saas/workflows/
# Make changes here
```

### Profiles Can Inherit
The saas profile can inherit from default and add/override specific standards and workflows. See your profile's structure for details.

---

## Troubleshooting

### "Agent OS base installation not found"
- **Solution**: Run base-install.sh first: `./scripts/base-install.sh`

### "Profile 'xyz' not found"
- **Solution**: Check available profiles with `./scripts/base-install.sh --help`

### Want to see what will be installed?
- **Solution**: Use `--dry-run` flag to preview changes

### Installation seems stuck
- **Solution**: Use `--verbose` flag to see detailed progress

### Need to start over?
- **Solution**: Use `--re-install` flag for project installation or choose option 5 for base installation

---

## Next Steps

1. **Customize Standards & Workflows**: Edit files in `~/agent-os/profiles/your-profile/standards/` and `~/agent-os/profiles/your-profile/workflows/`
2. **Install in Projects**: Run project-install.sh in each project
3. **Use Commands**: In Claude Code, use commands like `/create-spec`, `/plan-product`, etc.
4. **Read Documentation**: Visit [buildermethods.com/agent-os](https://buildermethods.com/agent-os)

---

## Quick Reference

### Base Installation
```bash
# Install with default profile
./scripts/base-install.sh

# Install with specific profile
./scripts/base-install.sh --profile saas
```

### Project Installation
```bash
# Basic installation
~/agent-os/scripts/project-install.sh

# Claude Code with subagents
~/agent-os/scripts/project-install.sh \
  --claude-code-commands true \
  --use-claude-code-subagents true

# Specific profile
~/agent-os/scripts/project-install.sh --profile saas

# Preview changes
~/agent-os/scripts/project-install.sh --dry-run
```

### File Locations
- **Base installation**: `~/agent-os/`
- **Project standards**: `./agent-os/standards/`
- **Project workflows**: `./agent-os/workflows/`
- **Claude Code commands**: `./.claude/commands/agent-os/`
- **Claude Code agents**: `./.claude/agents/agent-os/`
- **Agent OS commands**: `./agent-os/commands/`
