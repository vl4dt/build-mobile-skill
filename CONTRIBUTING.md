# Contributing to Build Mobile Skill

Thank you for your interest in contributing! This guide covers how to modify, test, and submit changes.

## Directory Structure

```
android-dev-skill/
├── README.md
├── LICENSE
├── CONTRIBUTING.md
└── build-mobile/              # The actual skill directory
    ├── SKILL.md
    ├── REFERENCE-GRADLE.md
    ├── REFERENCE-FLUTTER.md
    ├── REFERENCE-COMPOSE.md
    ├── REFERENCE-SWIFTUI.md
    └── scripts/
        └── android-env.sh
```

## Making Changes

1. **Edit the skill files** in `build-mobile/`
2. **Test locally** by pointing pi to your local copy:
   ```bash
   # Option 1: Symlink
   ln -sf $(pwd)/android-dev-skill/build-mobile ~/.pi/agent/skills/build-mobile

   # Option 2: Copy
   cp -r build-mobile ~/.pi/agent/skills/build-mobile
   ```
3. **Validate the skill** against the Agent Skills spec:
   ```bash
   gh skill publish   # validates frontmatter, structure, references
   ```

## Updating Environment Data

When SDK/Flutter/Kotlin versions change:

1. Run the environment audit script on your machine:
   ```bash
   bash scripts/android-env.sh
   ```
2. Update the Environment table in `SKILL.md` (replace placeholders)
3. Update version pins and compatibility matrices in both `SKILL.md` and references
4. Commit with a version bump

## Publishing a New Release

```bash
# 1. Commit changes
git add build-mobile/
git commit -m "chore: update Android SDK versions to 36/37"

# 2. Tag and push
git tag -a v2.0.0 -m "Release v2.0.0 - expanded SwiftUI support, split references"
git push && git push --tags

# 3. Publish to gh skill registry
gh skill publish
```

## PR Guidelines

- Keep `SKILL.md` under 100 lines (split to reference files if needed)
- Keep the `description` field under 1024 chars
- Include concrete examples in every workflow section
- No time-sensitive info (SDK versions should reference "check latest" commands)
- New reference files should be under 300 lines each (ideally)
- Remove all hardcoded credentials (IPs, passwords, usernames) before publishing
