#!/bin/bash

# Agent OS Base Installation Script
# Installs Agent OS from local source to ~/agent-os

set -e

# Source configuration
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# Installation paths
BASE_DIR="$HOME/agent-os"
TEMP_DIR=$(mktemp -d)
COMMON_FUNCTIONS_TEMP="$TEMP_DIR/common-functions.sh"

# -----------------------------------------------------------------------------
# Bootstrap Functions (before common-functions.sh is available)
# -----------------------------------------------------------------------------

# Minimal color codes for bootstrap
BLUE='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Bootstrap print functions
bootstrap_print() {
    echo -e "${BLUE}$1${NC}"
}

bootstrap_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Load common-functions.sh from local source
download_common_functions() {
    local functions_file="$SOURCE_DIR/scripts/common-functions.sh"

    if [[ -f "$functions_file" ]]; then
        cp "$functions_file" "$COMMON_FUNCTIONS_TEMP"
        # Source the common functions
        source "$COMMON_FUNCTIONS_TEMP"
        return 0
    else
        bootstrap_error "Failed to find common-functions.sh at $functions_file"
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# Initialize common functions
# -----------------------------------------------------------------------------

bootstrap_print "Initializing..."
download_common_functions

# Clean up temp directory on exit and restore cursor
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
    # Always restore cursor on exit
    tput cnorm 2>/dev/null || true
}
trap cleanup EXIT

# -----------------------------------------------------------------------------
# Version Functions
# -----------------------------------------------------------------------------

# Get version from local source
get_latest_version() {
    local config_file="$SOURCE_DIR/config.yml"
    if [[ -f "$config_file" ]]; then
        grep "^version:" "$config_file" | sed 's/version: *//' | tr -d '\r\n'
    else
        echo ""
    fi
}

# -----------------------------------------------------------------------------
# File Copy Functions
# -----------------------------------------------------------------------------

# Copy file from local source
download_file() {
    local relative_path=$1
    local dest_path=$2
    local source_path="$SOURCE_DIR/${relative_path}"

    mkdir -p "$(dirname "$dest_path")"

    if [[ -f "$source_path" ]]; then
        cp "$source_path" "$dest_path"
        return 0
    else
        return 1
    fi
}

# Define exclusion patterns
EXCLUSIONS=(
    "scripts/base-install.sh"
    "old-versions/*"
    ".git*"
    ".github/*"
)

# Check if a file should be excluded
should_exclude() {
    local file_path=$1

    for pattern in "${EXCLUSIONS[@]}"; do
        # Check exact match
        if [[ "$file_path" == "$pattern" ]]; then
            return 0
        fi
        # Check wildcard patterns
        if [[ "$pattern" == *"*"* ]]; then
            local prefix="${pattern%\*}"
            if [[ "$file_path" == "$prefix"* ]]; then
                return 0
            fi
        fi
    done

    return 1
}

# Get all files from local source directory
get_all_repo_files() {
    print_verbose "Listing files from local source: $SOURCE_DIR"

    # Use find to list all files, excluding .git and other patterns
    find "$SOURCE_DIR" -type f | while read -r full_path; do
        # Get relative path from SOURCE_DIR
        local file_path="${full_path#$SOURCE_DIR/}"

        # Skip if file should be excluded
        if ! should_exclude "$file_path"; then
            echo "$file_path"
        fi
    done
}

# Copy all files from the local source
download_all_files() {
    local dest_base=$1
    local file_count=0

    print_verbose "Listing local source files..."

    # Get list of all files (excluding our exclusion list)
    local all_files=$(get_all_repo_files)

    if [[ -z "$all_files" ]]; then
        echo "0"  # Return 0 to indicate no files copied
        return 1
    fi

    # Copy each file (using process substitution to avoid subshell variable issue)
    while IFS= read -r file_path; do
        if [[ -n "$file_path" ]]; then
            local dest_file="${dest_base}/${file_path}"

            # Create directory if needed
            local dir_path=$(dirname "$dest_file")
            [[ -d "$dir_path" ]] || mkdir -p "$dir_path"

            if download_file "$file_path" "$dest_file"; then
                ((file_count++)) || true
                print_verbose "  Copied: ${file_path}"
            else
                print_verbose "  Failed to copy: ${file_path}"
            fi
        fi
    done <<< "$all_files"

    echo "$file_count"
}

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

# Print status message without newline
print_status_no_newline() {
    echo -ne "${BLUE}$1${NC}"
}

# Animated spinner for long-running operations
spinner() {
    local delay=0.5
    while true; do
        for dot_count in "" "." ".." "..."; do
            echo -ne "\r${BLUE}Installing Agent OS files${dot_count}${NC}   "
            sleep $delay
        done
    done
}

# -----------------------------------------------------------------------------
# Installation Functions
# -----------------------------------------------------------------------------

# Install all files from local source
install_all_files() {
    if [[ "$DRY_RUN" != "true" ]]; then
        # Start spinner in background
        spinner_pid=""
        if [[ "$VERBOSE" != "true" ]]; then
            # Hide cursor before starting spinner
            tput civis 2>/dev/null || true
            spinner &
            spinner_pid=$!
        else
            print_status "Installing Agent OS files..."
        fi
    fi

    # Copy all files (excluding those in exclusion list)
    local file_count
    file_count=$(download_all_files "$BASE_DIR")
    local copy_status=$?

    # Stop spinner if running
    if [[ -n "$spinner_pid" ]]; then
        kill $spinner_pid 2>/dev/null
        wait $spinner_pid 2>/dev/null
        # Clear the line and restore cursor
        echo -ne "\r\033[K"
        tput cnorm 2>/dev/null || true  # Show cursor again
    fi

    if [[ "$DRY_RUN" != "true" ]]; then
        if [[ $copy_status -eq 0 && $file_count -gt 0 ]]; then
            echo "✓ Installed $file_count files to ~/agent-os"
        else
            print_error "No files were copied"
            return 1
        fi
    fi

    # Make scripts executable
    if [[ -d "$BASE_DIR/scripts" ]]; then
        chmod +x "$BASE_DIR/scripts/"*.sh 2>/dev/null || true
    fi

    return 0
}

# -----------------------------------------------------------------------------
# Overwrite Functions
# -----------------------------------------------------------------------------

# Prompt for overwrite choice
prompt_overwrite_choice() {
    local current_version=$1
    local latest_version=$2

    echo ""
    echo -e "${YELLOW}=== ⚠️  Existing Installation Detected ===${NC}"
    echo ""

    echo "You already have a base installation of Agent OS"

    if [[ -n "$current_version" ]]; then
        echo -e "  Your installed version: ${YELLOW}$current_version${NC}"
    else
        echo "  Your installed version: (unknown)"
    fi

    if [[ -n "$latest_version" ]]; then
        echo -e "  Latest available version: ${YELLOW}$latest_version${NC}"
    else
        echo "  Latest available version: (unable to determine)"
    fi

    # Show current and new profile if different
    local current_profile=""
    if [[ -f "$BASE_DIR/config.yml" ]]; then
        current_profile=$(get_yaml_value "$BASE_DIR/config.yml" "profile" "default")
    fi
    if [[ -n "$current_profile" ]]; then
        echo -e "  Your current profile: ${YELLOW}$current_profile${NC}"
    fi
    if [[ "$PROFILE" != "$current_profile" ]]; then
        echo -e "  New profile will be set to: ${YELLOW}$PROFILE${NC}"
    fi

    echo ""
    print_status "What would you like to do?"
    echo ""

    echo -e "${YELLOW}1) Full update${NC}"
    echo ""
    echo "    Updates & overwrites:"
    echo "    - ~/agent-os/profiles/default/*"
    echo "    - ~/agent-os/scripts/*"
    echo "    - ~/agent-os/CHANGELOG.md"
    echo ""
    echo "    Updates your version number in ~/agent-os/config.yml but doesn't change anything else in this file."
    if [[ "$PROFILE" != "$current_profile" ]]; then
        echo "    Also sets profile to '$PROFILE' in config.yml."
    fi
    echo ""
    echo "    Everything else in your ~/agent-os folder will remain intact."
    echo ""

    echo -e "${YELLOW}2) Update default profile only${NC}"
    echo ""
    echo "    Updates & overwrites:"
    echo "    - ~/agent-os/profiles/default/*"
    echo ""
    echo "    Everything else in your ~/agent-os folder will remain intact."
    echo ""

    echo -e "${YELLOW}3) Update scripts only${NC}"
    echo ""
    echo "    Updates & overwrites:"
    echo "    - ~/agent-os/scripts/*"
    echo ""
    echo "    Everything else in your ~/agent-os folder will remain intact."
    echo ""

    echo -e "${YELLOW}4) Update config.yml only${NC}"
    echo ""
    echo "    Updates & overwrites:"
    echo "    - ~/agent-os/config.yml"
    if [[ "$PROFILE" != "$current_profile" ]]; then
        echo "    Sets profile to '$PROFILE' in config.yml."
    fi
    echo ""
    echo "    Everything else in your ~/agent-os folder will remain intact."
    echo ""

    echo -e "${YELLOW}5) Delete & reinstall fresh${NC}"
    echo ""
    echo "    - Makes a backup of your current ~/agent-os folder at ~/agent-os.backup"
    echo "    - Deletes your current ~/agent-os folder and all of its contents."
    echo "    - Installs a fresh ~/agent-os base installation"
    echo ""

    echo -e "${YELLOW}6) Cancel and abort${NC}"
    echo ""

    read -p "Enter your choice (1-6): " choice < /dev/tty

    case $choice in
        1)
            echo ""
            print_status "Performing full update..."
            full_update "$latest_version"
            # Update profile setting if specified
            if [[ "$PROFILE" != "default" ]] && [[ -f "$BASE_DIR/config.yml" ]]; then
                sed -i.bak "s/^profile:.*/profile: $PROFILE/" "$BASE_DIR/config.yml"
                rm -f "$BASE_DIR/config.yml.bak"
                echo "✓ Set profile to $PROFILE in config.yml"
            fi
            ;;
        2)
            echo ""
            print_status "Updating default profile..."
            create_backup
            overwrite_profile
            ;;
        3)
            echo ""
            print_status "Updating scripts..."
            create_backup
            overwrite_scripts
            ;;
        4)
            echo ""
            print_status "Updating config.yml..."
            create_backup
            overwrite_config
            # Update profile setting if specified
            if [[ "$PROFILE" != "default" ]] && [[ -f "$BASE_DIR/config.yml" ]]; then
                sed -i.bak "s/^profile:.*/profile: $PROFILE/" "$BASE_DIR/config.yml"
                rm -f "$BASE_DIR/config.yml.bak"
                echo "✓ Set profile to $PROFILE in config.yml"
            fi
            ;;
        5)
            echo ""
            print_status "Deleting & reinstalling fresh..."
            overwrite_all
            ;;
        6)
            echo ""
            print_warning "Installation cancelled"
            exit 0
            ;;
        *)
            print_error "Invalid choice. Installation cancelled."
            exit 1
            ;;
    esac
}

# Create backup of existing installation
create_backup() {
    # Backup existing installation
    if [[ -d "$BASE_DIR.backup" ]]; then
        rm -rf "$BASE_DIR.backup"
    fi
    cp -R "$BASE_DIR" "$BASE_DIR.backup"
    echo "✓ Backed up existing installation to ~/agent-os.backup"
    echo ""
}

# Full update - updates profile, scripts, CHANGELOG.md, and version number in config.yml
full_update() {
    local latest_version=$1

    # Create backup first
    create_backup

    # Update default profile
    print_status "Updating default profile..."
    rm -rf "$BASE_DIR/profiles/default"
    local file_count=0
    local all_files=$(get_all_repo_files | grep "^profiles/default/")
    if [[ -n "$all_files" ]]; then
        while IFS= read -r file_path; do
            if [[ -n "$file_path" ]]; then
                local dest_file="${BASE_DIR}/${file_path}"
                local dir_path=$(dirname "$dest_file")
                [[ -d "$dir_path" ]] || mkdir -p "$dir_path"
                if download_file "$file_path" "$dest_file"; then
                    ((file_count++)) || true
                    print_verbose "  Copied: ${file_path}"
                fi
            fi
        done <<< "$all_files"
    fi
    echo "✓ Updated default profile ($file_count files)"
    echo ""

    # Update scripts
    print_status "Updating scripts..."
    rm -rf "$BASE_DIR/scripts"
    file_count=0
    all_files=$(get_all_repo_files | grep "^scripts/")
    if [[ -n "$all_files" ]]; then
        while IFS= read -r file_path; do
            if [[ -n "$file_path" ]]; then
                local dest_file="${BASE_DIR}/${file_path}"
                local dir_path=$(dirname "$dest_file")
                [[ -d "$dir_path" ]] || mkdir -p "$dir_path"
                if download_file "$file_path" "$dest_file"; then
                    ((file_count++)) || true
                    print_verbose "  Copied: ${file_path}"
                fi
            fi
        done <<< "$all_files"
        chmod +x "$BASE_DIR/scripts/"*.sh 2>/dev/null || true
    fi
    echo "✓ Updated scripts ($file_count files)"
    echo ""

    # Update CHANGELOG.md
    print_status "Updating CHANGELOG.md..."
    if download_file "CHANGELOG.md" "$BASE_DIR/CHANGELOG.md"; then
        echo "✓ Updated CHANGELOG.md"
    fi
    echo ""

    # Update version number in config.yml (without overwriting the entire file)
    print_status "Updating version number in config.yml..."
    if [[ -f "$BASE_DIR/config.yml" ]] && [[ -n "$latest_version" ]]; then
        # Use sed to update only the version line
        sed -i.bak "s/^version:.*/version: $latest_version/" "$BASE_DIR/config.yml"
        rm -f "$BASE_DIR/config.yml.bak"
        echo "✓ Updated version to $latest_version in config.yml"
    fi
    echo ""

    print_success "Full update completed!"
}

# Overwrite everything
overwrite_all() {
    # Backup existing installation
    if [[ -d "$BASE_DIR.backup" ]]; then
        rm -rf "$BASE_DIR.backup"
    fi
    mv "$BASE_DIR" "$BASE_DIR.backup"
    echo "✓ Backed up existing installation to ~/agent-os.backup"
    echo ""

    # Perform fresh installation
    perform_fresh_installation
}

# Overwrite only profile
overwrite_profile() {
    # Remove existing default profile
    rm -rf "$BASE_DIR/profiles/default"

    # Copy only profile files
    local file_count=0

    # Get all files and filter for profiles/default
    local all_files=$(get_all_repo_files | grep "^profiles/default/")

    if [[ -n "$all_files" ]]; then
        while IFS= read -r file_path; do
            if [[ -n "$file_path" ]]; then
                local dest_file="${BASE_DIR}/${file_path}"
                local dir_path=$(dirname "$dest_file")
                [[ -d "$dir_path" ]] || mkdir -p "$dir_path"

                if download_file "$file_path" "$dest_file"; then
                    ((file_count++)) || true
                    print_verbose "  Copied: ${file_path}"
                fi
            fi
        done <<< "$all_files"
    fi

    echo "✓ Updated default profile ($file_count files)"
    echo ""
    print_success "Default profile has been updated!"
}

# Overwrite only scripts
overwrite_scripts() {
    # Remove existing scripts
    rm -rf "$BASE_DIR/scripts"

    # Copy only script files
    local file_count=0

    # Get all files and filter for scripts/
    local all_files=$(get_all_repo_files | grep "^scripts/")

    if [[ -n "$all_files" ]]; then
        while IFS= read -r file_path; do
            if [[ -n "$file_path" ]]; then
                local dest_file="${BASE_DIR}/${file_path}"
                local dir_path=$(dirname "$dest_file")
                [[ -d "$dir_path" ]] || mkdir -p "$dir_path"

                if download_file "$file_path" "$dest_file"; then
                    ((file_count++)) || true
                    print_verbose "  Copied: ${file_path}"
                fi
            fi
        done <<< "$all_files"

        # Make scripts executable
        chmod +x "$BASE_DIR/scripts/"*.sh 2>/dev/null || true
    fi

    echo "✓ Updated scripts ($file_count files)"
    echo ""
    print_success "Scripts have been updated!"
}

# Overwrite only config
overwrite_config() {
    # Copy new config.yml
    if download_file "config.yml" "$BASE_DIR/config.yml"; then
        print_verbose "  Copied: config.yml"
    fi

    echo "✓ Updated config.yml"
    echo ""
    print_success "Config has been updated!"
}

# -----------------------------------------------------------------------------
# Main Installation Functions
# -----------------------------------------------------------------------------

# Perform fresh installation
perform_fresh_installation() {
    echo ""
    print_status "Configuration:"
    echo -e "  Source: ${YELLOW}${SOURCE_DIR}${NC}"
    echo -e "  Target: ${YELLOW}~/agent-os${NC}"
    echo -e "  Profile: ${YELLOW}${PROFILE}${NC}"
    echo ""

    # Create base directory
    ensure_dir "$BASE_DIR"
    echo "✓ Created base directory: ~/agent-os"
    echo ""

    # Install all files from repository
    if ! install_all_files; then
        print_error "Installation failed"
        exit 1
    fi

    # Update profile setting in config.yml if non-default profile specified
    if [[ "$PROFILE" != "default" ]] && [[ -f "$BASE_DIR/config.yml" ]]; then
        print_status "Setting profile to '$PROFILE' in config.yml..."
        sed -i.bak "s/^profile:.*/profile: $PROFILE/" "$BASE_DIR/config.yml"
        rm -f "$BASE_DIR/config.yml.bak"
        echo "✓ Set profile to $PROFILE in config.yml"
        echo ""
    fi

    echo ""
    print_success "Agent OS has been successfully installed!"
    echo ""
    echo -e "${GREEN}Next steps:${NC}"
    echo ""
    echo -e "${GREEN}1) Customize your profile's standards in ~/agent-os/profiles/$PROFILE/standards${NC}"
    echo ""
    echo -e "${GREEN}2) Navigate to a project directory${NC}"
    echo -e "   ${YELLOW}cd path/to/project-directory${NC}"
    echo ""
    echo -e "${GREEN}3) Install Agent OS in your project by running:${NC}"
    echo -e "   ${YELLOW}~/agent-os/scripts/project-install.sh${NC}"
    echo ""
    echo -e "${GREEN}Visit the docs for guides on how to use Agent OS: https://buildermethods.com/agent-os${NC}"
    echo ""
}

# Check for existing installation
check_existing_installation() {
    if [[ -d "$BASE_DIR" ]]; then
        # Get current version if available
        local current_version=""
        if [[ -f "$BASE_DIR/config.yml" ]]; then
            current_version=$(get_yaml_value "$BASE_DIR/config.yml" "version" "")
        fi

        # Get latest version from GitHub
        local latest_version=$(get_latest_version)

        # Prompt for overwrite choice
        prompt_overwrite_choice "$current_version" "$latest_version"
    else
        # Fresh installation
        perform_fresh_installation
    fi
}

# -----------------------------------------------------------------------------
# Global Variables
# -----------------------------------------------------------------------------

VERBOSE=false
DRY_RUN=false
PROFILE="default"

# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------

main() {
    print_section "Agent OS Base Installation"

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            --profile)
                PROFILE="$2"
                shift 2
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --profile NAME   Install and set specific profile as default (default: default)"
                echo "  -v, --verbose    Show verbose output"
                echo "  -h, --help       Show this help message"
                echo ""
                echo "Available profiles:"
                if [[ -d "$SOURCE_DIR/profiles" ]]; then
                    for profile_dir in "$SOURCE_DIR/profiles"/*; do
                        if [[ -d "$profile_dir" ]]; then
                            echo "  - $(basename "$profile_dir")"
                        fi
                    done
                fi
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use -h or --help for usage information"
                exit 1
                ;;
        esac
    done

    # Validate profile exists
    if [[ ! -d "$SOURCE_DIR/profiles/$PROFILE" ]]; then
        print_error "Profile '$PROFILE' not found at $SOURCE_DIR/profiles/$PROFILE"
        echo ""
        print_status "Available profiles:"
        for profile_dir in "$SOURCE_DIR/profiles"/*; do
            if [[ -d "$profile_dir" ]]; then
                echo "  - $(basename "$profile_dir")"
            fi
        done
        exit 1
    fi

    # Check for existing installation or perform fresh install
    check_existing_installation
}

# Run main function
main "$@"
