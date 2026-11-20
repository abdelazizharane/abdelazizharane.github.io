#!/bin/bash
set -e
MSG="${1:-feat: update}"
git add .
git commit -m "$MSG"
git push origin main
echo "Live in ~3 min"