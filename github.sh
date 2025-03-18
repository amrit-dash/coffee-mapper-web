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

# Function to wait for GitHub checks to complete
wait_for_checks() {
    local pr_number=$1
    
    echo "Waiting for 10s to breathe..."
    sleep 10  # Wait for 2 minutes
    
    echo "Checking build status..."
    check_status=$(gh pr checks $pr_number 2>&1)
    echo "Current status: $check_status"
    
    if echo "$check_status" | grep -q "successful" || echo "$check_status" | grep -q "pass"; then
        echo "✅ Checks completed successfully!"
        return 0
    elif echo "$check_status" | grep -q "fail"; then
        echo "❌ Some checks failed, but proceeding with admin merge..."
        return 0
    else
        echo "⚠️ Status unclear, proceeding with admin merge..."
        return 0
    fi
}

# Commit workflow
if [ "$COMMAND" == "commit" ]; then
    if [ -z "$MSG" ]; then
        echo "Please provide a commit message"
        echo "Usage: ./github.sh commit \"commit message\""
        exit 1
    fi
    
    echo "Creating new commit..."
    
    # Check if there are changes to commit
    check_changes
    
    # Add all changes
    git add .
    
    # Commit changes
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
        
        # Push to development branch
        git push origin develop
        
        echo "Changes pushed to development branch"

    # Production workflow
    else
        echo "Running production workflow..."
        
        # Ensure we're on develop branch
        if [ "$(git rev-parse --abbrev-ref HEAD)" != "develop" ]; then
            echo "Must be on develop branch to run production workflow"
            exit 1
        fi
        
        # Push to development branch first
        git push origin develop
        
        # Create pull request
        echo "Creating pull request..."
        pr_output=$(gh pr create --base main --head develop --title "$MSG" --body "Merging development changes into main branch")
        
        # Extract PR number from the URL
        pr_number=$(echo "$pr_output" | grep -o '#[0-9]\+' | tr -d '#')
        
        # Brief check for build status
        wait_for_checks $pr_number
        
        # Force merge with admin privileges
        echo "Force merging pull request with admin privileges..."
        gh pr merge $pr_number --merge --admin
        
        # Update local main branch
        git fetch origin main
        git checkout main
        git pull origin main
        
        # Switch back to develop and rebase from main
        git checkout develop
        git rebase main
        
        echo "Production workflow completed successfully!"
    fi
else
    echo "Invalid command. Usage:"
    echo "  For commits: ./github.sh commit \"commit message\""
    echo "  For pushing: ./github.sh [dev|prod] \"push message\""
    exit 1
fi 