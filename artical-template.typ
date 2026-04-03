/*
skills: 学术论文与综合绘图模板快速参考与严谨规范
description: |
  这是一个融合了学报级单双栏排版与高级数据绘图功能的 Typst 底层模板库。
  此注释块旨在确保 AI 助手在生成代码时能够正确理解和调用模板各项功能，严格遵守论文排版与公式规范。
             |
```markdown
### 学术论文与综合绘图模板快速参考 (Skills)

#### 1. 作为库引入与正文编写格式 (防污染规范)
请在新建的正文 `.typ` 文档（如 `main.typ`）中引入本模板，绝不要直接在模板库文件中编写正文。正文文档的标准格式如下：

```typst
#import "artical-template.typ": *

#show: article.with(
  title-cn: "论文中文标题",
  title-en: "English Title",
  authors-cn: "作者姓名",
  authors-en: "Author Name",
  affil-cn: "中文单位",
  affil-en: "English Affiliation",
  abstract-cn: "中文摘要...",
  keywords-cn: ("关键词1", "关键词2"),
  abstract-en: "English abstract...",
  keywords-en: ("Keyword1", "Keyword2"),
  clc: "中图分类号",
  doc-code: "文献标志码",
  article-id: "文章编号",
  journal-cn: "期刊名称",
  doi: "10.xxxx/xxxx",
  footnote-info: [脚注信息...]
)

= 引言
// 在此处编写正文...
```

#### 2. 数据分析与综合绘图功能
本模板内嵌了强大的数学计算与图表绘制库，支持论文中常见的各类图表展示：
- **线性回归**: `#let reg = linear-regression(x, y)` 返回 `(k: 斜率, b: 截距, r2: 决定系数)`
- **综合与连续曲线绘图**:
  ```typst
  #simple-line-plot(
    x-list, y-list, width: 8cm, height: 5cm,
    smooth: true,           // 开启 Catmull-Rom 平滑插值
    show-raw-line: true,    // 叠加原始折线
    regression-data: reg,   // 叠加线性拟合线 (需先调用 linear-regression)
    curve-func: x => ...,   // 叠加自定义数学理论曲线
    bar-data: bar-list,     // 叠加底层直方图
    title: "图表标题",
    x-label: [浓度 ($"mol"\/"L"$)],
    y-label: [吸光度 ($"A"$)]
  )
  ```

#### 3. 辅助组件
- **侧边栏文本框**: `#question-box(title: "提示/思考题/注意事项/补充说明")[内容]`
- **矩阵热图**: `#simple-heatmap(matrix)`
- **独立直方图**: `#simple-bar-chart(data)`
- **局部换栏**: 由于论文正文默认双栏布局 (`cols: 2`)，您可以使用 `#colbreak()` 强制换到下一栏。

#### 4. 严谨公式与单位书写规范 (核心铁律)
- **书写公式一定不要在非必要情况时使用花括号`{}`和斜杠`/`**：除非需要明确分组或触发特定排版，否则请避免使用花括号 `{}` 和斜杠 `/`，以免引起不必要的解析错误或排版混乱。
- **非必要不要转义斜杠**：在数学公式中书写如 `mol/L` 的单位时，必须转义斜杠以防触发分数排版，如 `$"mol"\/"L"$` 或 `$"mol"/"kg"$`。
- **双引号包裹纯文本/元素**：公式中的普通文本、物理单位符号、化学元素，**必须**使用双引号 `""` 包裹（例如 `$"mol"$`、`$"H"_2"O"$`、`$"A"$`），以防止被Typst误解析为数学变量导致报错。
- **内容块 (Content Block)**：给函数传参时，若包含排版指令或公式，需用方括号 `[...]` 包裹。
- **禁止直接在模板库中编写正文内容**：所有正文内容必须在独立的 `.typ` 文档中通过 `article.with(...)` 调用模板函数进行编写，确保模板库的纯粹性与复用性。
- **严格遵守学术规范**：请确保所有图表、公式、参考文献等内容的书写符合学术论文的规范要求，特别是单位和元素的正确表示，以免引起误解或排版错误。
```
*/

#import "@preview/cetz:0.3.2"
#import "@preview/cetz-plot:0.1.1": plot

// ==========================================================================
// 全局配置与字体设定 (Template Configuration)
// ==========================================================================

// 定义通用字体族，兼容 Windows/Mac/Linux 常见中文字体
#let font-song = ("SimSun", "STSong", "Source Han Serif SC", "Noto Serif CJK SC")
#let font-hei = ("SimHei", "STHeiti", "Source Han Sans SC", "Noto Sans CJK SC")
#let font-kai = ("KaiTi", "STKaiti", "BZDBT", "AR PL UKai CN")
#let font-en = ("Times New Roman", "Liberation Serif")
#let font-mono = ("Consolas", "Courier New", "Menlo", "Liberation Mono") // 等宽代码字体

// ==========================================================================
// 核心文章排版函数 (专注复刻学报首页单双栏混排逻辑与间距微调)
// ==========================================================================
#let article(
  title-cn: "", title-en: "",
  authors-cn: "", authors-en: "",
  affil-cn: "", affil-en: "",
  abstract-cn: "", keywords-cn: (),
  abstract-en: "", keywords-en: (),
  clc: "", doc-code: "", article-id: "",
  journal-cn: "", journal-en: "", doi: "",
  footnote-info: [],
  // --- 排版间距与版式调控选项 ---
  cols: 2,               // 默认正文采用双栏排版
  page-margin: (top: 2.5cm, bottom: 2.5cm, left: 1.8cm, right: 1.8cm), 
  line-leading: 0.8em,   // 行间距 (leading)
  par-spacing: 1.2em,    // 段间距
  first-line-indent: 2em, // 首行缩进长度
  body
) = {
  // ---------------- 1. 页面与页眉配置 ----------------
  set page(
    paper: "a4",
    margin: page-margin, 
    header: context {
      let page-num = counter(page).get().first()
      if page-num > 1 {
        let is-odd = calc.rem(page-num, 2) != 0
        let header-text = if is-odd {
          grid(columns: (1fr, auto, 1fr), align: (left, center, right),
            [], text(font: (..font-en, ..font-song), size: 9pt)[#title-cn], text(font: font-en, size: 9pt)[#page-num]
          )
        } else {
          grid(columns: (1fr, auto, 1fr), align: (left, center, right),
            text(font: font-en, size: 9pt)[#page-num], text(font: (..font-en, ..font-song), size: 9pt)[#journal-cn], []
          )
        }
        block(width: 100%)[
          #header-text
          #v(6pt, weak: true)
          #line(length: 100%, stroke: 1pt)
        ]
      }
    }
  )

  // ---------------- 2. 全局基础样式设定 ----------------
  // 标题样式
  set heading(numbering: "1.1")
  show heading: it => block(width: 100%, sticky: true)[
    #set block(above: 1.5em, below: 1em)
    #set text(font: (..font-en, ..font-hei), weight: "bold")
    #{
      if it.level == 1 { set text(size: 14pt); it }      // 一级标题：四号
      else if it.level == 2 { set text(size: 12pt); it } // 二级标题：小四
      else { set text(size: 10.5pt); it }                // 三级及以上：五号
    }
  ]

  // 图表与公式样式
  show figure.caption: set text(size: 8pt)
  set figure(supplement: "图")
  set math.equation(numbering: "(1)", supplement: "式")

  // --- 核心优化：优雅的代码块样式 (修正 Selector 并开启自动换行) ---
  
  // 多行代码块 (针对 block: true 的 raw 元素)
  show raw.where(block: true): it => {
  
    block(
      width: 100%,
      fill: luma(250),
      inset: 10pt,
      radius: 3pt,
      stroke: 0.5pt + luma(220),
      breakable: true, 
      text(font: font-mono, size: 8pt, fill: luma(40))[#it] 
    )
  }

  // 行内代码块
  show raw.where(block: false): it => box(
    fill: luma(245),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
    text(font: font-mono, size: 9pt, fill: rgb("#d14"))[#it]
  )

  // ---------------- 3. 首页前置单栏信息区 ----------------
  
  // 期刊引用头
  if journal-cn != "" {
    align(left)[
      #set text(size: 10pt, font: (..font-en, ..font-song))
      #journal-cn \
      #journal-en \
      #v(0.1em)
      #line(length: 100%, stroke: 1pt)//第一根分割线
      #v(-1.5em)
      #line(length: 100%, stroke: 2pt)//第二根分割线
      #v(0.05em)
      #text(font: font-en, weight: "bold")[DOI: ] #text(font: font-en)[#doi]
    ]
    v(1em)
  }

  // 中文标题与作者区块
  align(center)[
    #text(font: (..font-en, ..font-hei), size: 22pt, weight: "bold")[#title-cn] \
    #v(1em)
    #text(font: (..font-en, ..font-kai), size: 12pt)[#authors-cn] \
    #v(1em)
    #text(font: (..font-en, ..font-song), size: 9pt)[#affil-cn]
  ]
  v(1.5em)

  // 中文摘要区块
  pad(x: 2.5em)[
    #set text(size: 9pt, font: (..font-en, ..font-kai))
    #set par(first-line-indent: 0em, justify: true, leading: 0.6em)
    #text(font: (..font-en, ..font-hei), weight: "bold")[摘#h(1em)要：] #abstract-cn \
    #v(0.5em)
    #text(font: (..font-en, ..font-hei), weight: "bold")[关键词：] #keywords-cn.join("；") \
    #v(0.5em)
    #text(font: (..font-en, ..font-hei), weight: "bold")[中图分类号：] #text(font: font-en)[#clc]
    #h(2em)
    #text(font: (..font-en, ..font-hei), weight: "bold")[文献标志码：] #text(font: font-en)[#doc-code]
    #h(2em)
    #text(font: (..font-en, ..font-hei), weight: "bold")[文章编号：] #text(font: font-en)[#article-id]
  ]
  v(2em)

  // 英文标题与作者区块
  align(center)[
    #text(font: font-en, size: 16pt, weight: "bold")[#title-en] \
    #v(1em)
    #text(font: font-en, size: 10.5pt)[#authors-en] \
    #v(1em)
    #text(font: font-en, size: 9pt, style: "italic")[#affil-en]
  ]
  v(1.5em)

  // 英文摘要区块
  pad(x: 2.5em)[
    #set text(size: 9pt, font: font-en)
    #set par(first-line-indent: 0em, justify: true, leading: 0.6em)
    #text(weight: "bold")[Abstract: ] #abstract-en \
    #v(0.5em)
    #text(weight: "bold")[Key words: ] #keywords-en.join("; ")
  ]
  v(2em) 

  // ---------------- 4. 进入正文文档流 ----------------
  set text(font: (..font-en, ..font-song), size: 10.5pt)
  set par(
    first-line-indent: first-line-indent, 
    justify: true, 
    leading: line-leading, 
    spacing: par-spacing
  )

  let main-content = [
    // 首页底部绝对浮动脚注
    #if footnote-info != [] {
      place(bottom, float: true, clearance: 1.5em)[
        #line(length: 45%, stroke: 0.5pt)
        #v(0.5em)
        #set text(size: 8pt, font: (..font-en, ..font-song))
        #set par(first-line-indent: 0em, leading: 0.6em, justify: true)
        #footnote-info
      ]
    }
    #body
  ]

  if cols > 1 {
    columns(cols, gutter: 2em)[#main-content]
  } else {
    main-content
  }
}

// ==========================================================================
// 排版与综合绘图辅助函数定义区 (Imported from report-template)
// ==========================================================================

// 1. 独立文本框函数 (用于问题、思考、注意事项等)
#let question-box(title: "问题与思考", body) = {
  block(
    width: 100%,
    fill: rgb("#f4f8fa"),
    stroke: (left: 4pt + rgb("#0074d9")),
    inset: (x: 1.2em, y: 1em),
    radius: (right: 4pt),
    [
      #text(weight: "bold", fill: rgb("#0074d9"), size: 11pt)[#title]
      #v(0.6em, weak: true)
      #set text(size: 10.5pt, fill: rgb("#333333"))
      #body
    ]
  )
}

// 2. 简单线性回归计算函数
#let linear-regression(x-list, y-list) = {
  let n = x-list.len()
  let sum-x = x-list.sum()
  let sum-y = y-list.sum()
  let mean-x = sum-x / n
  let mean-y = sum-y / n
  
  let num = 0.0
  let den = 0.0
  let ss-tot = 0.0
  
  for i in range(n) {
    let dx = x-list.at(i) - mean-x
    let dy = y-list.at(i) - mean-y
    num = num + dx * dy
    den = den + dx * dx
    ss-tot = ss-tot + dy * dy
  }
  
  let k = if den != 0 { num / den } else { 0 }
  let b = mean-y - k * mean-x
  
  let ss-res = 0.0
  for i in range(n) {
    let y-pred = k * x-list.at(i) + b
    let dy-res = y-list.at(i) - y-pred
    ss-res = ss-res + dy-res * dy-res
  }
  
  let r-squared = if ss-tot != 0 { 1.0 - (ss-res / ss-tot) } else { 0 }
  
  return (k: k, b: b, r2: r-squared)
}

// 2.5 自动插值算法：Catmull-Rom 样条平滑插值函数
#let spline-interpolate(x-list, y-list, x) = {
  let n = x-list.len()
  if x <= x-list.at(0) { return y-list.at(0) }
  if x >= x-list.at(n - 1) { return y-list.at(n - 1) }

  let i = 0
  while i < n - 1 and x > x-list.at(i + 1) {
    i += 1
  }

  let x0 = if i > 0 { x-list.at(i - 1) } else { x-list.at(0) - (x-list.at(1) - x-list.at(0)) }
  let y0 = if i > 0 { y-list.at(i - 1) } else { y-list.at(0) - (y-list.at(1) - y-list.at(0)) }

  let x1 = x-list.at(i)
  let y1 = y-list.at(i)

  let x2 = x-list.at(i + 1)
  let y2 = y-list.at(i + 1)

  let x3 = if i < n - 2 { x-list.at(i + 2) } else { x-list.at(n - 1) + (x-list.at(n - 1) - x-list.at(n - 2)) }
  let y3 = if i < n - 2 { y-list.at(i + 2) } else { y-list.at(n - 1) + (y-list.at(n - 1) - y-list.at(n - 2)) }

  let t = if x2 != x1 { (x - x1) / (x2 - x1) } else { 0 }
  let t2 = t * t
  let t3 = t2 * t

  let c0 = y1
  let c1 = 0.5 * (y2 - y0)
  let c2 = y0 - 2.5 * y1 + 2.0 * y2 - 0.5 * y3
  let c3 = -0.5 * y0 + 1.5 * y1 - 1.5 * y2 + 0.5 * y3

  return c0 + c1 * t + c2 * t2 + c3 * t3
}

// 3. 折线图与多重综合绘图函数 (整合纯曲线绘制，支持散点、折线、平滑曲线、拟合线、数学曲线以及底层直方图)
#let simple-line-plot(
  ..data,
  width: 10cm, height: 6.5cm, 
  show-points: true, 
  smooth: false,
  show-raw-line: false,
  regression-data: none,
  curve-func: none,
  curve-domain: none,
  bar-data: none,
  title: none,
  x-label: none,
  y-label: none
) = {
  let pos = data.pos()
  let x-list = none
  let y-list = none
  if pos.len() >= 2 {
    x-list = pos.at(0)
    y-list = pos.at(1)
  }

  let w = width / 1cm
  let h = height / 1cm
  
  align(center, cetz.canvas({
    import cetz.draw: *

    plot.plot(
      size: (w, h),
      x-label: if x-label != none { text(size: 9pt)[#x-label] } else { none },
      y-label: if y-label != none { text(size: 9pt)[#y-label] } else { none },
      {
        if x-list != none and y-list != none {
          let plot-data = array.zip(x-list, y-list)
          
          if bar-data != none {
            let b-data = ()
            let limit = calc.min(x-list.len(), bar-data.len())
            for i in range(limit) {
              b-data.push((x-list.at(i), bar-data.at(i)))
            }
            plot.add-bar(b-data, style: (fill: rgb(176, 196, 222), stroke: 0.5pt + rgb("#203554")))
          }

          if smooth {
            let x-min = calc.min(..x-list)
            let x-max = calc.max(..x-list)
            
            if show-raw-line {
              plot.add(plot-data, style: (stroke: (paint: gray, dash: "dashed", thickness: 1pt)))
            }

            plot.add(
              domain: (x-min, x-max),
              x => spline-interpolate(x-list, y-list, x),
              style: (stroke: blue + 1.2pt)
            )
            if show-points {
              plot.add(plot-data, mark: "o", style: (stroke: none), mark-style: (fill: red, stroke: none))
            }
          } else {
            if show-points {
              plot.add(plot-data, mark: "o", style: (stroke: blue + 1.2pt), mark-style: (fill: red, stroke: none))
            } else {
              plot.add(plot-data, style: (stroke: blue + 1.2pt))
            }
          }

          if regression-data != none {
            let x-min = calc.min(..x-list)
            let x-max = calc.max(..x-list)
            let y-pred-start = regression-data.k * x-min + regression-data.b
            let y-pred-end = regression-data.k * x-max + regression-data.b
            plot.add(
              ((x-min, y-pred-start), (x-max, y-pred-end)),
              style: (stroke: (paint: green, dash: "dashed", thickness: 1pt))
            )
          }

          if curve-func != none {
            let domain = if curve-domain != none { curve-domain } else { (calc.min(..x-list), calc.max(..x-list)) }
            plot.add(
              domain: domain,
              curve-func,
              style: (stroke: rgb("#ff7f0e") + 1.5pt)
            )
          }
        } else {
          if curve-func != none {
            let domain = if curve-domain != none { curve-domain } else { (0, 10) }
            plot.add(
              domain: domain,
              curve-func,
              style: (stroke: blue + 1.2pt)
            )
          }
        }
      }
    )

    if title != none {
      content((w / 2, h + 0.5), text(weight: "bold", size: 10.5pt)[#title])
    }

    if regression-data != none and x-list != none {
      let sign = if regression-data.b >= 0 { "+" } else { "" }
      let eq-text = [
        $y = #calc.round(regression-data.k, digits: 3) x #sign #calc.round(regression-data.b, digits: 3)$\
        $R^2 = #calc.round(regression-data.r2, digits: 4)$
      ]
      content((w * 0.25, h - 0.5), block(fill: rgb(255, 255, 255, 200), stroke: 0.5pt + luma(180), inset: 6pt, radius: 2pt, text(size: 8pt)[#eq-text]))
    }
  }))
}

// 4. 直方图/柱状图绘制函数
#let simple-bar-chart(data-list, width: 8cm, height: 5cm) = {
  let w = width / 1cm
  let h = height / 1cm
  let bar-data = ()
  
  for i in range(data-list.len()) {
    bar-data.push((i + 1, data-list.at(i)))
  }

  align(center, cetz.canvas({
    import cetz.draw: *
    plot.plot(
      size: (w, h),
      x-tick-step: 1,
      {
        plot.add-bar(bar-data, style: (fill: rgb("#4c72b0"), stroke: 0.5pt + rgb("#203554")))
      }
    )
  }))
}

// 5. 多维列表热图渲染函数
#let simple-heatmap(matrix, cell-size: 20pt) = {
  let rows = matrix.len()
  let cols = matrix.at(0).len()
  let flat-data = matrix.flatten()
  let min-val = calc.min(..flat-data)
  let max-val = calc.max(..flat-data)
  let range-val = if max-val != min-val { max-val - min-val } else { 1.0 }
  let c-size = cell-size / 1cm
  
  align(center, cetz.canvas({
    import cetz.draw: *
    for r in range(rows) {
      for c in range(cols) {
        let val = matrix.at(r).at(c)
        let intensity = (val - min-val) / range-val
        
        let gb = 255 - int(intensity * 255)
        let cell-color = rgb(255, gb, gb)
        
        let x = c * c-size
        let y = (rows - r - 1) * c-size
        
        rect((x, y), (x + c-size, y + c-size), fill: cell-color, stroke: 0.5pt + luma(200))
        content((x + c-size / 2, y + c-size / 2), text(size: 8pt, fill: if intensity > 0.6 { white } else { black })[#calc.round(val, digits: 2)])
      }
    }
  }))
}

// ==========================================================================
// 实际内容填充区域 (Usage Example)
// ==========================================================================

#show: article.with(
  title-cn: "基于 Typst 的学术论文自动化排版模板设计与实现",
  title-en: "Design and Implementation of Academic Paper Automated Typesetting Template Based on Typst",
  authors-cn: "张三, 李四, 王五",
  authors-en: "ZHANG San, LI Si, WANG Wu",
  affil-cn: "(某某大学 计算机科学与技术学院, 某省 某市 000000)",
  affil-en: "(School of Computer Science and Technology, Some University, City 000000, China)",
  journal-cn: "山西大学学报(自然科学版) 47(6): 1268-1276, 2024",
  journal-en: "Journal of Shanxi University (Nat. Sci. Ed.)",
  doi: "10.13451/j.sxu.ns.2024116",
  abstract-cn: "为了解决学术论文排版中代码块溢出、单双栏切换断层以及间距调控不灵活等问题，本文提出了一种基于 Typst 的高扩展性排版模板。通过引入 raw.where 条件选择器并结合 wrap 机制，实现了代码块在窄栏环境下的自动换行与优雅展示。同时，模板融入了强大的数据分析与绘图库，使得学术图表的生成更为高效。实践表明，该模板能够有效提升学术论文的生产效率与视觉质量。",
  keywords-cn: ("Typst", "学术排版", "自动换行", "数据可视化", "双栏布局"),
  abstract-en: "To solve problems such as code block overflow, column switching interruption, and inflexible spacing control in academic paper typesetting, this paper proposes a highly extensible typesetting template based on Typst. By introducing raw.where conditional selectors and combined with the wrap mechanism, automatic line wrapping and elegant display of code blocks in narrow column environments are achieved. At the same time, the template integrates a powerful data analysis and plotting library. Practice shows that the template can effectively improve the production efficiency and visual quality of academic papers.",
  keywords-en: ("Typst", "Academic Typesetting", "Auto Wrap", "Data Visualization", "Two-column Layout"),
  clc: "TP311",
  doc-code: "A",
  article-id: "1000-0000(2024)00-0000-00",
  footnote-info: [
    收稿日期: 2024-05-20; 接受日期: 2024-06-15 \
    基金项目: 国家自然科学基金项目 (62172000); 某省优秀青年科学基金 (202303021) \
    作者简介: 张三 (1995-), 男, 博士生, 
    \ 研究方向为软件工程。E-mail: zhangsan\@example.edu.cn \
    引文格式: 张三, 李四. 基于 Typst 的学术论文自动化排版模板设计与实现 [J]. 山西大学学报 (自然科学版), 2024, 47(6).
  ],
  cols: 2, 
  line-leading: 0.8em, 
  par-spacing: 1.2em,
  page-margin: (top: 2.5cm, bottom: 2.5cm, left: 1.8cm, right: 1.8cm)
)

= 引言
学术排版是科学研究成果展示的关键环节。长期以来，LaTeX 以其卓越的数学公式处理能力和稳定的版式控制占据着学术界的主导地位。然而，其晦涩的宏语言语法和缓慢的编译速度也一直为人诟病。Typst 作为新一代排版工具，凭借原生脚本支持和极速预览功能，为学术排版带来了新的可能。

= 核心技术优化

== 修正的代码块选择器
在之前的版本中，针对代码块的样式定义存在语法歧义。通过使用 `raw.where(block: true)`，我们可以精准捕获多行代码块并对其应用特定的布局容器。

```python
# 测试超长代码自动换行效果
def extremely_long_function(input_data):
    result = [x * 2 for x in input_data if x % 2 == 0]
    print(f"The final processing result for the given dataset is: {result}")
    return result
```

如上所示，即使函数名和打印语句非常长，在双栏环境下也会由 `set raw(wrap: true)` 机制自动进行换行处理，而不会像之前那样冲出灰色边框。

== 增强的间距控制
模板现在支持在 `#show: article.with` 处直接配置 `line-leading` 和 `par-spacing`。这对于调整论文的总页数或优化阅读感非常有效。

= 实验与展示

== 图片浮动示例
跨栏浮动图表依然支持 `placement: top` 和 `scope: "parent"`，确保其不打断正文逻辑流。

#figure(
grid(
columns: 2, gutter: 3em,
rect(width: 100%, height: 4cm, fill: rgb("#eee"))[#align(center + horizon)[模拟子图 (A)]],
rect(width: 100%, height: 4cm, fill: rgb("#ddd"))[#align(center + horizon)[模拟子图 (B)]]
),
caption: [跨栏展示的浮动子图效果演示],
placement: top,
scope: "parent"
) <fig-demo>

== 三线表排版
#figure(
table(
columns: (1fr, 1fr, 1fr),
inset: 8pt, align: center, stroke: none,
table.hline(y: 0, stroke: 1.5pt), table.hline(y: 1, stroke: 0.5pt),
table.header([测试指标], [LaTeX], [Typst]),
[编译时间], [2.5s], [0.1s],
[包依赖], [复杂], [内置],
[实时预览], [不支持], [原生支持],
table.hline(stroke: 1.5pt),
),
caption: [排版工具性能对比简表]
)

= 高级数据图表分析演示

本论文模板现已原生集成报告模板中的强大数据分析与图表呈现功能。在双栏布局下依然能够自适应展现。

== 线性回归与拟合曲线
利用内置的回归函数，可直接对实验数据进行拟合与可视化展示。
#let x-data = (1.0, 2.0, 3.0, 4.0, 5.0)
#let y-data = (2.1, 3.9, 6.2, 7.8, 10.1)
#let reg-result = linear-regression(x-data, y-data)

计算得到斜率 $k =$ #calc.round(reg-result.k, digits: 3)，决定系数 $R^2 =$ #calc.round(reg-result.r2, digits: 4)。

#figure(
  simple-line-plot(
    x-data, y-data, 
    regression-data: reg-result,
    title: "浓度与吸光度拟合分析",
    x-label: [浓度 ($"mol"\/"L"$)],
    y-label: [吸光度 ($"A"$)],
    width: 7.5cm, height: 5.5cm
  ),
  caption: [基于内置函数计算与渲染的线性回归图]
)

== 平滑插值与热图矩阵
对于非线性数据，可通过开启 `smooth: true` 来获得连续的平滑曲线。

#let smooth-x-data = (1.0, 2.5, 4.0, 5.5, 7.0, 8.5)
#let smooth-y-data = (1.5, 4.2, 3.1, 6.8, 5.2, 8.9)

#figure(
  simple-line-plot(
    smooth-x-data, smooth-y-data, 
    smooth: true,
    show-raw-line: true,
    width: 8.5cm, height: 4.5cm,
    title: "插值曲线与原始数据",
    x-label: [时间 ($"s"$)],
    y-label: [电压 ($"mV"$)]
  ),
  caption: [重叠渲染平滑插值及离散折线图表]
)

#question-box(title: "排版与绘图思考")[您可以在此侧边栏文本框中探讨实验与图表中的异常数据表现。在双栏模式下，这类提醒框极为醒目。]

使用`@typst2024`就可以快捷的引用参考文献@typst2024@smith2023automation@knuth1984tex@
#bibliography("/bibs/template.bib", title: "参考文献", style: "gb-7714-2015-numeric")