#!/bin/bash

# Usage:
# ./scripts/update-module-ref.sh v1.0.8

set -e

NEW_TAG="$1"

if [ -z "$NEW_TAG" ]; then
  echo "❗ Usage: $0 <new_tag> (example: v1.0.8)"
  exit 1
fi

echo "🔍 Searching and updating module refs to: $NEW_TAG"
echo ""

# Calculate project root based on script location
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../infra/aws" && pwd)"

cd "$PROJECT_ROOT"

# Find and replace in all .tf files under infra/aws
grep -rl 'ref=v' . --include="*.tf" | while read -r file; do
  echo "✏ Updating $file"
  sed -i "s|ref=v[0-9]*\\.[0-9]*\\.[0-9]*|ref=$NEW_TAG|g" "$file"
done

echo ""
echo "✅ Done. All module refs updated to $NEW_TAG."
