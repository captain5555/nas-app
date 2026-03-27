# JSON 数据格式规范

## .material_index.json 格式

```json
{
  "version": 1,
  "updated_at": "2026-03-27T10:30:00Z",
  "files": {
    "文件名.jpg": {
      "title": "自定义标题",
      "description": "描述文案",
      "tags": {
        "usage": "used",
        "viral": "viral"
      },
      "updated_at": "2026-03-27T10:25:00Z",
      "file_size": 2150400,
      "file_modified_at": "2026-03-20T15:00:00Z"
    }
  }
}
```

## .sync_version 格式

简单文本文件，内容为 ISO 8601 时间戳：
```
2026-03-27T10:30:00Z
```

## 标签枚举值

- usage: "unused" | "used"
- viral: "not_viral" | "viral"

## 时间格式

所有时间使用 ISO 8601 UTC 格式，后缀 Z
