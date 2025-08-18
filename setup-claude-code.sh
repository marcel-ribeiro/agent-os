 #!/bin/bash

# Agent OS Claude Code Setup Script
# This script installs Agent OS commands for Claude Code

set -e  # Exit on error

# Function to copy file from local or remote source
# Usage: copy_file <destination> <source_path> <mode>
# mode: "local" or "remote"
copy_file() {
    local destination="$1"
    local source_path="$2"
    local mode="$3"
    
    echo "    [DEBUG] copy_file: destination='$destination' source_path='$source_path' mode='$mode'"
    
    if [ "$mode" = "remote" ]; then
        echo "    [DEBUG] Executing: curl -s -o \"$destination\" \"$BASE_URL/$source_path\""
        curl -s -o "$destination" "$BASE_URL/$source_path"
    elif [ "$mode" = "local" ]; then
        echo "    [DEBUG] Executing: cp \"./$source_path\" \"$destination\""
        cp "./$source_path" "$destination"
    else
        echo "Error: Invalid mode '$mode'. Use 'local' or 'remote'"
        exit 1
    fi
}

# Set default mode
COPY_MODE="local"

# Parse command line arguments
OVERRIDE_FLAG=false
for arg in "$@"; do
    case $arg in
        --override)
            OVERRIDE_FLAG=true
            shift
            ;;
        --use-remote)
            COPY_MODE="remote"
            shift
            ;;
        *)
            ;;
    esac
done

echo "🚀 Agent OS Claude Code Setup"
echo "============================="
echo ""

# Check if Agent OS base installation is present
if [ ! -d "$HOME/.agent-os/instructions" ] || [ ! -d "$HOME/.agent-os/standards" ]; then
    echo "⚠️  Agent OS base installation not found!"
    echo ""
    echo "Please install the Agent OS base installation first:"
    echo ""
    echo "Option 1 - Automatic installation:"
    echo "  curl -sSL https://raw.githubusercontent.com/buildermethods/agent-os/main/setup.sh | bash"
    echo ""
    echo "Option 2 - Manual installation:"
    echo "  Follow instructions at https://buildermethods.com/agent-os"
    echo ""
    exit 1
fi

# Base URL for raw GitHub content
BASE_URL="https://raw.githubusercontent.com/buildermethods/agent-os/main"

# Create directories
echo "📁 Creating directories..."
mkdir -p "$HOME/.claude/commands"
mkdir -p "$HOME/.claude/agents"

# Download command files for Claude Code
echo ""
echo "📥 Installing Claude Code command files to ~/.claude/commands/ (MODE: $COPY_MODE)"

# Commands
for cmd in plan-product create-spec execute-tasks analyze-product; do
    if [ -f "$HOME/.claude/commands/${cmd}.md" ] && [ "$OVERRIDE_FLAG" = false ]; then
        echo "  ⚠️  ~/.claude/commands/${cmd}.md already exists - skipping"
    else
        if [ -f "$HOME/.claude/commands/${cmd}.md" ] && [ "$OVERRIDE_FLAG" = true ]; then
            echo "  🔄 Overriding ~/.claude/commands/${cmd}.md"
        fi
        copy_file "$HOME/.claude/commands/${cmd}.md" "commands/${cmd}.md" "$COPY_MODE"
        echo "  ✓ ~/.claude/commands/${cmd}.md"
    fi
done

# Download Claude Code agents
echo ""
echo "📥 Installing Claude Code subagents to ~/.claude/agents/ (MODE: $COPY_MODE)"

# List of agent files to download
agents=("test-runner" "context-fetcher" "git-workflow" "file-creator" "date-checker" "jira-workflow")

for agent in "${agents[@]}"; do
    if [ -f "$HOME/.claude/agents/${agent}.md" ] && [ "$OVERRIDE_FLAG" = false ]; then
        echo "  ⚠️  ~/.claude/agents/${agent}.md already exists - skipping"
    else
        if [ -f "$HOME/.claude/agents/${agent}.md" ] && [ "$OVERRIDE_FLAG" = true ]; then
            echo "  🔄 Overriding ~/.claude/agents/${agent}.md"
        fi
        copy_file "$HOME/.claude/agents/${agent}.md" "claude-code/agents/${agent}.md" "$COPY_MODE"
        echo "  ✓ ~/.claude/agents/${agent}.md"
    fi
done

echo ""
echo "✅ Agent OS Claude Code installation complete!"
echo ""
echo "📍 Files installed to:"
echo "   ~/.claude/commands/        - Claude Code commands"
echo "   ~/.claude/agents/          - Claude Code specialized subagents"
echo ""
echo "Next steps:"
echo ""
echo "Initiate Agent OS in a new product's codebase with:"
echo "  /plan-product"
echo ""
echo "Initiate Agent OS in an existing product's codebase with:"
echo "  /analyze-product"
echo ""
echo "Initiate a new feature with:"
echo "  /create-spec (or simply ask 'what's next?')"
echo ""
echo "Build and ship code with:"
echo "  /execute-task"
echo ""
echo "Learn more at https://buildermethods.com/agent-os"
echo ""
