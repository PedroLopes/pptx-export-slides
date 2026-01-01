# pptx-export-slides: a powerpoint slides export tool (to PDF or PNG)

A Bash script to convert PowerPoint (`.pptx`) presentations into:

-   A PDF of the entire presentation
-   Per-slide images (PNG or JPEG)
-   An optional ZIP archive of generated images

------------------------------------------------------------------------

## Installing

The script depends on: **LibreOffice** (for PPTX → PDF), **poppler** (`pdftoppm`, for PDF → images) (and optionally if you want a ``brew install``you ned **Homebrew** for macOS).

**Simplest: using ``brew``**

```bash
brew tap pedrolopes/tools
install pptx-export-slides
brew install --cask libreoffice
```
**Automatic: using ``install.sh``
```bash
git clione https://github.com/PedroLopes/pptx-export-slides
chmod+x install.sh
./install.sh
```An `install.sh` script to install missing dependencies automatically.

------------------------------------------------------------------------



------------------------------------------------------------------------

## Basic Usage

``` bash
./slides.sh --pptx FILE.pptx
```

This will generate:

-   `FILE.pdf`
-   `png-output/FILE-*.png`
-   `FILE.zip`

------------------------------------------------------------------------

## Command-Line Options

### Required

  Option          Description
  --------------- -----------------------
  `--pptx FILE`   Input PowerPoint file

------------------------------------------------------------------------

### General Options

  Option            Description
  ----------------- -----------------------------------------------------
  `--workdir DIR`   Working directory (default: current directory)
  `--outdir DIR`    Output directory for images (default: `png-output`)
  `--name NAME`     Base name for output files
  `--no-install`    Skip dependency installation
  `--help`, `-h`    Show help and exit

------------------------------------------------------------------------

### Output Control

  Option         Description
  -------------- ---------------------------
  `--pdf-only`   Generate only the PDF
  `--png-only`   Generate only images
  `--no-zip`     Do not create ZIP archive

------------------------------------------------------------------------

### Image Options

  Option                 Description
  ---------------------- ------------------------------------------
  `--dpi N`              Image resolution in DPI (default: 150)
  `--format png\|jpeg`   Image format (default: png)
  `--slides A-B`         Export only slides A through B (1-based)

------------------------------------------------------------------------

## Examples

### High-resolution PNGs (slides 2--6 only)

``` bash
./slides.sh --pptx talk.pptx --dpi 300 --slides 2-6
```

### JPEG images only, no ZIP

``` bash
./slides.sh --pptx talk.pptx --format jpeg --png-only --no-zip
```

### PDF only

``` bash
./slides.sh --pptx talk.pptx --pdf-only
```

------------------------------------------------------------------------

## Output Files

Depending on options used, the script may produce:

-   `NAME.pdf`
-   `OUTDIR/NAME-1.png`, `NAME-2.png`, ...
-   `NAME.zip`

------------------------------------------------------------------------

## Notes

-   Slide numbering matches that of PowerPoint.
-   PNG and JPEG generation is handled by `pdftoppm`.

------------------------------------------------------------------------

## License

GNU GPL.
