#!/bin/bash

# NAS Material Manager v3 - Startup Script for Linux/Mac

echo "=================================="
echo "NAS Material Manager v3"
echo "=================================="
echo ""

# Navigate to backend directory
cd "$(dirname "$0")/backend" || exit 1

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "Creating .env file from .env.example..."
    cp .env.example .env
    echo "Please edit .env file to configure your settings"
    echo ""
fi

# Install dependencies
echo "Installing dependencies..."
npm install

echo ""
echo "Starting server..."
echo "The server will be available at http://localhost:3000"
echo ""
echo "Default admin credentials:"
echo "  Username: admin"
echo "  Password: admin123"
echo ""
echo "IMPORTANT: Please change the admin password after first login!"
echo ""

# Start server
npm start
