#!/bin/bash -e

# Variables
root="$1"
repository="$2"
ref="$3"

# Use root directory
cd "$root"

# Checkout repository
if [ ! -d "$root/$repository/$ref" ]; then
  mkdir -p "$root/$repository/$ref"
  git init "$root/$repository/$ref"
fi
cd "$root/$repository/$ref"
if [[ $(git remote) = "" ]]; then
  git remote add origin "https://github.com/$repository"
fi
git config gc.auto 0
git fetch --depth 1 origin "$ref"
git checkout FETCH_HEAD
git clean -xdf
git reset --hard FETCH_HEAD
