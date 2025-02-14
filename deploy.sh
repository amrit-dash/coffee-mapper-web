#!/bin/bash

# Usage: ./deploy.sh [dev|prod] [site]
# For production, site can be: main, backup, or all

ENV=$1
SITE=$2

if [ "$ENV" != "dev" ] && [ "$ENV" != "prod" ]; then
    echo "Please specify environment: dev or prod"
    exit 1
fi

if [ "$ENV" == "prod" ] && [ "$SITE" != "main" ] && [ "$SITE" != "backup" ] && [ "$SITE" != "all" ]; then
    echo "For production, please specify site: main, backup, or all"
    exit 1
fi

# Function to deploy to a specific site
deploy_to_site() {
    local site=$1
    echo "Deploying to site: $site..."
    firebase deploy --only hosting:$site
}

# Function to setup rules for the current environment
setup_rules() {
    local env=$1
    local rules_changed=false
    
    # Create directories if they don't exist
    mkdir -p firestore/$env storage/$env
    
    # Only copy rules if they don't exist or are different
    if [ ! -f firestore/$env/firestore.rules ] || ! cmp -s firestore.rules firestore/$env/firestore.rules; then
        cp firestore.rules firestore/$env/firestore.rules
        cp firestore/$env/firestore.rules firestore.rules
        rules_changed=true
    fi
    
    if [ ! -f firestore/$env/firestore.indexes.json ] || ! cmp -s firestore.indexes.json firestore/$env/firestore.indexes.json; then
        cp firestore.indexes.json firestore/$env/firestore.indexes.json
        cp firestore/$env/firestore.indexes.json firestore.indexes.json
        rules_changed=true
    fi
    
    if [ ! -f storage/$env/storage.rules ] || ! cmp -s storage.rules storage/$env/storage.rules; then
        cp storage.rules storage/$env/storage.rules
        cp storage/$env/storage.rules storage.rules
        rules_changed=true
    fi
    
    echo $rules_changed
}

# Build and deploy for the specified environment
if [ "$ENV" == "prod" ]; then
    echo "Building for production environment..."
    
    # Setup production rules and check if they changed
    rules_changed=$(setup_rules "prod")
    
    # Clean and build for production
    flutter clean
    rm -rf build/
    flutter build web --dart-define=ENVIRONMENT=production --release
    
    echo "Deploying to production environment..."
    firebase use prod
    
    # Deploy Firebase rules only if they changed
    if [ "$rules_changed" = "true" ]; then
        echo "Deploying updated Firebase rules and configurations..."
        firebase deploy --only firestore,storage
    fi
    
    # Deploy to specified production sites
    if [ "$SITE" == "main" ] || [ "$SITE" == "all" ]; then
        deploy_to_site "cdt-koraput"
    fi
    
    if [ "$SITE" == "backup" ] || [ "$SITE" == "all" ]; then
        deploy_to_site "coffeemapper"
    fi

    if [ "$SITE" == "all" ]; then
        deploy_to_site "cdtkoraput"
    fi

    if [ "$SITE" == "all" ]; then
        deploy_to_site "cdtdashboard"
    fi
    
else
    echo "Building for development environment..."
    
    # Setup development rules and check if they changed
    rules_changed=$(setup_rules "dev")
    
    # Clean and build for development
    flutter clean
    rm -rf build/
    flutter build web --dart-define=ENVIRONMENT=development --release
    
    echo "Deploying to development environment..."
    firebase use dev
    
    # Deploy Firebase rules only if they changed
    if [ "$rules_changed" = "true" ]; then
        echo "Deploying updated Firebase rules and configurations..."
        firebase deploy --only firestore,storage
    fi
    
    # Deploy to development site
    deploy_to_site "coffee-mapper-dashboard"
fi

# Switch back to development for local development
firebase use dev

echo "Deployment to $ENV completed!" 