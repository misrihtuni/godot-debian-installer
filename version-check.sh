#!/bin/bash

VERSION_INPUT=$1

# Retrieve version tags and save them to a file.
curl -s https://api.github.com/repos/godotengine/godot/tags | grep "name" | grep stable | grep -o '\([0-9]\.\)\+[0-9]' > versions.txt

# Check number of verified versions
wc -l versions.txt

# Check if the selected version exists.
version_check_result=$(cat versions.txt | grep $VERSION_INPUT)
if [[ "$version_check_result" == "" ]]; then
  echo "Version not found!"
else
  echo "Version was found, starting installer."
fi
