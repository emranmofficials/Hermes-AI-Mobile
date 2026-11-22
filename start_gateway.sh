#!/bin/sh
# Hermes AI Gateway & Webapp Launcher for Termux/Android
cd "$(dirname "$0")/gateway" || exit 1
echo "🚀 Starting Hermes AI Web App & Gateway on port 8000..."
python3 server.py
