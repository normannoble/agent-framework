#!/bin/sh
# Release the `agents` plugin: bump version, validate, commit, push, update the local install.
#
#   ./release.sh            # bump patch  (1.1.0 -> 1.1.1)
#   ./release.sh minor      # bump minor  (1.1.0 -> 1.2.0)
#   ./release.sh major      # bump major  (1.1.0 -> 2.0.0)
#   ./release.sh 1.4.0      # set an exact version
#
# After it finishes, restart Claude Code to load the new version.
set -eu

cd "$(dirname "$0")"
MANIFEST=.claude-plugin/plugin.json
MARKETPLACE=normannoble
PLUGIN=agents

if [ -n "$(git status --porcelain)" ]; then
  echo "Working tree is not clean. Commit or stash first." >&2
  git status --short >&2
  exit 1
fi

current=$(python3 -c "import json;print(json.load(open('$MANIFEST'))['version'])")
bump="${1:-patch}"
case "$bump" in
  patch|minor|major)
    new=$(python3 - "$current" "$bump" <<'EOF'
import sys
major, minor, patch = (int(x) for x in sys.argv[1].split('.'))
kind = sys.argv[2]
if kind == 'major': major, minor, patch = major + 1, 0, 0
elif kind == 'minor': minor, patch = minor + 1, 0
else: patch += 1
print(f"{major}.{minor}.{patch}")
EOF
) ;;
  *) new="$bump" ;;
esac

echo "$current -> $new"
python3 - "$MANIFEST" "$new" <<'EOF'
import json, sys
path, version = sys.argv[1], sys.argv[2]
data = json.load(open(path))
data['version'] = version
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
EOF

claude plugin validate . >/dev/null
git add "$MANIFEST"
git commit -q -m "Release $PLUGIN v$new"
git push
echo "pushed v$new"

claude plugin marketplace update "$MARKETPLACE"
claude plugin update "$PLUGIN@$MARKETPLACE"
echo
echo "Installed $PLUGIN v$new. Restart Claude Code to load it."
