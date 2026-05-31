# MiniMax Prompt — Copilot CLI 适配

## 安装

确保 Agent Skills 已配置好，将 skill 放置在正确路径。

## 调用

```bash
# 交互模式
skill minimax-prompt

# 快速模式
skill minimax-prompt "帮我重构这个 React 组件"
```

## 注意事项

- Copilot CLI 使用 `skill` 工具加载 skill
- 当前对话中优化完毕的 prompt 可以直接在后续消息中使用
