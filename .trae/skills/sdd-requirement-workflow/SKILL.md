---
name: sdd-requirement-workflow
description: "SDD 需求分析工作流编排手册：驱动 asiainfo-sdd V2 模板工程的 Step 0→8 需求分析流水线（状态检查→技能初始化→分发资产→画像→渲染→上下文→新变更→proposal+specs→设计交接）。本技能是 sdd-requirement-workflow 智能体的唯一执行手册，最高加载优先级。"
version: 1.0.0
updated: 2026-06-26
author: 严灿平
---

# sdd-requirement-workflow — SDD 需求分析工作流编排手册

本技能是 `sdd-requirement-workflow` 智能体的**唯一执行手册**。智能体的身份、触发规则、硬约束与"最高加载优先级"声明见其系统提示词（newprompt.md）；本文规定 **Step 0→8 的完整执行细节**，是 8 步流程的唯一权威。

> 约定：`<workspace>` = 工程根（含 `project-profile.yaml`）；`<skills>` = skills 根（Trae 下为 `.trae/skills/`）；`{change}` = 当前变更名（kebab-case）。
> 补充参照：模板工程根的 `sdd-workflow.md`（全景图/依赖/产物/旁路/速查/断点续跑），非必读。

---

## 硬约束（重申，与系统提示词一致）

1. **禁用 `aispec` CLI**：不调用 `aispec render/init/update/check/--version` 等。
2. 渲染统一用（**必须显式传 `--templates-dir`**，否则报"无法定位模板根目录"）：
   ```
   python3 <skills>/.scripts/render.py --all --templates-dir <skills>/.templates/
   ```
3. render.py 渲染出的 MCP 配置（`.vscode/mcp.json` 等）**不含 `aispec` server**；如需由用户手动添加。
4. `openspec` CLI（`openspec init --tools` / `openspec new change` / `openspec status`）保留。

---

## 顺序约束（不可跳步）

- **Step 2 ≺ Step 4**：render.py 的模板输入 `.templates/` 由 sdd-distribute-assets 分发，不分发则无法渲染。
- **Step 4 ≺ Step 5**：context-bootstrap 读写 `.ai-sdd/context/`，其骨架由 render 的 `--context` 建立。
- **openspec init（Step 3 Phase 7）≺ Step 6**：`openspec new change` 需要 `openspec/specs`、`openspec/changes` 目录已存在。
- **Step 5 ≺ Step 6**：ai-new-change 的 context-discover/update 依赖已建好的通用 `.ai-sdd/context/`。

## 流程边界（硬约束 — 不可越界）

- **本智能体只负责 Step 0→8 的需求分析编排，禁止执行 design/tasks/apply 等下游阶段的 skill。**
- Step 7 `ai-proposal-change` 完成后，本智能体的产物工作结束；**禁止自动衔接 `ai-design-change`**。
- Step 8 的唯一动作是"提醒用户切换设计分身智能体"，不调用任何 design skill。
- 即使 `ai-proposal-change` 的 mode=auto 默认自动接 specs，**specs 完成后必须停止**，不向 design 延伸。
- 任何"继续"指令在 specs 完成后，默认解释为"进入 Step 8 提示切换分身"，**不得解释为"由本智能体执行 design"**。
- 如需本智能体在 specs 完成后继续动作，用户必须**显式声明"在本分身内执行 design"**才允许；否则一律停止并提示切换分身。

---

## 计时与执行日志

记录每步执行耗时，便于定位慢环节（通常是 context-bootstrap / ai-proposal-change）。
- **日志**：`.ai-sdd/artifacts/orchestrator/timing.jsonl`（append-only；断点续跑可续写）
- **helper**：`<skills>/_shared/orchestrator-timer.py`（由 sdd-distribute-assets 随 `_shared/` 分发，**Step 2 后可用**）
- **每步包裹**（Step 2 起）：
  1. 开始 `python3 <skills>/_shared/orchestrator-timer.py begin` → 读出打印的毫秒数（**字面量记下**）
  2. 执行该步
  3. 结束 `python3 <skills>/_shared/orchestrator-timer.py end <毫秒数> "Step N" "<名称>" <ok|skip|fail> ".ai-sdd/artifacts/orchestrator/timing.jsonl"`
- **关键**：每次 bash 是独立 shell，`B=$(begin)` 不能跨调用保留——必须把 begin 打印的数字读出来当字面量填进 end。
- **Step 0/1**（`_shared/` 分发前，仅首次初始化时）：用内联 `python3 -c "import time;print(int(time.time()*1000))"` 取毫秒并 append 同一日志；这两步通常仅数秒，也可暂不计时。
- 跳过的步骤（如 preset 快速通道命中）记 `status=skip`；失败记 `fail` 并在第 7 个参数注明原因。
- 完成/暂停时：`python3 <skills>/_shared/orchestrator-timer.py report ".ai-sdd/artifacts/orchestrator/timing.jsonl"` 生成计时表。

---

## Step 0 · 项目状态检查（**必须执行，不可跳过**）

**0.1 上下文目录检查**
- 检查工程根是否已包含 `.ai-sdd/`：
  - **存在** → 依据**各技能自带的"恢复机制"**判断断点续跑（每个技能以其产物文件存在性定义恢复点，不存在统一的 orchestrator-state 文件），继续后续检查。
  - **不存在** → 使用 AskUserQuestion 询问是否初始化 SDD 工作流来分析需求：
    - 用户确认 → 执行完整 8 步流程。
    - 用户拒绝 → 退化为代码助手模式。

**0.2 技能目录完整性检查**
- 检查 `<skills>/` 是否存在且核心技能齐全，核心文件至少包含：
  `ai-sdd-init/SKILL.md`、`sdd-distribute-assets/SKILL.md`、`sdd-distribute-assets/scripts/render.py`、`_shared/`。
  - **缺失** → 仅对缺失技能重新执行 Step 1 的 MCP `install_skill` 单技能补装。**禁止清空整个 `<skills>/` 目录**（会误删已分发的 `.schemas/.templates/.scripts/_shared` 与用户自定义内容）。
  - **齐全但受管目录未分发**（`.schemas/.templates/.scripts` 缺失）→ 进入 Step 2 补充分发。
  - **齐全且已分发** → 直接进入 Step 3。

**0.3 需求文档收集**
- 若用户提供了需求文档路径或需求描述，记录路径，在 Step 6 自动使用。

**0.4 启动流程**
- 不询问模式选择，输出项目状态摘要表后直接进入 Step 1。

**摘要表字段**：`.ai-sdd/` 是否存在 | 技能目录是否齐全 | 受管资产（.schemas/.templates/.scripts）是否已分发


## Step 1 · 技能初始化（自动执行）

通过 MCP `install_skill`（server: `mcp_skills-platform`）下载全部技能，保存到 `<skills>/`。

**参数**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `skillCode` | string | 是 | 技能代码 |
| `installScope` | string | 否 | `project`（项目级）或 `user`（用户级），默认 `user` |
| `projectDirectory` | string | 否 | 工程根目录，`installScope=project` 时使用 |
| `targetDirectory` | string | 否 | 安装目标目录，优先级最高 |
| `overwrite` | boolean | 否 | 覆盖已安装目录 |

**调用示例**（`targetDirectory` 固定指向 `<skills>/`）：

```json
{
  "skillCode": "ai-sdd-init",
  "installScope": "project",
  "projectDirectory": "<工程根目录绝对路径>",
  "targetDirectory": "<工程根目录>/.trae/skills",
  "overwrite": true
}
```

**技能清单**（共 37 个执行技能，按前缀分组；`ai-admin-upgrade` 为模板工程维护技能，不随需求工作流下发；本编排手册 `sdd-requirement-workflow` 为最高优先级引导技能，已先行加载）：

| 前缀 | 数量 | 技能代码 |
|------|------|----------|
| `ai-*` | 16 | ai-apply-change, ai-archive-change, ai-create-e2e, ai-design-change, ai-new-change, ai-pre-code-review, ai-prepare-change, ai-proposal-change, ai-refine-change, ai-sdd-check, ai-sdd-init, ai-sdd-repo-add, ai-sdd-repo-del, ai-sdd-update, ai-tasks-change, ai-verify-change |
| `code-*` | 3 | code-api-discover, code-arch-scan, code-table-discover |
| `context-*` | 6 | context-bootstrap, context-discover, context-gitcommit, context-harvest, context-review, context-update |
| `openspec-*` | 11 | openspec-apply-change, openspec-archive-change, openspec-bulk-archive-change, openspec-continue-change, openspec-explore, openspec-ff-change, openspec-new-change, openspec-onboard, openspec-propose, openspec-sync-specs, openspec-verify-change |
| `sdd-*` | 1 | sdd-distribute-assets |

**下载完成后校验产物**：`<skills>/ai-sdd-init/SKILL.md`、`<skills>/sdd-distribute-assets/SKILL.md` 等核心文件存在。


## Step 2 · sdd-distribute-assets 分发辅助资产（自动执行）

打开 `<skills>/sdd-distribute-assets/SKILL.md` 完整阅读后按其 Step 1→4 执行，将技能包自带的辅助资产分发到 `<skills>/` 下的受管隐藏目录与共享目录，并构建 `.ai-sdd/` 骨架（等价 `aispec init` 的 `distributeAuxAssets()` + `distributeRootExamples()` + `buildAiSddTree()`，**无 aispec 依赖**）。

**工具固定为 Trae**（skills 目录 = `<skills>/`），不再询问。

**执行命令**（工程根目录下执行）：

```bash
python3 <skills>/sdd-distribute-assets/scripts/distribute_assets.py \
  --skill-dir <skills>/sdd-distribute-assets \
  --workspace . \
  --skills-dir <skills>
```

**校验产物**：`<skills>/.schemas/project-profile.schema.yaml`、`<skills>/.templates/`（含 config/context/ai-sdd-tree）、`<skills>/.scripts/render.py`、`<skills>/_shared/`、`scenarios.example.yaml` 全部存在；脚本退出码为 0。

**重要规则**：
- 仅整体替换 `.schemas/.templates/.scripts/_shared` 四个受管目录，**不清空 skills 根**。
- 本步完成后 render.py 输入（`.templates/`）齐备，**Step 4 才能执行**。


## Step 3 · ai-sdd-init（自动执行）

打开 `<skills>/ai-sdd-init/SKILL.md` 完整阅读，按 Phase 0.5 → 8 执行，并做以下"无 aispec"适配：

- 命中 preset 快速通道（5 个产物都存在）则跳过 Phase 1–4。
- **Phase 1 前置检查**：跳过 `aispec --version` / `npx aispec init` / `aispec init --tools` 相关检查项；`.ai-sdd/.installed-version` 缺失**不阻断**（仅提示）；保留 Python >3.11 + PyYAML 与"干净环境"检查。
- **Phase 3 提问**：优先智能推断填充字段，仅在关键阻塞点（无法推断的组织/项目名称）用 AskUserQuestion 一次性确认；可选字段用默认值。**禁止 schema_version 写成非 "2.1"**。
- **Phase 4 一次性渲染**：**不执行 `aispec render --all`**，改用下方 Step 4 的 render.py 命令完成（Step 4 即 ai-sdd-init Phase 4 的实现，不是独立新阶段）。
- **Phase 5 落档基线**：`cp project-profile.yaml .ai-sdd/.last-update-profile.yaml` 保留执行。
- **Phase 7 OpenSpec 初始化**：`openspec init --tools <tool>` 保留执行；失败不中止，记入摘要。


## Step 4 · render.py 渲染（自动执行，= Step 3 Phase 4）

从工程根目录执行（render.py 由 Step 2 分发到 `.scripts/`，**必须显式指定模板目录**）：

```bash
python3 <skills>/.scripts/render.py --all --templates-dir <skills>/.templates/
```

`--all` = `--config` + `--context` + `--ai-sdd-tree`，等价原 `aispec render --all`：

| 步骤 | 内容 | 输出 |
|------|------|------|
| 配置 | 读 `.templates/config/`，按 `tools.mcp_clients` 渲染 | `AGENTS.md`、`CLAUDE.md`、`openspec/config.yaml`、各 MCP 配置 |
| context 骨架 | 读 `.templates/context/`，原样复制各骨架 `.md`（仅新增：已存在跳过） | `.ai-sdd/context/` 全套 + `context-index.yaml` |
| ai-sdd-tree | 读 `.templates/ai-sdd-tree/`，补齐 `lib/tools/template/raw/requirements/artifacts` | `.ai-sdd/` 子目录树 |

**校验产物**：`openspec/config.yaml`、`AGENTS.md`、`CLAUDE.md`、MCP 配置文件存在；占位符 `{{...}}` 残留为 0；YAML/JSON 语法通过。

> MCP 配置**不含 `aispec` server**（本工作流不依赖 aispec）；若用户需要，提示其手动在 `.vscode/mcp.json` / `opencode.json` / `.cursor/mcp.json` / `.mcp.json` 中添加。
> 若报"无法定位模板根目录"，确认已传 `--templates-dir <skills>/.templates/`。


## Step 5 · context-bootstrap（自动执行）

打开 `<skills>/context-bootstrap/SKILL.md` 完整阅读。
- **模式默认值**：有需求文档 → `document-ingest`；否则 → `code-discover`。
- 通用前置：读 profile.yaml + context-index.yaml，建 `.ai-sdd/artifacts/context-bootstrap/<ts>-<mode>-report.md`。
- 按通用合并规则写入 `.ai-sdd/context/`，同步 index 的 summary/scope/stage/load_policy/triggers。
- 触发子技能：`architecture-scan` → **code-arch-scan**；`code-discover` → **code-api-discover** + **code-table-discover**；`document-ingest` → **context-update**。
- 质量门禁：单一特例不升级通用 / 纯命名不进 context / 硬编码须附说明 / entry-guided 独立生成。
- **无 aispec 适配**：忽略 `aispec context bootstrap --prompt` 注入来源，按用户对话输入处理。


## Step 6 · ai-new-change（自动执行）

打开 `<skills>/ai-new-change/SKILL.md` 完整阅读。
- **若 Step 0 用户提供了需求文档路径，自动使用该路径**。
- **需求来源默认**：`.md` 文件（自动检测）；未提供则文本模式。
- `.docx/.pdf` 调：`python3 <skills>/_shared/MarkDocsDown.py "<path>"`。
- Phase 1–4：格式转换 + 归档 → 需求采集（调 **context-discover**）→ 用户审阅（确认门）→ 上下文更新（调 **context-update**）。
- Phase 5：`openspec new change "<change-name>"`（openspec CLI，保留）。
- 校验产物：`openspec/changes/<change-name>/` 目录。


## Step 7 · ai-proposal-change（自动执行）

打开 `<skills>/ai-proposal-change/SKILL.md` 完整阅读。
- **mode 默认值**：`auto`（proposal 完成后自动接 specs）。
- 按需加载 `_shared/sdd-change-gate.md` + `_shared/sdd-context-loading.md`。
- Phase 1–6 按 `references/proposal-flow.md` 生成 proposal（最多 5 轮自检 + 用户确认）。
- Phase 7 按 `references/specs-flow.md` 生成 specs。
- 校验产物：`proposal.md` + `specs/**/*.md`（位于 `openspec/changes/<change-name>/`）。


## Step 8 · 设计阶段交接（切换设计分身智能体）

> **硬约束**：本步骤是需求分析工作流的终点，**严禁由本智能体执行任何 design skill（`ai-design-change` 等）**。

- 前 7 步（需求分析阶段）已完成，本智能体的编排工作到此结束。
- **唯一允许的动作**：向用户输出"切换设计分身智能体"的提示信息，并附产物清单。
- **禁止动作**：
  - 调用 `ai-design-change` / 生成 `design-brief.md` / `design-draft.md` / `design.md` / `contracts.md`
  - 调用 `ai-tasks-change` / `ai-apply-change` / `ai-refine-change` / `ai-verify-change` / `ai-archive-change`
  - 在用户未明确"在本分身内执行 design"的情况下，因"继续"指令而进入下游阶段
- **提示用户切换设计分身智能体**完成：概要设计（High-Level Design）、详细设计（Detailed Design）、接口契约设计（API Contracts）、设计评审与自检。
- 后续编码阶段用 `ai-tasks-change` / `ai-apply-change`（由设计/编码分身驱动，不在本流程内）。
- 输出提示信息：需求分析阶段已完成，产物已就绪。你可以切换设计分身智能体继续概要/详细/接口契约设计；也可以让我帮你输出一份详细需求说明书。


## 完成时输出

- 阶段执行结果表（Step 1–7，7 行）
- 步骤计时表（`timing.jsonl` 的 report 输出，标注最慢环节）
- 全部产物路径清单
- 关键决策记录（含默认值使用说明）
- MCP 配置提示：已渲染的 MCP 配置不含 `aispec` server；如需要请手动添加
- 下一步建议：
  - 开新需求前自检环境 → `ai-sdd-check`
  - 改了 `project-profile.yaml` → `ai-sdd-update`
  - 进入设计/编码 → 切换设计分身智能体，或 `ai-tasks-change` / `ai-apply-change`
- 已知风险 / 待人工确认


<!-- skills-platform-usage-reporting -->
## Usage Reporting

When this Skill is selected for a real task and the MCP tool `report_skill_invocation` is available, call it once at the start with:

```json
{
  "skillCode": "sdd-requirement-workflow",
  "agentName": "qoder",
  "installTarget": "qoder",
  "installScope": "project",
  "workspace": "d:\\IdeaProjects\\workshop",
  "invocationStatus": "STARTED",
  "sourceChannel": "MCP_CALLBACK"
}
```

Do not block the user's task if the reporting tool is unavailable or the callback fails.