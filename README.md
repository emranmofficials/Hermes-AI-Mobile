# 📱 Hermes AI Mobile (100% Official Webapp Clone)

> A production-grade Flutter mobile application delivering a **100% true clone of the official Nous Research Hermes Agent Webapp & Dashboard (`NousResearch/hermes-agent`)**.

---

## 🌟 100% Feature Parity Specification

| Hermes Webapp Route | Mobile Flutter Implementation | Key Capabilities |
| :--- | :--- | :--- |
| **`/` & `/sessions`** | [`lib/views/chat/chat_screen.dart`](lib/views/chat/chat_screen.dart) | Real-time token streaming, multi-turn conversation, code syntax highlighting, copy actions, message branching. |
| **Tool Execution** | [`lib/views/chat/widgets/tool_call_card.dart`](lib/views/chat/widgets/tool_call_card.dart) | Live visual cards for `bash`, `web_search`, `read_file`, `write_file` with status badges and expandable JSON argument & stdout inspection. |
| **`/kanban`** | [`lib/views/kanban/kanban_screen.dart`](lib/views/kanban/kanban_screen.dart) | Autonomous task planning board with **To-Do, In Progress, Review, and Done** stages, priority badges, and subagent assignments. |
| **`/api/files`** | [`lib/views/files/files_screen.dart`](lib/views/files/files_screen.dart) | Interactive workspace file explorer, tree view, file creation, deletion, and in-app syntax-highlighted code editor. |
| **`/skills`** | [`lib/views/skills/skills_screen.dart`](lib/views/skills/skills_screen.dart) | Complete **`SKILL.md`** learning hub with search, toggle, execution rules, and custom skill authoring dialog. |
| **`/memory`** | [`lib/views/memory/memory_screen.dart`](lib/views/memory/memory_screen.dart) | Long-term memory dashboard managing **`USER.md`** (user profile/preferences) and **`MEMORY.md`** (project rules). |
| **`/config` & `/status`** | [`lib/views/settings/settings_screen.dart`](lib/views/settings/settings_screen.dart) | Real-time telemetry (`/api/system/stats`: CPU %, RAM MB, active subagents, gateway status), model switching, temperature, and API keys. |
| **`/api/ws` Protocol** | [`lib/services/hermes_service.dart`](lib/services/hermes_service.dart) | Official **JSON-RPC 2.0 over WebSocket** protocol support + fallback Direct Cloud API mode (OpenRouter, Nous Portal, Ollama). |

---

## 📂 Architecture Overview

```
hermes_mobile/
├── lib/
│   ├── main.dart                      # Flutter app bootstrap
│   ├── app.dart                       # 5-Tab Navigation & Global State
│   ├── core/
│   │   ├── theme/hermes_theme.dart    # Deep Obsidian Black & Electric Cyan
│   │   └── storage/local_storage.dart # Offline cache for sessions, files, tasks
│   ├── models/
│   │   ├── app_settings.dart          # Config & Provider settings
│   │   ├── kanban_task.dart           # Autonomous task model (/kanban)
│   │   ├── workspace_file.dart        # File tree node (/api/files)
│   │   ├── system_stats.dart          # Live telemetry (/api/system/stats)
│   │   ├── message.dart               # Chat message & stream state
│   │   ├── tool_call.dart             # Agentic tool call model
│   │   ├── session.dart               # Conversation thread model
│   │   ├── skill.dart                 # SKILL.md definition
│   │   └── memory_item.dart           # MEMORY.md record
│   ├── services/
│   │   └── hermes_service.dart        # JSON-RPC 2.0 WebSocket & SSE engine
│   └── views/
│       ├── chat/                      # Agent Chat & Streaming
│       ├── kanban/                    # Kanban Task Board (/kanban)
│       ├── files/                     # Workspace File Explorer (/api/files)
│       ├── skills/                    # Skills Hub (/skills)
│       ├── memory/                    # Memory Hub (/memory)
│       ├── settings/                  # Config & Telemetry (/config)
│       └── sessions/                  # Chat History Drawer
```
