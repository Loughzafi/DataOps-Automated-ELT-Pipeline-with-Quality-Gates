#!/usr/bin/env bash
set -euo pipefail

echo "[1/6] Updating apt package index..."
sudo apt-get update

echo "[2/6] Installing base dependencies..."
sudo apt-get install -y ca-certificates curl git gnupg lsb-release python3 python3-pip python3-venv

echo "[3/6] Installing Docker engine..."
if ! command -v docker >/dev/null 2>&1; then
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

echo "[4/6] Enabling Docker for current user..."
sudo usermod -aG docker "$USER"

echo "[5/6] Validating Docker and Compose availability..."
docker --version || true
docker compose version || true

echo "[6/6] Bootstrap complete."
echo "Log out and back in (or run 'newgrp docker') before running docker commands without sudo."
