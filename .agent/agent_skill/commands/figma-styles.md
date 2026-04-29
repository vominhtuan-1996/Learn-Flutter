# Figma Styles

Lấy toàn bộ design tokens (màu sắc, typography, effects) từ Figma file.

## Instructions

Gọi tool `get_file_styles` với `file_key`.

Phân loại styles theo type: FILL (màu), TEXT (font), EFFECT (shadow/blur), GRID.
Nếu user muốn, tự động convert sang:
- CSS variables
- Tailwind config (`theme.extend`)
- TypeScript constants

## Output format

```
🎨 Styles trong file <file_key>:

FILL (màu sắc):
  - <name>: #<hex> (key: <style_key>)

TEXT (typography):
  - <name>: <font-family> <font-size>/<line-height> (key: <style_key>)

EFFECT:
  - <name>: <effect description>
```

## Example

`/figma-styles MO4JcMsNudV8vtIwmCPGoc`
`/figma-styles MO4JcMsNudV8vtIwmCPGoc → tailwind`
