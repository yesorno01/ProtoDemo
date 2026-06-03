# ProtoDemo

基于 Trae IDE 技能驱动的 PPT 与 原型设计工程，用于快速生成高质量 HTML 演示文稿并导出为 PowerPoint 文件，或者设计页面原型。

## 项目结构

```
ProtoDemo/
├── .trae/skills/              # Trae IDE 技能配置
│   ├── po-01-to-prd-需求文档/
│   ├── po-02-baoyu-diagram-流程图/
│   ├── po-03-baoyu-infographic-模块图/
│   ├── po-04-frontend-design-原型/
│   ├── po-05-frontend-slides-ppt/   # HTML 演示文稿生成
│   ├── po-06-brainstorming-superpower-头脑风暴/
│   └── po-07-web-design-engineer-原型/
├── .agent/skills/
│   └── dom-to-pptx-skill/           # HTML → PPTX 导出技能
├── design-system/             # 设计规范
│   └── china-minerals/        # 中矿品牌配色规范
├── docs/                      # 文档与教程
├── ppt/                       # PPT 产出物（HTML 格式）
├── prototype/                 # 原型文件
├── server.js                  # 本地开发服务器（CORS 支持）
├── package.json
└── CLAUDE.md                  # AI 编码行为准则
```

## 核心工作流

```
需求 → frontend-slides 生成 HTML → dom-to-pptx 改造 → 本地服务器预览 → 导出 PPTX
```

1. **设计**：使用 `po-05-frontend-slides-ppt` 技能生成视觉精美的 HTML 演示文稿
2. **改造**：按 `dom-to-pptx-skill` 规范调整 HTML 结构（固定尺寸、内联样式、绝对定位）
3. **预览**：启动本地服务器，浏览器中确认效果
4. **导出**：点击导出按钮，生成可编辑的 `.pptx` 文件

详细教程见 [使用frontend-slides和dom-to-pptx生成PPT教程](docs/使用frontend-slides和dom-to-pptx生成PPT教程.md)。

## 快速开始

### 安装依赖

```bash
npm install
```

### 启动本地服务器

```bash
node server.js
```

默认访问 `http://localhost:3000`，自动打开 e矿汇安全汇报页面。

也可使用 npx：

```bash
npx serve .
```

### 导出 PPTX

1. 浏览器打开 HTML 文件
2. 点击页面上的「导出 PPTX」按钮
3. 等待浏览器下载 `.pptx` 文件

## 已安装技能

| 技能 | 用途 |
|------|------|
| po-01-to-prd-需求文档 | 需求文档生成 |
| po-02-baoyu-diagram-流程图 | SVG 流程图/架构图/时序图 |
| po-03-baoyu-infographic-模块图 | 信息图/模块图 |
| po-04-frontend-design-原型 | 前端界面原型设计 |
| po-05-frontend-slides-ppt | HTML 演示文稿生成 |
| po-06-brainstorming-superpower-头脑风暴 | 头脑风暴辅助 |
| po-07-web-design-engineer-原型 | Web 视觉原型 |
| dom-to-pptx-skill | HTML DOM 转 PPTX |

## 设计规范

项目包含矿产品牌配色规范，位于 `design-system/minerals/矿产配色规范.md`。

核心色板：

| 色名 | HEX | 用途 |
|------|-----|------|
| 矿业金 | `#B89A4B` | 标题、强调、关键数据 |
| 深棕褐 | `#6B4423` | 副标题、边框装饰 |
| 石墨灰 | `#4A4A4A` | 正文文字 |
| 浅米白 | `#F5F0E6` | 页面背景 |
| 浅灰卡 | `#E8E4DC` | 卡片背景 |
| 边框灰 | `#D4CFC4` | 边框线、分隔线 |

## 本地服务器说明

`server.js` 是一个零依赖的 Node.js 静态文件服务器，特点：

- 自动设置 CORS 头（`Access-Control-Allow-Origin: *`），解决字体和图片跨域问题
- 支持常见 MIME 类型（HTML/CSS/JS/图片/字体）
- 端口占用时自动切换到下一端口
- 默认路由指向 e矿汇安全汇报页面

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
