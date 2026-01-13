# Omnara Integration - Quick Start Guide
## Implementing Your First Remote-Capable Tool

**Goal:** Get started with Omnara-like capabilities in 30 minutes

---

## Option 1: Simple MCP Manager (Easiest)

### Step 1: Create the Tool

Create `/root/pareng-boyong-data/python/tools/mcp_manager.py`:

```python
from python.helpers.tool import Tool, Response
from python.helpers import mcp_helper
import json

class MCPManagerTool(Tool):
    """
    Manage MCP (Model Context Protocol) servers and tools.
    Enables Omnara-style remote agent integration.
    """

    async def execute(self, **kwargs) -> Response:
        # Route to method handler
        if self.method == "list_servers":
            return await self.list_servers()
        elif self.method == "list_tools":
            return await self.list_tools()
        elif self.method == "get_capabilities":
            return await self.get_capabilities()
        else:
            return Response(
                message="Available methods: list_servers, list_tools, get_capabilities",
                break_loop=False
            )

    async def list_servers(self) -> Response:
        """List all connected MCP servers"""
        try:
            mcp_config = mcp_helper.MCPConfig.get_instance()

            # Get configured servers from agent config
            servers = []
            if hasattr(self.agent.config, 'mcp_servers'):
                for server_name, server_config in self.agent.config.mcp_servers.items():
                    servers.append({
                        "name": server_name,
                        "command": server_config.get("command", ""),
                        "args": server_config.get("args", []),
                        "status": "configured"
                    })

            result = "## Connected MCP Servers\n\n"
            if servers:
                for server in servers:
                    result += f"### {server['name']}\n"
                    result += f"- **Command:** `{server['command']}`\n"
                    result += f"- **Status:** {server['status']}\n\n"
            else:
                result += "No MCP servers configured.\n\n"
                result += "To add MCP servers, configure them in your agent settings.\n"

            return Response(message=result, break_loop=False)

        except Exception as e:
            return Response(
                message=f"Error listing MCP servers: {str(e)}",
                break_loop=False
            )

    async def list_tools(self) -> Response:
        """List all available tools from MCP servers"""
        try:
            mcp_config = mcp_helper.MCPConfig.get_instance()

            # Get all MCP tools
            tools = []
            if hasattr(mcp_config, 'get_all_tools'):
                tools = mcp_config.get_all_tools(self.agent)

            result = "## Available MCP Tools\n\n"
            if tools:
                for tool in tools:
                    result += f"### {tool.name}\n"
                    if hasattr(tool, 'description'):
                        result += f"{tool.description}\n\n"
            else:
                result += "No MCP tools available.\n"

            return Response(message=result, break_loop=False)

        except Exception as e:
            return Response(
                message=f"Error listing MCP tools: {str(e)}",
                break_loop=False
            )

    async def get_capabilities(self) -> Response:
        """Get MCP system capabilities"""
        server_name = self.args.get("server", "")

        if not server_name:
            return Response(
                message="Error: 'server' parameter required",
                break_loop=False
            )

        try:
            # Query capabilities from specific server
            result = f"## MCP Server Capabilities: {server_name}\n\n"
            result += "Capability querying is being implemented.\n"

            return Response(message=result, break_loop=False)

        except Exception as e:
            return Response(
                message=f"Error getting capabilities: {str(e)}",
                break_loop=False
            )
```

### Step 2: Create the Prompt

Create `/root/pareng-boyong-data/prompts/agent.system.tool.mcp_manager.md`:

```markdown
## mcp_manager
Manage MCP (Model Context Protocol) servers and tools for remote agent integration.

### mcp_manager:list_servers
List all connected MCP servers.

Arguments: None

### mcp_manager:list_tools
List all available tools from MCP servers.

Arguments: None

### mcp_manager:get_capabilities
Get capabilities of a specific MCP server.

Arguments:
- **server** (string, required) - Server name

Examples:
```json
{
    "tool_name": "mcp_manager:list_servers",
    "tool_args": {}
}
```

```json
{
    "tool_name": "mcp_manager:list_tools",
    "tool_args": {}
}
```

```json
{
    "tool_name": "mcp_manager:get_capabilities",
    "tool_args": {
        "server": "claude_code"
    }
}
```
```

### Step 3: Deploy

```bash
# Copy files to production
cp /root/parengboyong-linux/python/tools/mcp_manager.py /root/pareng-boyong-data/python/tools/
cp /root/parengboyong-linux/prompts/agent.system.tool.mcp_manager.md /root/pareng-boyong-data/prompts/

# Restart container
docker restart pareng-boyong

# Check logs
docker logs -f pareng-boyong | grep mcp_manager
```

### Step 4: Test

Open https://ai.innovatehub.site and ask:

```
Can you list all connected MCP servers?
```

Or:

```
Show me all available MCP tools
```

---

## Option 2: Simple Session Manager

### Step 1: Create the Tool

Create `/root/pareng-boyong-data/python/tools/session_manager.py`:

```python
from python.helpers.tool import Tool, Response
from python.helpers import files
import json, uuid
from datetime import datetime

class SessionManagerTool(Tool):
    """
    Manage remote sessions for multi-device access.
    Enables Omnara-style session continuity.
    """

    async def execute(self, **kwargs) -> Response:
        if self.method == "create":
            return await self.create_session()
        elif self.method == "info":
            return await self.get_session_info()
        elif self.method == "save":
            return await self.save_session()
        elif self.method == "load":
            return await self.load_session()
        else:
            return Response(
                message="Available methods: create, info, save, load",
                break_loop=False
            )

    async def create_session(self) -> Response:
        """Create a new session"""
        session_name = self.args.get("name", "")
        if not session_name:
            session_name = f"session_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}"

        session_id = str(uuid.uuid4())

        session_data = {
            "session_id": session_id,
            "session_name": session_name,
            "context_id": self.agent.context.id,
            "created_at": datetime.utcnow().isoformat(),
            "agent_name": self.agent.agent_name,
            "status": "active"
        }

        # Save to agent data
        self.agent.set_data(f"session:{session_id}", session_data)

        # Save to file for persistence
        session_file = files.get_abs_path(f"sessions/{session_id}.json")
        files.write_file(session_file, json.dumps(session_data, indent=2))

        result = f"## Session Created\n\n"
        result += f"**Session ID:** `{session_id}`\n"
        result += f"**Session Name:** {session_name}\n"
        result += f"**Created:** {session_data['created_at']}\n\n"
        result += f"Use this session ID to resume from another device:\n"
        result += f"```\nresume session {session_id}\n```"

        return Response(message=result, break_loop=False)

    async def get_session_info(self) -> Response:
        """Get current session information"""
        result = f"## Current Session Info\n\n"
        result += f"**Context ID:** `{self.agent.context.id}`\n"
        result += f"**Agent Name:** {self.agent.agent_name}\n"
        result += f"**Agent Number:** {self.agent.number}\n"

        # List all saved sessions
        sessions_dir = files.get_abs_path("sessions")
        if files.exists(sessions_dir):
            session_files = files.list_dir(sessions_dir)
            if session_files:
                result += f"\n**Saved Sessions:** {len(session_files)}\n"

        return Response(message=result, break_loop=False)

    async def save_session(self) -> Response:
        """Save current session state"""
        session_id = self.args.get("session_id", "")
        if not session_id:
            session_id = str(uuid.uuid4())

        checkpoint_data = {
            "session_id": session_id,
            "saved_at": datetime.utcnow().isoformat(),
            "context_id": self.agent.context.id,
            "agent_name": self.agent.agent_name,
            "history": self.agent.history[-50:],  # Last 50 messages
            "data": self.agent.data
        }

        # Save to file
        checkpoint_file = files.get_abs_path(f"sessions/{session_id}_checkpoint.json")
        files.write_file(checkpoint_file, json.dumps(checkpoint_data, indent=2))

        result = f"## Session Saved\n\n"
        result += f"**Session ID:** `{session_id}`\n"
        result += f"**Saved:** {checkpoint_data['saved_at']}\n"
        result += f"**Messages:** {len(checkpoint_data['history'])}\n"

        return Response(message=result, break_loop=False)

    async def load_session(self) -> Response:
        """Load session state"""
        session_id = self.args.get("session_id", "")

        if not session_id:
            return Response(
                message="Error: 'session_id' required",
                break_loop=False
            )

        checkpoint_file = files.get_abs_path(f"sessions/{session_id}_checkpoint.json")

        if not files.exists(checkpoint_file):
            return Response(
                message=f"Error: Session '{session_id}' not found",
                break_loop=False
            )

        # Load checkpoint
        checkpoint_data = json.loads(files.read_file(checkpoint_file))

        # Restore state
        self.agent.context.id = checkpoint_data["context_id"]
        self.agent.history = checkpoint_data["history"]
        self.agent.data = checkpoint_data["data"]

        result = f"## Session Loaded\n\n"
        result += f"**Session ID:** `{session_id}`\n"
        result += f"**Originally Saved:** {checkpoint_data['saved_at']}\n"
        result += f"**Messages Restored:** {len(checkpoint_data['history'])}\n"

        return Response(message=result, break_loop=False)
```

### Step 2: Create the Prompt

Create `/root/pareng-boyong-data/prompts/agent.system.tool.session_manager.md`:

```markdown
## session_manager
Manage sessions for multi-device access and session continuity.

### session_manager:create
Create a new session.

Arguments:
- **name** (string, optional) - Session name

### session_manager:info
Get current session information.

Arguments: None

### session_manager:save
Save current session state.

Arguments:
- **session_id** (string, optional) - Session ID to save to

### session_manager:load
Load session state.

Arguments:
- **session_id** (string, required) - Session ID to load

Examples:
```json
{
    "tool_name": "session_manager:create",
    "tool_args": {
        "name": "My Project Session"
    }
}
```

```json
{
    "tool_name": "session_manager:save",
    "tool_args": {
        "session_id": "abc-123"
    }
}
```

```json
{
    "tool_name": "session_manager:load",
    "tool_args": {
        "session_id": "abc-123"
    }
}
```
```

### Step 3: Deploy

```bash
# Copy files
cp /root/parengboyong-linux/python/tools/session_manager.py /root/pareng-boyong-data/python/tools/
cp /root/parengboyong-linux/prompts/agent.system.tool.session_manager.md /root/pareng-boyong-data/prompts/

# Create sessions directory
mkdir -p /root/pareng-boyong-data/sessions

# Restart container
docker restart pareng-boyong
```

### Step 4: Test

```
Create a new session called "Test Project"
```

Then:

```
Save the current session
```

Then:

```
Load session [session_id from previous response]
```

---

## Option 3: Simple Real-Time Broadcast

### Minimal WebSocket Implementation

Add to `/root/pareng-boyong-data/python/api/websocket.py`:

```python
from python.helpers.api import ApiHandler, Request, Response
import asyncio, json

class WebSocketHandler(ApiHandler):
    connections = {}  # {context_id: [websocket_connections]}

    async def handle(self, websocket, path):
        """Handle WebSocket connection"""
        context_id = None

        try:
            # Wait for subscribe message
            message = await websocket.recv()
            data = json.loads(message)

            if data.get("action") == "subscribe":
                context_id = data.get("context_id")

                # Add connection
                if context_id not in self.connections:
                    self.connections[context_id] = []
                self.connections[context_id].append(websocket)

                # Send initial state
                await websocket.send(json.dumps({
                    "type": "connected",
                    "context_id": context_id,
                    "timestamp": datetime.utcnow().isoformat()
                }))

                # Keep connection alive
                while True:
                    message = await websocket.recv()
                    # Handle incoming messages
                    await self.handle_message(websocket, message, context_id)

        except Exception as e:
            print(f"WebSocket error: {e}")

        finally:
            # Remove connection
            if context_id and context_id in self.connections:
                self.connections[context_id].remove(websocket)

    async def handle_message(self, websocket, message, context_id):
        """Handle incoming WebSocket message"""
        try:
            data = json.loads(message)
            action = data.get("action")

            if action == "ping":
                await websocket.send(json.dumps({"type": "pong"}))

        except Exception as e:
            await websocket.send(json.dumps({
                "type": "error",
                "message": str(e)
            }))

    @classmethod
    async def broadcast(cls, context_id, message):
        """Broadcast message to all connections for a context"""
        if context_id in cls.connections:
            for ws in cls.connections[context_id]:
                try:
                    await ws.send(json.dumps(message))
                except:
                    pass  # Connection closed
```

---

## Testing the Integration

### Test 1: MCP Manager

```bash
# In chat interface
"List all connected MCP servers"
"Show me available MCP tools"
```

### Test 2: Session Manager

```bash
# Create session
"Create a new session called 'Mobile Test'"

# Save session
"Save the current session"

# Get info
"What's my current session info?"
```

### Test 3: Integration Test

```bash
# Full workflow
"Create a new session, list MCP servers, and save the session"
```

---

## Next Steps

After these basic tools work:

1. **Add Database Support**
   - Set up PostgreSQL for persistent sessions
   - Set up Redis for real-time caching

2. **Implement WebSocket Server**
   - Add WebSocket endpoint to Flask
   - Implement real-time broadcasting

3. **Create Mobile PWA**
   - Build Progressive Web App
   - Add service worker for offline support
   - Implement push notifications

4. **Enhance MCP Integration**
   - Connect to Claude Code CLI
   - Share tools across agents
   - Implement tool discovery

5. **Deploy Additional Tools**
   - Device registry
   - Webhook integration
   - Cloud sync

---

## Troubleshooting

### Tool Not Loading

```bash
# Check file exists
ls -la /root/pareng-boyong-data/python/tools/mcp_manager.py

# Check logs
docker logs pareng-boyong | grep mcp_manager

# Restart container
docker restart pareng-boyong
```

### Session Files Not Saving

```bash
# Create sessions directory
docker exec pareng-boyong mkdir -p /a0/sessions

# Check permissions
docker exec pareng-boyong ls -la /a0/sessions
```

### WebSocket Not Connecting

```bash
# Check Nginx configuration
nginx -t

# Verify WebSocket upgrade headers
curl -i -N -H "Connection: Upgrade" -H "Upgrade: websocket" https://ai.innovatehub.site/ws
```

---

## Resources

- **Full Plan:** `OMNARA_INTEGRATION_PLAN.md`
- **Tool Architecture:** `TOOL_SYSTEM_ARCHITECTURE.md`
- **Tool Creation:** `TOOL_CREATION_QUICKSTART.md`

---

**Start with Option 1 (MCP Manager) - easiest to implement and test!**

**© 2026 InnovateHub - Pareng Boyong Project**
