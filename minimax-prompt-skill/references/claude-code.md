# MiniMax Prompt — Claude Code 适配

## 安装

确保 minimax-prompt-skill 目录位于 Claude Code 可发现的 skill 路径中：

```bash
# 通过 Superpowers 插件管理，将 skill 放置在 skills 目录
cp -r minimax-prompt-skill ~/.claude/skills/
```

## 调用

- **交互模式:** `/minimax-prompt`
- **快速模式:** `/minimax-prompt 帮我生成一个 Python 命令行工具`

## 注意事项

- Claude Code 使用 `Skill` 工具加载 skill
- 通过 slash command 方式触发
- 确认后的 prompt 可以直接在当前对话中使用
