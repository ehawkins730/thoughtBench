# thoughtBench

A native, offline-first LLM workbench for macOS + iPadOS.

thoughtBench exists because **“it works in Terminal” isn’t good enough for real workflows**.

This project is built for developers and builders who need:
- local-first privacy
- fast iteration (edit, retry, compare)
- file-heavy workflows (PDFs, docs, spreadsheets, images)
- a clean, Apple-native UI that doesn’t feel like a science project

---

## Documentation
- **Roadmap:** `docs/ROADMAP.md`
- **MVP-2 Specification:** `docs/MVP-2.md`
- **Architecture:** `docs/ARCHITECTURE.md`
- **Changelog:** `docs/CHANGELOG.md`
- **Philosophy:** `PHILOSOPHY.md`

---

## Requirements
- macOS with Xcode
- SwiftUI
- SQLite (bundled in project)
- Local LLM models (internal or external drives supported)

---

## Run
1. Open the Xcode project
2. Build and run (macOS target first)

---

## Repository Structure
thoughtBench/
├── DB/            # SQLite schema, migrations, repositories
├── Services/      # File management, model management, LLM client
├── UI/            # SwiftUI views and layout
├── docs/          # Roadmap, architecture, MVP specs

---

## Roadmap (High-Level)
- **MVP-2:** Local LLM integration, model manager, edit/retry/grade UX
- **MVP-3:** File intelligence (PDF, DOCX, XLSX, images)
- **MVP-4:** Workspaces (Swift / Python / HTML) + export tools

For full detail, see `docs/ROADMAP.md`.

---

## License
Apache License 2.0  
See the `LICENSE` file for details.