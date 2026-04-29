#!/usr/bin/env node
/**
 * figma-schema.js — Phân tích Figma UI để suy ra database schema.
 *
 * Phương pháp:
 *  1. Lấy toàn bộ node tree (depth=6) từ Figma API
 *  2. Duyệt từng FRAME cấp cao → mỗi frame là 1 entity
 *  3. Thu thập TEXT nodes → suy ra tên field và kiểu dữ liệu
 *  4. Xuất SQL / Dart model / JSON schema
 *
 * Usage:
 *   node figma-schema.js <file_key> [format=sql|dart|json|all]
 *
 * Examples:
 *   node figma-schema.js 6PX83qFaUYLQsCnff1YhkW
 *   node figma-schema.js 6PX83qFaUYLQsCnff1YhkW format=dart
 *   node figma-schema.js 6PX83qFaUYLQsCnff1YhkW format=sql
 *   node figma-schema.js 6PX83qFaUYLQsCnff1YhkW format=json
 *   node figma-schema.js 6PX83qFaUYLQsCnff1YhkW format=all
 */

import fetch from 'node-fetch';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.join(__dirname, '..', '.env') });

const TOKEN = process.env.FIGMA_ACCESS_TOKEN;
const FIGMA_API = 'https://api.figma.com/v1';

if (!TOKEN) {
  console.error('❌ Chưa có FIGMA_ACCESS_TOKEN trong ../.env');
  process.exit(1);
}

// ─── Parse args ───────────────────────────────────────────────
const [,, fileKey, ...rest] = process.argv;
if (!fileKey) {
  console.error('Usage: node figma-schema.js <file_key> [format=sql|dart|json|all]');
  process.exit(1);
}
const flags = Object.fromEntries(rest.filter(a => a.includes('=')).map(a => a.split('=')));
const format = flags.format || 'all';
const nodeId = flags.node ? flags.node.replace(/-/g, ':') : null;

// ─── Fetch single node ────────────────────────────────────────
async function fetchNode(key, id, depth = 6) {
  const encoded = encodeURIComponent(id);
  const res = await fetch(`${FIGMA_API}/files/${key}/nodes?ids=${encoded}&depth=${depth}`, {
    headers: { 'X-Figma-Token': TOKEN },
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({ message: res.statusText }));
    throw new Error(`Figma API (${res.status}): ${err.message}`);
  }
  const data = await res.json();
  const nodeData = data.nodes?.[id]?.document;
  if (!nodeData) throw new Error(`Node ${id} not found in file.`);
  return nodeData;
}

// ─── Fetch Figma file ──────────────────────────────────────────
async function fetchFile(key, depth = 6) {
  const res = await fetch(`${FIGMA_API}/files/${key}?depth=${depth}`, {
    headers: { 'X-Figma-Token': TOKEN },
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({ message: res.statusText }));
    throw new Error(`Figma API (${res.status}): ${err.message}`);
  }
  return res.json();
}

// ─── Type inference from field name ───────────────────────────
const TYPE_RULES = [
  { pattern: /\b(id|uuid|key)\b/i,                         type: 'INTEGER', dart: 'int' },
  { pattern: /\b(email|mail)\b/i,                          type: 'TEXT',    dart: 'String' },
  { pattern: /\b(phone|tel|mobile)\b/i,                    type: 'TEXT',    dart: 'String' },
  { pattern: /\b(url|link|href|avatar|image|photo|img)\b/i, type: 'TEXT',   dart: 'String?' },
  { pattern: /\b(date|time|at|created|updated|birthday)\b/i, type: 'INTEGER', dart: 'DateTime?' },
  { pattern: /\b(count|total|qty|quantity|amount|score|point|level|age|rank)\b/i, type: 'INTEGER', dart: 'int' },
  { pattern: /\b(price|cost|fee|balance|revenue|salary)\b/i, type: 'REAL',  dart: 'double' },
  { pattern: /\b(is|has|can|enable|active|status|flag|bool|toggle|done|complete|checked)\b/i, type: 'INTEGER', dart: 'bool' },
  { pattern: /\b(description|desc|note|content|bio|message|comment|body|detail)\b/i, type: 'TEXT', dart: 'String?' },
  { pattern: /\b(list|items|tags|categories|array|json)\b/i, type: 'TEXT',  dart: 'List<dynamic>?' },
  { pattern: /\b(password|pass|secret|token)\b/i,          type: 'TEXT',    dart: 'String' },
  { pattern: /\b(name|title|label|category|type|genre|habit|reminder)\b/i, type: 'TEXT', dart: 'String' },
  { pattern: /\b(color|colour|hex)\b/i,                    type: 'TEXT',    dart: 'String?' },
];

function inferType(label) {
  for (const rule of TYPE_RULES) {
    if (rule.pattern.test(label)) return { sql: rule.type, dart: rule.dart };
  }
  return { sql: 'TEXT', dart: 'String?' };
}

// ─── Normalise label to snake_case field name ──────────────────
function toSnakeCase(str) {
  return str
    .replace(/[^a-zA-Z0-9\s_]/g, ' ')
    .trim()
    .replace(/\s+/g, '_')
    .replace(/([a-z])([A-Z])/g, '$1_$2')
    .toLowerCase()
    .replace(/_{2,}/g, '_')
    .replace(/^_|_$/g, '');
}

// ─── toPascalCase for class names ─────────────────────────────
function toPascal(str) {
  return str.replace(/(^|[\s_-]+)(\w)/g, (_, __, c) => c.toUpperCase());
}

// ─── Walk node tree, collect TEXT nodes per frame ─────────────
function collectFrames(nodes) {
  const frames = [];

  function walkFrame(node, depth) {
    const labels = new Set();

    function collectText(n, d) {
      if (d > 5) return;
      if (n.type === 'TEXT' && n.characters) {
        const txt = n.characters.trim();
        // Filter noise: skip short/all-caps/numeric texts
        if (
          txt.length >= 3 &&
          txt.length <= 40 &&
          !/^\d+$/.test(txt) &&
          !/^[A-Z0-9\s]{2,}$/.test(txt)
        ) {
          labels.add(txt);
        }
      }
      (n.children || []).forEach(c => collectText(c, d + 1));
    }

    collectText(node, 0);
    return [...labels];
  }

  function walk(node, depth) {
    if (depth === 1 && node.type === 'FRAME') {
      const rawLabels = walkFrame(node, 0);
      if (rawLabels.length > 0) {
        frames.push({ name: node.name, labels: rawLabels });
      }
    }
    if (depth < 2) (node.children || []).forEach(c => walk(c, depth + 1));
  }

  nodes.forEach(page => walk(page, 0));
  return frames;
}

// ─── Build entity schema from frame ───────────────────────────
function buildEntity(frame) {
  const fields = new Map();

  // Always include id
  fields.set('id', { sql: 'INTEGER', dart: 'int', label: 'primary key' });

  frame.labels.forEach(label => {
    const snake = toSnakeCase(label);
    if (!snake || snake.length < 2 || fields.has(snake)) return;
    // Skip generic words that aren't field names
    if (['back', 'next', 'save', 'cancel', 'done', 'more', 'all', 'new', 'add', 'edit'].includes(snake)) return;
    const types = inferType(label);
    fields.set(snake, { ...types, label });
  });

  return { name: toPascal(toSnakeCase(frame.name)), fields };
}

// ─── Generators ───────────────────────────────────────────────
function generateSQL(entities) {
  const lines = ['-- 📊 Auto-generated from Figma UI (figma-schema.js)', ''];
  entities.forEach(({ name, fields }) => {
    lines.push(`CREATE TABLE IF NOT EXISTS ${toSnakeCase(name)} (`);
    const cols = [];
    fields.forEach((info, fieldName) => {
      if (fieldName === 'id') {
        cols.push(`  id        INTEGER PRIMARY KEY AUTOINCREMENT`);
      } else {
        const nullable = info.dart.endsWith('?') ? '' : ' NOT NULL';
        cols.push(`  ${fieldName.padEnd(20)} ${info.sql}${nullable}  -- ${info.label}`);
      }
    });
    lines.push(cols.join(',\n'));
    lines.push(');');
    lines.push('');
  });
  return lines.join('\n');
}

function generateDart(entities) {
  const lines = [
    '// 📊 Auto-generated from Figma UI (figma-schema.js)',
    '// ignore_for_file: invalid_annotation_target',
    '',
    "import 'package:freezed_annotation/freezed_annotation.dart';",
    '',
  ];

  entities.forEach(({ name, fields }) => {
    lines.push(`part '${toSnakeCase(name)}_model.freezed.dart';`);
    lines.push(`part '${toSnakeCase(name)}_model.g.dart';`);
    lines.push('');
    lines.push('@freezed');
    lines.push(`class ${name}Model with _\$${name}Model {`);
    lines.push(`  const factory ${name}Model({`);
    fields.forEach((info, fieldName) => {
      if (fieldName === 'id') {
        lines.push(`    required int id,`);
      } else {
        lines.push(`    required ${info.dart} ${snakeToCamel(fieldName)}, // ${info.label}`);
      }
    });
    lines.push('  }) = _' + name + 'Model;');
    lines.push('');
    lines.push(`  factory ${name}Model.fromJson(Map<String, dynamic> json) =>`);
    lines.push(`      _$${name}ModelFromJson(json);`);
    lines.push('}');
    lines.push('');
  });
  return lines.join('\n');
}

function generateJSON(entities) {
  const schema = {};
  entities.forEach(({ name, fields }) => {
    schema[name] = {};
    fields.forEach((info, fieldName) => {
      schema[name][fieldName] = {
        type: info.sql,
        dartType: info.dart,
        label: info.label,
      };
    });
  });
  return JSON.stringify({ schema }, null, 2);
}

function snakeToCamel(str) {
  return str.replace(/_([a-z])/g, (_, c) => c.toUpperCase());
}

// ─── Main ──────────────────────────────────────────────────────
console.log(`\n🔍 Đang phân tích Figma file: ${fileKey} ...${nodeId ? ' (node: ' + nodeId + ')' : ''}\n`);

let pages;
if (nodeId) {
  // Chỉ phân tích một node cụ thể
  const node = await fetchNode(fileKey, nodeId, 6);
  console.log(`📦 Node  : ${node.name} (${node.type})`);
  // Giả lập cấu trúc page để collectFrames có thể xử lý
  if (node.type === 'FRAME' || node.type === 'COMPONENT' || node.type === 'GROUP') {
    // Wrap node như 1 page chứa đúng 1 frame (chính node đó)
    pages = [{ name: 'Node', type: 'CANVAS', children: [node] }];
  } else {
    pages = [{ name: 'Root', type: 'CANVAS', children: [{ ...node, type: 'FRAME' }] }];
  }
} else {
  const data = await fetchFile(fileKey, 6);
  console.log(`📄 File   : ${data.name}`);
  pages = data.document?.children || [];
  console.log(`📑 Pages  : ${pages.map(p => p.name).join(', ')}\n`);
}

const frames = collectFrames(pages);
const entities = frames
  .filter(f => f.labels.length >= 2)
  .slice(0, 15) // max 15 entities
  .map(buildEntity);

console.log(`🧩 Phát hiện ${entities.length} entities:\n`);
entities.forEach(({ name, fields }) => {
  console.log(`  📦 ${name} (${fields.size} fields)`);
  fields.forEach((info, fieldName) => {
    if (fieldName !== 'id') {
      console.log(`     - ${fieldName} : ${info.dart}  ← "${info.label}"`);
    }
  });
  console.log('');
});

// Output by format
if (format === 'sql' || format === 'all') {
  console.log('━'.repeat(60));
  console.log('📝 SQL SCHEMA:');
  console.log('━'.repeat(60));
  console.log(generateSQL(entities));
}

if (format === 'dart' || format === 'all') {
  console.log('━'.repeat(60));
  console.log('🎯 DART MODELS (Freezed):');
  console.log('━'.repeat(60));
  console.log(generateDart(entities));
}

if (format === 'json' || format === 'all') {
  console.log('━'.repeat(60));
  console.log('📋 JSON SCHEMA:');
  console.log('━'.repeat(60));
  console.log(generateJSON(entities));
}
