import { McpServer } from "@modelcontextprotocol/sdk/server/mcp";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio";
import { z } from "zod";
import { request } from "undici";

const FIGMA_API_BASE = "https://api.figma.com/v1";
const FIGMA_TOKEN = process.env.FIGMA_TOKEN;

if (!FIGMA_TOKEN) {
  console.error("Missing FIGMA_TOKEN env var");
  process.exit(1);
}

async function figmaGet(path: string, query?: Record<string, string | undefined>) {
  const url = new URL(FIGMA_API_BASE + path);
  if (query) {
    for (const [k, v] of Object.entries(query)) {
      if (v !== undefined) url.searchParams.set(k, v);
    }
  }
  const res = await request(url.toString(), {
    headers: { Authorization: `Bearer ${FIGMA_TOKEN}` },
  });
  if (res.statusCode >= 400) {
    const body = await res.body.text();
    throw new Error(`Figma API ${res.statusCode}: ${body}`);
  }
  return res.body.json();
}

const mcpServer = new McpServer({ name: "mcp-figma", version: "0.1.0" });

 mcpServer.tool(
  "figma_get_file",
  {
    fileKey: z.string().min(1).describe("Figma file key"),
    depth: z.number().int().min(1).max(4).optional().describe("Optional depth 1-4"),
  },
  async ({ fileKey, depth }: { fileKey: string; depth?: number }) => {
    const data = await figmaGet(
      `/files/${encodeURIComponent(fileKey)}`,
      depth ? { depth: String(depth) } : undefined
    );
    return { content: [{ type: "json", json: data }] };
  }
);

 mcpServer.tool(
  "figma_get_nodes",
  {
    fileKey: z.string().min(1).describe("Figma file key"),
    nodeIds: z.array(z.string().min(1)).min(1).describe("Array of node IDs"),
  },
  async ({ fileKey, nodeIds }: { fileKey: string; nodeIds: string[] }) => {
    const data = await figmaGet(
      `/files/${encodeURIComponent(fileKey)}/nodes`,
      { ids: nodeIds.join(",") }
    );
    return { content: [{ type: "json", json: data }] };
  }
);

 mcpServer.tool(
  "figma_get_images",
  {
    fileKey: z.string().min(1).describe("Figma file key"),
    nodeIds: z.array(z.string().min(1)).min(1).describe("Array of node IDs"),
    format: z.enum(["png", "jpg", "svg", "pdf"]).optional(),
    scale: z.number().min(0.01).max(4).optional(),
  },
  async ({ fileKey, nodeIds, format, scale }: { fileKey: string; nodeIds: string[]; format?: "png"|"jpg"|"svg"|"pdf"; scale?: number }) => {
    const data = await figmaGet(`/images/${encodeURIComponent(fileKey)}`, {
      ids: nodeIds.join(","),
      format,
      scale: scale ? String(scale) : undefined,
    });
    return { content: [{ type: "json", json: data }] };
  }
);

async function main() {
  const transport = new StdioServerTransport();
  await mcpServer.connect(transport);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});


