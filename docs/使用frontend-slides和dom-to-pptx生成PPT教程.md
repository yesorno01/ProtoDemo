# 使用 frontend-slides + dom-to-pptx 生成 PPT 教程

本教程介绍如何使用 **frontend-slides** 技能设计 HTML 演示文稿，再通过 **dom-to-pptx** 技能添加导出按钮，最终生成可编辑的 PowerPoint 文件。

---

## 整体流程

```
内容构思 → frontend-slides 生成 HTML 演示文稿 → 按 dom-to-pptx 规范改造 HTML → 浏览器打开 → 点击导出按钮 → 生成 .pptx 文件
```

两个技能各司其职：

| 技能 | 职责 | 产出 |
|------|------|------|
| frontend-slides | 设计和生成视觉精美的 HTML 演示文稿 | `presentation.html` |
| dom-to-pptx | 将 HTML DOM 转换为原生 PPTX | `presentation.pptx` |

---

## 第一步：使用 frontend-slides 设计 HTML 演示文稿

### 1.1 触发技能

在 Trae IDE 中，直接描述你的演示需求即可触发 frontend-slides 技能。例如：

> "帮我制作一个关于 矿产平台平台安全保障体系的汇报 PPT，5-8页，面向集团领导汇报，用业务语言、场景化表达"

### 1.2 提供关键信息

frontend-slides 会询问以下信息，尽量提前准备：

- **用途**：路演、教学、会议报告、内部汇报
- **长度**：短篇(5-10页)、中篇(10-20页)、长篇(20+页)
- **内容状态**：完整文案、粗略笔记、仅有主题

### 1.3 选择视觉风格

frontend-slides 提供 12 种预设风格，通过生成 3 个单页预览让你选择：

| 风格 | 适合场景 | 感觉 |
|------|----------|------|
| Bold Signal | 路演、产品发布 | 自信、高冲击 |
| Electric Studio | 客户汇报、战略评审 | 干净、专业 |
| Creative Voltage | 创意工作室、品牌展示 | 活力、复古现代 |
| Dark Botanical | 奢侈品牌、高端叙事 | 优雅、高级 |
| Notebook Tabs | 报告、评审、结构化叙事 | 编辑感、有条理 |
| Pastel Geometry | 产品概览、入职培训 | 友好、现代 |
| Split Pastel | 机构介绍、工作坊 | 活泼、创意 |
| Vintage Editorial | 个人品牌、观点演讲 | 个性、杂志风 |
| Neon Cyber | AI、基础设施、未来科技 | 未来感、科技 |
| Terminal Green | API、CLI工具、工程演示 | 开发者、极客 |
| Swiss Modern | 企业、产品策略、数据分析 | 极简、精确 |
| Paper & Ink | 论文、叙事、宣言 | 文学感、深思 |

如果你已有品牌配色，可以直接指定，跳过风格预览。

### 1.4 frontend-slides 生成的 HTML 特点

生成的 HTML 文件有以下特征：

- **单文件**：所有 CSS 和 JS 内联，零依赖
- **视口适配**：每页 `height: 100vh; overflow: hidden`，不出现滚动条
- **动画丰富**：包含键盘/触摸/滚轮导航、进入动画、进度指示器
- **响应式**：使用 `clamp()` 适配不同屏幕
- **无障碍**：语义化结构、键盘导航、尊重 `prefers-reduced-motion`

---

## 第二步：按 dom-to-pptx 规范改造 HTML

frontend-slides 生成的 HTML 侧重浏览器演示体验，但 dom-to-pptx 对 HTML 结构有严格限制。**必须进行改造才能正确导出。**

### 2.1 核心差异对照

| 项目 | frontend-slides 产出 | dom-to-pptx 要求 |
|------|---------------------|-----------------|
| 幻灯片尺寸 | `100vw × 100vh`（响应式） | `1920px × 1080px`（固定像素） |
| 样式方式 | `<style>` 块 + CSS 变量 | **纯内联样式** |
| 定位方式 | flex/grid + clamp() | `position: absolute` + 固定 px |
| 单位 | rem/em/vw/vh/clamp() | **仅 px** |
| 动画 | @keyframes + transition | **禁止**（仅捕获静态状态） |
| 渐变 | 各种渐变 | 仅 `linear-gradient` |
| 图片路径 | 相对路径可用 | **必须 https:// 或 data:URI** |
| 字体加载 | 任意方式 | Google Fonts 须 `crossorigin="anonymous"` |
| SVG | 内联 SVG | 支持，`svgAsVector: true` 可保留矢量 |

### 2.2 改造模板

以下是一个符合 dom-to-pptx 规范的完整模板，将你的内容填入即可：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8" />
  <title>演示文稿标题</title>

  <!-- 字体必须加 crossorigin="anonymous" 才能嵌入 PPTX -->
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link
    href="https://fonts.googleapis.com/css2?family=Noto+Sans+SC:wght@400;600;700&display=swap"
    rel="stylesheet"
    crossorigin="anonymous"
  />

  <style>
    /* 仅页面外壳样式，幻灯片内容必须用内联样式 */
    html, body { margin: 0; padding: 0; background: #222; }
    body { font-family: 'Noto Sans SC', Arial, sans-serif; }
    .slide-stage {
      display: flex; flex-direction: column;
      align-items: center; gap: 24px; padding: 40px 0;
    }
    .export-btn {
      position: fixed; top: 20px; right: 20px; z-index: 9999;
      padding: 14px 28px; border: none; border-radius: 8px;
      background: #4361ee; color: #fff; font-size: 16px;
      cursor: pointer; box-shadow: 0 4px 12px rgba(0,0,0,0.3);
    }
    .export-btn:disabled { opacity: 0.6; cursor: wait; }
  </style>
</head>
<body>
  <div class="slide-stage">

    <!-- ═══ 幻灯片 1：标题页 ═══ -->
    <div class="slide" style="
      width: 1920px; height: 1080px;
      position: relative; overflow: hidden;
      background: linear-gradient(135deg, #1a1a1a 0%, #2d2d2d 100%);
    ">
      <!-- 装饰条 -->
      <div style="
        position: absolute; left: 120px; top: 380px;
        width: 120px; height: 6px;
        background: #FF5722; border-radius: 3px;
      "></div>
      <!-- 主标题 -->
      <div style="position: absolute; left: 120px; top: 420px; width: 1400px;">
        <h1 style="
          margin: 0; font-family: 'Noto Sans SC', Arial, sans-serif;
          font-size: 88px; font-weight: 700; line-height: 1.05;
          color: #ffffff; letter-spacing: -1px;
        ">演示文稿标题</h1>
        <p style="
          margin: 28px 0 0 0; font-size: 32px; font-weight: 400;
          color: #cccccc;
        ">副标题或标语</p>
      </div>
    </div>

    <!-- ═══ 幻灯片 2：内容页 ═══ -->
    <div class="slide" style="
      width: 1920px; height: 1080px;
      position: relative; overflow: hidden;
      background: #ffffff;
    ">
      <h2 style="
        position: absolute; left: 120px; top: 100px; margin: 0;
        font-family: 'Noto Sans SC', Arial, sans-serif;
        font-size: 56px; font-weight: 700; color: #1a1a1a;
      ">章节标题</h2>
      <ul style="
        position: absolute; left: 120px; top: 240px; width: 1200px;
        margin: 0; padding-left: 40px; list-style: disc;
      ">
        <li style="font-size: 30px; color: #333333; line-height: 1.5; margin-bottom: 24px;">要点一</li>
        <li style="font-size: 30px; color: #333333; line-height: 1.5; margin-bottom: 24px;">要点二</li>
        <li style="font-size: 30px; color: #333333; line-height: 1.5; margin-bottom: 24px;">要点三</li>
      </ul>
    </div>

    <!-- 按需复制更多幻灯片... -->

  </div>

  <!-- 导出按钮 -->
  <button class="export-btn" id="exportBtn">导出 PPTX</button>

  <!-- 验证器脚本（可选，推荐） -->
  <script>
    // 验证器会在导出前检查 HTML 是否符合规范
    // 详见 dom-to-pptx-skill 的 VALIDATION.md
  </script>

  <!-- dom-to-pptx 库 -->
  <script src="https://cdn.jsdelivr.net/npm/dom-to-pptx@latest/dist/dom-to-pptx.bundle.js"></script>

  <!-- 导出逻辑 -->
  <script>
    const btn = document.getElementById('exportBtn');

    btn.addEventListener('click', async () => {
      // 预检验证
      const issues = window.validateSlides ? window.validateSlides() : [];
      if (issues.length) {
        const proceed = confirm(
          '验证器发现 ' + issues.length + ' 个问题:\n\n' +
          issues.slice(0, 10).map(i => '• ' + i).join('\n') +
          '\n\n仍然导出？'
        );
        if (!proceed) return;
      }

      // 执行导出
      btn.disabled = true;
      btn.textContent = '导出中…';
      try {
        const slides = document.querySelectorAll('.slide');
        await domToPptx.exportToPptx(Array.from(slides), {
          fileName: '演示文稿.pptx',
          autoEmbedFonts: true,
        });
        btn.textContent = '下载完成 ✓';
      } catch (err) {
        console.error(err);
        btn.textContent = '导出失败 — 请查看控制台';
      } finally {
        setTimeout(() => {
          btn.disabled = false;
          btn.textContent = '导出 PPTX';
        }, 2500);
      }
    });
  </script>
</body>
</html>
```

### 2.3 改造检查清单

将 frontend-slides 生成的 HTML 改造为 dom-to-pptx 兼容格式时，逐项检查：

**结构**
- [ ] 每个 `.slide` 使用固定像素尺寸 `1920×1080`
- [ ] 每个 `.slide` 设置 `position: relative; overflow: hidden`
- [ ] `.slide` 不在 CSS transform 的祖先元素内

**样式**
- [ ] 所有幻灯片内容使用内联样式（不用 `<style>` 块或 class）
- [ ] 所有尺寸单位为 `px`（不用 rem/em/vw/vh/clamp）
- [ ] 子元素使用 `position: absolute` + `left/top/width/height` 定位
- [ ] 不使用 `transform: translate/scale/skew/matrix`（rotate 可以）
- [ ] 不使用 `animation`、`transition`、`@keyframes`
- [ ] 不使用 `backdrop-filter`、`clip-path`、`mix-blend-mode`
- [ ] 不使用 `radial-gradient`、`conic-gradient`（仅 `linear-gradient`）
- [ ] 不使用视口单位 `vh/vw/vmin/vmax`

**资源**
- [ ] 图片使用 `https://` 开头的 URL 或 `data:` URI（不用相对路径或 file://）
- [ ] 图片不加 `loading="lazy"`
- [ ] Google Fonts `<link>` 加 `crossorigin="anonymous"`

**文字**
- [ ] `font-size` 使用 `px`
- [ ] 自定义字体有 web-safe 回退（如 `Arial, sans-serif`）

---

## 第三步：启动本地服务器并导出

### 3.1 为什么需要本地服务器

直接双击打开 HTML 文件（`file://` 协议）会遇到以下问题：

- **CORS 限制**：无法加载 Google Fonts、CDN 图片、dom-to-pptx 库
- **字体嵌入失败**：PPTX 中字体回退为 Arial
- **图片加载失败**：Unsplash 等外部图片被浏览器安全策略拦截

### 3.2 启动服务器

在 HTML 文件所在目录执行：

```bash
# 方式一：使用 npx serve（推荐）
npx serve .

# 方式二：使用 Python
python -m http.server 8080
```

然后在浏览器中打开 `http://localhost:3000/你的文件名.html`（serve 默认 3000 端口）或 `http://localhost:8080/你的文件名.html`。

### 3.3 点击导出

1. 在浏览器中打开 HTML 文件
2. 确认所有幻灯片显示正常
3. 点击右上角「导出 PPTX」按钮
4. 等待浏览器下载 `.pptx` 文件
5. 用 PowerPoint 打开检查效果

---

## 第四步：导出后验证与调整

### 4.1 常见问题与解决

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 字体回退为 Arial | Google Fonts 未加 `crossorigin="anonymous"` | 在 `<link>` 标签添加该属性 |
| 图片缺失 | 使用了相对路径或 CORS 受限的 URL | 改用 `https://` 的 CORS 图片或 `data:` URI |
| 布局错位 | 使用了 `transform: translate` 或视口单位 | 改用 `position: absolute` + 固定 px |
| 渐变丢失 | 使用了 `radial-gradient` 或 `conic-gradient` | 改用 `linear-gradient` |
| 动画效果消失 | dom-to-pptx 只捕获静态状态 | 正常行为，PPT 不支持 Web 动画 |
| 毛玻璃效果消失 | `backdrop-filter` 不被支持 | 用半透明叠加 div 模拟 |
| 文字溢出 | PPTX 中文字渲染与浏览器有差异 | 减少文字量，留更多边距 |

### 4.2 SVG 矢量图导出

如果幻灯片包含 SVG 图表或图标，可以在 `exportToPptx` 选项中启用矢量导出：

```javascript
await domToPptx.exportToPptx(Array.from(slides), {
  fileName: '演示文稿.pptx',
  autoEmbedFonts: true,
  svgAsVector: true,  // SVG 保持矢量，可在 PPT 中"转换为形状"
});
```

---

## 完整示例：从零到 PPTX

以下是一个完整的端到端示例，展示从内容构思到最终 PPTX 的全过程。

### 场景

制作一个"矿产平台平台安全保障体系"汇报 PPT，面向集团领导，1-2分钟汇报，场景化表达。

### Step 1：用 frontend-slides 生成 HTML

向 AI 提问：（此处可以引用写好的配色规范）

> "帮我制作一个关于矿产平台平台安全保障体系的汇报PPT，5页左右，面向集团领导，用业务语言、场景化表达。风格选 Dark Botanical，配色用矿产品牌色（矿业金 #B89A4B、深棕褐 #6B4423、米白 #F5F0E6）"

AI 会生成一个视觉效果出色的 HTML 演示文稿，包含动画、导航、响应式布局。

### Step 2：改造为 dom-to-pptx 兼容格式

将生成的 HTML 按以下规则改造：

1. **尺寸**：`100vw × 100vh` → `1920px × 1080px`
2. **定位**：flex/clamp 布局 → `position: absolute` + 固定 px
3. **样式**：`<style>` 块 → 内联 `style=""`
4. **单位**：rem/em/clamp → px
5. **去掉**：动画、transition、scroll-snap、Intersection Observer
6. **添加**：dom-to-pptx 库引用 + 导出按钮 + 验证器

### Step 3：启动服务器并导出

```bash
cd d:\A\gProjectM\ProtoDemo\ppt\矿产平台安全目标
npx serve .
```

浏览器打开 `http://localhost:3000/矿产平台安全汇报.html`，点击「导出 PPTX」。

### Step 4：在 PowerPoint 中检查

打开生成的 `.pptx` 文件，检查：
- 文字是否完整显示
- 布局是否与浏览器中一致
- 颜色是否正确
- 字体是否嵌入

---