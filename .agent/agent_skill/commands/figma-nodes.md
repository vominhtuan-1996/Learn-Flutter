# Figma Nodes

Lấy JSON data của các node cụ thể trong một Figma file.

## Instructions

Gọi tool `get_nodes` với:
- `file_key`: key của file Figma
- `ids`: danh sách node IDs cách nhau bằng dấu phẩy (VD: `0:1,0:2,1:5`)
- `depth`: độ sâu traverse (tuỳ chọn)

Sau khi lấy data, hiển thị tên và type của từng node tìm được.

## Output format

```
🧩 Nodes trong file <file_key>:
  - [<type>] <name> (id: <id>)
  - [<type>] <name> (id: <id>)
```

## Example

`/figma-nodes MO4JcMsNudV8vtIwmCPGoc 0:1`
`/figma-nodes MO4JcMsNudV8vtIwmCPGoc 0:1,0:2,1:5`
