#!/usr/bin/env bash

set -euo pipefail

# -----------------------------
# Defaults
# -----------------------------
WORKDIR="$(pwd)"
INPUT_PPTX=""
OUTPUT_DIR="png-output"
BASENAME=""
ZIP_OUTPUT=true
INSTALL_DEPS=true

DPI=150
FORMAT="png"
SLIDES=""
DO_PDF=true
DO_PNG=true

# -----------------------------
# Help
# -----------------------------
show_help() {
  cat <<EOF
Usage: $(basename "$0") --pptx FILE [options]

This program renders your powerpoint (.pptx) slides as a PDF and/or a folder with PNG images (also a .zip).

Required:
  --pptx FILE            Input .pptx file

Options:
  --workdir DIR          Working directory (default: current directory)
  --outdir DIR           Image output directory (default: png-output)
  --name NAME            Base name for outputs (default: derived from pptx)

  --dpi N                DPI for image generation (default: 150)
  --format png|jpeg      Image format (default: png)
  --slides 1-5           Export only slides 1 through 5

  --pdf-only             Only generate PDF
  --png-only             Only generate images (still generates PDF but deletes it)
  --no-zip               Do not generate zip file
  --no-install           Skip dependency check and installation
  --help, -h             Show this help and exit

Outputs:
  NAME.pdf
  DIR/NAME-*.{png|jpg}
  NAME.zip (optional)
EOF
}

# Unfortunately, kink of current homebrew laws prevent installing the libreoffice from a cask in a formula
# Check for LibreOffice
if [[ ! -d "/Applications/LibreOffice.app" ]]; then
  echo "ERROR: LibreOffice is required."
  echo "Install it manually via Homebrew:"
  echo "  brew install --cask libreoffice"
  exit 1
fi

# Check for pdftoppm
if ! command -v pdftoppm >/dev/null 2>&1; then
  echo "ERROR: poppler (pdftoppm) is required. Install via Homebrew:"
  echo "  brew install poppler"
  exit 1
fi

# -----------------------------
# Argument parsing
# -----------------------------
if [[ $# -eq 0 ]]; then
  show_help
  exit 0
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pptx)
      INPUT_PPTX="$2"
      shift 2
      ;;
    --workdir)
      WORKDIR="$2"
      shift 2
      ;;
    --outdir)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --name)
      BASENAME="$2"
      shift 2
      ;;
    --dpi)
      DPI="$2"
      shift 2
      ;;
    --format)
      FORMAT="$2"
      shift 2
      ;;
    --slides)
      SLIDES="$2"
      shift 2
      ;;
    --pdf-only)
      DO_PNG=false
      shift
      ;;
    --png-only)
      DO_PDF=false
      shift
      ;;
    --no-zip)
      ZIP_OUTPUT=false
      shift
      ;;
    --no-install)
      INSTALL_DEPS=false
      shift
      ;;
    --help|-h)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo
      show_help
      exit 1
      ;;
  esac
done

# -----------------------------
# Validation
# -----------------------------
if [[ -z "$INPUT_PPTX" ]]; then
  echo "ERROR: --pptx is required."
  exit 1
fi

if [[ ! -f "$INPUT_PPTX" ]]; then
  echo "ERROR: PPTX file not found: $INPUT_PPTX"
  exit 1
fi

if [[ "$FORMAT" != "png" && "$FORMAT" != "jpeg" ]]; then
  echo "ERROR: --format must be png or jpeg."
  exit 1
fi

cd "$WORKDIR"

if [[ -z "$BASENAME" ]]; then
  BASENAME="$(basename "$INPUT_PPTX" .pptx)"
fi

PDF_FILE="${BASENAME}.pdf"
ZIP_FILE="${BASENAME}.zip"

# -----------------------------
# Dependencies
# -----------------------------
if $INSTALL_DEPS; then
  ./install.sh
fi

# -----------------------------
# Prepare output
# -----------------------------
mkdir -p "$OUTPUT_DIR"
rm -f "$OUTPUT_DIR"/*

# -----------------------------
# PPTX → PDF
# -----------------------------
if $DO_PDF || $DO_PNG; then
  /Applications/LibreOffice.app/Contents/MacOS/soffice \
    --headless \
    --invisible \
    --convert-to pdf \
    "$INPUT_PPTX"

  if [[ -n "$BASENAME" ]]; then
    SOURCENAME="$(basename "$INPUT_PPTX" .pptx)"
    echo "$SOURCENAME"
    mv $SOURCENAME.pdf $PDF_FILE #if we need a --name then rename it to apply it
  fi
  # else name is already in base mode

  echo "Generated PDF: $PDF_FILE"
fi

# -----------------------------
# PDF → Images
# -----------------------------
if $DO_PNG; then
  PPM_FORMAT_FLAG="-${FORMAT}"
  DPI_FLAG="-r $DPI"

  PAGE_FLAG=""
  if [[ -n "$SLIDES" ]]; then
    START="${SLIDES%-*}"
    END="${SLIDES#*-}"
    PAGE_FLAG="-f $START -l $END"
  fi

  pdftoppm \
    $DPI_FLAG \
    $PPM_FORMAT_FLAG \
    $PAGE_FLAG \
    "$PDF_FILE" \
    "$OUTPUT_DIR/$BASENAME"

  echo "Generated images in $OUTPUT_DIR ($FORMAT, ${DPI}dpi)"
fi

# -----------------------------
# ZIP (optional)
# -----------------------------
if $DO_PNG && $ZIP_OUTPUT; then
  rm -f "$ZIP_FILE"
  zip -j "$ZIP_FILE" "$OUTPUT_DIR"/*
  echo "Created zip archive: $ZIP_FILE"
fi

echo
echo "All done successfully."

