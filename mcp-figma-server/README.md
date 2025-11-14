## mcp-figma-server (minimal)

Minimal MCP server exposing Figma API tools:
- figma_get_file
- figma_get_nodes
- figma_get_images

### Setup
1) Requirements
- Node.js 18+
- Figma Personal Access Token

2) Install
```bash
npm install
```

3) Build
```bash
npm run build
```

4) Run manually
```bash
FIGMA_TOKEN=YOUR_TOKEN node dist/index.js
```

### Connect in Cursor
- Cursor > Settings > MCP Servers (Experimental) > Add New Server
  - Name: figma
  - Command: node
  - Args: ["/Users/noise/Documents/Develop/Calendar/mcp-figma-server/dist/index.js"]
  - Working Dir: /Users/noise/Documents/Develop/Calendar/mcp-figma-server
  - Env:
    - FIGMA_TOKEN: YOUR_TOKEN

Open a new chat and verify tools are available.

