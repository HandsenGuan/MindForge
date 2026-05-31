# MiniMax Prompt 优化 Agent Skill

跨平台的 MiniMax 2.7 提示词优化指令集。帮助用户在向 MiniMax 2.7 提交 prompt 之前，通过结构化的规则体系对其进行优化、编辑和确认。

## 功能

- **创建模式** — 从需求描述生成优化后的 prompt
- **优化模式** — 对已有 prompt 进行分析和优化
- **快速模式** — 直接从对话历史提取并优化

## 支持平台

| 平台 | 调用方式 |
| --- | --- |
| Claude Code | `/minimax-prompt` |
| Copilot CLI | `skill minimax-prompt` |
| Gemini CLI | `activate_skill minimax-prompt` |
| OpenCode | `/minimax-prompt` |

## 文件结构

```
minimax-prompt-skill/
├── SKILL.md                    ← 核心规则文件（平台无关）
├── README.md                   ← 本文件
└── references/
    ├── claude-code.md          ← Claude Code 适配
    ├── copilot-cli.md          ← Copilot CLI 适配
    ├── gemini-cli.md           ← Gemini CLI 适配
    └── opencode.md             ← OpenCode 适配
```

## 自定义扩展

在 SKILL.md 的 `## MiniMax 2.7 优化规则` 章节中，可以：
- 追加新的场景规则（如数据库、DevOps、AI/ML）
- 修改现有规则参数
- 添加更多语言/框架专项规则
