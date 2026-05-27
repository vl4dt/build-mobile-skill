# Contributing to Android Dev Skill

Thank you for your interest in contributing! This guide covers how to modify, test, and submit changes.

## Directory Structure

```
android-dev-skill/
├── README.md
├── LICENSE
├── CONTRIBUTING.md
└── android-dev/              # The actual skill directory
    ├── SKILL.md
    ├── REFERENCE.md
    └── scripts/
        └── android-env.sh
```

## Making Changes

1. **Edit the skill files** in `android-dev/`
2. **Test locally** by pointing pi to your local copy:
   ```bash
   # Option 1: Symlink
   ln -sf $(pwd)/android-dev-skill/android-dev ~/.pi/agent/skills/android-dev

   # Option 2: Copy
   cp -r android-dev ~/.pi/agent/skills/android-dev
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
2. Update the Environment table in `SKILL.md`
3. Update version pins and compatibility matrices in both `SKILL.md` and `REFERENCE.md`
4. Commit with a version bump

## Publishing a New Release

```bash
# 1. Commit changes
git add android-dev/
git commit -m "chore: update Android SDK versions to 36/37"

# 2. Tag and push
git tag -a v1.1.0 -m "Release v1.1.0 - updated SDK versions"
git push && git push --tags

# 3. Publish to gh skill registry
gh skill publish
```

## PR Guidelines

- Keep `SKILL.md` under 100 lines (split to `REFERENCE.md` if needed)
- Keep the `description` field under 1024 chars
- Include concrete examples in every workflow section
- No time-sensitive info (SDK versions should reference "check latest" commands)
