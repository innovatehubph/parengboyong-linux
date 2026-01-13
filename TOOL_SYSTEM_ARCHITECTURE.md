# Tool System Architecture - Complete Guide

**Pareng Boyong / Agent Zero Tool System**
**Documentation Version:** 1.0
**Last Updated:** 2026-01-13

---

## Table of Contents

1. [Overview](#overview)
2. [Tool Storage & Organization](#tool-storage--organization)
3. [Base Tool Class Architecture](#base-tool-class-architecture)
4. [Tool Registration & Loading](#tool-registration--loading)
5. [Tool Configuration System](#tool-configuration-system)
6. [Tool Structure & Implementation](#tool-structure--implementation)
7. [Agent Context Integration](#agent-context-integration)
8. [Tool Execution Flow](#tool-execution-flow)
9. [Extension System Integration](#extension-system-integration)
10. [Creating New Tools](#creating-new-tools)
11. [Tool Testing Guidelines](#tool-testing-guidelines)
12. [Advanced Patterns](#advanced-patterns)

---

## Overview

The Pareng Boyong tool system is a flexible, extensible architecture that allows the AI agent to interact with external systems, execute code, manage memory, and perform various operations. Tools are the primary mechanism through which the agent takes actions in response to user requests.

### Key Features

- **Dynamic Loading**: Tools are loaded on-demand from multiple sources
- **Profile Support**: Agent-specific tool customization via profiles
- **MCP Integration**: External tool providers via Model Context Protocol
- **Lifecycle Hooks**: Pre/post execution hooks for extensions
- **Progress Tracking**: Real-time progress updates during execution
- **Method Variants**: Single tool can expose multiple operations
- **Error Handling**: Graceful fallback for missing/malformed tools

---

## Tool Storage & Organization

### Directory Structure

```
/root/parengboyong-linux/
├── python/tools/              # Default tools (18 total)
│   ├── response.py           # Final response to user
│   ├── code_execution_tool.py # Python/Node/Terminal execution
│   ├── memory_save.py        # Store to memory database
│   ├── memory_load.py        # Retrieve from memory
│   ├── memory_delete.py      # Delete memory entries
│   ├── memory_forget.py      # Forget by query
│   ├── document_query.py     # Query documents with LLM
│   ├── vision_load.py        # Load and encode images
│   ├── search_engine.py      # Web search
│   ├── browser_agent.py      # Playwright browser automation
│   ├── call_subordinate.py   # Delegate to subordinate agents
│   ├── scheduler.py          # Task scheduling
│   ├── notify_user.py        # User notifications
│   ├── wait.py               # Pause/delay execution
│   ├── input.py              # Keyboard input forwarding
│   ├── behaviour_adjustment.py # Update agent behavior
│   ├── a2a_chat.py           # Agent-to-agent communication
│   └── unknown.py            # Error handler for missing tools
│
├── agents/{profile}/tools/   # Profile-specific tools (optional)
│   └── custom_tool.py        # Custom tool for specific agent
│
└── prompts/
    ├── agent.system.tool.*.md # Tool descriptions for LLM
    └── agent.system.tools.py  # Tool list generator
```

### All Available Tools

| Tool Name | File | Purpose | Method Support |
|-----------|------|---------|----------------|
| `response` | response.py | Final response to user | No |
| `code_execution_tool` | code_execution_tool.py | Execute code (Python/Node/Terminal) | No |
| `memory_save` | memory_save.py | Save information to memory | No |
| `memory_load` | memory_load.py | Load from memory by query | No |
| `memory_delete` | memory_delete.py | Delete specific memory | No |
| `memory_forget` | memory_forget.py | Forget memories matching query | No |
| `document_query` | document_query.py | Query document contents | No |
| `vision_load` | vision_load.py | Load and analyze images | No |
| `search_engine` | search_engine.py | Perform web searches | No |
| `browser_agent` | browser_agent.py | Automate browser actions | No |
| `call_subordinate` | call_subordinate.py | Delegate to subordinate agent | No |
| `scheduler` | scheduler.py | Manage scheduled tasks | **Yes** (6 methods) |
| `notify_user` | notify_user.py | Send notifications | No |
| `wait` | wait.py | Pause execution | No |
| `input` | input.py | Get keyboard input | No |
| `behaviour_adjustment` | behaviour_adjustment.py | Adjust agent behavior | No |
| `a2a_chat` | a2a_chat.py | Agent-to-agent messaging | No |
| `unknown` | unknown.py | Handle missing tools | No |

---

## Base Tool Class Architecture

### Location

**File:** `/root/parengboyong-linux/python/helpers/tool.py`

### Core Classes

#### 1. Response Dataclass

```python
from dataclasses import dataclass
from typing import Any

@dataclass
class Response:
    message: str              # Result message to add to history
    break_loop: bool          # Whether to end message loop
    additional: dict[str, Any] | None = None  # Extra data
```

**Usage:**
- `break_loop=True`: Ends message loop, returns to user (e.g., `response` tool)
- `break_loop=False`: Continues loop, agent can use result (e.g., `memory_load`)

#### 2. Tool Base Class

```python
class Tool:
    def __init__(
        self,
        agent: Agent,
        name: str,
        method: str | None,
        args: dict[str, str],
        message: str,
        loop_data: LoopData | None,
        **kwargs
    ) -> None:
        self.agent = agent              # Reference to Agent instance
        self.name = name                # Tool identifier (e.g., "memory_save")
        self.method = method            # Optional method (e.g., "list_tasks")
        self.args = args                # Arguments from LLM
        self.message = message          # Original LLM JSON message
        self.loop_data = loop_data      # Message loop context
        self.progress = None            # Progress tracking object
        self.log = None                 # Log entry object
```

### Abstract Methods

```python
async def execute(self, **kwargs) -> Response:
    """MUST be implemented by all tools"""
    raise NotImplementedError("Tool must implement execute method")
```

### Lifecycle Methods

```python
async def before_execution(self, **kwargs) -> None:
    """Called before execute() - logs tool usage by default"""

async def after_execution(self, response: Response, **kwargs) -> None:
    """Called after execute() - adds result to history by default"""
```

### Utility Methods

```python
def set_progress(self, content: str | None) -> None:
    """Set/update progress message"""

def add_progress(self, content: str | None) -> None:
    """Append to progress message"""

def get_log_object(self):
    """Create/return log entry (override for custom logging)"""

def nice_key(self, key: str) -> str:
    """Format argument key for display"""
```

---

## Tool Registration & Loading

### Loading Priority Order

```
1. MCP Tools (Model Context Protocol servers)
   ↓
2. Profile-Specific Tools (agents/{profile}/tools/{name}.py)
   ↓
3. Default Tools (python/tools/{name}.py)
   ↓
4. Unknown Tool (python/tools/unknown.py)
```

### Tool Retrieval Process

**Location:** `agent.py` lines 908-936

```python
def get_tool(self, tool_name: str, tool_method: str | None, **kwargs) -> Tool:
    # 1. Try MCP first
    mcp_tool = mcp_helper.MCPConfig.get_instance().get_tool(
        self, tool_name, method=tool_method, **kwargs
    )
    if mcp_tool:
        return mcp_tool

    # 2. Try profile-specific tools
    if self.config.profile:
        classes = extract_tools.load_classes_from_file(
            f"agents/{self.config.profile}/tools/{tool_name}.py", Tool
        )

    # 3. Try default tools
    if not classes:
        classes = extract_tools.load_classes_from_file(
            f"python/tools/{tool_name}.py", Tool
        )

    # 4. Fallback to Unknown tool
    if not classes:
        classes = extract_tools.load_classes_from_file(
            f"python/tools/unknown.py", Tool
        )

    # Instantiate and return
    tool_class = classes[0]
    return tool_class(
        agent=self,
        name=tool_name,
        method=tool_method,
        **kwargs
    )
```

### Dynamic Loading Helper

**File:** `/root/parengboyong-linux/python/helpers/extract_tools.py`

```python
def load_classes_from_file(file: str, base_class: type[T]) -> list[type[T]]:
    """
    Dynamically load Python classes from a file.

    Args:
        file: Path relative to project root (e.g., "python/tools/memory_save.py")
        base_class: Parent class to filter for (e.g., Tool)

    Returns:
        List of matching classes
    """
    # Uses importlib.util to load module
    # Inspects module for subclasses of base_class
    # Returns matching classes
```

---

## Tool Configuration System

### Prompt-Based Configuration

Each tool has a corresponding prompt file that describes it to the LLM.

**Pattern:** `/root/parengboyong-linux/prompts/agent.system.tool.{name}.md`

**Example - Response Tool:**

```markdown
# prompts/agent.system.tool.response.md

## response
Ends task and returns to the user.
**Use this tool as final response to the user.**

Arguments:
- **text** - Final response to the user.
```

### Tool List Generation

**File:** `/root/parengboyong-linux/prompts/agent.system.tools.py`

```python
from python.helpers import files
import os, glob

def execute(agent):
    # Scan for all agent.system.tool.*.md files
    tools_dir = files.get_abs_path("prompts")
    pattern = os.path.join(tools_dir, "agent.system.tool.*.md")
    tool_files = glob.glob(pattern)

    # Concatenate all tool descriptions
    tool_descriptions = []
    for file in tool_files:
        content = files.read_file(file)
        tool_descriptions.append(content)

    tools_text = "\n\n".join(tool_descriptions)

    return {"tools": tools_text}
```

### System Prompt Integration

**File:** `/root/parengboyong-linux/python/extensions/system_prompt/_10_system_prompt.py`

```python
async def execute(self):
    # ... other system prompt parts ...

    # Add tools section
    tools_prompt = get_tools_prompt(self.agent)
    system_parts.append(tools_prompt)

    # Add MCP tools
    mcp_tools_prompt = get_mcp_tools_prompt(self.agent)
    if mcp_tools_prompt:
        system_parts.append(mcp_tools_prompt)

    return "\n\n".join(system_parts)
```

### Enabling/Disabling Tools

**Method 1 - Remove Prompt File:**
```bash
# Disable a tool by removing its prompt
rm /root/parengboyong-linux/prompts/agent.system.tool.browser.md
```

**Method 2 - Profile Override:**
```python
# Create profile with limited tools
mkdir -p agents/restricted/tools/
# Only include specific tools in profile
```

**Method 3 - Extension Filtering:**
```python
# Create extension to filter tools in tool_execute_before hook
# Check tool_name and raise exception to block
```

---

## Tool Structure & Implementation

### Minimal Tool Template

```python
from python.helpers.tool import Tool, Response

class MyTool(Tool):
    async def execute(self, **kwargs) -> Response:
        # Get arguments (with defaults)
        my_arg = self.args.get("my_arg", "")

        # Do work
        result = f"Processed: {my_arg}"

        # Return response
        return Response(
            message=result,
            break_loop=False
        )
```

### Tool with Progress Tracking

```python
from python.helpers.tool import Tool, Response

class LongRunningTool(Tool):
    async def execute(self, **kwargs) -> Response:
        # Initialize progress
        self.set_progress("Starting operation...")

        # Step 1
        await self.step_1()
        self.add_progress("Step 1 complete (33%)")

        # Step 2
        await self.step_2()
        self.add_progress("Step 2 complete (66%)")

        # Step 3
        result = await self.step_3()
        self.add_progress("Step 3 complete (100%)")

        return Response(message=result, break_loop=False)
```

### Tool with Multiple Methods

```python
from python.helpers.tool import Tool, Response

class SchedulerTool(Tool):
    async def execute(self, **kwargs) -> Response:
        # Route to method handler
        if self.method == "list_tasks":
            return await self.list_tasks(**kwargs)
        elif self.method == "create_scheduled_task":
            return await self.create_scheduled_task(**kwargs)
        elif self.method == "delete_scheduled_task":
            return await self.delete_scheduled_task(**kwargs)
        else:
            return Response(
                message=f"Unknown method: {self.method}",
                break_loop=False
            )

    async def list_tasks(self, **kwargs) -> Response:
        # Implementation
        pass

    async def create_scheduled_task(self, **kwargs) -> Response:
        # Implementation
        pass

    async def delete_scheduled_task(self, **kwargs) -> Response:
        # Implementation
        pass
```

**LLM Usage:**
```json
{
    "tool_name": "scheduler:list_tasks",
    "tool_args": {}
}
```

### Tool with Custom Lifecycle

```python
from python.helpers.tool import Tool, Response

class CustomLifecycleTool(Tool):
    async def before_execution(self, **kwargs) -> None:
        # Custom pre-execution logic
        self.agent.context.log.log(
            type="info",
            content=f"Preparing to execute {self.name}"
        )
        # Note: NOT calling super() to skip default behavior

    async def execute(self, **kwargs) -> Response:
        result = "Execution complete"
        return Response(message=result, break_loop=False)

    async def after_execution(self, response: Response, **kwargs) -> None:
        # Custom post-execution logic
        # Add to history in custom format
        self.agent.history.append({
            "role": "tool_result",
            "content": f"Custom format: {response.message}"
        })
        # Note: NOT calling super() to skip default behavior
```

### Tool with Custom Logging

```python
from python.helpers.tool import Tool, Response

class CustomLogTool(Tool):
    def get_log_object(self):
        # Override default log entry creation
        return self.agent.context.log.log(
            type="tool",
            heading=f"🔧 {self.name.upper()}",
            content="Executing...",
            kvps={
                "arg1": self.args.get("arg1", "N/A"),
                "arg2": self.args.get("arg2", "N/A")
            }
        )

    async def execute(self, **kwargs) -> Response:
        result = "Custom log format applied"
        return Response(message=result, break_loop=False)
```

---

## Agent Context Integration

### Accessing Agent Properties

```python
class ContextAwareTool(Tool):
    async def execute(self, **kwargs) -> Response:
        # Access agent configuration
        model_name = self.agent.config.chat_model
        temperature = self.agent.config.chat_temperature

        # Access agent context
        context_id = self.agent.context.id
        context_log = self.agent.context.log

        # Access agent number/name
        agent_number = self.agent.number
        agent_name = self.agent.agent_name

        # Access shared data
        custom_data = self.agent.get_data("custom_key")
        self.agent.set_data("result_key", "value")

        # Access history
        history = self.agent.history

        # Read prompt templates
        prompt = self.agent.read_prompt(
            "custom_prompt.md",
            variable1="value1",
            variable2="value2"
        )

        return Response(message="Context accessed", break_loop=False)
```

### Accessing Loop Data

```python
class LoopAwareTool(Tool):
    async def execute(self, **kwargs) -> Response:
        if not self.loop_data:
            return Response(message="No loop data", break_loop=False)

        # Current iteration
        iteration = self.loop_data.iteration

        # User message that started this loop
        user_msg = self.loop_data.user_message

        # System prompts in effect
        system_prompts = self.loop_data.system

        # History for this loop
        history_output = self.loop_data.history_output

        # Temporary/persistent extras
        temp_extras = self.loop_data.extras_temporary
        persist_extras = self.loop_data.extras_persistent

        # Last response from LLM
        last_response = self.loop_data.last_response

        return Response(
            message=f"Loop iteration: {iteration}",
            break_loop=False
        )
```

### Handling User Intervention

```python
class InterventionAwareTool(Tool):
    async def execute(self, **kwargs) -> Response:
        # Check for user intervention (pause/stop requests)
        # Raises exception if intervention detected
        await self.agent.handle_intervention()

        # Long operation
        for i in range(10):
            await asyncio.sleep(1)
            self.add_progress(f"Step {i+1}/10")

            # Check again during long operation
            await self.agent.handle_intervention()

        return Response(message="Completed", break_loop=False)
```

### Creating Subordinate Agents

```python
from agent import Agent, AgentConfig

class DelegationTool(Tool):
    async def execute(self, **kwargs) -> Response:
        task = self.args.get("task", "")

        # Create subordinate agent config
        sub_config = self.agent.config.clone()
        sub_config.max_iterations = 10

        # Create subordinate agent
        subordinate = Agent(
            number=self.agent.number + 1,
            config=sub_config,
            context=self.agent.context
        )

        # Link to superior
        subordinate.set_data(Agent.DATA_NAME_SUPERIOR, self.agent)

        # Inject task
        from agent import UserMessage
        subordinate.context.communicate(UserMessage(task))

        # Execute
        result = await subordinate.monologue()

        return Response(
            message=f"Subordinate completed: {result}",
            break_loop=False
        )
```

---

## Tool Execution Flow

### Complete Lifecycle Diagram

```
┌─────────────────────────────────────────────────┐
│          AGENT MESSAGE LOOP                     │
│       (agent.py monologue())                    │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│     LLM GENERATES TOOL CALL                     │
│  {"tool_name": "memory_save",                   │
│   "tool_args": {"query": "...", "data": "..."}} │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│     PARSE TOOL REQUEST                          │
│  - Extract JSON via json_parse_dirty()          │
│  - Split "tool_name:method" if present          │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│     RETRIEVE TOOL                               │
│  1. Try MCP tools                               │
│  2. Try agents/{profile}/tools/{name}.py        │
│  3. Try python/tools/{name}.py                  │
│  4. Fallback to unknown.py                      │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│     INSTANTIATE TOOL                            │
│  tool = ToolClass(                              │
│      agent=self,                                │
│      name=tool_name,                            │
│      method=tool_method,                        │
│      args=tool_args,                            │
│      message=message,                           │
│      loop_data=loop_data                        │
│  )                                              │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│     SET CURRENT TOOL                            │
│  self.loop_data.current_tool = tool             │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│     BEFORE EXECUTION                            │
│  - await tool.before_execution(**tool_args)     │
│  - Logs tool usage by default                   │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│     EXTENSION HOOK: tool_execute_before         │
│  - Extensions can preprocess args               │
│  - Unmask secrets                               │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│     CHECK INTERVENTION                          │
│  await self.handle_intervention()               │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│     EXECUTE TOOL                                │
│  response = await tool.execute(**tool_args)     │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│     EXTENSION HOOK: tool_execute_after          │
│  - Extensions can postprocess response          │
│  - Mask secrets                                 │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│     AFTER EXECUTION                             │
│  - await tool.after_execution(response)         │
│  - Adds result to history by default            │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│     CHECK INTERVENTION                          │
│  await self.handle_intervention()               │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
        ┌────────┴────────┐
        │                 │
        ▼                 ▼
┌──────────────┐  ┌──────────────┐
│ break_loop   │  │ break_loop   │
│ = True       │  │ = False      │
└──────┬───────┘  └──────┬───────┘
       │                 │
       ▼                 ▼
┌──────────────┐  ┌──────────────┐
│ Return to    │  │ Continue     │
│ User         │  │ Loop         │
└──────────────┘  └──────────────┘
```

### Code Flow

**Location:** `agent.py` lines 799-882

```python
async def process_tools(self, msg: str) -> str | None:
    # Parse tool call from LLM response
    tool_request = extract_tools.json_parse_dirty(msg)
    tool_name = tool_request.get("tool_name", "")
    tool_args = tool_request.get("tool_args", {})

    # Split method if present
    parts = tool_name.split(":")
    name = parts[0]
    method = parts[1] if len(parts) > 1 else None

    # Get tool instance
    tool = self.get_tool(
        tool_name=name,
        tool_method=method,
        args=tool_args,
        message=msg,
        loop_data=self.loop_data
    )

    # Set as current tool
    self.loop_data.current_tool = tool

    # Pre-execution
    await tool.before_execution(**tool_args)

    # Extension hook
    await self.call_extensions(
        "tool_execute_before",
        tool_args=tool_args,
        tool_name=tool_name
    )

    # Check intervention
    await self.handle_intervention()

    # Execute
    response = await tool.execute(**tool_args)

    # Extension hook
    await self.call_extensions(
        "tool_execute_after",
        response=response,
        tool_name=tool_name
    )

    # Post-execution
    await tool.after_execution(response)

    # Check intervention
    await self.handle_intervention()

    # Handle response
    if response.break_loop:
        return response.message  # End loop
    else:
        return None  # Continue loop
```

---

## Extension System Integration

### Available Extension Hooks

| Hook | Location | Purpose |
|------|----------|---------|
| `tool_execute_before` | Before tool.execute() | Preprocess arguments, unmask secrets |
| `tool_execute_after` | After tool.execute() | Postprocess response, mask secrets |
| `hist_add_tool_result` | When adding to history | Modify history entry |

### Extension Implementation Example

**File:** `/root/parengboyong-linux/python/extensions/tool_execute_before/unmask_secrets.py`

```python
from python.helpers.extension import Extension

class UnmaskSecrets(Extension):
    async def execute(self, tool_args: dict, tool_name: str, **kwargs):
        # Get secrets manager
        secrets = self.agent.context.secrets

        # Unmask all arguments
        for key, value in tool_args.items():
            if isinstance(value, str):
                tool_args[key] = secrets.unmask_secret(value)

        # Extensions modify data in-place
        # No return value needed
```

**File:** `/root/parengboyong-linux/python/extensions/tool_execute_after/mask_secrets.py`

```python
from python.helpers.extension import Extension

class MaskSecrets(Extension):
    async def execute(self, response, tool_name: str, **kwargs):
        # Get secrets manager
        secrets = self.agent.context.secrets

        # Mask secrets in response message
        if hasattr(response, 'message'):
            response.message = secrets.mask_secret(response.message)

        # Mask in additional data
        if hasattr(response, 'additional') and response.additional:
            for key, value in response.additional.items():
                if isinstance(value, str):
                    response.additional[key] = secrets.mask_secret(value)
```

### Registering Extensions

Extensions are auto-discovered from:
- `/root/parengboyong-linux/python/extensions/{hook_name}/*.py`

Example directory structure:
```
python/extensions/
├── tool_execute_before/
│   ├── unmask_secrets.py
│   └── validate_args.py
├── tool_execute_after/
│   ├── mask_secrets.py
│   └── log_metrics.py
└── hist_add_tool_result/
    └── format_result.py
```

---

## Creating New Tools

### Step-by-Step Guide

#### Step 1: Create Tool File

**File:** `/root/parengboyong-linux/python/tools/mytool.py`

```python
from python.helpers.tool import Tool, Response
from python.helpers import files
import asyncio

class MyTool(Tool):
    """
    Description of what this tool does.
    """

    async def execute(self, **kwargs) -> Response:
        # Get arguments with defaults
        arg1 = self.args.get("arg1", "")
        arg2 = self.args.get("arg2", 0)

        # Validate arguments
        if not arg1:
            return Response(
                message="Error: arg1 is required",
                break_loop=False
            )

        # Set initial progress
        self.set_progress("Starting mytool...")

        # Check for intervention
        await self.agent.handle_intervention()

        # Do work (example)
        result = f"Processed {arg1} with value {arg2}"

        # Update progress
        self.add_progress("Work complete")

        # Return response
        return Response(
            message=result,
            break_loop=False
        )
```

#### Step 2: Create Tool Prompt

**File:** `/root/parengboyong-linux/prompts/agent.system.tool.mytool.md`

```markdown
## mytool
Brief description of what this tool does (1-2 sentences).

Arguments:
- **arg1** (string, required) - Description of arg1
- **arg2** (integer, optional) - Description of arg2, defaults to 0

Example:
```json
{
    "thoughts": [
        "I need to use mytool to accomplish X"
    ],
    "tool_name": "mytool",
    "tool_args": {
        "arg1": "example value",
        "arg2": 42
    }
}
```
```

#### Step 3: Test Tool

```bash
# Restart Docker container to load new tool
docker restart pareng-boyong

# Test via web interface or API
curl -X POST http://localhost:50002/api/message \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Please use mytool with arg1='test' and arg2=10",
    "context": ""
  }'
```

#### Step 4: Verify in Logs

```bash
# Check logs for tool execution
docker logs -f pareng-boyong | grep "mytool"
```

---

## Tool Testing Guidelines

### Test Coverage Checklist

- [ ] **Argument Validation**: Test with missing/invalid arguments
- [ ] **Success Case**: Test with valid arguments
- [ ] **Error Handling**: Test error scenarios
- [ ] **Progress Tracking**: Verify progress updates appear
- [ ] **Intervention**: Test pause/stop during execution
- [ ] **Return Value**: Verify response message and break_loop flag
- [ ] **History Integration**: Check result appears in conversation history
- [ ] **Logging**: Verify tool execution is logged correctly
- [ ] **Extension Hooks**: Test with extensions enabled/disabled
- [ ] **Performance**: Test with large inputs/long operations

### Manual Test Script

```python
# test_mytool.py
import asyncio
from agent import Agent, AgentConfig, AgentContext, UserMessage

async def test_mytool():
    # Create test agent
    config = AgentConfig()
    context = AgentContext()
    agent = Agent(0, config, context)

    # Create tool instance
    from python.tools.mytool import MyTool
    tool = MyTool(
        agent=agent,
        name="mytool",
        method=None,
        args={"arg1": "test", "arg2": 10},
        message="",
        loop_data=None
    )

    # Execute
    response = await tool.execute()

    # Verify
    assert response.message is not None
    assert response.break_loop == False
    print(f"✅ Test passed: {response.message}")

if __name__ == "__main__":
    asyncio.run(test_mytool())
```

### Automated Test Example

```python
# tests/test_tools.py
import pytest
from agent import Agent, AgentConfig, AgentContext

@pytest.mark.asyncio
async def test_mytool_success():
    # Setup
    config = AgentConfig()
    context = AgentContext()
    agent = Agent(0, config, context)

    from python.tools.mytool import MyTool
    tool = MyTool(
        agent=agent,
        name="mytool",
        method=None,
        args={"arg1": "test", "arg2": 10},
        message="",
        loop_data=None
    )

    # Execute
    response = await tool.execute()

    # Assert
    assert "Processed test with value 10" in response.message
    assert response.break_loop == False

@pytest.mark.asyncio
async def test_mytool_missing_arg():
    # Setup
    config = AgentConfig()
    context = AgentContext()
    agent = Agent(0, config, context)

    from python.tools.mytool import MyTool
    tool = MyTool(
        agent=agent,
        name="mytool",
        method=None,
        args={},  # Missing arg1
        message="",
        loop_data=None
    )

    # Execute
    response = await tool.execute()

    # Assert
    assert "Error: arg1 is required" in response.message
```

---

## Advanced Patterns

### Pattern 1: Streaming Results

```python
class StreamingTool(Tool):
    async def execute(self, **kwargs) -> Response:
        query = self.args.get("query", "")

        # Stream results
        accumulated = ""
        async for chunk in self.stream_api_call(query):
            accumulated += chunk
            self.set_progress(accumulated)
            await self.agent.handle_intervention()

        return Response(message=accumulated, break_loop=False)

    async def stream_api_call(self, query: str):
        # Simulated streaming API
        words = query.split()
        for word in words:
            await asyncio.sleep(0.1)
            yield word + " "
```

### Pattern 2: Multi-Step Tool with Rollback

```python
class TransactionalTool(Tool):
    async def execute(self, **kwargs) -> Response:
        actions_taken = []

        try:
            # Step 1
            self.set_progress("Step 1...")
            await self.step_1()
            actions_taken.append("step_1")

            # Step 2
            self.add_progress("Step 2...")
            await self.step_2()
            actions_taken.append("step_2")

            # Step 3
            self.add_progress("Step 3...")
            await self.step_3()
            actions_taken.append("step_3")

            return Response(message="All steps completed", break_loop=False)

        except Exception as e:
            # Rollback
            self.add_progress(f"Error: {e}. Rolling back...")
            await self.rollback(actions_taken)
            return Response(message=f"Failed: {e}", break_loop=False)

    async def rollback(self, actions: list[str]):
        for action in reversed(actions):
            await self.undo_action(action)
```

### Pattern 3: Caching Tool Results

```python
class CachedTool(Tool):
    _cache = {}  # Class-level cache

    async def execute(self, **kwargs) -> Response:
        query = self.args.get("query", "")

        # Check cache
        cache_key = f"{self.name}:{query}"
        if cache_key in self._cache:
            self.set_progress("Retrieved from cache")
            return Response(
                message=self._cache[cache_key],
                break_loop=False
            )

        # Compute result
        self.set_progress("Computing...")
        result = await self.expensive_operation(query)

        # Store in cache
        self._cache[cache_key] = result

        return Response(message=result, break_loop=False)
```

### Pattern 4: Tool with File I/O

```python
from python.helpers import files

class FileProcessingTool(Tool):
    async def execute(self, **kwargs) -> Response:
        file_path = self.args.get("file_path", "")

        # Validate file exists
        if not files.exists(file_path):
            return Response(
                message=f"File not found: {file_path}",
                break_loop=False
            )

        # Read file
        self.set_progress("Reading file...")
        content = files.read_file(file_path)

        # Process content
        self.add_progress("Processing...")
        processed = await self.process_content(content)

        # Write result
        self.add_progress("Writing result...")
        output_path = file_path + ".processed"
        files.write_file(output_path, processed)

        return Response(
            message=f"Processed and saved to {output_path}",
            break_loop=False
        )
```

### Pattern 5: Tool with Agent Data Sharing

```python
class DataSharingTool(Tool):
    async def execute(self, **kwargs) -> Response:
        key = self.args.get("key", "")
        value = self.args.get("value", "")
        action = self.args.get("action", "set")  # set/get/delete

        if action == "set":
            # Store data accessible to all agents in this context
            self.agent.set_data(key, value)
            return Response(
                message=f"Stored {key} = {value}",
                break_loop=False
            )

        elif action == "get":
            # Retrieve data
            stored_value = self.agent.get_data(key)
            return Response(
                message=f"{key} = {stored_value}",
                break_loop=False
            )

        elif action == "delete":
            # Delete data
            self.agent.del_data(key)
            return Response(
                message=f"Deleted {key}",
                break_loop=False
            )
```

### Pattern 6: Conditional Break Loop

```python
class ConditionalResponseTool(Tool):
    async def execute(self, **kwargs) -> Response:
        message = self.args.get("message", "")
        final = self.args.get("final", "false").lower() == "true"

        # Add message to history
        self.agent.hist_add_message(role="assistant", content=message)

        # Only break loop if this is marked as final response
        return Response(
            message=message,
            break_loop=final
        )
```

---

## Key Files Reference

| File | Purpose | Lines of Interest |
|------|---------|-------------------|
| `python/helpers/tool.py` | Tool base class | All |
| `python/helpers/extract_tools.py` | Dynamic tool loading | All |
| `agent.py` | Tool retrieval & execution | 799-882, 908-936 |
| `python/helpers/mcp_handler.py` | MCP tool integration | All |
| `prompts/agent.system.tools.py` | Tool list generator | All |
| `python/extensions/system_prompt/_10_system_prompt.py` | System prompt building | Tool sections |
| `python/extensions/tool_execute_before/` | Pre-execution hooks | All |
| `python/extensions/tool_execute_after/` | Post-execution hooks | All |

---

## Summary

The Pareng Boyong tool system provides:

1. **Flexible Architecture**: Base class with lifecycle hooks
2. **Dynamic Loading**: Profile-specific and MCP integration
3. **Extensibility**: Extension hooks for preprocessing/postprocessing
4. **Progress Tracking**: Real-time updates during execution
5. **Error Handling**: Graceful fallbacks and unknown tool handler
6. **Method Variants**: Single tool, multiple operations
7. **Agent Integration**: Full access to agent context and capabilities

**Creating a new tool requires:**
- One Python file in `python/tools/`
- One Markdown file in `prompts/`
- Implementation of `execute()` method
- Testing and validation

**Best Practices:**
- Always validate arguments
- Use progress tracking for long operations
- Check for intervention in long loops
- Return meaningful error messages
- Override lifecycle methods only when needed
- Use extensions for cross-cutting concerns

---

**For Questions or Issues:**
- Check existing tool implementations in `python/tools/`
- Review tool prompts in `prompts/agent.system.tool.*.md`
- Test in isolation before deploying
- Monitor Docker logs for debugging

**Version History:**
- 1.0 (2026-01-13): Initial comprehensive documentation

---

**© 2026 InnovateHub - Pareng Boyong Project**
