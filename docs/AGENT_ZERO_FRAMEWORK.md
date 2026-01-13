# Agent Zero Framework - Technical Reference for Pareng Boyong

## Overview
This document provides comprehensive information about the Agent Zero AI framework that powers Pareng Boyong (Innovatehub AI).

## What is Agent Zero?
Agent Zero is an open-source agentic AI framework designed as "a personal, organic agentic framework that grows and learns with you." It's a general-purpose AI assistant that can:
- Gather information from the web
- Execute commands and code
- Cooperate with other agent instances
- Learn and grow from interactions
- Handle complex, multi-step tasks autonomously

## Core Philosophy

### 1. Transparency First
- **Fully readable code**: Nothing is hidden or obfuscated
- **Comprehensible design**: Easy to understand and modify
- **Customizable behavior**: Everything can be extended or changed
- **Open source**: Free and community-driven

### 2. Computer as Tool
- Uses the **operating system itself** as the primary tool
- Can write its own code and use the terminal
- Creates and uses its own tools as needed
- No pre-programmed single-purpose limitations

### 3. Multi-Agent Cooperation
- Agents can create subordinate agents for subtasks
- Maintains clean context hierarchies
- Agents communicate and cooperate
- Parallel task execution capabilities

### 4. Prompt-Driven Design
- **System behavior defined entirely through prompt files**
- Located in `prompts/` directory
- Editable system prompt: `prompts/default/agent.system.md`
- No hard-coded behavior constraints

## Architecture

```
┌─────────────────────────────────────────┐
│         User Interface Layer            │
│  (Web UI: http://localhost:15080)      │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Agent Layer (run_ui.py)         │
│  - Request handling                     │
│  - Session management                   │
│  - Authentication                       │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│      Core Agent Zero Framework          │
│  ┌───────────────────────────────────┐  │
│  │  Agent System                     │  │
│  │  - Main agent                     │  │
│  │  - Sub-agents (for delegation)    │  │
│  │  - Multi-agent cooperation        │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Tools                            │  │
│  │  - Online search                  │  │
│  │  - Code/terminal execution        │  │
│  │  - Memory management              │  │
│  │  - Custom instruments             │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Memory System                    │  │
│  │  - Persistent memory              │  │
│  │  - Message history                │  │
│  │  - Context summarization          │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Prompt System                    │  │
│  │  - System prompts                 │  │
│  │  - User prompts                   │  │
│  │  - Tool prompts                   │  │
│  └───────────────────────────────────┘  │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         LLM Provider Layer              │
│  (LiteLLM - supports 100+ providers)    │
│  - Anthropic (Claude)                   │
│  - OpenAI (GPT models)                  │
│  - Google (Gemini)                      │
│  - Groq, Mistral, etc.                  │
└─────────────────────────────────────────┘
```

## Key Features

### 1. Default Tools
- **Online Search**: Web search capabilities (SearXNG integration)
- **Code Execution**: Run Python, JavaScript, bash, etc.
- **Terminal Commands**: Full OS access
- **Memory Management**: Store and retrieve information
- **Inter-Agent Communication**: Agents can talk to each other
- **Custom Instruments**: User-defined functions

### 2. Advanced Features (v0.9.7+)
- **Persistent Memory**: Learning from previous solutions
- **Document Q&A with RAG**: Retrieval-Augmented Generation
- **Browser Automation**: Web scraping and interaction
- **Speech-to-Text & Text-to-Speech**: Voice interfaces (Kokoro TTS)
- **MCP Server/Client**: Model Context Protocol support
- **Projects Isolation**: Dedicated configs per project
- **Secrets Management**: Secure credential storage
- **External APIs & A2A Protocol**: Agent-to-Agent communication

### 3. Real-Time Capabilities
- **Streamed Output**: Live response formatting
- **Interactive Intervention**: Pause and adjust during execution
- **Markdown Rendering**: Beautiful formatted output
- **HTML Logs**: Automatically saved per session

## Configuration Files (Pareng Boyong)

### 1. Environment Configuration
**File**: `D:\Boyong\agent-zero\.env`

```env
# AI Provider API Keys
API_KEY_ANTHROPIC=your-anthropic-api-key-here
API_KEY_OPENAI=your-openai-api-key-here
API_KEY_GOOGLE=your-google-api-key-here
API_KEY_GROQ=your-groq-api-key-here

# Web UI Configuration
WEB_UI_HOST=0.0.0.0
WEB_UI_PORT=15080

# Working Directory
WORK_DIR=D:/

# Authentication
AUTH_LOGIN=your-username
AUTH_PASSWORD=your-password

# Runtime ID
A0_PERSISTENT_RUNTIME_ID=c23e57e6279863726dffb6c2789673db
```

### 2. System Prompt
**File**: `prompts/default/agent.system.md`

This is the **master file** that defines Pareng Boyong's behavior:
- Personality and tone
- Available tools and capabilities
- Task execution patterns
- Communication style
- Decision-making logic

### 3. Configuration Directory
**Location**: `conf/`

Contains settings for:
- LLM provider configurations
- Tool settings
- Memory system parameters
- Extension configurations

### 4. Custom Tools
**Location**: `python/tools/`

Default tool implementations that can be:
- Copied and modified
- Extended with new functionality
- Replaced with custom versions

## Prompt Engineering

### System Prompt Structure
The system prompt (`prompts/default/agent.system.md`) defines:

1. **Identity & Role**
   - Who the agent is (Pareng Boyong - Innovatehub AI)
   - Primary purpose and capabilities
   - Communication style

2. **Available Tools**
   - Tool descriptions and usage
   - When to use each tool
   - Tool limitations

3. **Task Execution Patterns**
   - How to approach problems
   - Multi-step task handling
   - Sub-agent delegation strategies

4. **Memory & Learning**
   - How to store information
   - When to retrieve memories
   - Context management

5. **Communication Rules**
   - How to format responses
   - When to ask for clarification
   - Error handling procedures

### Customizing Pareng Boyong
To modify behavior, edit the system prompt:

```bash
# Edit system prompt
notepad D:\Boyong\agent-zero\prompts\default\agent.system.md

# Restart Pareng Boyong
D:\Boyong\RESTART_ALL.bat
```

## LLM Provider Integration

### Supported Providers (via LiteLLM)
- **Anthropic**: Claude 3.5 Sonnet, Claude 3 Opus, etc.
- **OpenAI**: GPT-4, GPT-4 Turbo, GPT-3.5
- **Google**: Gemini Pro, Gemini Ultra
- **Groq**: Ultra-fast inference
- **Mistral**: Mistral Large, Mistral Medium
- **OpenRouter**: 100+ models
- **Azure OpenAI**: Enterprise deployment
- **Ollama**: Local model hosting

### Configuring Providers
Add API keys to `.env` file:

```env
API_KEY_ANTHROPIC=sk-ant-...
API_KEY_OPENAI=sk-...
API_KEY_GOOGLE=...
```

## Multi-Agent Cooperation

### How It Works
1. **Main Agent** (Level 0): Receives user request
2. **Task Analysis**: Breaks down complex tasks
3. **Sub-Agent Creation** (Level 1): Spawns specialized agents
4. **Parallel Execution**: Sub-agents work simultaneously
5. **Result Aggregation**: Main agent combines results
6. **Response Delivery**: Formatted output to user

### Use Cases
- **Research Tasks**: Multiple sources searched in parallel
- **Code Development**: Backend + Frontend + Tests simultaneously
- **Data Analysis**: Different data sources processed concurrently
- **Content Creation**: Research + Writing + Editing in parallel

## Memory System

### Types of Memory
1. **Short-Term Memory**: Current conversation context
2. **Message History**: Previous conversation turns
3. **Persistent Memory**: Long-term learned information
4. **Summarization**: Condensed historical context

### Memory Management
- Automatic context summarization
- Relevance-based retrieval
- Configurable retention policies
- Manual memory dashboard (v0.9.6+)

## Security Considerations

### ⚠️ Important Warnings
Agent Zero (and Pareng Boyong) can be **dangerous**:
- Full OS access via terminal
- Can execute any code
- Can modify/delete files
- Can access network resources
- Can make API calls

### Security Best Practices
1. **Run in Docker**: Isolated environment recommended
2. **Strong Authentication**: Set AUTH_LOGIN and AUTH_PASSWORD
3. **Firewall Rules**: Limit access to port 15080
4. **API Key Security**: Use environment variables, not hardcoded
5. **Prompt Engineering**: Define clear boundaries in system prompt
6. **Monitor Logs**: Review HTML logs regularly
7. **Secrets Vault**: Use built-in secrets management (v0.9.5+)

## Version History

- **v0.9.7**: Projects management with isolated workspaces
- **v0.9.6**: Memory dashboard for management
- **v0.9.5**: Secrets vault for credentials
- **v0.9.4**: External APIs and A2A protocol
- **v0.9.1**: LiteLLM replacement for broader provider support
- **v0.8**: Docker runtime, TTS/STT, file attachments
- **Earlier**: Core framework development

## Pareng Boyong Specifics

### Rebranding Changes
- **Name**: Agent Zero → Pareng Boyong (Innovatehub AI)
- **Logo**: Custom Innovatehub branding
- **GitHub**: innovatehubph/pareng-boyong
- **Website**: innovatehub.ph
- **Port**: Changed from 5000 to 15080 (Windows server compatibility)

### Access Information
- **Local**: http://localhost:15080
- **Network**: http://192.168.55.103:15080
- **Public**: http://win-ai.innovatehub.site:15080
- **IP**: http://130.105.71.58:15080

### Management Scripts
- **Start**: `D:\Boyong\START_ALL.bat`
- **Restart**: `D:\Boyong\RESTART_ALL.bat`
- **Update**: `D:\Boyong\UPDATE_AND_RESTART.bat`

## Development & Extension

### Creating Custom Tools
1. Copy example from `python/tools/`
2. Modify functionality
3. Update tool prompt in `prompts/`
4. Register in configuration
5. Restart Pareng Boyong

### Creating Custom Instruments
Instruments are user-defined functions that agents can call:

```python
# Example instrument
def custom_function(param1, param2):
    """Description for the agent"""
    # Your code here
    return result
```

### Extending Capabilities
- Add new LLM providers (via LiteLLM)
- Create domain-specific tools
- Integrate external APIs
- Add custom memory backends
- Implement new communication protocols

## Troubleshooting

### Common Issues

1. **Flask Async Error**
   - **Problem**: `RuntimeError: Install Flask with the 'async' extra`
   - **Solution**: `pip install asgiref` or `pip install flask[async]`

2. **Port Already in Use**
   - **Check**: `netstat -ano | findstr ":15080"`
   - **Solution**: Change WEB_UI_PORT in .env

3. **API Key Errors**
   - **Check**: .env file has valid API keys
   - **Solution**: Update API keys from provider dashboard

4. **Memory Issues**
   - **Check**: Disk space and RAM usage
   - **Solution**: Clear old logs, increase memory limits

5. **Permission Denied**
   - **Check**: Running as Administrator
   - **Solution**: Right-click → Run as administrator

## Resources & Documentation

### Official Links
- **GitHub**: https://github.com/agent0ai/agent-zero
- **Website**: https://www.agent-zero.ai/
- **Documentation**: https://github.com/agent0ai/agent-zero/tree/main/docs
- **Discord**: Community support server
- **YouTube**: Tutorial videos

### Pareng Boyong Links
- **GitHub**: https://github.com/innovatehubph/pareng-boyong
- **Website**: https://innovatehub.ph

## Best Practices

### Prompt Engineering
1. Be specific and clear in system prompts
2. Define tool usage patterns explicitly
3. Set clear boundaries and limitations
4. Include examples of desired behavior
5. Test and iterate on prompt modifications

### Performance Optimization
1. Use appropriate LLM models (balance cost/performance)
2. Implement caching for repeated queries
3. Optimize memory retention policies
4. Monitor token usage
5. Use sub-agents for parallel tasks

### Maintenance
1. Regular backups of configuration
2. Monitor logs for errors
3. Update dependencies periodically
4. Test after updates
5. Document custom modifications

## Future Enhancements

### Planned Features
- Enhanced browser automation
- More voice interface options
- Advanced RAG capabilities
- Improved multi-agent orchestration
- Better secrets management
- Extended API integrations

### Community Contributions
Agent Zero is open source and welcomes contributions:
- Bug fixes
- New tools and instruments
- Documentation improvements
- Example use cases
- Integration tutorials

---

## Summary

Agent Zero (Pareng Boyong) is a powerful, transparent, and highly customizable AI agent framework that:
- Uses your computer as a tool
- Can learn and grow with you
- Supports multi-agent cooperation
- Is fully open source and extensible
- Prioritizes user control and transparency

**Remember**: With great power comes great responsibility. Always use Pareng Boyong carefully and securely.

---

*Last updated: 2026-01-13*
*Based on Agent Zero v0.9.7*
