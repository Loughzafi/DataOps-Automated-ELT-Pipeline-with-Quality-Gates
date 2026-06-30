#!/usr/bin/env bash
set -euo pipefail

echo "[1/6] Updating apt package index..."
sudo apt-get update

echo "[2/6] Installing base dependencies..."
sudo apt-get install -y ca-certificates curl git gnupg lsb-release python3 python3-pip python3-venv

echo "[3/6] Installing Docker engine..."
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sudo sh
fi

echo "[4/6] Enabling Docker for current user..."
sudo usermod -aG docker "$USER"

echo "[5/6] Validating Docker and Compose availability..."
docker --version || true
docker compose version || true

echo "[6/6] Bootstrap complete."
echo "Log out and back in (or run 'newgrp docker') before running docker commands without sudo."
