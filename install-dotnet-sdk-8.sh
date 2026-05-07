#!/usr/bin/env bash
set -euo pipefail

# Configure APT for .NET
wget https://packages.microsoft.com/config/debian/13/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

# Install .NET SDK
apt-get update && apt-get install -y dotnet-sdk-8.0