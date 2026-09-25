#!/usr/bin/env sh
# Build the storefront/artisan web app and the admin dashboard, and copy them into services/webapp so the API
# serves them (/ and /admin/). Run after changing either app, then commit services/webapp.
# CanvasKit is left out: Flutter loads it from the gstatic CDN by default.
set -e
export MSYS_NO_PATHCONV=1  # Git Bash on Windows would rewrite /admin/ into a Windows path
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FLUTTER="${FLUTTER:-flutter}"
# --no-tree-shake-icons: Windows Smart App Control blocks Flutter's font-subset tool.
(cd "$ROOT/apps/mobile" && "$FLUTTER" build web --release --no-tree-shake-icons)
(cd "$ROOT/apps/admin_web" && "$FLUTTER" build web --release --no-tree-shake-icons --base-href /admin/ -o build/web_admin)

rm -rf "$ROOT/services/webapp"
mkdir -p "$ROOT/services/webapp"
cp -r "$ROOT/apps/mobile/build/web" "$ROOT/services/webapp/store"
cp -r "$ROOT/apps/admin_web/build/web_admin" "$ROOT/services/webapp/admin"
rm -rf "$ROOT/services/webapp/store/canvaskit" "$ROOT/services/webapp/admin/canvaskit"
du -sh "$ROOT/services/webapp"/*
