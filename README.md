# ProtoDemo

面向**项目经理**与**产品经理**的技能驱动型产研工作台。基于 Trae IDE 的可扩展技能体系，一站式产出 PPT 汇报、流程图、页面原型、需求文档、日报周报、信息图等材料，并按类型归档到独立目录，保障项目结构清晰。

## 适用角色

- **项目经理（PM）**：项目立项、进度汇报、日报周报、流程梳理
- **产品经理（PO）**：需求文档、页面原型、UI/UE 设计、信息图、演示文稿

## 项目结构

```
ProtoDemo/
├── .trae/skills/              # Trae IDE 技能配置（可扩展）
│   ├── pm-01-daily-report-日周报/
│   ├── po-01-to-prd-需求文档/
│   ├── po-02-baoyu-diagram-流程图/
│   ├── po-03-baoyu-infographic-模块图/
│   ├── po-04-frontend-design-原型/
│   ├── po-05-frontend-slides-ppt/
│   ├── po-06-brainstorming-superpower-头脑风暴/
│   ├── po-07-web-design-engineer-原型/
│   └── po-09-ui-ux-pro-max-前端UiUe设计原型/
├── .agent/skills/
│   └── dom-to-pptx-skill/           # HTML → PPTX 导出技能
├── docs/                      # 原始需求文档与教程（输入材料）
├── design-system/             # UI/UE 规范目录（原始或总结的规范）
│   ├── asia/                  # asia 主题 PPT 设计规范
│   └── minerals/              # 矿产配色规范、视觉规范
├── ppt/                       # 产出：PPT（HTML + PPTX）
├── diagram/                   # 产出：流程图/架构图/时序图
├── prototype/                 # 产出：页面原型
├── prd/                       # 产出：需求文档（PRD）
├── report/                    # 产出：日报/周报
├── infographic/               # 产出：信息图/模块图
├── temp/                      # 临时文件目录（可定期清理）
├── CLAUDE.md                  # AI 编码行为准则
├── OUTPUT_RULES.md            # 产出材料目录规范（强制）
├── README.md
└── package.json
```

## 可扩展技能体系

| 技能 | 用途 | 产出目录 |
|------|------|----------|
| pm-01-daily-report-日周报 | 日报/周报生成 | `report/` |
| po-01-to-prd-需求文档 | 需求文档（PRD）生成 | `prd/` |
| po-02-baoyu-diagram-流程图 | SVG 流程图/架构图/时序图 | `diagram/` |
| po-03-baoyu-infographic-模块图 | 信息图/模块图 | `infographic/` |
| po-04-frontend-design-原型 | 前端界面原型设计 | `prototype/` |
| po-05-frontend-slides-ppt | HTML 演示文稿生成 | `ppt/` |
| po-06-brainstorming-superpower-头脑风暴 | 头脑风暴辅助 | `temp/` |
| po-07-web-design-engineer-原型 | Web 视觉原型 | `prototype/` |
| po-09-ui-ux-pro-max-前端UiUe设计原型 | UI/UE 设计原型 | `prototype/` |
| dom-to-pptx-skill | HTML DOM 转 PPTX | 配合 `ppt/` 使用 |

新增技能时，将技能目录放入 `.trae/skills/`，并在上表登记用途与产出目录映射。

## 输入与规范

| 目录 | 说明 |
|------|------|
| `docs/` | 上传的原始需求文档、立项材料、参考资料 |
| `design-system/` | UI/UE 规范（原始规范文件或总结提炼的规范），包含配色、字体、组件、PPT 设计规范等 |

## 核心工作流

### PPT 生成（默认三步工作流）

```
需求 → frontend-slides 生成 HTML → dom-to-pptx 改造 → 本地服务器预览 → 导出 PPTX
```

1. **设计**：使用 `po-05-frontend-slides-ppt` 技能生成视觉精美的 HTML 演示文稿
2. **改造**：按 `dom-to-pptx-skill` 规范调整 HTML 结构（固定尺寸、内联样式、绝对定位）
3. **导出**：启动本地服务器，浏览器预览后点击「导出 PPTX」按钮

完整教程见 [使用frontend-slides和dom-to-pptx生成PPT教程](docs/使用frontend-slides和dom-to-pptx生成PPT教程.md)。

### 其他材料生成

- **流程图/架构图**：调用 `po-02-baoyu-diagram-流程图`，产出 SVG/PG 保存到 `diagram/`
- **页面原型**：调用 `po-04/frontend-design` 或 `po-07/web-design-engineer`，产出到 `prototype/`
- **需求文档**：调用 `po-01-to-prd-需求文档`，产出到 `prd/`
- **日报周报**：调用 `pm-01-daily-report-日周报`，产出到 `report/`

## 快速开始

### 安装依赖

```bash
npm install
```

### 启动本地服务器

```bash
npx serve .
```

默认访问 `http://localhost:3000`。

### 导出 PPTX

1. 浏览器打开 HTML 文件
2. 点击页面上的「导出 PPTX」按钮
3. 等待浏览器下载 `.pptx` 文件

## 设计规范

项目规范位于 `design-system/`，矿产品牌核心色板：

| 色名 | HEX | 用途 |
|------|-----|------|
| 矿业金 | `#B89A4B` | 标题、强调、关键数据 |
| 深棕褐 | `#6B4423` | 副标题、边框装饰 |
| 石墨灰 | `#4A4A4A` | 正文文字 |
| 浅米白 | `#F5F0E6` | 页面背景 |
| 浅灰卡 | `#E8E4DC` | 卡片背景 |
| 边框灰 | `#D4CFC4` | 边框线、分隔线 |

## 产出规范

所有产出材料必须按类型归档到对应目录，**不得散落在根目录或随意放置**。临时文件统一放入 `temp/`，可定期清理。完整规则见 [OUTPUT_RULES.md](OUTPUT_RULES.md)。

## dom-to-pptx 兼容要点

将 HTML 演示文稿改造为可导出格式时，核心规则：

- 幻灯片尺寸：`1920px × 1080px`（固定像素）
- 样式：纯内联 `style=""`，不用 `<style>` 块或 class
- 定位：`position: absolute` + `left/top/width/height`（px）
- 单位：仅 `px`，不用 rem/em/vw/vh/clamp
- 渐变：仅 `linear-gradient`
- 图片：`https://` 或 `data:` URI
- 字体：Google Fonts 须加 `crossorigin="anonymous"`
- 禁止：animation、transition、backdrop-filter、clip-path、transform: translate/scale

完整白名单见 `.agent/skills/dom-to-pptx-skill/reference/STYLE_WHITELIST.md`。
