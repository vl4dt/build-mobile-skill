#!/bin/bash
# Version sync script for build-mobile skill
# Scans all reference files for @version-check markers and suggests updates.
# Run this periodically to ensure version pins in templates are current.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SKILL_DIR="$REPO_ROOT/build-mobile"

echo "=== Build-Mobile Version Sync ==="
echo "Scanning: $SKILL_DIR"
echo ""

# Find all .md files in the skill directory
REFERENCE_FILES=$(find "$SKILL_DIR" -name "REFERENCE-*.md" -o -name "SKILL.md" 2>/dev/null)

if [ -z "$REFERENCE_FILES" ]; then
    echo "ERROR: No reference files found in $SKILL_DIR"
    exit 1
fi

echo "Checking for @version-check markers..."
echo ""

# Track all findings
FINDINGS=0
WARNINGS=0

while IFS= read -r file; do
    echo "📄 $(basename "$file")"
    
    # Find lines with @version-check markers
    while IFS= read -r line_num; do
        FINDINGS=$((FINDINGS + 1))
        echo "  ⚠️  Line $line_num: @version-check marker found"
        # Extract the version info from the line
        line_content=$(sed -n "${line_num}p" "$file")
        echo "     $line_content"
        WARNINGS=$((WARNINGS + 1))
    done < <(grep -n "@version-check" "$file" 2>/dev/null || true)
    
    echo ""
done <<< "$REFERENCE_FILES"

echo "=== Summary ==="
echo "Total @version-check markers: $FINDINGS"
echo ""
echo "These are intentional markers提醒ing you to verify version pins."
echo "To check for updates:"
echo "  - Gradle/BOM: https://mvnrepository.com/artifact/androidx.compose/compose-bom"
echo "  - Flutter pub: flutter pub outdated"
echo "  - Swift/iOS: Xcode → Check for Updates"
echo "  - Kotlin: https://kotlinlang.org/docs/releases.html"
echo ""
echo "To update a version pin, edit the reference file and bump to the latest."
