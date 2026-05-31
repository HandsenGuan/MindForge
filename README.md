# MindForge

个人 LLM 知识库 — 汇集 AI 模型使用中的工具、技巧与最佳实践。

## 项目结构

```text
MindForge/
├── minimax-prompt-skill/      ← MiniMax 2.7 提示词优化 Agent Skill
└── (更多内容持续补充)
```

## minimax-prompt-skill

针对 MiniMax 2.7 的跨平台 prompt 提示词优化 agent 指令集。支持从零创建和优化已有 prompt 两种模式，主要面向代码生成场景（含 ArkTS/鸿蒙专项优化），兼顾软件开发中的常见场景。

**核心功能：**

- 创建模式 — 从需求描述生成优化后的 prompt
- 优化模式 — 对已有 prompt 进行分析和优化
- 快速模式 — 直接从对话历史提取并优化

**支持平台：** Claude Code、Copilot CLI、Gemini CLI、OpenCode

详见 [minimax-prompt-skill/README.md](minimax-prompt-skill/README.md)。
