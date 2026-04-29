# Figma Export

Lấy URL export ảnh của các node trong Figma file.

## Instructions

Gọi tool `get_images` với:
- `file_key`: key của file Figma
- `ids`: danh sách node IDs cần export
- `format`: định dạng ảnh — mặc định `png`, hỗ trợ `jpg`, `svg`, `pdf`
- `scale`: tỉ lệ — mặc định `1`, dùng `2` cho @2x, `3` cho @3x

Trả về danh sách URL để download ảnh.

## Output format

```
🖼️ Export URLs (<format> @<scale>x):
  - <node_id>: <url>
  - <node_id>: <url>
```

## Example

`/figma-export MO4JcMsNudV8vtIwmCPGoc 0:1`
`/figma-export MO4JcMsNudV8vtIwmCPGoc 0:1,0:2 format=svg`
`/figma-export MO4JcMsNudV8vtIwmCPGoc 0:1 format=png scale=2`
