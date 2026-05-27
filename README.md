# Build Mobile Skill for AI Coding Agents

> A portable, open-standard Agent Skill for Android, Flutter, KMP, and SwiftUI development.

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-blue.svg)](LICENSE)
[![Agent Skills](https://custom-icon-badges.demolab.com/badge/Agent%20Skills-9cf?logo=star&logoColor=fff)](https://agentskills.io)
[![gh skill](https://img.shields.io/badge/gh--skill-supported-444?label=compatible)](https://cli.github.com/manual/gh_skill)

## Overview

This skill gives AI coding agents deep expertise in **Android, Flutter, Kotlin Multiplatform (KMP), and SwiftUI** development. It encodes SDK-first workflows, cross-platform compatibility matrices, and iOS/macOS build guidance for remote Mac setups — so the agent scaffolds, builds, tests, and debugs mobile apps using proper SDK commands instead of manual file manipulation.

## What's Included

| File | Purpose |
|------|---------|
| `SKILL.md` | Main instructions — environment, golden rules, workflows |
| `REFERENCE-GRADLE.md` | Gradle templates, KMP structure, Compose testing |
| `REFERENCE-FLUTTER.md` | Pubspec essentials, state management, folder structure |
| `REFERENCE-COMPOSE.md` | Compose testing patterns |
| `REFERENCE-SWIFTUI.md` | SwiftUI fundamentals, Xcode CLI, remote Mac setup |
| `scripts/android-env.sh` | Environment audit script — refreshes cached SDK state |

## Quick Install

### Via GitHub CLI (recommended — works across agents)

```bash
# Install from this repository
gh skill install vl4dt/android-dev-skill build-mobile

# Or pin to a specific release
gh skill install vl4dt/android-dev-skill build-mobile --pin v2.0.0
```

### Via Pi (pi-mono)

```bash
# Install directly from GitHub
pi install git+https://github.com/vl4dt/android-dev-skill.git#build-mobile
```

### Manual

```bash
# Clone and symlink
git clone https://github.com/vl4dt/android-dev-skill.git
ln -s $(pwd)/android-dev-skill/build-mobile ~/.pi/agent/skills/build-mobile
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

- **SDK-first workflows** — always prefer `flutter pub add`, `sdkmanager`, `avdmanager`, `gradlew`
- **Compatibility matrices** — AGP ↔ Kotlin ↔ Gradle ↔ JDK ↔ Compose ↔ Flutter version guards
- **KMP project scaffolding** — shared module + Android app module patterns
- **SwiftUI fundamentals** — views, state management, MVVM, navigation, concurrency
- **Remote Mac build guidance** — SSH-based iOS/macOS builds (user-configured)
- **Environment audit script** — `scripts/android-env.sh` to refresh cached state
- **Split reference files** — GRADLE, FLUTTER, COMPOSE, SWIFTUI for easy navigation

## Directory Structure

```
build-mobile/
├── SKILL.md                    # Main instructions (required, <100 lines)
├── REFERENCE-GRADLE.md         # Gradle templates, KMP, Compose testing
├── REFERENCE-FLUTTER.md        # Pubspec, state management, patterns
├── REFERENCE-COMPOSE.md        # Compose testing patterns
├── REFERENCE-SWIFTUI.md        # SwiftUI, Xcode CLI, remote Mac
└── scripts/
    └── android-env.sh          # Environment audit script
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
