#!/usr/bin/env bash
# Build report/report.pdf. Prefer pandoc (Markdown -> XeLaTeX), then fall back
# to an existing report.tex.
set -euo pipefail
cd "$(dirname "$0")/.."

PANDOC="${PANDOC:-pandoc}"
if ! command -v "$PANDOC" >/dev/null 2>&1 && [[ -x /tmp/pandoc-3.13/bin/pandoc ]]; then
  PANDOC=/tmp/pandoc-3.13/bin/pandoc
fi

if [[ -f report/report.md ]] && command -v "$PANDOC" >/dev/null 2>&1 && command -v xelatex >/dev/null 2>&1; then
  "$PANDOC" report/report.md \
    -o report/report.pdf \
    --pdf-engine=xelatex \
    -V geometry:margin=1.8cm \
    -V fontsize=10pt \
    -V mainfont="Noto Serif" \
    -V sansfont="Noto Sans" \
    -V colorlinks=true \
    -V linkcolor=blue \
    --highlight-style=tango
  "$PANDOC" report/report.md -s -t latex -o report/report.tex
  echo "wrote report/report.pdf and report/report.tex"
  exit 0
fi

if [[ -f report/report.tex ]] && command -v xelatex >/dev/null 2>&1; then
  (
    cd report
    xelatex -interaction=nonstopmode -halt-on-error report.tex >/tmp/report-xelatex-1.log
    xelatex -interaction=nonstopmode -halt-on-error report.tex >/tmp/report-xelatex-2.log
  )
  echo "wrote report/report.pdf"
  exit 0
fi

echo "Install pandoc+xelatex (recommended) or xelatex; report/report.md is the source." >&2
exit 1
