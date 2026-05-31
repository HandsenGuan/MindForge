# MiniMax Prompt — Gemini CLI 适配

## 安装

确保 Skills 已配置，将 skill 放置在 Gemini CLI 可发现的路径中。

## 调用

```bash
# 交互模式
activate_skill minimax-prompt

# 快速模式
activate_skill minimax-prompt "帮我写一段 SQL 查询"
```

## 注意事项

- Gemini CLI 使用 `activate_skill` 工具加载 skill
- 优化好的 prompt 可以直接在当前对话中继续使用
