#!/bin/bash -e

# Variables
root=$1

# Use root directory
cd "$root"

# Create virtual environment
python3 -m venv "$root/venv"

# Install dependencies
"$root/venv/bin/pip" install --upgrade cibuildwheel packaging wheel
