# 📚 文档索引

## 鸿蒙应用端侧架构文档库

&gt; 系统化分析鸿蒙应用架构设计、架构演进和最佳实践

### 1️⃣ **架构演进分析**
| 文档 | 分类 | 关键词 | 摘要 |
|-----|------|-------|-----|
| [鸿蒙应用端侧架构演进分析](docs/architecture/鸿蒙应用端侧架构演进分析.md) | 架构演进 | 三层架构, Ability, ArkUI, 分布式, 方舟编译 | 系统性推演从传统三层架构到极致优化的完整演进路径 |

### 2️⃣ **三层架构设计**
| 文档 | 分类 | 关键词 | 摘要 |
|-----|------|-------|-----|
| [鸿蒙三层架构深度分析](docs/feature/鸿蒙三层架构CommonFeatureProduct分析.md) | Feature架构 | Common层, Feature层, Product层, 膨胀问题, 交叉依赖 | Common/Feature/Product三层架构的设计、优化和最佳实践 |
| [HAP/HAR/HSP方案分析](docs/comparison/鸿蒙三层架构HAP_HAR_HSP方案分析.md) | 包类型方案 | HSP, HAR, HAP, 包类型选择 | 详细分析三种包类型在三层架构中的应用和优化方案 |

### 3️⃣ **Feature模块设计**
| 文档 | 分类 | 关键词 | 摘要 |
|-----|------|-------|-----|
| [Feature间View组件依赖问题深度剖析](docs/feature/dependency/Feature间View组件依赖问题深度剖析.md) | Feature解耦 | 组件依赖, 组合插槽, 数据驱动, 路由跳转 | Feature间View组件交叉依赖的深度分析和解决方案 |

### 📂 文档目录结构
```
docs/
├── architecture/          # 架构演进分析
│   └── 鸿蒙应用端侧架构演进分析.md
├── feature/               # Feature模块设计
│   ├── 鸿蒙三层架构CommonFeatureProduct分析.md
│   └── dependency/        # Feature依赖问题
│       └── Feature间View组件依赖问题深度剖析.md
├── comparison/            # 方案对比
│   └── 鸿蒙三层架构HAP_HAR_HSP方案分析.md
└── DOCS_META.md           # 文档元数据
```

### 🔍 关键词快速查找
- **三层架构** → [鸿蒙三层架构深度分析](docs/feature/鸿蒙三层架构CommonFeatureProduct分析.md)
- **Common膨胀** → [鸿蒙三层架构深度分析](docs/feature/鸿蒙三层架构CommonFeatureProduct分析.md)
- **组件依赖** → [Feature间View组件依赖问题深度剖析](docs/feature/dependency/Feature间View组件依赖问题深度剖析.md)
- **HAP/HAR/HSP** → [HAP/HAR/HSP方案分析](docs/comparison/鸿蒙三层架构HAP_HAR_HSP方案分析.md)
- **架构演进** → [鸿蒙应用端侧架构演进分析](docs/architecture/鸿蒙应用端侧架构演进分析.md)

### 📖 阅读顺序建议
1. **入门**：从架构演进开始 → [鸿蒙应用端侧架构演进分析](docs/architecture/鸿蒙应用端侧架构演进分析.md)
2. **深入**：接着阅读三层架构设计 → [鸿蒙三层架构深度分析](docs/feature/鸿蒙三层架构CommonFeatureProduct分析.md)
3. **方案选择**：再看包类型对比 → [HAP/HAR/HSP方案分析](docs/comparison/鸿蒙三层架构HAP_HAR_HSP方案分析.md)
4. **问题解决**：遇到组件依赖问题 → [Feature间View组件依赖问题深度剖析](docs/feature/dependency/Feature间View组件依赖问题深度剖析.md)
