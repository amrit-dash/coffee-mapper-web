#!/bin/bash

# Usage: ./run.sh [dev|prod]
# Script to run the Flutter web app locally with environment-specific configurations

ENV=$1

if [ "$ENV" != "dev" ] && [ "$ENV" != "prod" ]; then
    echo "Please specify environment: dev or prod"
    echo "Usage: ./run.sh [dev|prod]"
    exit 1
fi

# Function to setup rules for the current environment
setup_rules() {
    local env=$1
    
    # Create directories if they don't exist
    mkdir -p firestore/$env storage/$env
    
    # Copy rules if they don't exist
    if [ ! -f firestore/$env/firestore.rules ]; then
        cp firestore.rules firestore/$env/firestore.rules
    fi
    
    if [ ! -f firestore/$env/firestore.indexes.json ]; then
        cp firestore.indexes.json firestore/$env/firestore.indexes.json
    fi
    
    if [ ! -f storage/$env/storage.rules ]; then
        cp storage.rules storage/$env/storage.rules
    fi
    
    # Use environment-specific rules
    cp firestore/$env/firestore.rules firestore.rules
    cp firestore/$env/firestore.indexes.json firestore.indexes.json
    cp storage/$env/storage.rules storage.rules
}

# Clean any previous builds
echo "Cleaning previous builds..."
flutter clean
rm -rf build/

# Setup environment-specific configurations
if [ "$ENV" == "prod" ]; then
    echo "Setting up production environment..."
    setup_rules "prod"
    firebase use prod
    
    echo "Starting Flutter web app in production mode..."
    flutter run -d chrome --web-port=5000 --dart-define=ENVIRONMENT=production
else
    echo "Setting up development environment..."
    setup_rules "dev"
    firebase use dev
    
    echo "Starting Flutter web app in development mode..."
    flutter run -d chrome --web-port=5000 --dart-define=ENVIRONMENT=development
fi 