# Omnara-Like Architecture Integration Plan
## Pareng Boyong Native Tools for Remote, Multi-Device AI Agent Control

**Version:** 1.0
**Date:** 2026-01-13
**Status:** Planning & Design Phase

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Current State Analysis](#current-state-analysis)
3. [Proposed Architecture](#proposed-architecture)
4. [Native Tools Design](#native-tools-design)
5. [Implementation Roadmap](#implementation-roadmap)
6. [Use Cases & Benefits](#use-cases--benefits)
7. [Technical Specifications](#technical-specifications)
8. [Security Considerations](#security-considerations)
9. [Mobile Integration Strategy](#mobile-integration-strategy)
10. [Performance & Scalability](#performance--scalability)

---

## Executive Summary

### Vision

Transform Pareng Boyong into a **fully remote-capable, multi-device AI agent platform** by implementing Omnara-inspired native tools that enable:

- **Remote Agent Control** from any device (mobile, web, desktop)
- **Session Continuity** across devices and interruptions
- **Real-Time Synchronization** of agent state and outputs
- **Enhanced MCP Integration** for external tool ecosystems
- **Mobile-First Experience** with push notifications and offline support
- **Multi-User Collaboration** with shared agent sessions

### Core Strategy

Rather than bolting on external systems, we'll create **native Pareng Boyong tools** that leverage the existing tool architecture to provide Omnara-like capabilities:

1. **MCP Management Tool** - Enhanced MCP server/client integration
2. **Remote Session Tool** - Multi-device session management
3. **Real-Time Sync Tool** - WebSocket/SSE state broadcasting
4. **Mobile Command Tool** - Mobile-optimized agent interaction
5. **Session Recovery Tool** - Automatic session persistence and recovery
6. **Device Registry Tool** - Multi-device authentication and management
7. **Webhook Integration Tool** - External service notifications
8. **Cloud Sync Tool** - Cloud-based agent state synchronization

---

## Current State Analysis

### What Pareng Boyong Already Has

| Feature | Status | Omnara Alignment |
|---------|--------|------------------|
| **Multi-Agent Architecture** | ✅ Complete | Hierarchical agents (Pareng Boyong + Filipino subordinates) |
| **Tool System** | ✅ Complete | 18 tools, extensible architecture |
| **Docker Runtime** | ✅ Complete | Containerized, portable deployment |
| **Web UI** | ✅ Complete | Real-time interface at ai.innovatehub.site |
| **REST API** | ✅ Complete | `/api/message`, `/api/context` endpoints |
| **MCP Support** | ✅ Partial | MCP client implemented, limited server features |
| **Session Management** | ✅ Basic | Context persistence, memory tools |
| **A2A Communication** | ✅ Complete | `a2a_chat` tool for agent-to-agent messaging |
| **Authentication** | ✅ Basic | Basic auth (username/password) |
| **Mobile Access** | ⚠️ Limited | Web UI works on mobile but not optimized |
| **Real-Time Sync** | ⚠️ Limited | Polling-based, no WebSocket/SSE |
| **Session Recovery** | ❌ Missing | No automatic recovery after disconnection |
| **Device Management** | ❌ Missing | No multi-device tracking |
| **Push Notifications** | ❌ Missing | No mobile push support |
| **Offline Support** | ❌ Missing | No offline queue |
| **Cloud Sync** | ❌ Missing | All data local to VPS |

### Gaps to Fill

1. **Real-Time Communication**: Need WebSocket/SSE for instant updates
2. **Session Continuity**: Auto-recovery after network interruptions
3. **Device Management**: Track and manage multiple connected devices
4. **Mobile Optimization**: Native mobile app or PWA
5. **Push Notifications**: Alert users on mobile devices
6. **Offline Queue**: Handle commands when disconnected
7. **Enhanced MCP**: Richer MCP protocol usage
8. **Cloud Sync**: Optional cloud backup and sync

---

## Proposed Architecture

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      CLIENT LAYER                               │
├─────────────────────────────────────────────────────────────────┤
│  Mobile App (PWA)   │   Web Browser   │   CLI Client   │  API   │
│  - iOS/Android      │   - Desktop     │   - Terminal   │  - cURL│
│  - Push enabled     │   - Laptop      │   - Scripts    │  - SDK │
└──────────┬──────────┴─────────┬───────┴────────┬───────┴────────┘
           │                    │                │
           └────────────────────┼────────────────┘
                                │
                    ┌───────────▼───────────┐
                    │   NGINX REVERSE PROXY  │
                    │   - SSL/TLS           │
                    │   - Load balancing    │
                    │   - WebSocket upgrade │
                    └───────────┬───────────┘
                                │
           ┌────────────────────┼────────────────────┐
           │                    │                    │
    ┌──────▼──────┐      ┌──────▼──────┐     ┌──────▼──────┐
    │  REST API   │      │  WebSocket  │     │  MCP Server │
    │  /api/*     │      │  /ws/*      │     │  /mcp/*     │
    └──────┬──────┘      └──────┬──────┘     └──────┬──────┘
           │                    │                    │
           └────────────────────┼────────────────────┘
                                │
                    ┌───────────▼───────────┐
                    │   PARENG BOYONG CORE  │
                    │   Agent Loop          │
                    └───────────┬───────────┘
                                │
         ┌──────────────────────┼──────────────────────┐
         │                      │                      │
    ┌────▼─────┐         ┌──────▼──────┐       ┌──────▼──────┐
    │  NATIVE  │         │  ENHANCED   │       │   NEW       │
    │  TOOLS   │         │  TOOLS      │       │   TOOLS     │
    │          │         │             │       │             │
    │ - memory │         │ - mcp_mgmt  │       │ - remote    │
    │ - code   │         │ - realtime  │       │ - device    │
    │ - browser│         │ - mobile    │       │ - webhook   │
    │ - etc.   │         │ - recovery  │       │ - cloudsync │
    └────┬─────┘         └──────┬──────┘       └──────┬──────┘
         │                      │                      │
         └──────────────────────┼──────────────────────┘
                                │
                    ┌───────────▼───────────┐
                    │   PERSISTENCE LAYER   │
                    ├───────────────────────┤
                    │ - PostgreSQL/SQLite   │
                    │ - Redis (sessions)    │
                    │ - File storage        │
                    │ - Vector DB (memory)  │
                    └───────────────────────┘
```

### Component Breakdown

#### 1. Enhanced API Layer

**New Endpoints:**
```
POST   /api/v2/message          # Send message with device info
GET    /api/v2/context/:id      # Get context state
POST   /api/v2/session/create   # Create new session
POST   /api/v2/session/resume   # Resume existing session
GET    /api/v2/session/list     # List user's sessions
DELETE /api/v2/session/:id      # Delete session
POST   /api/v2/device/register  # Register device
GET    /api/v2/device/list      # List registered devices
DELETE /api/v2/device/:id       # Unregister device
POST   /api/v2/webhook/create   # Create webhook
GET    /api/v2/webhook/list     # List webhooks
POST   /api/v2/push/subscribe   # Subscribe to push notifications
```

#### 2. WebSocket/SSE Layer

**WebSocket Endpoints:**
```
WS  /ws/agent/:context_id       # Real-time agent updates
WS  /ws/session/:session_id     # Session-level updates
WS  /ws/device/:device_id       # Device-specific updates
```

**Message Types:**
```json
// Agent message
{
  "type": "agent_message",
  "context_id": "abc123",
  "agent_name": "Pareng Boyong",
  "content": "Working on your request...",
  "timestamp": "2026-01-13T10:00:00Z"
}

// Tool execution
{
  "type": "tool_execution",
  "context_id": "abc123",
  "tool_name": "code_execution_tool",
  "status": "running",
  "progress": "Executing Python code...",
  "timestamp": "2026-01-13T10:00:01Z"
}

// Session state change
{
  "type": "session_state",
  "session_id": "xyz789",
  "state": "active",
  "devices": ["device1", "device2"],
  "timestamp": "2026-01-13T10:00:02Z"
}
```

#### 3. MCP Integration Layer

**Enhanced MCP Server:**
- Expose all Pareng Boyong tools via MCP
- Support remote tool registration
- Enable cross-agent tool sharing
- Provide rich tool metadata

**MCP Client Enhancements:**
- Auto-discover available MCP servers
- Cache tool definitions
- Handle connection failures gracefully
- Support tool versioning

---

## Native Tools Design

### Tool 1: MCP Management Tool

**File:** `python/tools/mcp_manager.py`

**Purpose:** Advanced MCP server/client management

**Methods:**
- `mcp_manager:list_servers` - List connected MCP servers
- `mcp_manager:register_server` - Register new MCP server
- `mcp_manager:unregister_server` - Remove MCP server
- `mcp_manager:list_tools` - List all available MCP tools
- `mcp_manager:call_tool` - Execute tool on remote MCP server
- `mcp_manager:get_capabilities` - Query server capabilities

**Implementation Sketch:**
```python
from python.helpers.tool import Tool, Response
from python.helpers import mcp_helper

class MCPManagerTool(Tool):
    async def execute(self, **kwargs) -> Response:
        if self.method == "list_servers":
            return await self.list_servers()
        elif self.method == "register_server":
            return await self.register_server()
        elif self.method == "call_tool":
            return await self.call_tool()
        # ... other methods

    async def list_servers(self) -> Response:
        mcp_config = mcp_helper.MCPConfig.get_instance()
        servers = mcp_config.get_all_servers()

        result = "Connected MCP Servers:\n"
        for server in servers:
            result += f"- {server['name']} ({server['url']})\n"
            result += f"  Tools: {len(server['tools'])}\n"

        return Response(message=result, break_loop=False)

    async def register_server(self) -> Response:
        url = self.args.get("url", "")
        name = self.args.get("name", "")

        mcp_config = mcp_helper.MCPConfig.get_instance()
        success = await mcp_config.register_server(url, name)

        if success:
            return Response(
                message=f"Registered MCP server: {name}",
                break_loop=False
            )
        else:
            return Response(
                message=f"Failed to register MCP server: {name}",
                break_loop=False
            )

    async def call_tool(self) -> Response:
        server_name = self.args.get("server", "")
        tool_name = self.args.get("tool", "")
        tool_args = self.args.get("args", {})

        # Get MCP tool and execute
        mcp_tool = self.agent.get_tool(
            f"mcp:{server_name}:{tool_name}",
            None,
            args=tool_args,
            message="",
            loop_data=self.loop_data
        )

        result = await mcp_tool.execute(**tool_args)
        return result
```

**Use Cases:**
- Connect to Claude Code CLI as MCP server
- Use external tools from other agents
- Share Pareng Boyong tools with other systems
- Build tool marketplaces

---

### Tool 2: Remote Session Tool

**File:** `python/tools/remote_session.py`

**Purpose:** Multi-device session management

**Methods:**
- `remote_session:create` - Create new remote session
- `remote_session:resume` - Resume existing session
- `remote_session:list` - List all sessions
- `remote_session:share` - Share session with other users
- `remote_session:sync` - Sync session state across devices
- `remote_session:disconnect` - Gracefully disconnect device

**Implementation Sketch:**
```python
from python.helpers.tool import Tool, Response
import json, uuid
from datetime import datetime

class RemoteSessionTool(Tool):
    async def execute(self, **kwargs) -> Response:
        if self.method == "create":
            return await self.create_session()
        elif self.method == "resume":
            return await self.resume_session()
        elif self.method == "list":
            return await self.list_sessions()
        # ... other methods

    async def create_session(self) -> Response:
        device_id = self.args.get("device_id", "")
        device_name = self.args.get("device_name", "Unknown Device")

        # Generate session ID
        session_id = str(uuid.uuid4())

        # Store session metadata
        session_data = {
            "session_id": session_id,
            "context_id": self.agent.context.id,
            "created_at": datetime.utcnow().isoformat(),
            "devices": [{
                "device_id": device_id,
                "device_name": device_name,
                "connected_at": datetime.utcnow().isoformat()
            }],
            "state": "active"
        }

        # Save to agent data
        self.agent.set_data(f"session:{session_id}", session_data)

        # Also save to persistent storage (Redis/PostgreSQL)
        await self.save_to_db(session_data)

        return Response(
            message=f"Created session: {session_id}",
            break_loop=False,
            additional={"session_id": session_id}
        )

    async def resume_session(self) -> Response:
        session_id = self.args.get("session_id", "")
        device_id = self.args.get("device_id", "")

        # Load session from storage
        session_data = await self.load_from_db(session_id)

        if not session_data:
            return Response(
                message=f"Session not found: {session_id}",
                break_loop=False
            )

        # Add device to session
        session_data["devices"].append({
            "device_id": device_id,
            "connected_at": datetime.utcnow().isoformat()
        })

        # Restore agent context
        self.agent.context.id = session_data["context_id"]

        # Update storage
        await self.save_to_db(session_data)

        return Response(
            message=f"Resumed session: {session_id}",
            break_loop=False,
            additional={"context_id": session_data["context_id"]}
        )

    async def save_to_db(self, session_data):
        # TODO: Implement Redis/PostgreSQL storage
        pass

    async def load_from_db(self, session_id):
        # TODO: Implement Redis/PostgreSQL retrieval
        pass
```

**Use Cases:**
- Start conversation on laptop, continue on mobile
- Share agent session with team members
- Auto-save and recover from crashes
- Multi-device collaboration

---

### Tool 3: Real-Time Sync Tool

**File:** `python/tools/realtime_sync.py`

**Purpose:** Real-time state broadcasting

**Methods:**
- `realtime_sync:broadcast` - Broadcast message to all devices
- `realtime_sync:subscribe` - Subscribe device to updates
- `realtime_sync:unsubscribe` - Unsubscribe device
- `realtime_sync:get_state` - Get current agent state
- `realtime_sync:push_update` - Push specific update to devices

**Implementation Sketch:**
```python
from python.helpers.tool import Tool, Response
import asyncio
import json

class RealtimeSyncTool(Tool):
    # Class-level WebSocket connection manager
    _connections = {}  # {device_id: websocket_connection}

    async def execute(self, **kwargs) -> Response:
        if self.method == "broadcast":
            return await self.broadcast()
        elif self.method == "subscribe":
            return await self.subscribe()
        elif self.method == "push_update":
            return await self.push_update()
        # ... other methods

    async def broadcast(self) -> Response:
        message = self.args.get("message", "")
        message_type = self.args.get("type", "agent_message")

        # Create broadcast payload
        payload = {
            "type": message_type,
            "context_id": self.agent.context.id,
            "agent_name": self.agent.agent_name,
            "content": message,
            "timestamp": datetime.utcnow().isoformat()
        }

        # Broadcast to all connected devices
        sent_count = 0
        for device_id, ws in self._connections.items():
            try:
                await ws.send(json.dumps(payload))
                sent_count += 1
            except Exception as e:
                # Remove disconnected device
                del self._connections[device_id]

        return Response(
            message=f"Broadcasted to {sent_count} devices",
            break_loop=False
        )

    async def subscribe(self) -> Response:
        device_id = self.args.get("device_id", "")
        # WebSocket connection would be passed via kwargs
        ws_connection = kwargs.get("ws_connection")

        # Store connection
        self._connections[device_id] = ws_connection

        # Send initial state
        state = await self.get_current_state()
        await ws_connection.send(json.dumps(state))

        return Response(
            message=f"Device {device_id} subscribed",
            break_loop=False
        )

    async def get_current_state(self):
        return {
            "type": "initial_state",
            "context_id": self.agent.context.id,
            "agent_name": self.agent.agent_name,
            "history": self.agent.history[-10:],  # Last 10 messages
            "timestamp": datetime.utcnow().isoformat()
        }
```

**Use Cases:**
- Live progress updates on mobile while agent works
- Multi-user collaboration with real-time sync
- Dashboard monitoring of multiple agents
- Live demo presentations

---

### Tool 4: Mobile Command Tool

**File:** `python/tools/mobile_command.py`

**Purpose:** Mobile-optimized agent interaction

**Methods:**
- `mobile_command:send` - Send mobile-friendly command
- `mobile_command:quick_action` - Predefined quick actions
- `mobile_command:voice_input` - Process voice command
- `mobile_command:get_summary` - Get mobile-friendly summary
- `mobile_command:format_response` - Format for mobile display

**Implementation Sketch:**
```python
from python.helpers.tool import Tool, Response

class MobileCommandTool(Tool):
    async def execute(self, **kwargs) -> Response:
        if self.method == "send":
            return await self.send_command()
        elif self.method == "quick_action":
            return await self.quick_action()
        elif self.method == "get_summary":
            return await self.get_summary()
        # ... other methods

    async def send_command(self) -> Response:
        command = self.args.get("command", "")
        device_type = self.args.get("device_type", "mobile")

        # Process command (might be voice-to-text)
        processed_command = await self.process_mobile_input(command)

        # Execute via agent
        from agent import UserMessage
        self.agent.context.communicate(UserMessage(processed_command))

        # Get response and format for mobile
        response = await self.agent.monologue()
        formatted = await self.format_for_mobile(response, device_type)

        return Response(
            message=formatted,
            break_loop=True
        )

    async def quick_action(self) -> Response:
        action = self.args.get("action", "")

        # Predefined quick actions
        quick_actions = {
            "status": "What's the current status of all running tasks?",
            "summary": "Give me a brief summary of what you've done today",
            "pause": "Pause all current operations",
            "resume": "Resume all paused operations",
            "help": "What can I ask you to do?"
        }

        if action in quick_actions:
            command = quick_actions[action]
            # Execute command
            from agent import UserMessage
            self.agent.context.communicate(UserMessage(command))
            response = await self.agent.monologue()

            return Response(
                message=response,
                break_loop=True
            )
        else:
            return Response(
                message=f"Unknown quick action: {action}",
                break_loop=False
            )

    async def format_for_mobile(self, text, device_type):
        # Simplify markdown, shorten responses, etc.
        # Remove code blocks if too long
        # Summarize if > 500 chars
        if len(text) > 500:
            # Use LLM to summarize
            summary = await self.agent.call_llm(
                f"Summarize this in 2-3 sentences for mobile display:\n{text}"
            )
            return summary
        return text
```

**Use Cases:**
- Quick status checks from phone
- Voice commands while driving
- One-tap actions (pause, resume, status)
- Mobile-friendly responses

---

### Tool 5: Session Recovery Tool

**File:** `python/tools/session_recovery.py`

**Purpose:** Automatic session persistence and recovery

**Methods:**
- `session_recovery:checkpoint` - Create recovery checkpoint
- `session_recovery:restore` - Restore from checkpoint
- `session_recovery:auto_save` - Enable auto-save
- `session_recovery:list_checkpoints` - List available checkpoints
- `session_recovery:clean_old` - Clean old checkpoints

**Implementation Sketch:**
```python
from python.helpers.tool import Tool, Response
from python.helpers import files
import json, pickle
from datetime import datetime, timedelta

class SessionRecoveryTool(Tool):
    async def execute(self, **kwargs) -> Response:
        if self.method == "checkpoint":
            return await self.create_checkpoint()
        elif self.method == "restore":
            return await self.restore_checkpoint()
        elif self.method == "auto_save":
            return await self.enable_auto_save()
        # ... other methods

    async def create_checkpoint(self) -> Response:
        checkpoint_name = self.args.get("name", "")
        if not checkpoint_name:
            checkpoint_name = f"auto_{datetime.utcnow().isoformat()}"

        # Capture full agent state
        checkpoint_data = {
            "timestamp": datetime.utcnow().isoformat(),
            "context_id": self.agent.context.id,
            "agent_number": self.agent.number,
            "agent_name": self.agent.agent_name,
            "history": self.agent.history,
            "data": self.agent.data,
            "config": {
                "chat_model": self.agent.config.chat_model,
                "max_iterations": self.agent.config.max_iterations,
                # ... other config
            }
        }

        # Save to file
        checkpoint_path = files.get_abs_path(
            f"recovery/checkpoints/{checkpoint_name}.json"
        )
        files.write_file(checkpoint_path, json.dumps(checkpoint_data, indent=2))

        return Response(
            message=f"Created checkpoint: {checkpoint_name}",
            break_loop=False,
            additional={"checkpoint_name": checkpoint_name}
        )

    async def restore_checkpoint(self) -> Response:
        checkpoint_name = self.args.get("name", "")

        # Load checkpoint
        checkpoint_path = files.get_abs_path(
            f"recovery/checkpoints/{checkpoint_name}.json"
        )

        if not files.exists(checkpoint_path):
            return Response(
                message=f"Checkpoint not found: {checkpoint_name}",
                break_loop=False
            )

        checkpoint_data = json.loads(files.read_file(checkpoint_path))

        # Restore agent state
        self.agent.context.id = checkpoint_data["context_id"]
        self.agent.history = checkpoint_data["history"]
        self.agent.data = checkpoint_data["data"]

        return Response(
            message=f"Restored from checkpoint: {checkpoint_name}",
            break_loop=False
        )

    async def enable_auto_save(self) -> Response:
        interval = int(self.args.get("interval", "60"))  # seconds

        # Start background auto-save task
        asyncio.create_task(self.auto_save_loop(interval))

        return Response(
            message=f"Auto-save enabled (every {interval}s)",
            break_loop=False
        )

    async def auto_save_loop(self, interval):
        while True:
            await asyncio.sleep(interval)
            await self.create_checkpoint()
```

**Use Cases:**
- Recover from network disconnections
- Resume after server restarts
- Rollback to previous state
- Disaster recovery

---

### Tool 6: Device Registry Tool

**File:** `python/tools/device_registry.py`

**Purpose:** Multi-device authentication and management

**Methods:**
- `device_registry:register` - Register new device
- `device_registry:unregister` - Remove device
- `device_registry:list` - List registered devices
- `device_registry:authorize` - Authorize device for session
- `device_registry:revoke` - Revoke device access
- `device_registry:get_info` - Get device information

**Implementation Sketch:**
```python
from python.helpers.tool import Tool, Response
import uuid, hashlib
from datetime import datetime

class DeviceRegistryTool(Tool):
    async def execute(self, **kwargs) -> Response:
        if self.method == "register":
            return await self.register_device()
        elif self.method == "list":
            return await self.list_devices()
        elif self.method == "authorize":
            return await self.authorize_device()
        # ... other methods

    async def register_device(self) -> Response:
        device_name = self.args.get("device_name", "")
        device_type = self.args.get("device_type", "unknown")  # mobile/desktop/tablet
        user_id = self.args.get("user_id", "default")

        # Generate device ID and token
        device_id = str(uuid.uuid4())
        device_token = hashlib.sha256(
            f"{device_id}:{datetime.utcnow()}".encode()
        ).hexdigest()

        # Store device info
        device_data = {
            "device_id": device_id,
            "device_name": device_name,
            "device_type": device_type,
            "user_id": user_id,
            "token": device_token,
            "registered_at": datetime.utcnow().isoformat(),
            "last_seen": datetime.utcnow().isoformat(),
            "status": "active"
        }

        # Save to database
        await self.save_device(device_data)

        return Response(
            message=f"Device registered: {device_name}",
            break_loop=False,
            additional={
                "device_id": device_id,
                "device_token": device_token
            }
        )

    async def list_devices(self) -> Response:
        user_id = self.args.get("user_id", "default")

        # Load all devices for user
        devices = await self.load_devices(user_id)

        result = f"Registered Devices for {user_id}:\n"
        for device in devices:
            result += f"- {device['device_name']} ({device['device_type']})\n"
            result += f"  ID: {device['device_id']}\n"
            result += f"  Last seen: {device['last_seen']}\n"
            result += f"  Status: {device['status']}\n"

        return Response(message=result, break_loop=False)

    async def save_device(self, device_data):
        # Save to PostgreSQL/Redis
        pass

    async def load_devices(self, user_id):
        # Load from PostgreSQL/Redis
        return []
```

**Use Cases:**
- Manage multiple devices per user
- Revoke access from lost devices
- Track device usage
- Device-specific permissions

---

### Tool 7: Webhook Integration Tool

**File:** `python/tools/webhook.py`

**Purpose:** External service notifications

**Methods:**
- `webhook:create` - Create webhook endpoint
- `webhook:delete` - Remove webhook
- `webhook:list` - List active webhooks
- `webhook:trigger` - Manually trigger webhook
- `webhook:test` - Test webhook delivery

**Implementation Sketch:**
```python
from python.helpers.tool import Tool, Response
import aiohttp, json

class WebhookTool(Tool):
    async def execute(self, **kwargs) -> Response:
        if self.method == "create":
            return await self.create_webhook()
        elif self.method == "trigger":
            return await self.trigger_webhook()
        # ... other methods

    async def create_webhook(self) -> Response:
        url = self.args.get("url", "")
        event_type = self.args.get("event_type", "all")  # all/tool/message/error

        # Store webhook configuration
        webhook_id = str(uuid.uuid4())
        webhook_data = {
            "webhook_id": webhook_id,
            "url": url,
            "event_type": event_type,
            "created_at": datetime.utcnow().isoformat(),
            "status": "active"
        }

        self.agent.set_data(f"webhook:{webhook_id}", webhook_data)

        return Response(
            message=f"Created webhook: {webhook_id}",
            break_loop=False,
            additional={"webhook_id": webhook_id}
        )

    async def trigger_webhook(self) -> Response:
        webhook_id = self.args.get("webhook_id", "")
        payload = self.args.get("payload", {})

        # Load webhook config
        webhook_data = self.agent.get_data(f"webhook:{webhook_id}")

        if not webhook_data:
            return Response(
                message=f"Webhook not found: {webhook_id}",
                break_loop=False
            )

        # Send HTTP POST to webhook URL
        async with aiohttp.ClientSession() as session:
            try:
                async with session.post(
                    webhook_data["url"],
                    json=payload,
                    headers={"Content-Type": "application/json"}
                ) as resp:
                    status = resp.status

                    if status == 200:
                        return Response(
                            message=f"Webhook triggered successfully",
                            break_loop=False
                        )
                    else:
                        return Response(
                            message=f"Webhook failed: HTTP {status}",
                            break_loop=False
                        )
            except Exception as e:
                return Response(
                    message=f"Webhook error: {e}",
                    break_loop=False
                )
```

**Use Cases:**
- Notify Slack when tasks complete
- Trigger GitHub Actions
- Send alerts to monitoring systems
- Integrate with Zapier/IFTTT

---

### Tool 8: Cloud Sync Tool

**File:** `python/tools/cloud_sync.py`

**Purpose:** Cloud-based agent state synchronization

**Methods:**
- `cloud_sync:upload` - Upload state to cloud
- `cloud_sync:download` - Download state from cloud
- `cloud_sync:auto_sync` - Enable automatic sync
- `cloud_sync:list_backups` - List cloud backups
- `cloud_sync:restore` - Restore from cloud backup

**Implementation Sketch:**
```python
from python.helpers.tool import Tool, Response
import boto3  # AWS S3
import json

class CloudSyncTool(Tool):
    async def execute(self, **kwargs) -> Response:
        if self.method == "upload":
            return await self.upload_to_cloud()
        elif self.method == "download":
            return await self.download_from_cloud()
        elif self.method == "auto_sync":
            return await self.enable_auto_sync()
        # ... other methods

    async def upload_to_cloud(self) -> Response:
        provider = self.args.get("provider", "s3")  # s3/gcs/azure
        bucket = self.args.get("bucket", "pareng-boyong-backups")

        # Prepare state data
        state_data = {
            "timestamp": datetime.utcnow().isoformat(),
            "context_id": self.agent.context.id,
            "history": self.agent.history,
            "data": self.agent.data,
            "agent_name": self.agent.agent_name
        }

        # Upload to S3
        if provider == "s3":
            s3 = boto3.client('s3')
            key = f"backups/{self.agent.context.id}/{datetime.utcnow().isoformat()}.json"

            s3.put_object(
                Bucket=bucket,
                Key=key,
                Body=json.dumps(state_data),
                ContentType='application/json'
            )

            return Response(
                message=f"Uploaded to cloud: s3://{bucket}/{key}",
                break_loop=False
            )

        return Response(
            message=f"Unsupported provider: {provider}",
            break_loop=False
        )

    async def download_from_cloud(self) -> Response:
        provider = self.args.get("provider", "s3")
        bucket = self.args.get("bucket", "")
        key = self.args.get("key", "")

        # Download from S3
        if provider == "s3":
            s3 = boto3.client('s3')
            obj = s3.get_object(Bucket=bucket, Key=key)
            state_data = json.loads(obj['Body'].read())

            # Restore state
            self.agent.context.id = state_data["context_id"]
            self.agent.history = state_data["history"]
            self.agent.data = state_data["data"]

            return Response(
                message=f"Restored from cloud: s3://{bucket}/{key}",
                break_loop=False
            )
```

**Use Cases:**
- Backup agent state to S3/GCS/Azure
- Sync across multiple VPS instances
- Disaster recovery
- Cross-region replication

---

## Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)

**Goals:** Core infrastructure for remote capabilities

**Tasks:**
1. ✅ Set up PostgreSQL database for session management
2. ✅ Set up Redis for real-time state caching
3. ✅ Implement WebSocket server in Flask
4. ✅ Create base database models (sessions, devices, webhooks)
5. ✅ Implement authentication middleware
6. ✅ Create API v2 endpoints structure

**Deliverables:**
- PostgreSQL schema
- Redis configuration
- WebSocket infrastructure
- API v2 framework

---

### Phase 2: Native Tools (Weeks 3-4)

**Goals:** Implement 8 native tools

**Tasks:**
1. ✅ Implement `mcp_manager` tool
2. ✅ Implement `remote_session` tool
3. ✅ Implement `realtime_sync` tool
4. ✅ Implement `mobile_command` tool
5. ✅ Implement `session_recovery` tool
6. ✅ Implement `device_registry` tool
7. ✅ Implement `webhook` tool
8. ✅ Implement `cloud_sync` tool

**Deliverables:**
- 8 new tool files (`python/tools/*.py`)
- 8 new prompt files (`prompts/agent.system.tool.*.md`)
- Unit tests for each tool
- Integration tests

---

### Phase 3: Mobile Integration (Weeks 5-6)

**Goals:** Mobile-first experience

**Tasks:**
1. ✅ Create Progressive Web App (PWA)
2. ✅ Implement push notification service
3. ✅ Add service worker for offline support
4. ✅ Create mobile-optimized UI components
5. ✅ Implement voice input support
6. ✅ Add quick action shortcuts
7. ✅ Test on iOS and Android

**Deliverables:**
- PWA with offline support
- Push notification system
- Mobile-optimized interface
- Voice command support

---

### Phase 4: Enhanced MCP (Week 7)

**Goals:** Rich MCP integration

**Tasks:**
1. ✅ Enhance MCP server to expose all tools
2. ✅ Implement MCP tool discovery
3. ✅ Add MCP tool versioning
4. ✅ Create MCP SDK for external clients
5. ✅ Integrate with Claude Code CLI as example

**Deliverables:**
- Enhanced MCP server
- Tool discovery mechanism
- MCP SDK documentation
- Claude Code CLI integration guide

---

### Phase 5: Production Deployment (Week 8)

**Goals:** Deploy to production VPS

**Tasks:**
1. ✅ Update Docker configuration
2. ✅ Configure Nginx for WebSocket
3. ✅ Set up PostgreSQL and Redis
4. ✅ Migrate existing data
5. ✅ Load test and optimize
6. ✅ Create backup procedures
7. ✅ Deploy to ai.innovatehub.site

**Deliverables:**
- Production deployment
- Load testing results
- Backup/recovery procedures
- Monitoring dashboards

---

## Use Cases & Benefits

### Use Case 1: Remote Team Collaboration

**Scenario:** Development team uses Pareng Boyong for code review

**Flow:**
1. Developer starts code review session on laptop
2. Creates shared session with `remote_session:create`
3. Shares session ID with team
4. Team members join from mobile/desktop with `remote_session:resume`
5. All see real-time updates via `realtime_sync:broadcast`
6. Comments and changes visible to all instantly

**Benefits:**
- Real-time collaboration
- Cross-device accessibility
- Persistent session history
- Mobile participation

---

### Use Case 2: Mobile Task Monitoring

**Scenario:** Manager monitors long-running data processing task

**Flow:**
1. Start data processing task on desktop
2. Leave office, switch to mobile
3. Use `mobile_command:quick_action` for "status" updates
4. Receive push notifications for milestones
5. Review mobile-formatted progress summaries
6. Send voice commands if adjustments needed

**Benefits:**
- Stay informed on the go
- Quick status checks
- No need to return to desktop
- Voice control while busy

---

### Use Case 3: Multi-Region Deployment

**Scenario:** Company runs Pareng Boyong in multiple regions

**Flow:**
1. Deploy instances in US, EU, Asia regions
2. Connect all via `mcp_manager:register_server`
3. Share tools across regions
4. Use `cloud_sync:auto_sync` for state replication
5. Failover automatically if one region goes down

**Benefits:**
- Global availability
- Disaster recovery
- Cross-region tool sharing
- Low latency for all users

---

### Use Case 4: External Integration Pipeline

**Scenario:** Automate notifications to Slack and GitHub

**Flow:**
1. Create webhook with `webhook:create` for Slack
2. Create webhook for GitHub Actions
3. When task completes, agent triggers webhooks
4. Slack receives formatted notification
5. GitHub Action starts deployment pipeline

**Benefits:**
- No manual notifications
- Tight integration with existing tools
- Automated workflows
- Real-time team updates

---

### Use Case 5: Session Recovery After Crash

**Scenario:** Server restarts during long operation

**Flow:**
1. Agent auto-saves every 60s with `session_recovery:auto_save`
2. Server crashes during task
3. On restart, agent detects unsaved session
4. Automatically restores with `session_recovery:restore`
5. Continues from last checkpoint

**Benefits:**
- Zero data loss
- Seamless recovery
- No user intervention needed
- Reliable long-running tasks

---

## Technical Specifications

### Database Schema

#### Sessions Table

```sql
CREATE TABLE sessions (
    session_id UUID PRIMARY KEY,
    context_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    state VARCHAR(50) DEFAULT 'active',
    metadata JSONB
);

CREATE INDEX idx_sessions_user ON sessions(user_id);
CREATE INDEX idx_sessions_context ON sessions(context_id);
```

#### Devices Table

```sql
CREATE TABLE devices (
    device_id UUID PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    device_name VARCHAR(255) NOT NULL,
    device_type VARCHAR(50),
    device_token VARCHAR(255) UNIQUE NOT NULL,
    registered_at TIMESTAMP DEFAULT NOW(),
    last_seen TIMESTAMP DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'active',
    metadata JSONB
);

CREATE INDEX idx_devices_user ON devices(user_id);
CREATE INDEX idx_devices_token ON devices(device_token);
```

#### Webhooks Table

```sql
CREATE TABLE webhooks (
    webhook_id UUID PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    url VARCHAR(500) NOT NULL,
    event_type VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'active',
    metadata JSONB
);

CREATE INDEX idx_webhooks_user ON webhooks(user_id);
```

#### Checkpoints Table

```sql
CREATE TABLE checkpoints (
    checkpoint_id UUID PRIMARY KEY,
    session_id UUID REFERENCES sessions(session_id),
    checkpoint_name VARCHAR(255),
    checkpoint_data JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_checkpoints_session ON checkpoints(session_id);
```

---

### Redis Data Structures

```
# Active sessions
sessions:{session_id} -> {session_data}

# Device connections
devices:{device_id}:connection -> {connection_info}

# Real-time state
state:{context_id} -> {current_state}

# WebSocket subscriptions
subscriptions:{context_id} -> [device_id1, device_id2, ...]

# Rate limiting
ratelimit:{user_id}:{endpoint} -> counter

# Cache
cache:{key} -> {value}
```

---

### WebSocket Protocol

#### Client → Server Messages

```json
// Subscribe to context updates
{
    "action": "subscribe",
    "context_id": "abc123",
    "device_id": "device456"
}

// Unsubscribe
{
    "action": "unsubscribe",
    "context_id": "abc123"
}

// Send command
{
    "action": "command",
    "context_id": "abc123",
    "command": "List all running tasks"
}

// Heartbeat
{
    "action": "ping"
}
```

#### Server → Client Messages

```json
// Agent message update
{
    "type": "agent_message",
    "context_id": "abc123",
    "agent_name": "Pareng Boyong",
    "content": "I'm working on your request...",
    "timestamp": "2026-01-13T10:00:00Z"
}

// Tool execution update
{
    "type": "tool_execution",
    "context_id": "abc123",
    "tool_name": "code_execution_tool",
    "status": "running",
    "progress": "50%",
    "timestamp": "2026-01-13T10:00:01Z"
}

// Session state change
{
    "type": "session_state",
    "session_id": "xyz789",
    "state": "active",
    "devices_count": 3,
    "timestamp": "2026-01-13T10:00:02Z"
}

// Error
{
    "type": "error",
    "message": "Session not found",
    "code": "SESSION_NOT_FOUND"
}

// Heartbeat response
{
    "type": "pong"
}
```

---

## Security Considerations

### Authentication

**Multi-Layer Auth:**
1. **Basic Auth** (existing) - Username/password for Web UI
2. **API Keys** (new) - For programmatic access
3. **Device Tokens** (new) - For registered devices
4. **JWT Tokens** (new) - For session continuity

### Authorization

**Role-Based Access Control (RBAC):**
```python
roles = {
    "admin": {
        "can_manage_users": True,
        "can_manage_devices": True,
        "can_access_all_sessions": True,
        "can_manage_webhooks": True
    },
    "user": {
        "can_manage_own_devices": True,
        "can_access_own_sessions": True,
        "can_create_webhooks": True
    },
    "viewer": {
        "can_view_sessions": True
    }
}
```

### Encryption

**Data at Rest:**
- PostgreSQL: Encrypt sensitive columns (tokens, passwords)
- Redis: Enable TLS encryption
- File storage: Encrypt checkpoint files

**Data in Transit:**
- HTTPS/TLS for all API calls
- WSS (WebSocket Secure) for real-time connections
- MCP over TLS

### Rate Limiting

```python
# API endpoints
rate_limits = {
    "/api/v2/message": "60/minute",
    "/api/v2/session/create": "10/minute",
    "/api/v2/device/register": "5/minute",
    "/api/v2/webhook/trigger": "100/minute"
}

# WebSocket connections
ws_rate_limits = {
    "messages_per_second": 10,
    "max_connections_per_user": 5
}
```

### Input Validation

```python
# Example validation schema
message_schema = {
    "text": {
        "type": "string",
        "maxLength": 10000,
        "required": True
    },
    "context_id": {
        "type": "string",
        "pattern": "^[a-zA-Z0-9-]+$",
        "required": False
    }
}
```

---

## Mobile Integration Strategy

### Progressive Web App (PWA)

**Features:**
- Installable on iOS/Android home screen
- Offline functionality with service workers
- Push notification support
- Fast loading with caching
- Responsive design

**Implementation:**
```javascript
// service-worker.js
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open('pareng-boyong-v1').then((cache) => {
      return cache.addAll([
        '/',
        '/static/css/main.css',
        '/static/js/main.js',
        '/offline.html'
      ]);
    })
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      return response || fetch(event.request);
    })
  );
});

self.addEventListener('push', (event) => {
  const data = event.data.json();
  const options = {
    body: data.body,
    icon: '/static/images/icon.png',
    badge: '/static/images/badge.png'
  };
  event.waitUntil(
    self.registration.showNotification(data.title, options)
  );
});
```

### Push Notifications

**Architecture:**
```
Pareng Boyong Agent
    ↓ (task complete)
Push Notification Service (Firebase/OneSignal)
    ↓
APNs (iOS) / FCM (Android)
    ↓
Mobile Device
```

**Implementation:**
```python
# python/helpers/push_notifications.py
import requests

class PushNotificationService:
    def __init__(self, api_key):
        self.api_key = api_key
        self.base_url = "https://fcm.googleapis.com/fcm/send"

    async def send_notification(self, device_token, title, body):
        payload = {
            "to": device_token,
            "notification": {
                "title": title,
                "body": body,
                "click_action": "https://ai.innovatehub.site"
            },
            "data": {
                "context_id": self.context_id,
                "timestamp": datetime.utcnow().isoformat()
            }
        }

        headers = {
            "Authorization": f"key={self.api_key}",
            "Content-Type": "application/json"
        }

        response = requests.post(
            self.base_url,
            json=payload,
            headers=headers
        )

        return response.status_code == 200
```

### Voice Input Support

**Implementation:**
```javascript
// voice-input.js
class VoiceInput {
    constructor() {
        this.recognition = new webkitSpeechRecognition();
        this.recognition.continuous = false;
        this.recognition.interimResults = false;
        this.recognition.lang = 'en-US';
    }

    start() {
        this.recognition.start();

        this.recognition.onresult = (event) => {
            const transcript = event.results[0][0].transcript;
            this.sendCommand(transcript);
        };
    }

    async sendCommand(text) {
        const response = await fetch('/api/v2/mobile/command', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                command: text,
                device_type: 'mobile',
                input_type: 'voice'
            })
        });

        const result = await response.json();
        this.displayResponse(result);
    }
}
```

---

## Performance & Scalability

### Horizontal Scaling

**Load Balancer Configuration:**
```nginx
upstream pareng_boyong_backends {
    least_conn;
    server 10.0.1.10:50002;
    server 10.0.1.11:50002;
    server 10.0.1.12:50002;
}

server {
    listen 443 ssl http2;
    server_name ai.innovatehub.site;

    location / {
        proxy_pass http://pareng_boyong_backends;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### Caching Strategy

**Multi-Level Caching:**
1. **Browser Cache** - Static assets (CSS, JS, images)
2. **CDN Cache** - Global distribution of static content
3. **Redis Cache** - Session data, frequent queries
4. **Database Cache** - PostgreSQL query cache

### Performance Targets

| Metric | Target | Current |
|--------|--------|---------|
| API Response Time (p95) | < 200ms | ~150ms |
| WebSocket Latency | < 50ms | TBD |
| Session Recovery Time | < 5s | TBD |
| Concurrent Sessions | 1000+ | ~50 |
| Concurrent Devices | 5000+ | TBD |
| Message Throughput | 10,000/min | ~100/min |

### Monitoring & Observability

**Metrics to Track:**
- API endpoint latency
- WebSocket connection count
- Session creation/recovery rate
- Tool execution time
- Database query performance
- Redis hit rate
- Error rate by endpoint
- Device registration rate

**Tools:**
- **Prometheus** - Metrics collection
- **Grafana** - Visualization
- **Loki** - Log aggregation
- **Jaeger** - Distributed tracing

---

## Conclusion

This integration plan transforms Pareng Boyong into a **production-grade, multi-device AI agent platform** with:

✅ **8 Native Tools** for remote capabilities
✅ **Real-Time Synchronization** via WebSocket
✅ **Mobile-First Design** with PWA and push notifications
✅ **Session Continuity** with auto-recovery
✅ **Enhanced MCP** for external tool ecosystems
✅ **Cloud Sync** for disaster recovery
✅ **Multi-Device Support** with device registry
✅ **Webhook Integration** for external services

**Next Steps:**
1. Review and approve this plan
2. Set up development environment (PostgreSQL, Redis)
3. Begin Phase 1 implementation
4. Iterate based on testing and feedback

**Timeline:** 8 weeks to full production deployment

**Resources Needed:**
- PostgreSQL database
- Redis server
- Push notification service (Firebase/OneSignal)
- Cloud storage (S3/GCS) for backups
- Additional VPS instances for scaling (optional)

---

**Ready to revolutionize Pareng Boyong! 🚀**

**© 2026 InnovateHub - Pareng Boyong Project**
