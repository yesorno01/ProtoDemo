---
name: "daily-report"
description: "Generate daily/weekly reports from Feishu Bitable or Tencent Docs spreadsheets. Invoke when user mentions 日报/周报 with a document URL, or asks to summarize work data into a report."
---

# Daily/Weekly Report Generator

Generate structured daily or weekly reports from online spreadsheets (Feishu Bitable or Tencent Docs).

## When to Use

- User provides a Feishu Bitable URL and asks for 日报/周报 generation
- User provides a Tencent Docs URL and asks for 日报/周报 generation
- User mentions "日报" or "周报" with a document reference
- User needs to summarize spreadsheet data into report format

## Default Data Source

The default Feishu Bitable URL for daily/weekly reports:

```
https://my.feishu.cn/wiki/QXwYwtQ3RiPzDRkXHC1c758Bnrf?table=tblyH94WEPPLz45C&view=vewtjftMSX
```

- `app_token`: `QXwYwtQ3RiPzDRkXHC1c758Bnrf`
- `table_id`: `tblyH94WEPPLz45C`
- `view_id`: `vewtjftMSX`

When the user says "日报" or "周报" without providing a URL, use this default source automatically. Only ask for a URL if the user explicitly wants to use a different document.

## Step 1: Identify Data Source

Determine the document type from the URL (use the default URL above if none provided):

| URL Pattern | Source | Key Extraction |
|-------------|--------|----------------|
| `feishu.cn/wiki/xxx?table=yyy&view=zzz` | Feishu Bitable | `app_token`=xxx, `table_id`=yyy, `view_id`=zzz |
| `feishu.cn/base/xxx` | Feishu Bitable | `app_token`=xxx |
| `docs.qq.com/sheet/xxx` | Tencent Docs | `file_id`=xxx |

## Step 2: Read Data

### Feishu Bitable (Preferred)

Use Feishu MCP tools in this order:

1. **Get field structure**: Call `mcp_feishu-wiki-mcp_bitable_v1_appTableField_list`
   - `path.app_token`: extracted from URL
   - `path.table_id`: extracted from URL
   - `params.view_id`: extracted from URL (optional)

2. **Query records**: Call `mcp_feishu-wiki-mcp_bitable_v1_appTableRecord_search`
   - `path.app_token`: same as above
   - `path.table_id`: same as above
   - `params.page_size`: 500 (max)
   - For daily report: filter by today's date
   - For weekly report: filter by this week's date range
   - If `has_more` is true, continue with `page_token`

3. **Date filtering**: Fetch ALL records (page_size=500) and filter locally by date.
   - **IMPORTANT**: Do NOT use the `filter` parameter with `isGreaterEqual`/`isLess` on date fields — the Feishu Bitable API does not reliably support these operators on DateTime fields.
   - Instead, fetch all records sorted by date descending, then filter in code by comparing the timestamp value.
   - Date field values are Unix timestamps in milliseconds, stored as midnight in the user's timezone (CST/UTC+8 for China).
   - **CRITICAL: Timezone handling** — Feishu stores dates as midnight in the user's timezone. To correctly convert:
     - Timestamp to date (CST): `new Date(timestamp + 8*3600*1000).toISOString().slice(0,10)` — MUST add UTC+8 offset before converting
     - Date string to timestamp (CST): `new Date(dateStr + "T00:00:00+08:00").getTime()` — MUST use timezone-aware parsing
     - Example: `1782230400000` → `new Date(1782230400000 + 28800000).toISOString().slice(0,10)` = `"2026-06-24"` (NOT `"2026-06-23"`)
     - Wrong way: `new Date(1782230400000).toISOString().slice(0,10)` = `"2026-06-23"` (off by 1 day due to timezone)

### Tencent Docs (Fallback)

Use `tencent-docs` skill tools. If MCP access fails, ask user to export as CSV/Excel and read locally.

## Step 3: Parse and Analyze Data

### Field Mapping

Auto-detect field semantics from field names:

| Semantic | Common Field Names | Type |
|----------|-------------------|------|
| Date | 日报日期, 日期, date | DateTime |
| Submitter | 提交人, 姓名, owner | User |
| Progress | 后端整体进度, 整体进度, progress | Progress/Number |
| Work Content | 后端工作内容, 工作内容, 今日工作 | Text |
| Product Design | 产品设计, 产品, design | Text |
| Other Work | 其他工作, 其他 | Text |
| Blocker | 阻塞, 问题, blocker | Text |
| Notes | 备注, 说明, notes | Text |

### Text Field Parsing

Work content fields often contain numbered items with completion percentages:
- Parse lines like `1、询比价接口开发完成度90%` → extract task name and progress
- Group tasks by completion status: completed (100%), in-progress (<100%), not started (0%)

### Progress Field

Progress fields store values as decimals (0.6 = 60%). Convert to percentage for display.

## Step 4: Generate Report

### Daily Report Template

Plain text format, NO tables, NO progress bars, NO markdown headers:

```
{YYYY-MM-DD}
整体：
{module_1_summary_line}
{module_2_summary_line}
...

后端
1、{task_1}
2、{task_2}
...

产品设计
1、{task_1}
2、{task_2}
...

其他工作
{other_work_content}

阻塞
{blockers}

备注
{notes}
```

**Overall summary rules**:
- Write one summary line per major module/project, each on its own line
- Each summary line should describe: module name + current status + progress + dependencies
- Example: "优采功能业务测试中，整体进度以测试为准，后端无遗留问题"
- Example: "长协-需求征集开发完成，整体80%，同步发起联调，联调进度以前端为准"
- Example: "数据服务收费需求完成开发100%，联调进度以前端为准"
- Infer module names from work content keywords (优采, 长协, 数据服务, 询比价, etc.)
- If progress field exists, use it as reference but write a descriptive sentence, NOT just a percentage

**Category section rules**:
- Use short category names: "后端" (not "后端工作内容"), "产品设计" (not "产品设计工作内容")
- Only include sections that have content — omit empty sections entirely
- "其他工作", "阻塞", "备注" sections: only show if the field has content, otherwise omit

**Task formatting rules**:
- Keep the original numbered format from the source data: `1、xxx 100%`
- Preserve the exact text from the work content field, including completion percentages
- Do NOT reformat into tables or add extra decoration
- Remove trailing `\n` and empty lines from source text

### Weekly Report Template

```
各位领导、老师好，本周工作情况汇报如下：

本周进展：{各模块整体进展一句话概括，含关键进度百分比}。

本周主要工作进展：
1、{模块1名称}：{本周该模块主要工作内容及进展，含完成百分比}。
2、{模块2名称}：{本周该模块主要工作内容及进展，含完成百分比}。
3、{模块3名称}：{本周该模块主要工作内容及进展，含完成百分比}。
4、其他：{阻塞、备注等需要特别说明的事项}。

下周重点工作安排：
1、{模块1名称}：{下周该模块重点计划}。
2、{模块2名称}：{下周该模块重点计划}。
3、{模块3名称}：{下周该模块重点计划}。
```

**Weekly report formatting rules**:
- Opening: 固定使用"各位领导、老师好，本周工作情况汇报如下："
- 本周进展: 一句话概括各模块整体进展，包含关键进度百分比
- 本周主要工作进展: 按模块分组（优采、长协、数据服务、询比价等），每个模块一段，汇总该模块本周所有工作及进度变化
- 模块名称从工作内容关键词推断（优采、长协、数据服务、询比价等）
- 其他: 将阻塞、备注等需要特别说明的事项放在"其他"条目中
- 下周重点工作安排: 按模块分组，基于本周未完成项和阻塞推断下周计划
- 每个模块的工作内容要汇总精炼，不要逐条罗列每日重复项，突出进度变化
- NO tables, NO progress bars, NO markdown headers — use plain text with Chinese numbering

### Report Generation Rules

1. **Daily report**: Show all records for the specified date, grouped by submitter
2. **Weekly report**: Show each day's work chronologically, then summarize completed/in-progress items
3. **NO tables, NO progress bars, NO markdown headers** — use plain text with Chinese numbering
4. **Overall summary**: Write a concise summary per module based on progress and work content, NOT just a percentage
5. **Task extraction**: Keep original numbered items from text fields as-is, including percentages
6. **Weekly summary**: Calculate progress delta, list completed vs in-progress items
7. **Next week plan**: Infer from unfinished tasks and blockers
8. **Date format**: Use `YYYY-MM-DD` (e.g., `2026-05-27`)
9. **Empty fields**: If a field has no content, omit that section entirely (do not show "无" for work content fields)

## Step 5: Output

Offer these output options to the user:

1. **Display inline** — Show report directly in conversation
2. **Save to local file** — Save as `reports/日报-YYYYMMDD.md` or `reports/周报-YYYYMMDD-YYYYMMDD.md`
3. **Write back to Feishu** — Use `mcp_feishu-wiki-mcp_bitable_v1_appTableRecord_create` or create a Feishu Doc

## Important: Empty Records Handling

When querying Feishu Bitable, some records may return with only `日报日期` and `提交人` fields but **missing work content fields** (后端工作内容, 产品设计, etc.). This happens when:

1. Records were pre-created as templates (batch-created with dates but no content filled in yet)
2. The Feishu app (tenant_access_token) lacks field-level read permission for certain records

**Detection**: A record is considered "empty" if all work content fields (后端工作内容, 产品设计, 其他工作) are absent from the `fields` object.

**Handling**:
- If the target date record is empty, explicitly tell the user: "该日期暂无日报内容，可能尚未填写"
- Do NOT fall back to earlier dates silently
- If ALL recent records are empty, show the most recent record that has content and note the date

## Error Handling

| Error | Code | Solution |
|-------|------|----------|
| Permission denied | 99991672 | Ask user to add the Feishu app as collaborator on the Bitable |
| Token expired | 99991663 | Ask user to check Feishu MCP configuration and refresh token |
| Not found | 1770002 | Verify app_token and table_id from URL |
| Tencent Docs auth fail | 400006 | Ask user to re-authorize or export as CSV |
| Empty record fields | - | Record exists but content fields are empty — tell user the date has no content yet |

## Example Interactions

**User**: "帮我生成今天的日报 https://my.feishu.cn/wiki/QXwYwtQ3RiPzDRkXHC1c758Bnrf?table=tblyH94WEPPLz45C&view=vewtjftMSX"

**Agent**:
1. Extract: app_token=`QXwYwtQ3RiPzDRkXHC1c758Bnrf`, table_id=`tblyH94WEPPLz45C`, view_id=`vewtjftMSX`
2. Call `bitable_v1_appTableField_list` to get field structure
3. Call `bitable_v1_appTableRecord_search` with date filter for today
4. Parse work content, progress, blockers
5. Generate and display daily report

**User**: "生成本周周报"

**Agent**:
1. Use the same document URL from context (or ask if not provided)
2. Calculate this week's Monday-Sunday date range
3. Query all records in the range
4. Aggregate and generate weekly report with progress trends
