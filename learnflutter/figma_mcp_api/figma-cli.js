#!/usr/bin/env node
/**
 * figma-cli.js — Gọi Figma REST API trực tiếp từ terminal.
 * Đọc token từ ../.env (FIGMA_ACCESS_TOKEN) hoặc biến môi trường.
 *
 * Usage:
 *   node figma-cli.js <tool> [params...]
 *
 * Tools:
 *   me
 *   file         <file_key> [depth=N]
 *   nodes        <file_key> <node_ids>
 *   components   <file_key>
 *   styles       <file_key>
 *   versions     <file_key>
 *   comments     <file_key>
 *   images       <file_key> <node_ids> [format=png|jpg|svg|pdf] [scale=1]
 *   projects     <team_id>
 *   project-files <project_id>
 *
 * Examples:
 *   node figma-cli.js me
 *   node figma-cli.js file MO4JcMsNudV8vtIwmCPGoc
 *   node figma-cli.js file MO4JcMsNudV8vtIwmCPGoc depth=2
 *   node figma-cli.js nodes MO4JcMsNudV8vtIwmCPGoc 1:2,3:4
 *   node figma-cli.js components MO4JcMsNudV8vtIwmCPGoc
 *   node figma-cli.js styles MO4JcMsNudV8vtIwmCPGoc
 *   node figma-cli.js images MO4JcMsNudV8vtIwmCPGoc 1:2 format=png scale=2
 *   node figma-cli.js comments MO4JcMsNudV8vtIwmCPGoc
 *   node figma-cli.js projects 123456789
 *   node figma-cli.js project-files 123456789
 */

import fetch from 'node-fetch';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.join(__dirname, '..', '.env') });

const FIGMA_API_BASE = 'https://api.figma.com/v1';
const TOKEN = process.env.FIGMA_ACCESS_TOKEN;

if (!TOKEN) {
  console.error('❌ Chưa có FIGMA_ACCESS_TOKEN trong ../.env');
  console.error('   Tạo file learnflutter/.env với nội dung:');
  console.error('   FIGMA_ACCESS_TOKEN=figd_your_token_here');
  process.exit(1);
}

// Parse key=value args
function parseArgs(argv) {
  const positional = [];
  const flags = {};
  for (const arg of argv) {
    if (arg.includes('=')) {
      const [k, v] = arg.split('=');
      flags[k] = v;
    } else {
      positional.push(arg);
    }
  }
  return { positional, flags };
}

async function callApi(endpoint, method = 'GET', body = null) {
  const url = `${FIGMA_API_BASE}${endpoint}`;
  const opts = {
    method,
    headers: { 'X-Figma-Token': TOKEN, 'Content-Type': 'application/json' },
  };
  if (body) opts.body = JSON.stringify(body);

  const res = await fetch(url, opts);
  const data = await res.json();

  if (!res.ok) {
    console.error(`❌ Figma API Error (${res.status}): ${data.message || JSON.stringify(data)}`);
    process.exit(1);
  }
  return data;
}

// Pretty print helper
function pretty(data) {
  console.log(JSON.stringify(data, null, 2));
}

// Summary helpers
function summaryFile(data) {
  const pages = data.document?.children || [];
  console.log(`\n📄 File   : ${data.name}`);
  console.log(`🔑 Key    : ${data.key || '(see URL)'}`);
  console.log(`📑 Pages  (${pages.length}):`);
  pages.forEach((p, i) => console.log(`  ${i + 1}. ${p.name}`));
  console.log('');
}

function summaryMe(data) {
  console.log(`\n👤 User   : ${data.handle}`);
  console.log(`📧 Email  : ${data.email}`);
  console.log(`🖼  Avatar : ${data.img_url}`);
  console.log('');
}

function summaryComponents(data) {
  const items = data.meta?.components || [];
  console.log(`\n🧩 Components (${items.length}):`);
  items.slice(0, 20).forEach(c => console.log(`  • ${c.name} — node: ${c.node_id}`));
  if (items.length > 20) console.log(`  ... và ${items.length - 20} component khác`);
  console.log('');
}

function summaryStyles(data) {
  const items = data.meta?.styles || [];
  console.log(`\n🎨 Styles (${items.length}):`);
  items.slice(0, 20).forEach(s => console.log(`  • [${s.style_type}] ${s.name} — node: ${s.node_id}`));
  if (items.length > 20) console.log(`  ... và ${items.length - 20} style khác`);
  console.log('');
}

// --- Main ---
const [,, tool, ...rest] = process.argv;
const { positional, flags } = parseArgs(rest);

if (!tool) {
  console.log(`
Usage: node figma-cli.js <tool> [args]

Tools:
  me
  file         <file_key> [depth=N]
  nodes        <file_key> <node_ids>
  components   <file_key>
  styles       <file_key>
  versions     <file_key>
  comments     <file_key>
  images       <file_key> <node_ids> [format=png] [scale=1]
  projects     <team_id>
  project-files <project_id>
`);
  process.exit(0);
}

try {
  switch (tool) {
    case 'me': {
      const data = await callApi('/me');
      summaryMe(data);
      break;
    }

    case 'file': {
      const [fileKey] = positional;
      if (!fileKey) { console.error('❌ Cần file_key'); process.exit(1); }
      const qs = new URLSearchParams();
      if (flags.depth) qs.append('depth', flags.depth);
      if (flags.ids)   qs.append('ids', flags.ids);
      const q = qs.toString();
      const data = await callApi(`/files/${fileKey}${q ? '?' + q : ''}`);
      summaryFile(data);
      if (flags.raw) pretty(data);
      break;
    }

    case 'nodes': {
      const [fileKey, ids] = positional;
      if (!fileKey || !ids) { console.error('❌ Cần file_key và node_ids'); process.exit(1); }
      const qs = new URLSearchParams({ ids });
      if (flags.depth) qs.append('depth', flags.depth);
      const data = await callApi(`/files/${fileKey}/nodes?${qs}`);
      pretty(data);
      break;
    }

    case 'components': {
      const [fileKey] = positional;
      if (!fileKey) { console.error('❌ Cần file_key'); process.exit(1); }
      const data = await callApi(`/files/${fileKey}/components`);
      summaryComponents(data);
      if (flags.raw) pretty(data);
      break;
    }

    case 'styles': {
      const [fileKey] = positional;
      if (!fileKey) { console.error('❌ Cần file_key'); process.exit(1); }
      const data = await callApi(`/files/${fileKey}/styles`);
      summaryStyles(data);
      if (flags.raw) pretty(data);
      break;
    }

    case 'versions': {
      const [fileKey] = positional;
      if (!fileKey) { console.error('❌ Cần file_key'); process.exit(1); }
      const data = await callApi(`/files/${fileKey}/versions`);
      const versions = data.versions || [];
      console.log(`\n📦 Versions (${versions.length}):`);
      versions.slice(0, 10).forEach(v =>
        console.log(`  • [${v.created_at?.slice(0,10)}] ${v.label || '(no label)'} — id: ${v.id}`)
      );
      console.log('');
      break;
    }

    case 'comments': {
      const [fileKey] = positional;
      if (!fileKey) { console.error('❌ Cần file_key'); process.exit(1); }
      const data = await callApi(`/files/${fileKey}/comments`);
      const comments = data.comments || [];
      console.log(`\n💬 Comments (${comments.length}):`);
      comments.slice(0, 10).forEach(c =>
        console.log(`  • [${c.created_at?.slice(0,10)}] ${c.user?.handle}: ${c.message}`)
      );
      console.log('');
      break;
    }

    case 'images': {
      const [fileKey, ids] = positional;
      if (!fileKey || !ids) { console.error('❌ Cần file_key và node_ids'); process.exit(1); }
      const qs = new URLSearchParams({ ids });
      if (flags.format) qs.append('format', flags.format);
      if (flags.scale)  qs.append('scale', flags.scale);
      const data = await callApi(`/images/${fileKey}?${qs}`);
      console.log('\n🖼  Image URLs:');
      Object.entries(data.images || {}).forEach(([nodeId, url]) =>
        console.log(`  • ${nodeId}: ${url}`)
      );
      console.log('');
      break;
    }

    case 'projects': {
      const [teamId] = positional;
      if (!teamId) { console.error('❌ Cần team_id'); process.exit(1); }
      const data = await callApi(`/teams/${teamId}/projects`);
      const projects = data.projects || [];
      console.log(`\n📁 Projects (${projects.length}):`);
      projects.forEach(p => console.log(`  • ${p.name} — id: ${p.id}`));
      console.log('');
      break;
    }

    case 'project-files': {
      const [projectId] = positional;
      if (!projectId) { console.error('❌ Cần project_id'); process.exit(1); }
      const data = await callApi(`/projects/${projectId}/files`);
      const files = data.files || [];
      console.log(`\n📄 Files (${files.length}):`);
      files.forEach(f => console.log(`  • ${f.name} — key: ${f.key}`));
      console.log('');
      break;
    }

    default:
      console.error(`❌ Tool không hợp lệ: "${tool}"`);
      console.error('   Chạy: node figma-cli.js để xem danh sách tools');
      process.exit(1);
  }
} catch (err) {
  console.error(`❌ ${err.message}`);
  process.exit(1);
}
