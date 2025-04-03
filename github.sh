#!/bin/bash

# Usage: 
# For commits: ./github.sh commit "commit message"
# For pushing: ./github.sh [dev|prod] "push message"

COMMAND=$1
MSG=$2

# Function to check if there are any changes to commit
check_changes() {
    if [ -z "$(git status --porcelain)" ]; then
        echo "No changes to commit"
        exit 0
    fi
}

# Function to ensure we're on the correct branch
ensure_branch() {
    local required_branch=$1
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    if [ "$current_branch" != "$required_branch" ]; then
        echo "Must be on $required_branch branch (currently on $current_branch)"
        exit 1
    fi
}

# Function to safely update a branch
update_branch() {
    local branch=$1
    echo "Updating $branch branch..."
    git fetch origin $branch
    git checkout $branch
    git pull origin $branch
}

# Function to wait for GitHub checks to complete
wait_for_checks() {
    local pr_number=$1
    local max_attempts=30  # 5 minutes total (10 seconds * 30)
    local attempt=1
    
    echo "Waiting for GitHub checks to complete..."
    
    while [ $attempt -le $max_attempts ]; do
        echo "Check attempt $attempt of $max_attempts..."
        sleep 10
        
        check_status=$(gh pr checks $pr_number 2>&1)
        echo "Current status: $check_status"
        
        if echo "$check_status" | grep -q "successful" || echo "$check_status" | grep -q "pass"; then
            echo "✅ Checks completed successfully!"
            return 0
        elif echo "$check_status" | grep -q "fail"; then
            echo "❌ Checks failed. Please review and fix the issues."
            return 1
        elif [ $attempt -eq $max_attempts ]; then
            echo "⚠️ Checks timed out, proceeding with caution..."
            return 0
        fi
        
        ((attempt++))
    done
}

# Function to cleanup temporary branches
cleanup_branches() {
    local backup_pattern="backup/.*"
    echo "Cleaning up temporary branches..."
    
    # List all branches matching the backup pattern
    for branch in $(git branch | grep "$backup_pattern" | sed 's/^[ *]*//'); do
        echo "Deleting backup branch: $branch"
        git branch -D "$branch"
    done
    
    # Clean up any remote backup branches if they exist
    for branch in $(git branch -r | grep "$backup_pattern" | sed 's/^[ *]*//'); do
        echo "Deleting remote backup branch: $branch"
        git push origin --delete "${branch#origin/}"
    done
}

# Function to handle production merge
handle_production_merge() {
    # Create backup branches
    echo "Creating backup branches..."
    git branch "backup/main-$(date +%Y%m%d-%H%M%S)" main
    git branch "backup/develop-$(date +%Y%m%d-%H%M%S)" develop
    
    # Update both branches
    update_branch "main"
    update_branch "develop"
    
    # Push to development branch first
    echo "Pushing to development branch..."
    if ! git push origin develop; then
        echo "Failed to push to development branch. Please check your changes and try again."
        cleanup_branches
        exit 1
    fi
    
    # Create and handle pull request
    echo "Creating pull request..."
    pr_output=$(gh pr create --base main --head develop --title "$MSG" --body "Merging development changes into main branch")
    
    if [ $? -ne 0 ]; then
        echo "Failed to create pull request. Please check if there are any existing PRs or conflicts."
        cleanup_branches
        exit 1
    fi
    
    # Extract PR number
    pr_number=$(echo "$pr_output" | grep -o '#[0-9]\+' | tr -d '#')
    
    # Wait for checks
    if ! wait_for_checks $pr_number; then
        echo "GitHub checks failed. Please review the issues and try again."
        cleanup_branches
        exit 1
    fi
    
    # Merge the pull request
    echo "Merging pull request..."
    if ! gh pr merge $pr_number --merge --admin; then
        echo "Failed to merge pull request. Please check for conflicts and try again."
        cleanup_branches
        exit 1
    fi
    
    # Update branches
    update_branch "main"
    update_branch "develop"
    
    # Rebase develop from main to ensure it's up to date
    echo "Rebasing develop from main..."
    git checkout develop
    if ! git rebase main; then
        echo "Failed to rebase develop from main. Please resolve any conflicts manually."
        cleanup_branches
        exit 1
    fi
    
    # Clean up temporary branches
    cleanup_branches
    
    echo "Production merge completed successfully!"
}

# Commit workflow
if [ "$COMMAND" == "commit" ]; then
    if [ -z "$MSG" ]; then
        echo "Please provide a commit message"
        echo "Usage: ./github.sh commit \"commit message\""
        exit 1
    fi
    
    echo "Creating new commit..."
    check_changes
    
    git add .
    git commit -m "$MSG"
    
    echo "Changes committed successfully!"
    exit 0
fi

# Development/Production workflow
if [ "$COMMAND" == "dev" ] || [ "$COMMAND" == "prod" ]; then
    if [ -z "$MSG" ]; then
        echo "Please provide a push message"
        echo "Usage: ./github.sh [dev|prod] \"push message\""
        exit 1
    fi

    # Development workflow
    if [ "$COMMAND" == "dev" ]; then
        echo "Running development workflow..."
        ensure_branch "develop"
        git push origin develop
        echo "Changes pushed to development branch"

    # Production workflow
    else
        echo "Running production workflow..."
        ensure_branch "develop"
        handle_production_merge
    fi
else
    echo "Invalid command. Usage:"
    echo "  For commits: ./github.sh commit \"commit message\""
    echo "  For pushing: ./github.sh [dev|prod] \"push message\""
    exit 1
fi 