# 📚 Econ Research Skills

> 经济学实证论文全流程 AI 技能系统 | A Complete AI Skill System for Empirical Economics Research

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🎯 这是什么？

一套专为**经济学博士生**设计的 AI 技能指令系统（Skills），覆盖实证论文从选题到发表的**全生命周期**。

基于 Stanford CS146S "Power Prompting for LLMs" 的方法论，运用 System Prompt、Chain-of-Thought、Reflexion 等技术构建。

## 🏗️ 系统架构

```
选题 → 文献 → 理论 → 方法 → 数据 → 代码 → 结果 → 写作
 🎯      📚      🏛️      ⚗️      🔧      💻      📊      ✍️
```

## 📦 内容一览

### `skills/` — 8个AI技能模块 (38个任务)

| 模块 | 任务数 | 核心能力 |
|------|--------|---------|
| 🎯 [Topic_Selector](skills/Topic_Selector/) | 3 | 选题头脑风暴 · 背景速写 · 可行性评估 |
| 📚 [Literature_Navigator](skills/Literature_Navigator/) | 4 | 深度阅读 · 文献矩阵 · 综述撰写 · 缺口定位 |
| ⚗️ [Causal_Inference_Guide](skills/Causal_Inference_Guide/) | 6 | DID全家桶(7种) · 内生性检验 · 稳健性清单 · 教材索引 |
| 🏛️ [Theoretical_Framework](skills/Theoretical_Framework/) | 3 | 理论推荐 · 假说推导 · 30+理论速查库 |
| 🔧 [Data_Pipeline](skills/Data_Pipeline/) | 5 | 数据寻找 · 清洗 · 管理规范 · 变量描述 · 数据字典 |
| 💻 [Code_Project_Manager](skills/Code_Project_Manager/) | 5 | Master脚本 · 回归流水线 · 代码审查 · 复现代码 |
| 📊 [Results_Manager](skills/Results_Manager/) | 5 | 结果解读 · 异质性设计 · 机制分析 · 表格规范 |
| ✍️ [Academic_Paper_Writer](skills/Academic_Paper_Writer/) | 7 | 初稿 · 打磨 · 审稿回复 · 摘要 · 引言 · 结论 · 语言精修 |

### `code_library/` — 经典方法代码库
- `did/` — DID全家桶 (TWFE, CS, SA, Imputation, Bacon, HonestDiD)
- `data_cleaning/` — 缩尾、缺失值、面板平衡
- `tables_figures/` — 事件研究图、系数图、出表代码

### `templates/` — 可复用的项目模板
- `stata/` — Stata 标准项目模板 (Master.do + 8个子文件)
- `r/` — R 标准项目模板

### `references/` — 教材与文献索引
- 6本因果推断经典教材的章节索引
- DID/IV/RD 前沿论文列表

### `checklists/` — 检查清单
- 内生性检验清单 · 稳健性检验清单 · 投稿前检查

## 🚀 快速开始

### 方式一：配合 AI 编程工具使用
将 `skills/` 文件夹放入你的项目目录，AI 工具会自动识别并按指令执行。

### 方式二：作为参考手册
直接阅读各 `SKILL.md` 文件，作为论文写作的结构化指南使用。

## 📖 推荐教材

| 教材 | 作者 | 难度 | 在线资源 |
|------|------|------|---------|
| *Mastering Metrics* | Angrist & Pischke | ⭐ 入门 | [官网](https://www.masteringmetrics.com/) |
| *Mostly Harmless Econometrics* | Angrist & Pischke | ⭐⭐ 进阶 | — |
| *Causal Inference: The Mixtape* | Cunningham | ⭐⭐ 进阶 | [免费在线](https://mixtape.scunning.com/) |
| *The Effect* | Huntington-Klein | ⭐⭐ 进阶 | [免费在线](https://theeffectbook.net/) |
| *Causal Inference* | Imbens & Rubin | ⭐⭐⭐ 高阶 | — |
| 《高级计量经济学》 | 陈强 | ⭐⭐ 进阶 | — |

## 🤝 贡献

欢迎通过 Pull Request 贡献代码、修正错误或添加新的 Skill 模块。

## 📄 License

MIT License — 自由使用、修改和分发。
