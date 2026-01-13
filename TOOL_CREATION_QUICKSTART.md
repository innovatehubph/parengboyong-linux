# Tool Creation Quick Start Guide

**Fast reference for creating new tools in Pareng Boyong**

---

## 30-Second Overview

```
1. Create python/tools/mytool.py
2. Create prompts/agent.system.tool.mytool.md
3. Restart Docker container
4. Test via chat interface
```

---

## Minimal Working Example

### File 1: `python/tools/example.py`

```python
from python.helpers.tool import Tool, Response

class ExampleTool(Tool):
    async def execute(self, **kwargs) -> Response:
        # Get arguments
        text = self.args.get("text", "")

        # Do work
        result = f"You said: {text}"

        # Return
        return Response(message=result, break_loop=False)
```

### File 2: `prompts/agent.system.tool.example.md`

```markdown
## example
Simple example tool that echoes text back.

Arguments:
- **text** (string) - Text to echo back

Example:
{
    "tool_name": "example",
    "tool_args": {
        "text": "Hello world"
    }
}
```

### Deploy

```bash
docker restart pareng-boyong
```

---

## Common Patterns

### 1. Tool with Progress Updates

```python
class ProgressTool(Tool):
    async def execute(self, **kwargs) -> Response:
        self.set_progress("Step 1: Starting...")
        await step1()

        self.add_progress("Step 2: Processing...")
        await step2()

        self.add_progress("Step 3: Completing...")
        result = await step3()

        return Response(message=result, break_loop=False)
```

### 2. Tool with File Operations

```python
from python.helpers import files

class FileTool(Tool):
    async def execute(self, **kwargs) -> Response:
        path = self.args.get("file_path", "")

        # Read
        content = files.read_file(path)

        # Process
        processed = content.upper()

        # Write
        output = path + ".processed"
        files.write_file(output, processed)

        return Response(message=f"Saved to {output}", break_loop=False)
```

### 3. Tool with Multiple Methods

```python
class MultiMethodTool(Tool):
    async def execute(self, **kwargs) -> Response:
        if self.method == "action1":
            return await self.action1()
        elif self.method == "action2":
            return await self.action2()
        else:
            return Response(message="Unknown method", break_loop=False)

    async def action1(self) -> Response:
        return Response(message="Action 1 done", break_loop=False)

    async def action2(self) -> Response:
        return Response(message="Action 2 done", break_loop=False)
```

**LLM calls it as:**
```json
{"tool_name": "multimethodtool:action1", "tool_args": {}}
```

### 4. Tool with Validation

```python
class ValidatedTool(Tool):
    async def execute(self, **kwargs) -> Response:
        required = self.args.get("required_field", "")
        optional = self.args.get("optional_field", "default")

        # Validate
        if not required:
            return Response(
                message="Error: required_field is mandatory",
                break_loop=False
            )

        # Process
        result = f"Processed {required} with {optional}"
        return Response(message=result, break_loop=False)
```

### 5. Tool with External API Call

```python
import aiohttp

class APITool(Tool):
    async def execute(self, **kwargs) -> Response:
        query = self.args.get("query", "")

        self.set_progress("Calling API...")

        async with aiohttp.ClientSession() as session:
            async with session.get(
                "https://api.example.com/search",
                params={"q": query}
            ) as resp:
                data = await resp.json()

        self.add_progress("API call complete")

        return Response(message=str(data), break_loop=False)
```

### 6. Tool with Error Handling

```python
class SafeTool(Tool):
    async def execute(self, **kwargs) -> Response:
        try:
            self.set_progress("Starting operation...")
            result = await risky_operation()
            return Response(message=result, break_loop=False)

        except ValueError as e:
            return Response(
                message=f"Validation error: {e}",
                break_loop=False
            )

        except Exception as e:
            return Response(
                message=f"Unexpected error: {e}",
                break_loop=False
            )
```

### 7. Tool with Agent Data Storage

```python
class DataStorageTool(Tool):
    async def execute(self, **kwargs) -> Response:
        key = self.args.get("key", "")
        value = self.args.get("value", "")

        # Store data accessible across all agents in this conversation
        self.agent.set_data(key, value)

        return Response(
            message=f"Stored {key}={value}",
            break_loop=False
        )
```

### 8. Tool with Long Operation & Intervention Check

```python
class LongTool(Tool):
    async def execute(self, **kwargs) -> Response:
        items = self.args.get("items", [])

        for i, item in enumerate(items):
            # Check if user wants to pause/stop
            await self.agent.handle_intervention()

            # Process item
            await process_item(item)

            # Update progress
            self.set_progress(f"Processed {i+1}/{len(items)} items")

        return Response(message="All items processed", break_loop=False)
```

---

## Tool Prompt Templates

### Simple Tool Prompt

```markdown
## toolname
Brief one-line description.

Arguments:
- **arg1** (type) - Description
- **arg2** (type, optional) - Description, defaults to X

Example:
{
    "tool_name": "toolname",
    "tool_args": {
        "arg1": "value"
    }
}
```

### Multi-Method Tool Prompt

```markdown
## toolname
Parent tool description.

### toolname:method1
Description of method1.

Arguments:
- **arg1** (type) - Description

### toolname:method2
Description of method2.

Arguments:
- **arg2** (type) - Description

Examples:
{
    "tool_name": "toolname:method1",
    "tool_args": {"arg1": "value"}
}

{
    "tool_name": "toolname:method2",
    "tool_args": {"arg2": "value"}
}
```

---

## Response Types

### Continue Loop (Most Common)

```python
return Response(message="Result", break_loop=False)
```
Agent can use the result and continue working.

### End Loop (Final Response)

```python
return Response(message="Final answer", break_loop=True)
```
Returns message to user and stops.

### With Additional Data

```python
return Response(
    message="Result",
    break_loop=False,
    additional={"key": "value", "data": [1, 2, 3]}
)
```

---

## Accessing Agent Context

```python
class ContextTool(Tool):
    async def execute(self, **kwargs) -> Response:
        # Agent info
        agent_name = self.agent.agent_name        # "Pareng Boyong" or Filipino name
        agent_number = self.agent.number          # 0 for main, 1+ for subordinates

        # Configuration
        model = self.agent.config.chat_model      # e.g., "gpt-4"
        temp = self.agent.config.chat_temperature # e.g., 0.7

        # Context
        context_id = self.agent.context.id        # Conversation ID
        log = self.agent.context.log              # Logging interface

        # History
        history = self.agent.history              # Message history

        # Data storage
        value = self.agent.get_data("key")        # Get shared data
        self.agent.set_data("key", "value")       # Set shared data

        # Read prompts
        prompt = self.agent.read_prompt(
            "prompt_file.md",
            variable="value"
        )

        return Response(message="Context accessed", break_loop=False)
```

---

## Testing Tools

### Quick Test via Docker Logs

```bash
# Watch logs in real-time
docker logs -f pareng-boyong

# In chat interface, tell agent:
# "Use the example tool with text='test'"

# Check logs for tool execution
```

### Test via API

```bash
curl -X POST http://localhost:50002/api/message \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Use example tool with text=\"hello\"",
    "context": ""
  }'
```

### Python Test Script

```python
# test_tool.py
import asyncio
from agent import Agent, AgentConfig, AgentContext

async def test():
    config = AgentConfig()
    context = AgentContext()
    agent = Agent(0, config, context)

    from python.tools.example import ExampleTool
    tool = ExampleTool(
        agent=agent,
        name="example",
        method=None,
        args={"text": "test"},
        message="",
        loop_data=None
    )

    response = await tool.execute()
    print(f"Result: {response.message}")
    print(f"Break loop: {response.break_loop}")

asyncio.run(test())
```

---

## Common Arguments Types

```python
# String
text = self.args.get("text", "")

# Integer
count = int(self.args.get("count", "0"))

# Float
ratio = float(self.args.get("ratio", "0.5"))

# Boolean
enabled = self.args.get("enabled", "false").lower() == "true"

# List (JSON array)
import json
items = json.loads(self.args.get("items", "[]"))

# Dict (JSON object)
config = json.loads(self.args.get("config", "{}"))
```

---

## File Helpers

```python
from python.helpers import files

# Read file
content = files.read_file("path/to/file.txt")

# Write file
files.write_file("path/to/output.txt", "content")

# Check existence
if files.exists("path/to/file.txt"):
    pass

# Get absolute path
abs_path = files.get_abs_path("relative/path")

# List directory
file_list = files.list_dir("path/to/dir")
```

---

## Custom Lifecycle Hooks

### Override Before Execution

```python
class CustomBeforeTool(Tool):
    async def before_execution(self, **kwargs) -> None:
        # Custom pre-execution logic
        self.agent.context.log.log(
            type="info",
            content=f"About to execute {self.name}"
        )
        # Don't call super() to skip default behavior
```

### Override After Execution

```python
class CustomAfterTool(Tool):
    async def after_execution(self, response: Response, **kwargs) -> None:
        # Custom post-execution logic
        self.agent.hist_add_message(
            role="tool_result",
            content=f"Custom: {response.message}"
        )
        # Don't call super() to skip default behavior
```

### Override Logging

```python
class CustomLogTool(Tool):
    def get_log_object(self):
        return self.agent.context.log.log(
            type="tool",
            heading=f"🔧 {self.name.upper()}",
            content="Executing...",
            kvps=self.args
        )
```

---

## Deployment Checklist

- [ ] Created `python/tools/{name}.py` with Tool class
- [ ] Created `prompts/agent.system.tool.{name}.md` with description
- [ ] Implemented `async def execute(self, **kwargs) -> Response`
- [ ] Added argument validation
- [ ] Added progress tracking for long operations
- [ ] Added intervention checks for loops
- [ ] Tested with valid arguments
- [ ] Tested with missing/invalid arguments
- [ ] Tested error cases
- [ ] Restarted Docker container
- [ ] Verified in chat interface
- [ ] Checked Docker logs for errors

---

## Troubleshooting

### Tool Not Found

```bash
# Check file exists
ls -la /root/pareng-boyong-data/python/tools/mytool.py

# Check prompt exists
ls -la /root/pareng-boyong-data/prompts/agent.system.tool.mytool.md

# Restart container
docker restart pareng-boyong

# Check logs
docker logs pareng-boyong | grep mytool
```

### Tool Not Executing

```bash
# Check for syntax errors
docker logs pareng-boyong | grep "SyntaxError"

# Check for import errors
docker logs pareng-boyong | grep "ImportError"

# Verify tool is listed in system prompt
docker logs pareng-boyong | grep "## mytool"
```

### Arguments Not Working

```python
# Debug print arguments
async def execute(self, **kwargs) -> Response:
    print(f"DEBUG: args = {self.args}")
    print(f"DEBUG: kwargs = {kwargs}")
    # ... rest of code
```

---

## Best Practices

1. **Always validate required arguments**
   ```python
   if not self.args.get("required_field"):
       return Response(message="Error: required_field needed", break_loop=False)
   ```

2. **Use progress tracking for operations > 2 seconds**
   ```python
   self.set_progress("Working...")
   ```

3. **Check intervention in long loops**
   ```python
   await self.agent.handle_intervention()
   ```

4. **Return meaningful error messages**
   ```python
   return Response(message=f"Failed: {specific_reason}", break_loop=False)
   ```

5. **Use break_loop=False for intermediate tools**
   ```python
   # Let agent continue working with result
   return Response(message=result, break_loop=False)
   ```

6. **Use break_loop=True only for final responses**
   ```python
   # Only when done and ready to return to user
   return Response(message=final_answer, break_loop=True)
   ```

7. **Document arguments clearly in prompt**
   - Specify type (string, integer, boolean, etc.)
   - Mark as required or optional
   - Provide defaults for optional arguments
   - Include example usage

8. **Handle exceptions gracefully**
   ```python
   try:
       result = await risky_operation()
   except Exception as e:
       return Response(message=f"Error: {e}", break_loop=False)
   ```

---

## Quick Reference Links

- **Full Architecture**: `TOOL_SYSTEM_ARCHITECTURE.md`
- **Existing Tools**: `/root/parengboyong-linux/python/tools/`
- **Tool Prompts**: `/root/parengboyong-linux/prompts/agent.system.tool.*.md`
- **Base Class**: `/root/parengboyong-linux/python/helpers/tool.py`
- **Helper Functions**: `/root/parengboyong-linux/python/helpers/`

---

## Example: Complete Calculator Tool

### `python/tools/calculator.py`

```python
from python.helpers.tool import Tool, Response

class CalculatorTool(Tool):
    async def execute(self, **kwargs) -> Response:
        operation = self.args.get("operation", "")
        a = self.args.get("a", "")
        b = self.args.get("b", "")

        # Validate
        if not operation or not a or not b:
            return Response(
                message="Error: operation, a, and b are required",
                break_loop=False
            )

        try:
            num_a = float(a)
            num_b = float(b)
        except ValueError:
            return Response(
                message="Error: a and b must be numbers",
                break_loop=False
            )

        # Calculate
        if operation == "add":
            result = num_a + num_b
        elif operation == "subtract":
            result = num_a - num_b
        elif operation == "multiply":
            result = num_a * num_b
        elif operation == "divide":
            if num_b == 0:
                return Response(
                    message="Error: division by zero",
                    break_loop=False
                )
            result = num_a / num_b
        else:
            return Response(
                message=f"Error: unknown operation '{operation}'",
                break_loop=False
            )

        return Response(
            message=f"{a} {operation} {b} = {result}",
            break_loop=False
        )
```

### `prompts/agent.system.tool.calculator.md`

```markdown
## calculator
Performs basic arithmetic operations.

Arguments:
- **operation** (string, required) - One of: add, subtract, multiply, divide
- **a** (number, required) - First number
- **b** (number, required) - Second number

Example:
{
    "tool_name": "calculator",
    "tool_args": {
        "operation": "add",
        "a": "10",
        "b": "5"
    }
}
```

---

**Ready to create your first tool? Follow the minimal example at the top!**

**© 2026 InnovateHub - Pareng Boyong Project**
