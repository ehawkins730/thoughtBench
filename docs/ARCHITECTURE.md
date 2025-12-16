# thoughtBench Architecture

thoughtBench is built as a layered, modular, Apple-native system.

---

## High-Level Overview

UI (SwiftUI)
↓
Application Services
↓
Persistence + Model Layer
↓
Local Filesystem + LLM Runtime

---

## Core Components

### 1. UI Layer (SwiftUI)
- Chat views
- Message rows
- Attachment previews
- Console panes
- Workspace containers

Design goals:
- Calm
- Dense but readable
- Zero modal spam

---

### 2. Services Layer

#### ChatService
- Message lifecycle
- Retry/edit flows
- Context assembly

#### ModelService
- Track model roots
- Resolve models
- Launch local runtime
- Health checks

#### FileService
- File import
- Metadata extraction
- Secure bookmarks
- External drive support

---

### 3. Persistence Layer (SQLite)

Tables:
- conversations
- messages
- attachments
- models
- model_roots
- response_grades

Goals:
- Predictable performance
- Explicit schema
- Easy export/debug

---

### 4. LLM Runtime
- Local execution
- Managed lifecycle
- No hidden background processes
- App-controlled startup/shutdown

---

## Why SQLite (not SwiftData)
- Deterministic behavior
- Easy migrations
- External tooling support
- Long-term stability

---

## Storage Strategy
- Default: Application Support
- User-selectable root
- External drives fully supported
- Never hardcoded paths