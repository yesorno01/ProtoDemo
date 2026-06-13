---
name: "daily-report"
description: "Use when user asks to generate daily/weekly reports from Tencent Docs spreadsheets, or when needing to read and summarize data from online documents for report generation."
---

# Daily/Weekly Report Generator

## Overview

This skill guides the agent to read data from Tencent Docs (docs.qq.com) spreadsheets and generate structured daily or weekly reports.

## When to Use

- User provides a Tencent Docs URL and asks for daily/weekly report generation
- User mentions "日报" (daily report) or "周报" (weekly report) with a document reference
- User needs to summarize spreadsheet data into report format

## Prerequisites

1. **Tencent Docs Skill**: Must have `tencent-docs` skill installed and configured
2. **MCP Token**: User must provide valid Tencent Docs MCP token for authentication
3. **Document Access**: The spreadsheet must be accessible (owned by or shared with the user)

## Workflow

### Step 1: Extract Document Info

From the provided URL, extract:
- `file_id` or `sheet_id`: The document identifier from the URL path
  - Example: `DTktxSkVzcFRUeG1C` from `https://docs.qq.com/sheet/DTktxSkVzcFRUeG1C`
- `tab` parameter: Specific sheet tab if provided

### Step 2: Read Spreadsheet Data

Use tencent-docs MCP tools to read the spreadsheet:

```bash
# List available tools
mcporter list tencent-docs

# Get sheet content (adjust tool name based on available tools)
mcporter call "tencent-docs" "sheet.get_content" --args '{"file_id": "<file_id>"}'

# Or use smartcanvas/sheet tools as appropriate
mcporter call "tencent-docs" "get_content" --args '{"file_id": "<file_id>"}'
```

**Note**: If direct MCP access fails (network restrictions, auth issues), ask user to:
1. Export the spreadsheet as Excel/CSV
2. Upload the file to the project directory
3. The agent will read the local file instead

### Step 3: Analyze Data

Identify key data points for the report:
- **Daily Report**: Today's tasks, completed items, blockers, tomorrow's plan
- **Weekly Report**: Week summary, achievements, metrics, next week plan

Common spreadsheet columns to look for:
- Date/Time
- Task/Project name
- Status (completed/in-progress/pending)
- Owner/Assignee
- Progress percentage
- Notes/Comments

### Step 4: Generate Report

Create report in the requested format:

#### Daily Report Template

```markdown
# 日报 - YYYY年MM月DD日

## 今日完成
- [任务1] - 状态 - 备注
- [任务2] - 状态 - 备注

## 进行中
- [任务3] - 进度% - 备注

## 明日计划
- [计划1]
- [计划2]

## 问题与风险
- [问题描述] - [解决方案/需要帮助]
```

#### Weekly Report Template

```markdown
# 周报 - YYYY年MM月DD日 ~ YYYY年MM月DD日

## 本周总结
本周主要围绕[项目/方向]展开工作...

## 完成情况
| 任务 | 状态 | 进度 | 备注 |
|------|------|------|------|
| 任务1 | 已完成 | 100% | |
| 任务2 | 进行中 | 60% | |

## 关键成果
1. [成果1]
2. [成果2]

## 下周计划
- [计划1]
- [计划2]

## 需要协调
- [事项] - [需要的支持]
```

### Step 5: Output Options

- Save to local file: `reports/日报-YYYYMMDD.md`
- Create in Tencent Docs: Use `create_smartcanvas_by_mdx` or `create_doc_by_markdown`
- Display inline in conversation

## Error Handling

| Error | Solution |
|-------|----------|
| Token expired (400006) | Ask user to re-authorize via `references/auth.md` |
| VIP required (400007) | Inform user VIP is needed for this operation |
| File not found | Verify file_id and permissions |
| Network timeout | Suggest exporting to local file instead |

## Example Usage

**User**: "帮我根据这个腾讯文档生成今天的日报: https://docs.qq.com/sheet/DTktxSkVzcFRUeG1C"

**Agent**:
1. Extract file_id: `DTktxSkVzcFRUeG1C`
2. Try MCP: `mcporter call "tencent-docs" "get_content" --args '{"file_id": "DTktxSkVzcFRUeG1C"}'`
3. If successful: Parse data and generate report
4. If failed: Ask user to export as Excel/CSV

## Notes

- Always verify date range with user before generating report
- Ask user if they prefer specific report format/template
- For recurring reports, suggest setting up automation schedule
- Keep report concise - focus on key metrics and actionable items