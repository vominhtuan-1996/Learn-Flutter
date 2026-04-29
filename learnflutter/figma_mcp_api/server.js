#!/usr/bin/env node

import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
import fetch from 'node-fetch';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
dotenv.config({ path: path.join(__dirname, '..', '.env') });

const FIGMA_API_BASE = 'https://api.figma.com/v1';

/**
 * Validates if a Figma access token is available.
 */
function getEffectiveToken(providedToken) {
  const token = providedToken || process.env.FIGMA_ACCESS_TOKEN;
  if (!token) {
    throw new Error('No Figma access token provided. Set FIGMA_ACCESS_TOKEN in .env or pass _token parameter.');
  }
  return token;
}

/**
 * Helper to call Figma API.
 */
async function callFigmaApi(endpoint, token, options = {}) {
  const url = `${FIGMA_API_BASE}${endpoint}`;
  const response = await fetch(url, {
    ...options,
    headers: {
      'X-Figma-Token': token,
      'Content-Type': 'application/json',
      ...options.headers,
    },
  });

  if (!response.ok) {
    const errorData = await response.json().catch(() => ({ message: response.statusText }));
    throw new Error(`Figma API Error (${response.status}): ${errorData.message || JSON.stringify(errorData)}`);
  }

  return response.json();
}

const server = new McpServer({
  name: 'figma-api',
  version: '1.1.0',
});

// --- Common Schemas ---

const commonParams = {
  _token: z.string().optional().describe('Figma Access Token (overrides .env)'),
};

// --- Register Tools ---

// Tool: get_file
server.tool(
  'get_file',
  'Retrieve the full document JSON for a given file key.',
  {
    ...commonParams,
    file_key: z.string().describe('The key of the Figma file'),
    ids: z.string().optional().describe('A comma separated list of node IDs to retrieve from the document'),
    depth: z.number().optional().describe('Positive integer representing how deep into the document tree to traverse'),
    version: z.string().optional().describe('A specific version ID to retrieve'),
  },
  async ({ file_key, ids, depth, version, _token }) => {
    try {
      const token = getEffectiveToken(_token);
      const queryParams = new URLSearchParams();
      if (ids) queryParams.append('ids', ids);
      if (depth) queryParams.append('depth', String(depth));
      if (version) queryParams.append('version', version);

      const qs = queryParams.toString();
      const endpoint = `/files/${file_key}${qs ? `?${qs}` : ''}`;
      const data = await callFigmaApi(endpoint, token);

      return {
        content: [{ type: 'text', text: JSON.stringify(data, null, 2) }],
      };
    } catch (err) {
      return {
        content: [{ type: 'text', text: `Error: ${err.message}` }],
        isError: true,
      };
    }
  }
);

// Tool: get_nodes
server.tool(
  'get_nodes',
  'Retrieve JSON data for specific nodes within a file.',
  {
    ...commonParams,
    file_key: z.string().describe('The key of the Figma file'),
    ids: z.string().describe('A comma separated list of node IDs to retrieve'),
    depth: z.number().optional().describe('Positive integer representing how deep into the document tree to traverse'),
    version: z.string().optional().describe('A specific version ID to retrieve'),
  },
  async ({ file_key, ids, depth, version, _token }) => {
    try {
      const token = getEffectiveToken(_token);
      const queryParams = new URLSearchParams({ ids });
      if (depth) queryParams.append('depth', String(depth));
      if (version) queryParams.append('version', version);

      const qs = queryParams.toString();
      const endpoint = `/files/${file_key}/nodes?${qs}`;
      const data = await callFigmaApi(endpoint, token);

      return {
        content: [{ type: 'text', text: JSON.stringify(data, null, 2) }],
      };
    } catch (err) {
      return {
        content: [{ type: 'text', text: `Error: ${err.message}` }],
        isError: true,
      };
    }
  }
);

// Tool: get_images
server.tool(
  'get_images',
  'Get image export URLs for specific nodes.',
  {
    ...commonParams,
    file_key: z.string().describe('The key of the Figma file'),
    ids: z.string().describe('A comma separated list of node IDs to render'),
    scale: z.number().optional().describe('A number between 0.01 and 4'),
    format: z.enum(['jpg', 'png', 'svg', 'pdf']).optional().describe('A string enum: "jpg", "png", "svg", or "pdf"'),
    version: z.string().optional().describe('A specific version ID to retrieve'),
  },
  async ({ file_key, ids, scale, format, version, _token }) => {
    try {
      const token = getEffectiveToken(_token);
      const queryParams = new URLSearchParams({ ids });
      if (scale) queryParams.append('scale', String(scale));
      if (format) queryParams.append('format', format);
      if (version) queryParams.append('version', version);

      const qs = queryParams.toString();
      const endpoint = `/images/${file_key}?${qs}`;
      const data = await callFigmaApi(endpoint, token);

      return {
        content: [{ type: 'text', text: JSON.stringify(data, null, 2) }],
      };
    } catch (err) {
      return {
        content: [{ type: 'text', text: `Error: ${err.message}` }],
        isError: true,
      };
    }
  }
);

// Tool: get_file_components
server.tool(
  'get_file_components',
  'List all components defined in a file.',
  {
    ...commonParams,
    file_key: z.string().describe('The key of the Figma file'),
  },
  async ({ file_key, _token }) => {
    try {
      const token = getEffectiveToken(_token);
      const endpoint = `/files/${file_key}/components`;
      const data = await callFigmaApi(endpoint, token);

      return {
        content: [{ type: 'text', text: JSON.stringify(data, null, 2) }],
      };
    } catch (err) {
      return {
        content: [{ type: 'text', text: `Error: ${err.message}` }],
        isError: true,
      };
    }
  }
);

// Tool: get_file_styles
server.tool(
  'get_file_styles',
  'List all styles defined in a file.',
  {
    ...commonParams,
    file_key: z.string().describe('The key of the Figma file'),
  },
  async ({ file_key, _token }) => {
    try {
      const token = getEffectiveToken(_token);
      const endpoint = `/files/${file_key}/styles`;
      const data = await callFigmaApi(endpoint, token);

      return {
        content: [{ type: 'text', text: JSON.stringify(data, null, 2) }],
      };
    } catch (err) {
      return {
        content: [{ type: 'text', text: `Error: ${err.message}` }],
        isError: true,
      };
    }
  }
);

// Tool: get_me
server.tool(
  'get_me',
  'Get details about the authenticated user.',
  {
    ...commonParams,
  },
  async ({ _token }) => {
    try {
      const token = getEffectiveToken(_token);
      const data = await callFigmaApi('/me', token);
      return {
        content: [{ type: 'text', text: JSON.stringify(data, null, 2) }],
      };
    } catch (err) {
      return {
        content: [{ type: 'text', text: `Error: ${err.message}` }],
        isError: true,
      };
    }
  }
);

// Tool: get_file_versions
server.tool(
  'get_file_versions',
  'Retrieve the version history of a Figma file.',
  {
    ...commonParams,
    file_key: z.string().describe('The key of the Figma file'),
  },
  async ({ file_key, _token }) => {
    try {
      const token = getEffectiveToken(_token);
      const data = await callFigmaApi(`/files/${file_key}/versions`, token);
      return {
        content: [{ type: 'text', text: JSON.stringify(data, null, 2) }],
      };
    } catch (err) {
      return {
        content: [{ type: 'text', text: `Error: ${err.message}` }],
        isError: true,
      };
    }
  }
);

// Tool: get_comments
server.tool(
  'get_comments',
  'List all comments on a Figma file.',
  {
    ...commonParams,
    file_key: z.string().describe('The key of the Figma file'),
  },
  async ({ file_key, _token }) => {
    try {
      const token = getEffectiveToken(_token);
      const data = await callFigmaApi(`/files/${file_key}/comments`, token);
      return {
        content: [{ type: 'text', text: JSON.stringify(data, null, 2) }],
      };
    } catch (err) {
      return {
        content: [{ type: 'text', text: `Error: ${err.message}` }],
        isError: true,
      };
    }
  }
);

// Tool: post_comment
server.tool(
  'post_comment',
  'Add a new comment to a Figma file.',
  {
    ...commonParams,
    file_key: z.string().describe('The key of the Figma file'),
    message: z.string().describe('The comment text'),
    client_meta: z.object({
      x: z.number().optional(),
      y: z.number().optional(),
      node_id: z.string().optional(),
      node_offset: z.object({ x: z.number(), y: z.number() }).optional(),
    }).optional().describe('Optional metadata for comment placement'),
  },
  async ({ file_key, message, client_meta, _token }) => {
    try {
      const token = getEffectiveToken(_token);
      const data = await callFigmaApi(`/files/${file_key}/comments`, token, {
        method: 'POST',
        body: JSON.stringify({ message, client_meta }),
      });
      return {
        content: [{ type: 'text', text: JSON.stringify(data, null, 2) }],
      };
    } catch (err) {
      return {
        content: [{ type: 'text', text: `Error: ${err.message}` }],
        isError: true,
      };
    }
  }
);

// Tool: get_project_files
server.tool(
  'get_project_files',
  'List all files in a specific Figma project.',
  {
    ...commonParams,
    project_id: z.string().describe('The ID of the Figma project'),
  },
  async ({ project_id, _token }) => {
    try {
      const token = getEffectiveToken(_token);
      const data = await callFigmaApi(`/projects/${project_id}/files`, token);
      return {
        content: [{ type: 'text', text: JSON.stringify(data, null, 2) }],
      };
    } catch (err) {
      return {
        content: [{ type: 'text', text: `Error: ${err.message}` }],
        isError: true,
      };
    }
  }
);

// Tool: get_team_projects
server.tool(
  'get_team_projects',
  'List all projects in a specific Figma team.',
  {
    ...commonParams,
    team_id: z.string().describe('The ID of the Figma team'),
  },
  async ({ team_id, _token }) => {
    try {
      const token = getEffectiveToken(_token);
      const data = await callFigmaApi(`/teams/${team_id}/projects`, token);
      return {
        content: [{ type: 'text', text: JSON.stringify(data, null, 2) }],
      };
    } catch (err) {
      return {
        content: [{ type: 'text', text: `Error: ${err.message}` }],
        isError: true,
      };
    }
  }
);

// --- Start Server ---

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('Figma MCP Server running on stdio');
}

main().catch((err) => {
  console.error('Fatal error starting server:', err);
  process.exit(1);
});
