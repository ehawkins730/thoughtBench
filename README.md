# thoughtBench

A native, offline-first LLM workbench for macOS + iPadOS.

thoughtBench exists because “it works in Terminal” isn’t good enough for real workflows. This project focuses on:
- local-first privacy
- fast iteration (edit, retry, compare)
- file-heavy work (PDFs, docs, spreadsheets, images)
- a clean, Apple-native UI that doesn’t feel like a science project

## MVP-1 (current)
- SQLite-backed persistence (conversations, messages, attachments metadata)
- File import surface (foundation)
- Chat UI foundation + console view scaffolding

## MVP-2 (next)
- LLM engine integration (local server + model selection + persistence)
- Save model locations (multiple roots, external drives supported)
- Row-specific “Edit prompt”, “Try again”, and response grading

## Requirements
- Xcode (macOS)
- SwiftUI + SQLite (bundled via project code)
- Local models can live anywhere (internal or external drive)

## Run
1. Open the Xcode project
2. Build + Run (macOS target first)

## Repo Structure
- `thoughtBench/` — app source
  - `DB/` — SQLite + repos
  - `Services/` — file storage, (MVP-2: LLM client)
  - `UI/` — views

## Roadmap (short)
- MVP-2: local LLM + model manager + “edit/retry/grade”
- MVP-3: file parsers (PDF, docx, xlsx) + retrieval
- MVP-4: “workspaces” (Swift/Python/HTML consoles) + export

## License
Apache License 2.0. See the `LICENSE` file for details.
