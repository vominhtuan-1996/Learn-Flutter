# Figma Projects

Xem danh sách projects trong team hoặc files trong project.

## Instructions

Phân tích argument để xác định:

**Xem projects của team:**
- Gọi `get_team_projects` với `team_id`
- Team ID lấy từ URL Figma: `figma.com/files/team/<team_id>/...`

**Xem files trong project:**
- Gọi `get_project_files` với `project_id`
- Project ID lấy từ URL Figma: `figma.com/files/project/<project_id>/...`

## Output format

**Team projects:**
```
📁 Projects của team <team_id>:
  - [<id>] <name>
```

**Project files:**
```
📄 Files trong project <project_id>:
  - [<key>] <name> — cập nhật: <last_modified>
```

## Example

`/figma-projects team 123456789`
`/figma-projects project 987654321`
