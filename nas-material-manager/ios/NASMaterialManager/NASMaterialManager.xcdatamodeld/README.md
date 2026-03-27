# Core Data 模型配置

在 Xcode 中创建以下实体：

## Folder 实体

| 属性 | 类型 | 必填 |
|------|------|------|
| id | UUID | 是 |
| path | String | 是 |
| name | String | 是 |
| parentFolderID | UUID | 否 |

关系：
- childrenFolders: To Many -> Folder (inverse: parentFolder)
- materials: To Many -> Material (inverse: folder)

## Material 实体

| 属性 | 类型 | 必填 |
|------|------|------|
| id | UUID | 是 |
| filename | String | 是 |
| path | String | 是 |
| title | String | 否 |
| descriptionText | String | 否 |
| usageTag | String | 是 |
| viralTag | String | 是 |
| fileSize | Integer 64 | 否 |
| fileModifiedAt | Date | 否 |
| localUpdatedAt | Date | 是 |

关系：
- folder: To One -> Folder (inverse: materials)
