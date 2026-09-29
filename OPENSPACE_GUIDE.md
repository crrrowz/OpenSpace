# OpenSpace Complete Architecture, MCP & Operational Guide

Comprehensive reference manual for operating, maintaining, integrating, and evolving OpenSpace via Docker, FastMCP (SSE), and Local LLMs.

---

## 1. System Architecture & Overview

OpenSpace is an autonomous agent skill layer designed to:
- **Retrieve:** Dynamically discover and rank local and cloud skills for incoming tasks.
- **Evaluate:** Benchmark and score skill performance based on real execution telemetry.
- **Evolve:** Continuously self-improve by capturing working patterns (`CAPTURED`), deriving enhancements (`DERIVED`), and repairing broken workflows (`FIX`).
- **Share:** Distribute modular skills across autonomous agents and cloud registries.

```
┌────────────────────────────────────────────────────────┐
│                   AI Agent / Client                    │
│      (Kilo CLI / Claude Desktop / Cursor / Antigravity)│
└───────────────────────────┬────────────────────────────┘
                            │ SSE Protocol (HTTP)
                            ▼
┌────────────────────────────────────────────────────────┐
│             Docker: openspace-mcp                      │
│  ├─ FastMCP SSE Server  ──> :28580 (Host Port)         │
│  └─ Dashboard Web GUI   ──> :28588 (Host Port)         │
│  ┌──────────────────────────────────────────────────┐  │
│  │               Supervisor Multi-Process           │  │
│  └───────────┬──────────────────────────┬───────────┘  │
│              │                          │              │
│              ▼                          ▼              │
│  ┌───────────────────────┐  ┌───────────────────────┐  │
│  │   Skill Engine        │  │ Execution Runtime     │  │
│  │ (Retrieve/Evolve/Fix) │  │ (Grounding Engine)    │  │
│  └───────────┬───────────┘  └───────────┬───────────┘  │
└──────────────┼──────────────────────────┼──────────────┘
               │                          │
               ▼                          ▼
┌───────────────────────────┐  ┌─────────────────────────┐
│     Local LLM Proxy       │  │ Persistent Volumes      │
│  http://192.168.85.129    │  │ - openspace_skills      │
│          :20128/v1        │  │ - openspace_workspace   │
│ (gemini-3.7-flash-tiered) │  │ - openspace_data        │
└───────────────────────────┘  └─────────────────────────┘
```

---

## 2. Infrastructure & Dedicated Endpoints

- **FastMCP SSE Endpoint:** `http://192.168.85.129:28580/sse`
- **Dashboard Web GUI:** `http://192.168.85.129:28588/`
- **Dashboard Health API:** `http://192.168.85.129:28588/api/v1/health`
- **LLM Base URL:** `http://192.168.85.129:20128/v1`
- **Active Model:** `openai/antigravity/gemini-3.7-flash-tiered`
- **Project Directory:** `D:\files\Contracted projects\IdeaProjects\OpenSpace`

---

## 3. Operations & Daily Maintenance

Run all commands from PowerShell in the project root:

```powershell
# Check container status
docker compose ps

# Follow real-time logs
docker compose logs -f

# Restart the service
docker compose restart

# Stop the container
docker compose down

# Start the container in detached mode
docker compose up -d

# Update to latest codebase & rebuild container
git pull; docker compose up -d --build
```

---

## 4. MCP Tools Reference

OpenSpace exposes the following high-level tools via FastMCP:

| Tool | Purpose & Usage |
| :--- | :--- |
| `openspace_search_skills` | Search local skill registry using hybrid ranking (BM25 + semantic). |
| `openspace_cloud_browse_skills` | Stepwise interactive browser for searching and importing cloud skills. |
| `openspace_execute_task` | Grounded execution engine. Auto-registers local skills, attempts execution, and triggers auto-evolution (`FIX`, `DERIVED`, `CAPTURED`). |
| `openspace_fix_skill` | Triggers a dedicated `FIX` evolution job for repairing broken or failing skills. |
| `openspace_upload_skill` | Uploads validated and trusted local skills to the cloud package registry. |
| `openspace_cloud_auth_flow` | Handles user authentication and cloud API key lifecycle management. |

---

## 5. Skill Evolution Lifecycle

```
               ┌────────────────────────┐
               │    Execute Task /      │
               │   Autonomous Run       │
               └───────────┬────────────┘
                           │
           ┌───────────────┴───────────────┐
           ▼                               ▼
    [No Existing Skill]            [Existing Skill]
           │                               │
           ▼                               ▼
     Task Success?                   Execution Status?
     ┌─────┴─────┐                     ┌─────┴─────┐
     │           │                     │           │
    YES          NO                 SUCCESS     FAILURE
     │           │                     │           │
     ▼           ▼                     ▼           ▼
 ┌─────────┐  [Discard]          ┌──────────┐ ┌─────────┐
 │CAPTURED │                     │ DERIVED  │ │   FIX   │
 │ (New)   │                     │ (Expand) │ │(Repair) │
 └─────────┘                     └──────────┘ └─────────┘
```

1. **`CAPTURED`**: New successful execution traces with no prior skill coverage are consolidated and saved as standalone reusable skills.
2. **`DERIVED`**: Existing skills that succeed in novel or expanded scenarios are specialized into derived versions.
3. **`FIX`**: Skills that fail or produce execution errors are fed into the auto-fix engine with contextual error diffs.

---

## 6. Client Configuration Examples

### A. Kilo Configuration (`kilo.jsonc`)
```jsonc
{
  "mcp": {
    "openspace": {
      "type": "remote",
      "url": "http://192.168.85.129:28580/sse",
      "enabled": true,
      "timeout": 600000
    }
  }
}
```

### B. Claude Desktop / Gemini CLI (`mcp_config.json`)
```json
{
  "mcpServers": {
    "openspace": {
      "url": "http://192.168.85.129:28580/sse",
      "toolTimeout": 600
    }
  }
}
```

---

## 7. Storage & Persistent Volumes

| Volume Name | Container Path | Description |
| :--- | :--- | :--- |
| `openspace_skills` | `/app/skills` | Storage for all installed and generated skill definition files (`SKILL.md`). |
| `openspace_workspace` | `/app/workspace` | Isolated execution workspace for task grounding and tool runs. |
| `openspace_data` | `/app/.openspace` | SQLite databases, telemetry records, and skill evaluation weights. |
| `openspace_logs` | `/app/logs` | Structured application and execution log files. |

---

## 8. Automated Update Script (Windows PowerShell)

Save this as `update-openspace.ps1` to automate updates via Windows Task Scheduler or manual runs:

```powershell
# update-openspace.ps1
Set-Location -LiteralPath "D:\files\Contracted projects\IdeaProjects\OpenSpace"

Write-Host "[1/3] Pulling latest changes from Git..." -ForegroundColor Cyan
git pull origin main

Write-Host "[2/3] Rebuilding and recreating Docker containers..." -ForegroundColor Cyan
docker compose up -d --build

Write-Host "[3/3] Checking container health..." -ForegroundColor Cyan
docker compose ps
```
