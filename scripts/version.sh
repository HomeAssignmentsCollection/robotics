#!/bin/bash

# Version management script for DevOps CI/CD Demo
# Usage: ./scripts/version.sh [command] [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

VERSION_FILE="VERSION"
GIT_TAG_PREFIX="v"

# Function to get current version
get_current_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "0.0.0"
    fi
}

# Function to get latest git tag
get_latest_git_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0"
}

# Function to parse version components
parse_version() {
    local version=$1
    local major=$(echo $version | cut -d. -f1)
    local minor=$(echo $version | cut -d. -f2)
    local patch=$(echo $version | cut -d. -f3 | cut -d- -f1)
    echo "$major $minor $patch"
}

# Function to bump version
bump_version() {
    local current_version=$(get_current_version)
    local bump_type=$1
    
    read major minor patch <<< $(parse_version $current_version)
    
    case $bump_type in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        *)
            echo -e "${RED}Error: Invalid bump type. Use major, minor, or patch${NC}"
            exit 1
            ;;
    esac
    
    echo "$major.$minor.$patch"
}

# Function to create git tag
create_git_tag() {
    local version=$1
    local tag="${GIT_TAG_PREFIX}${version}"
    
    echo -e "${BLUE}Creating git tag: $tag${NC}"
    git tag -a "$tag" -m "Release version $version"
    git push origin "$tag"
}

# Function to update version file
update_version_file() {
    local version=$1
    echo -e "${BLUE}Updating VERSION file: $version${NC}"
    echo "$version" > "$VERSION_FILE"
    git add "$VERSION_FILE"
    git commit -m "chore: bump version to $version"
}

# Function to generate build metadata
generate_build_metadata() {
    local commit_hash=$(git rev-parse --short HEAD)
    local timestamp=$(date -u +%Y%m%d.%H%M%S)
    echo "${timestamp}.${commit_hash}"
}

# Function to get git commit hash
get_git_commit() {
    git rev-parse --short HEAD
}

# Function to get git branch
get_git_branch() {
    git branch --show-current
}

# Function to check if working directory is clean
is_working_directory_clean() {
    git diff-index --quiet HEAD --
}

# Main command handler
case "${1:-help}" in
    get)
        echo $(get_current_version)
        ;;
    
    bump)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Specify bump type (major, minor, patch)${NC}"
            exit 1
        fi
        
        # Check if working directory is clean
        if ! is_working_directory_clean; then
            echo -e "${RED}Error: Working directory is not clean. Commit or stash changes first.${NC}"
            exit 1
        fi
        
        new_version=$(bump_version "$2")
        echo -e "${GREEN}Bumping version to: $new_version${NC}"
        update_version_file "$new_version"
        ;;
    
    release)
        current_version=$(get_current_version)
        echo -e "${GREEN}Creating release for version: $current_version${NC}"
        
        # Check if working directory is clean
        if ! is_working_directory_clean; then
            echo -e "${RED}Error: Working directory is not clean. Commit or stash changes first.${NC}"
            exit 1
        fi
        
        # Create git tag
        create_git_tag "$current_version"
        
        # Generate build metadata
        build_metadata=$(generate_build_metadata)
        echo -e "${BLUE}Build metadata: $build_metadata${NC}"
        
        # Set environment variables for CI/CD
        if [ -n "$GITHUB_ENV" ]; then
            echo "VERSION=$current_version" >> $GITHUB_ENV
            echo "BUILD_METADATA=$build_metadata" >> $GITHUB_ENV
            echo "DOCKER_TAG=$current_version" >> $GITHUB_ENV
            echo "GIT_COMMIT=$(get_git_commit)" >> $GITHUB_ENV
            echo "GIT_BRANCH=$(get_git_branch)" >> $GITHUB_ENV
        fi
        
        echo -e "${GREEN}Release created successfully!${NC}"
        echo "Version: $current_version"
        echo "Build Metadata: $build_metadata"
        echo "Git Commit: $(get_git_commit)"
        echo "Git Branch: $(get_git_branch)"
        ;;
    
    tag)
        version=${2:-$(get_current_version)}
        echo -e "${GREEN}Creating git tag for version: $version${NC}"
        create_git_tag "$version"
        ;;
    
    info)
        current_version=$(get_current_version)
        latest_tag=$(get_latest_git_tag)
        build_metadata=$(generate_build_metadata)
        
        echo -e "${BLUE}Version Information:${NC}"
        echo "  Current Version: $current_version"
        echo "  Latest Git Tag: $latest_tag"
        echo "  Build Metadata: $build_metadata"
        echo "  Git Branch: $(get_git_branch)"
        echo "  Git Commit: $(get_git_commit)"
        echo "  Working Directory Clean: $(is_working_directory_clean && echo 'Yes' || echo 'No')"
        ;;
    
    validate)
        version=$(get_current_version)
        if [[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.-]+)?$ ]]; then
            echo -e "${GREEN}Version format is valid: $version${NC}"
        else
            echo -e "${RED}Error: Invalid version format: $version${NC}"
            exit 1
        fi
        ;;
    
    init)
        if [ -f "$VERSION_FILE" ]; then
            echo -e "${YELLOW}VERSION file already exists: $(cat $VERSION_FILE)${NC}"
        else
            echo "1.0.0" > "$VERSION_FILE"
            echo -e "${GREEN}Initialized VERSION file with 1.0.0${NC}"
            git add "$VERSION_FILE"
            git commit -m "chore: initialize version file"
        fi
        ;;
    
    help|*)
        echo -e "${BLUE}Version Management Script${NC}"
        echo ""
        echo "Usage: $0 [command] [options]"
        echo ""
        echo "Commands:"
        echo "  get                    - Get current version"
        echo "  bump [major|minor|patch] - Bump version"
        echo "  release                - Create release (tag + metadata)"
        echo "  tag [version]          - Create git tag"
        echo "  info                   - Show version information"
        echo "  validate               - Validate version format"
        echo "  init                   - Initialize VERSION file"
        echo "  help                   - Show this help"
        echo ""
        echo "Examples:"
        echo "  $0 get                 # Get current version"
        echo "  $0 bump patch          # Bump patch version"
        echo "  $0 bump minor          # Bump minor version"
        echo "  $0 bump major          # Bump major version"
        echo "  $0 release             # Create release"
        echo "  $0 info                # Show version info"
        echo "  $0 init                # Initialize version file"
        echo ""
        echo "Version File: $VERSION_FILE"
        echo "Git Tag Prefix: $GIT_TAG_PREFIX"
        ;;
esac 