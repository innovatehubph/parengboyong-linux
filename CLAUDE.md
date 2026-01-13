# CLAUDE.md - AI Assistant Guide for Pareng Boyong

> **Project:** Pareng Boyong (InnovateHub AI)
> **Based on:** Agent Zero Framework
> **Last Updated:** 2026-01-13

---

## Quick Reference

| Item | Value |
|------|-------|
| **Primary Language** | Python 3.12+ |
| **Framework** | Agent Zero (AI Agent Framework) |
| **Web Server** | Flask (async) |
| **Frontend** | Vanilla HTML/CSS/JS |
| **Deployment** | Docker + Nginx |
| **Production URL** | https://ai.innovatehub.site |
| **Repository** | https://github.com/innovatehubph/parengboyong-linux |

---

## Project Overview

**Pareng Boyong** is InnovateHub's AI personal assistant, a rebranded and customized deployment of the Agent Zero open-source AI agent framework. It features:

- **Filipino Branding**: "Pareng Boyong" as main agent, "Boss Marc" as user label
- **Multi-agent Architecture**: Hierarchical agent delegation with Filipino subordinate names
- **Tool-based Actions**: 22+ native tools for various operations
- **Memory System**: Persistent memory with fragments and solutions
- **Web UI**: Modern chat interface with authentication
- **Docker Deployment**: Production-ready containerized deployment

---

## Directory Structure

```
parengboyong-linux/
├── agent.py                 # Core Agent class implementation (main entry point)
├── initialize.py            # Framework initialization
├── models.py                # Model providers configuration (OpenAI, Anthropic, etc.)
├── preload.py               # Pre-initialization routines
├── prepare.py               # Environment preparation
├── run_ui.py                # Web UI launcher (Flask server)
├── run_tunnel.py            # Tunnel service launcher
│
├── python/                  # Core Python codebase
│   ├── api/                 # API endpoints (50+ endpoints)
│   │   ├── message.py       # Main message handling
│   │   ├── chat_*.py        # Chat management endpoints
│   │   ├── backup_*.py      # Backup system endpoints
│   │   ├── scheduler_*.py   # Task scheduler endpoints
│   │   ├── settings_*.py    # Settings management
│   │   └── ...              # Other API endpoints
│   │
│   ├── extensions/          # Modular extension system (23 extension hooks)
│   │   ├── agent_init/      # Agent initialization hooks
│   │   ├── system_prompt/   # System prompt construction
│   │   ├── message_loop_*/  # Message loop lifecycle hooks
│   │   ├── monologue_*/     # Monologue lifecycle hooks
│   │   ├── tool_execute_*/  # Tool execution hooks
│   │   ├── response_stream*/# Response streaming hooks
│   │   └── ...              # Other extension points
│   │
│   ├── tools/               # Tool implementations (18 default tools)
│   │   ├── response.py      # Final response to user
│   │   ├── code_execution_tool.py  # Code execution (Python/Node/Terminal)
│   │   ├── memory_*.py      # Memory operations (save/load/delete/forget)
│   │   ├── browser_agent.py # Browser automation
│   │   ├── scheduler.py     # Task scheduling
│   │   ├── call_subordinate.py  # Agent delegation
│   │   └── ...              # Other tools
│   │
│   └── helpers/             # Utility modules
│       ├── tool.py          # Base Tool class
│       ├── extension.py     # Extension base class
│       ├── files.py         # File operations
│       ├── memory.py        # Memory management
│       ├── log.py           # Logging system
│       └── ...              # Other helpers
│
├── prompts/                 # System prompts and tool definitions
│   ├── agent.system.main.md # Main system prompt hub
│   ├── agent.system.main.role.md     # Agent role definition
│   ├── agent.system.main.solving.md  # Problem-solving approach
│   ├── agent.system.tool.*.md        # Tool prompt definitions
│   └── ...                  # Other prompt files
│
├── agents/                  # Agent profiles
│   ├── default/             # Default agent configuration
│   ├── developer/           # Developer-focused agent
│   ├── researcher/          # Research-focused agent
│   ├── hacker/              # Security-focused agent
│   └── _example/            # Example profile template
│
├── instruments/             # Custom scripts and tools
│   ├── default/             # Default instruments
│   └── custom/              # Custom user instruments
│
├── knowledge/               # Knowledge base storage
│   └── default/main/        # Default knowledge files
│
├── memory/                  # Persistent agent memory
├── logs/                    # HTML chat logs
├── backups/                 # Backup storage
│
├── webui/                   # Web interface
│   ├── index.html           # Main UI
│   ├── login.html           # Login page
│   ├── components/          # UI components
│   ├── js/                  # JavaScript modules
│   └── css/                 # Stylesheets
│
├── docker/                  # Docker configuration
│   ├── base/                # Base image config
│   └── run/                 # Runtime image config
│
├── docs/                    # Documentation
│   ├── architecture.md      # Architecture overview
│   ├── development.md       # Development setup guide
│   ├── extensibility.md     # Extension creation guide
│   ├── installation.md      # Installation guide
│   └── ...                  # Other documentation
│
├── tests/                   # Test files
├── conf/                    # Configuration templates
└── traefik/                 # Traefik reverse proxy config (optional)
```

---

## Key Files Reference

| File | Purpose | Key Concepts |
|------|---------|--------------|
| `agent.py` | Core Agent implementation | AgentContext, AgentConfig, Agent class, tool execution |
| `models.py` | LLM provider configurations | Model setup for OpenAI, Anthropic, Google, Ollama, etc. |
| `initialize.py` | Framework startup | Environment setup, context initialization |
| `run_ui.py` | Web UI server | Flask app, WebSocket support, authentication |
| `python/helpers/tool.py` | Tool base class | Response dataclass, Tool lifecycle |
| `python/helpers/extension.py` | Extension base | Extension hooks, call_extensions() |

---

## Architecture Overview

### Agent Hierarchy

```
User (Boss Marc)
    ↓
Agent 0 (Pareng Boyong)
    ↓
Subordinate Agents (Juan, Pedro, Jose, Maria, etc.)
    ↓
Tools & Instruments
```

### Message Loop Flow

```
User Message
    ↓
[Extensions: message_loop_start]
    ↓
System Prompt Construction
    ↓
[Extensions: message_loop_prompts_*]
    ↓
LLM Call
    ↓
Response Parsing
    ↓
Tool Execution (if tool call detected)
    ├─ [Extensions: tool_execute_before]
    ├─ tool.execute()
    └─ [Extensions: tool_execute_after]
    ↓
[Extensions: message_loop_end]
    ↓
Response to User (if break_loop=True)
    OR
Continue Loop (if break_loop=False)
```

### Runtime Architecture

```
Docker Container (Production)
    ├─ Flask Web Server (port 80)
    ├─ Agent Zero Framework
    ├─ SearXNG Search Engine
    └─ Code Execution Runtime

Nginx Reverse Proxy (VPS)
    ├─ SSL Termination
    ├─ Routing to Container
    └─ WebSocket Support
```

---

## Tool System

### Creating a New Tool

1. **Create tool file**: `python/tools/mytool.py`

```python
from python.helpers.tool import Tool, Response

class MyTool(Tool):
    async def execute(self, **kwargs) -> Response:
        # Get arguments
        arg1 = self.args.get("arg1", "")

        # Progress tracking
        self.set_progress("Working...")

        # Do work
        result = f"Processed: {arg1}"

        # Return response
        return Response(
            message=result,
            break_loop=False  # True to end loop and respond to user
        )
```

2. **Create tool prompt**: `prompts/agent.system.tool.mytool.md`

```markdown
## mytool
Brief description of tool purpose.

Arguments:
- **arg1** (string, required) - Description
- **arg2** (integer, optional) - Description, defaults to 0
```

3. **Restart container** to load the new tool

### Available Tools (18 Default)

| Tool | Purpose |
|------|---------|
| `response` | Final response to user |
| `code_execution_tool` | Execute Python/Node/Terminal |
| `memory_save` | Save to memory |
| `memory_load` | Load from memory |
| `memory_delete` | Delete memory entry |
| `memory_forget` | Forget by query |
| `document_query` | Query documents |
| `vision_load` | Load/analyze images |
| `search_engine` | Web search |
| `browser_agent` | Browser automation |
| `call_subordinate` | Delegate to subordinate |
| `scheduler` | Task scheduling (6 methods) |
| `notify_user` | Send notifications |
| `wait` | Pause execution |
| `input` | Keyboard input |
| `behaviour_adjustment` | Adjust agent behavior |
| `a2a_chat` | Agent-to-agent messaging |
| `unknown` | Handle missing tools |

---

## Extension System

### Extension Hook Points (23 hooks)

| Hook | Purpose |
|------|---------|
| `agent_init` | Agent initialization |
| `system_prompt` | System prompt construction |
| `message_loop_start` | Loop iteration start |
| `message_loop_prompts_before` | Before prompts added |
| `message_loop_prompts_after` | After prompts added |
| `message_loop_end` | Loop iteration end |
| `monologue_start` | Monologue start |
| `monologue_end` | Monologue end |
| `tool_execute_before` | Before tool execution |
| `tool_execute_after` | After tool execution |
| `response_stream` | Response streaming |
| `response_stream_chunk` | Each stream chunk |
| `response_stream_end` | Stream end |
| `reasoning_stream` | Reasoning output |
| `hist_add_before` | Before history addition |
| `hist_add_tool_result` | Tool result to history |

### Creating an Extension

```python
# python/extensions/tool_execute_before/my_extension.py
from python.helpers.extension import Extension

class MyExtension(Extension):
    async def execute(self, tool_args: dict, tool_name: str, **kwargs):
        # Modify tool_args in place
        # Or perform side effects
        pass
```

Extensions are auto-discovered from subdirectories named after hooks.

---

## Agent Profiles

Profiles customize agent behavior. Located in `agents/{profile}/`:

```
agents/developer/
├── _context.md          # Profile context/description
├── prompts/             # Profile-specific prompts
│   └── agent.system.main.role.md
└── tools/               # Profile-specific tools (optional)
```

### Available Profiles

| Profile | Purpose |
|---------|---------|
| `default` | General-purpose agent |
| `developer` | Software development focus |
| `researcher` | Research and analysis focus |
| `hacker` | Security testing focus |
| `agent0` | Original Agent Zero behavior |

---

## Development Workflow

### Local Development Setup

1. **Clone repository**
```bash
git clone https://github.com/innovatehubph/parengboyong-linux.git
cd parengboyong-linux
```

2. **Create virtual environment**
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# or: venv\Scripts\activate  # Windows
```

3. **Install dependencies**
```bash
pip install -r requirements.txt
playwright install chromium
```

4. **Configure environment**
```bash
cp example.env .env
# Edit .env with your API keys
```

5. **Run locally**
```bash
python run_ui.py
# Access at http://localhost:5000
```

### Docker Development

For code execution features, run a Docker instance:

```bash
docker pull agent0ai/agent-zero:latest
docker run -d \
  --name pareng-boyong \
  -p 8880:80 \
  -p 8822:22 \
  agent0ai/agent-zero:latest
```

Configure RFC connection in Settings for local-to-Docker communication.

### Debugging (VS Code)

Use `.vscode/launch.json` configurations:
- Set breakpoints in Python files
- Run "run_ui.py" debug configuration
- Inspect variables at runtime

---

## Environment Configuration

### Required Environment Variables

```env
# LLM API Keys (at least one required)
API_KEY_ANTHROPIC=your-key
API_KEY_OPENAI=your-key
API_KEY_GOOGLE=your-key

# Web UI
WEB_UI_HOST=0.0.0.0
WEB_UI_PORT=5000

# Authentication
BASIC_AUTH_USERNAME=admin
BASIC_AUTH_PASSWORD=your-password

# CORS (production)
ALLOWED_ORIGINS=https://ai.innovatehub.site
```

### Optional Configuration

```env
# Model settings
CHAT_MODEL=claude-sonnet-4-20250514
UTILITY_MODEL=gpt-4o-mini

# Runtime
A0_PERSISTENT_RUNTIME_ID=auto-generated

# RFC (Remote Function Call)
RFC_PASSWORD=your-rfc-password
RFC_URL=localhost
RFC_SSH_PORT=22
RFC_HTTP_PORT=80
```

---

## Testing

### Test Files Location

```
tests/
├── chunk_parser_test.py
├── test_fasta2a_client.py
├── email_parser_test.py
├── rate_limiter_test.py
└── test_file_tree_visualize.py
```

### Running Tests

```bash
# Run all tests
python -m pytest tests/

# Run specific test
python -m pytest tests/test_specific.py -v
```

### Manual Tool Testing

```python
import asyncio
from agent import Agent, AgentConfig, AgentContext

async def test_tool():
    config = AgentConfig()
    context = AgentContext(config)
    agent = Agent(0, config, context)

    from python.tools.mytool import MyTool
    tool = MyTool(
        agent=agent,
        name="mytool",
        method=None,
        args={"arg1": "test"},
        message="",
        loop_data=None
    )

    response = await tool.execute()
    print(f"Result: {response.message}")

asyncio.run(test_tool())
```

---

## Deployment

### Docker Deployment (Production)

```bash
# Pull image
docker pull agent0ai/agent-zero:latest

# Create data directory
mkdir -p /root/pareng-boyong-data

# Run container
docker run -d \
  --name pareng-boyong \
  --restart unless-stopped \
  -p 50002:80 \
  -v /root/pareng-boyong-data:/a0 \
  agent0ai/agent-zero:latest
```

### Container Management

```bash
# View logs
docker logs -f pareng-boyong

# Restart
docker restart pareng-boyong

# Stop/Start
docker stop pareng-boyong
docker start pareng-boyong

# Monitor resources
docker stats pareng-boyong
```

### Nginx Configuration

```nginx
server {
    listen 443 ssl;
    server_name ai.innovatehub.site;

    ssl_certificate /etc/letsencrypt/live/ai.innovatehub.site/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ai.innovatehub.site/privkey.pem;

    location / {
        proxy_pass http://localhost:50002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## Key Conventions for AI Assistants

### Code Style

- **Python**: Follow PEP 8, use type hints
- **Async**: All tool execute methods are `async`
- **Imports**: Use relative imports within python/ package
- **Docstrings**: Include for public methods

### File Naming

- **Tools**: `python/tools/{tool_name}.py` (lowercase, underscores)
- **Extensions**: `python/extensions/{hook_name}/{nn}_{name}.py` (numbered for order)
- **Prompts**: `prompts/agent.system.tool.{name}.md`

### Branding Guidelines

- Use "Pareng Boyong" for main agent
- Use "Boss Marc" for user references
- Filipino subordinate names: Juan, Pedro, Jose, Maria, Ana, etc.
- InnovateHub branding in documentation
- Avoid references to "Agent Zero" in user-facing content

### Important Patterns

1. **Tool Response**
   - `break_loop=True`: Ends message loop, returns to user
   - `break_loop=False`: Continues loop, agent can use result

2. **Progress Tracking**
   - Use `self.set_progress()` and `self.add_progress()`
   - Important for long-running operations

3. **Intervention Handling**
   - Call `await self.agent.handle_intervention()` in long loops
   - Allows user to pause/stop operations

4. **Memory Access**
   - Use `self.agent.context` for shared context
   - Use `self.agent.set_data()` / `self.agent.get_data()` for agent data

### Do NOT

- Expose original "Agent Zero" branding to users
- Modify core framework files without understanding dependencies
- Skip intervention checks in long-running operations
- Hardcode file paths (use helpers)
- Store sensitive data in prompts

---

## Common Tasks

### Adding a New API Endpoint

1. Create file in `python/api/`:
```python
# python/api/my_endpoint.py
from python.helpers.api import ApiHandler

class MyEndpoint(ApiHandler):
    async def process(self, input, log):
        # Handle request
        return {"result": "success"}
```

2. Endpoint auto-registered at `/api/my_endpoint`

### Modifying System Prompt

1. Edit or create files in `prompts/`
2. Main hub: `prompts/agent.system.main.md`
3. Use `{{variable}}` for dynamic content

### Adding Knowledge

1. Place files in `knowledge/custom/main/`
2. Supported: `.txt`, `.pdf`, `.csv`, `.html`, `.json`, `.md`
3. Or use "Import Knowledge" button in UI

### Creating an Instrument

1. Create folder in `instruments/custom/{name}/`
2. Add `{name}.md` description file
3. Add `{name}.sh` (or other executable) script
4. Agent will auto-detect and recall when needed

---

## Troubleshooting

### Container Issues

```bash
# Check logs
docker logs pareng-boyong

# Restart container
docker restart pareng-boyong

# Recreate container
docker stop pareng-boyong && docker rm pareng-boyong
docker run -d --name pareng-boyong ...
```

### Import Errors

```bash
# Verify Python path
export PYTHONPATH=/path/to/parengboyong-linux:$PYTHONPATH

# Check dependencies
pip install -r requirements.txt
```

### Tool Not Found

1. Verify file exists: `python/tools/{name}.py`
2. Verify prompt exists: `prompts/agent.system.tool.{name}.md`
3. Restart container/server
4. Check logs for import errors

---

## Related Documentation

| Document | Description |
|----------|-------------|
| `README.md` | Project overview and quick start |
| `TOOL_SYSTEM_ARCHITECTURE.md` | Deep dive into tool system |
| `TOOL_CREATION_QUICKSTART.md` | Quick tool creation guide |
| `docs/architecture.md` | Framework architecture |
| `docs/development.md` | Development setup guide |
| `docs/extensibility.md` | Extension creation guide |
| `LINUX_DEPLOYMENT.md` | Linux VPS deployment guide |
| `PHASE_2_COMPLETE.md` | Recent feature additions |

---

## Contact & Support

- **Repository**: https://github.com/innovatehubph/parengboyong-linux
- **Website**: https://innovatehub.ph
- **Production**: https://ai.innovatehub.site

---

**© 2026 InnovateHub. All rights reserved.**
