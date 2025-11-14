declare module "@modelcontextprotocol/sdk/server/mcp" {
  export class McpServer {
    server: any;
    constructor(serverInfo: { name: string; version: string }, options?: any);
    connect(transport: any): Promise<void>;
    tool(name: string, ...args: any[]): any;
    registerTool?: any;
    sendToolListChanged?: any;
  }
}

declare module "@modelcontextprotocol/sdk/server/stdio" {
  export class StdioServerTransport {
    constructor(stdin?: any, stdout?: any);
    onmessage?: (msg: any) => void;
    onerror?: (err: any) => void;
    onclose?: () => void;
    start?: () => Promise<void>;
    close?: () => Promise<void>;
    send?: (message: any) => Promise<void>;
  }
}


