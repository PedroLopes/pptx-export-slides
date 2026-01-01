#!/usr/bin/env bash

set -euo pipefail

echo "Checking dependencies…"
echo

# ---- LibreOffice (GUI app, via cask) ----
if [[ -d "/Applications/LibreOffice.app" ]]; then
  echo "LibreOffice already installed."
else
  echo "LibreOffice not found. Installing…"
  brew install --cask libreoffice
fi

echo

# ---- poppler / pdftoppm (CLI tool) ----
if command -v pdftoppm >/dev/null 2>&1; then
  echo "pdftoppm already installed."
else
  echo "pdftoppm not found. Installing poppler…"
  brew install poppler
fi

echo
echo "Verifying installations…"
echo

# ---- Verification ----
if [[ ! -d "/Applications/LibreOffice.app" ]]; then
  echo "ERROR: LibreOffice installation failed."
  exit 1
fi

if ! command -v pdftoppm >/dev/null 2>&1; then
  echo "ERROR: pdftoppm installation failed."
  exit 1
fi

echo "All dependencies installed and verified successfully."
