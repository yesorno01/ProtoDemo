# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

## 5. PPT 生成默认工作流（frontend-slides + dom-to-pptx）

当用户要求生成 PPT / 演示文稿 / 汇报材料时，**默认采用** `frontend-slides` 技能 + `dom-to-pptx` 工作流，除非用户明确指定其他方式。完整教程见 `docs/使用frontend-slides和dom-to-pptx生成PPT教程.md`。

### 工作流（三步，不可跳过）

1. **设计 HTML 演示文稿** → 调用 `frontend-slides` 技能生成视觉精美的 HTML
2. **按 dom-to-pptx 规范改造 HTML** → 见下方兼容规范（frontend-slides 产出不能直接导出，必须改造）
3. **本地服务器导出** → `npx serve .` 启动，浏览器打开后点击「导出 PPTX」按钮，生成可编辑 `.pptx`

### dom-to-pptx 兼容规范（强制）

每个 `.slide` 元素必须满足：

| 项 | 要求 |
|---|---|
| 尺寸 | `width: 1920px; height: 1080px` 固定像素 |
| 容器定位 | `position: relative; overflow: hidden` |
| 子元素定位 | `position: absolute` + `left/top/width/height`（禁用 flex/grid/clamp 布局） |
| 单位 | 仅 `px`（禁用 rem/em/vw/vh/clamp/vmin/vmax） |
| 样式方式 | 内联 `style=""`（不用 `<style>` 块或 class 定义幻灯片内容样式） |
| 渐变 | 仅 `linear-gradient`（禁用 radial-gradient / conic-gradient） |
| 字体 | Google Fonts `<link>` 加 `crossorigin="anonymous"`；`font-size` 用 px；有 web-safe 回退（如 `Arial, sans-serif`） |
| 图片 | 必须 `https://` 或 `data:` URI；不加 `loading="lazy"`；禁用相对路径与 `file://` |

**禁用特性**：`animation`、`transition`、`@keyframes`、`transform: translate/scale/skew/matrix`（`rotate` 可用）、`backdrop-filter`、`clip-path`、`mix-blend-mode`、所有视口单位。

**结构约束**：`.slide` 不得位于任何 CSS `transform` 的祖先元素内。

### 导出流程

1. 在 HTML 文件所在目录执行 `npx serve .`（默认 3000 端口）
2. 浏览器打开 `http://localhost:3000/<文件名>.html`
3. 确认所有幻灯片显示正常后，点击右上角「导出 PPTX」按钮
4. 用 PowerPoint 打开生成的 `.pptx`，检查：文字完整、布局一致、颜色正确、字体嵌入

### 常见问题速查

| 现象 | 原因 | 解决 |
|---|---|---|
| 字体回退为 Arial | Google Fonts 未加 `crossorigin` | `<link>` 添加 `crossorigin="anonymous"` |
| 图片缺失 | 相对路径或 CORS 受限 | 改用 `https://` CORS 图片或 `data:` URI |
| 布局错位 | 用了 transform translate 或视口单位 | 改用 `position: absolute` + 固定 px |
| 渐变丢失 | 用了 radial/conic-gradient | 改用 `linear-gradient` |
| 动画 / 毛玻璃消失 | dom-to-pptx 只捕获静态状态 | 正常行为；毛玻璃用半透明叠加 div 模拟 |
| 文字溢出 | PPTX 文字渲染与浏览器有差异 | 减少文字量，留更多边距 |

### 需要完整细节时

若需完整 HTML 模板、frontend-slides 的 12 种风格选择表、SVG 矢量导出（`svgAsVector: true`）、验证器脚本等细节，读取 `docs/使用frontend-slides和dom-to-pptx生成PPT教程.md`。
