# Android Dev Skill for AI Coding Agents

> A portable, open-standard Agent Skill for Android, Flutter, and Kotlin Multiplatform development.

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-blue.svg)](LICENSE)
[![Agent Skills](https://custom-icon-badges.demolab.com/badge/Agent%20Skills-9cf?logo=star&logoColor=fff)](https://agentskills.io)
[![gh skill](https://img.shields.io/badge/gh--skill-supported-444?label=compatible)](https://cli.github.com/manual/gh_skill)

## Overview

This skill gives AI coding agents deep expertise in Android, Flutter, and Kotlin Multiplatform (KMP) development. It encodes project-specific environment details, SDK tooling workflows, compatibility matrices, and remote build infrastructure — so the agent scaffolds, builds, tests, and debugs mobile apps using proper SDK commands instead of manual file manipulation.

## What's Included

| File | Purpose |
|------|---------|
| `SKILL.md` | Main instructions — environment, golden rules, workflows, quick commands |
| `REFERENCE.md` | Detailed templates, Gradle configs, Compose/KMP patterns |
| `scripts/android-env.sh` | Environment audit script — refreshes cached SDK state |

## Quick Install

### Via GitHub CLI (recommended — works across agents)

```bash
# Install from this repository
gh skill install YOUR-USERNAME/android-dev-skill android-dev

# Or pin to a specific release
gh skill install YOUR-USERNAME/android-dev-skill android-dev --pin v1.0.0
```

### Via Pi (pi-mono)

```bash
# Install directly from GitHub
pi install git+https://github.com/YOUR-USERNAME/android-dev-skill.git#android-dev
```

### Manual

```bash
# Clone and symlink
git clone https://github.com/YOUR-USERNAME/android-dev-skill.git
ln -s $(pwd)/android-dev-skill/android-dev ~/.pi/agent/skills/android-dev
```

## Compatible Agent Hosts

This skill follows the [Agent Skills specification](https://agentskills.io) and is compatible with:

- **Pi (pi-mono)** — primary development target
- **GitHub Copilot CLI** — via `gh skill install`
- **Claude Code** — via `gh skill install --agent claude-code`
- **Cursor** — via `gh skill install --agent cursor`
- **Codex** — via `gh skill install --agent codex`
- **Gemini CLI** — via `gh skill install --agent gemini`

See the full [client showcase](https://agentskills.io/clients) for more.

## Key Features

- **Pre-cached environment** — SDK paths, JDK version, Flutter/Dart/Kotlin versions
- **SDK-first workflows** — always prefer `flutter pub add`, `sdkmanager`, `avdmanager`, `gradlew`
- **Compatibility matrices** — AGP ↔ Kotlin ↔ Gradle ↔ JDK version guards
- **Remote Mac integration** — iOS/macOS builds over SSH to a remote MacBook Pro
- **KMP project scaffolding** — shared module + Android app module patterns
- **Environment audit script** — `scripts/android-env.sh` to refresh cached state

## Development

To modify this skill, edit the files in `android-dev/`. The skill directory is self-contained and follows the Agent Skills spec:

```
android-dev/
├── SKILL.md           # Main instructions (required)
├── REFERENCE.md       # Detailed docs (split for >100 lines)
└── scripts/
    └── android-env.sh # Environment audit script
```

## Publishing

This repo is structured for `gh skill publish`:

```bash
gh login
gh skill publish
```

The publish command validates against the [agentskills.io spec](https://agentskills.io/specification) and creates a git tag + release for versioning.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

This project is licensed under the [Apache License 2.0](LICENSE).

---

Built with ❤️ for the AI coding agent community.
