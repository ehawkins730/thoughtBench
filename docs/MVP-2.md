# MVP-2 — Core LLM Workbench

This milestone transforms thoughtBench from a shell into a professional offline LLM environment.

---

## Goals
- Make the app fully usable without Terminal
- Ensure the app never “forgets” models or files
- Enable fast iteration on individual prompts
- Respect local-first privacy

---

## Core Features

### 1. LLM Engine Integration
- Local LLM server managed by the app
- No manual startup required
- Graceful handling of model load times
- Explicit error states (no infinite “thinking”)

---

### 2. Model Manager
- Persist model locations in SQLite
- Support:
  - Internal storage
  - External drives
  - Custom folders
- Detect existing models
- Online mode:
  - Show available models
  - Allow download/import
- Offline mode:
  - Only show local models
  - Never block UI

---

### 3. Chat Iteration UX
Each assistant response supports:
- **Edit prompt** (row-specific)
- **Try again**
- **Grade response**
  - Stored for user learning
  - Not global fine-tuning

---

### 4. Persistence
- Conversations never lost
- Messages immutable unless edited explicitly
- Model choice saved per conversation
- Storage location configurable

---

## Non-goals (for this MVP)
- Cloud sync
- Multi-user
- Embedding-based RAG
- Auto agents

---

## Definition of Done
- App can be opened offline
- A model can be selected and used
- Responses can be edited/retried
- All state persists across restarts