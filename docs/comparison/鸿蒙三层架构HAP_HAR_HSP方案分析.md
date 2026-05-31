# 鸿蒙三层架构：Common(HSP) + Feature(HAR) + Product(HAP)方案分析

---

## 目录

1. [包类型基础回顾](#1-包类型基础回顾)
2. [方案架构设计](#2-方案架构设计)
3. [优点分析](#3-优点分析)
4. [缺点分析](#4-缺点分析)
5. [问题场景剖析](#5-问题场景剖析)
6. [优化建议方案](#6-优化建议方案)
7. [最佳实践指南](#7-最佳实践指南)

---

## 1. 包类型基础回顾

### 1.1 三种包类型对比

| 维度 | HAP (Harmony Ability Package) | HAR (Harmony Archive) | HSP (Harmony Shared Package) |
|-----|------------------------------|---------------------|------------------------------|
| **全称** | 鸿蒙能力包 | 鸿蒙归档包 | 鸿蒙共享包 |
| **性质** | 应用安装/运行基本单元 | 静态共享包 | 动态共享包 |
| **加载方式** | 独立安装运行 | 编译时打包进引用方 | 运行时按需加载 |
| **代码共享** | 不共享 | 每个引用方一份拷贝 | 多模块共享一份 |
| **包含Ability** | ✅ 可以包含 | ❌ 不能包含 | ✅ 可以包含 |
| **独立发布** | ✅ 可以 | ✅ 可以 | ❌ 不可以 |
| **启动性能** | ⚡ 最快 | ⚡ 快 | 🐌 稍慢（运行时加载） |

### 1.2 官方建议的选择策略

```
被大量HAP频繁复用 → HSP（节省空间）
被少数HAP引用 → HAR（加载效率高）
需要独立发布到OHPM → HAR
对启动速度要求极高 → HAR
应用包体大小敏感 → HSP
```

---

## 2. 方案架构设计

### 2.1 原始方案

```
Product层（HAP）
    ├── Entry HAP（主入口）
    └── Feature HAP（可选特性模块）
            │
    ┌───────┴─────────┐
    │                 │
Feature层（HAR）      │
    ├── feature-user.har
    ├── feature-product.har
    ├── feature-order.har
    └── feature-cart.har
            │
    ┌───────┴─────────┐
    │                 │
Common层（HSP）       │
    └── common-core.hsp
```

### 2.2 依赖关系图

```
Product (HAP)
    ↓ 直接依赖
Feature (HAR)
    ↓ 直接依赖
Common (HSP)
```

**编译后形态**：
- 每个Feature HAR都会被完整拷贝进Product HAP
- Common HSP只保留一份，运行时共享

---

## 3. 优点分析

### 3.1 优点1：Common代码真正共享

```typescript
// ✅ 场景：多个Feature都依赖Common工具类
// Common作为HSP，所有HAR共享同一份代码

// 编译后包体
Product.hap
├── entry_hap/
│   ├── feature_user_har（编译后拷贝）
│   ├── feature_product_har（编译后拷贝）
│   └── ...
└── common_core_hsp（仅一份，共享）
```

**收益**：
- 包体积优化：Common代码不会重复
- 内存优化：运行时只加载一份Common代码
- 统一行为：所有Feature使用相同的Common版本

### 3.2 优点2：Feature编译速度快

```typescript
// ✅ 场景：修改一个Feature模块

// Feature作为HAR
// 1. 只编译修改的HAR模块
// 2. 其他HAR不受影响
// 3. 增量编译速度快
```

**收益**：
- 开发效率高：单个Feature修改，无需全量编译
- 并行开发：团队可并行开发不同Feature模块
- 测试隔离：单个HAR可独立进行单元测试

### 3.3 优点3：架构职责清晰

```
Product (HAP) - 应用入口和产品定制
Feature (HAR) - 业务功能模块
Common (HSP)  - 公共基础能力
```

**收益**：
- 职责分明：每层有明确的边界
- 团队分工：不同团队可负责不同层
- 演进路线清晰：每层可独立演进

---

## 4. 缺点分析

### 4.1 缺点1：Feature作为HAR无法包含Ability

```typescript
// ❌ 问题：HAR的核心限制

// module.json5 中Library类型Module
{
  "module": {
    "type": "har",  // Library类型
    "abilities": [  // ❌ HAR不能包含Ability！
      {
        "name": "UserAbility",
        ...
      }
    ]
  }
}

// 编译报错：
// ERROR: HAR module cannot contain Ability declaration
```

**场景举例**：

```typescript
// ❌ Feature想包含页面怎么办？
// feature-user.har 中：
@Entry
@Component
struct LoginPage {
  // 编译报错！HAR不能包含Entry组件
}
```

### 4.2 缺点2：Feature间通信困难

```typescript
// ❌ 问题：两个Feature HAR都依赖Common HSP

// Product.hap 编译后
entry_hap
├── feature_user_har（拷贝）
├── feature_product_har（拷贝）
└── common_core_hsp（共享）

// 问题：
// feature_user.har 想调用 feature_product.har → 无法直接通信
// 因为它们是独立拷贝，运行时也是独立存在
```

**通信困难场景**：

```typescript
// ❌ feature-user 想获取 feature-product 的数据
import { ProductService } from 'feature-product/services/ProductService'  // 编译依赖

// 问题：
// 1. 编译时就产生依赖耦合
// 2. 修改Product模块需要重新编译User模块
// 3. 两个HAR的隔离性被打破
```

### 4.3 缺点3：启动性能问题

```typescript
// ❌ 问题：HSP的运行时加载开销

// Common作为HSP，启动流程
App启动 → 加载Entry HAP → 加载Common HSP → 初始化 → 渲染首屏
         （已在内存）   （运行时加载）    （耗时）

// Common作为HAR，启动流程
App启动 → 加载Entry HAP（已包含Common） → 直接初始化 → 渲染首屏
         （编译时已打包）                （更快）
```

**性能对比**：

| 场景 | Common作为HSP | Common作为HAR |
|-----|--------------|--------------|
| **首屏加载** | 稍慢（需运行时加载HSP） | 更快（编译时已打包） |
| **包体积** | 更小（只一份） | 更大（每个HAP一份） |
| **内存占用** | 更低（共享） | 更高（重复） |

### 4.4 缺点4：调试复杂度增加

```typescript
// ❌ 问题：多层包的调试链路

// 调试链路
Product HAP
    ↓
Feature HAR
    ↓
Common HSP

// 断点调试时需要：
// 1. 确认调用链经过哪些包
// 2. HSP的代码需要动态加载后才能调试
// 3. 堆栈跟踪需要跨多个包追踪
```

---

## 5. 问题场景剖析

### 5.1 场景1：Feature需要包含页面

**原始方案问题**：

```typescript
// ❌ feature-user.har 想包含用户登录页面
// module.json5
{
  "module": {
    "type": "har",  // Library类型
    "abilities": [  // ❌ 不支持！
      {
        "name": "LoginAbility"
      }
    ]
  }
}

// 编译报错：Library module cannot contain Ability
```

**为什么HAR不能包含Ability？**

- HAR是编译时拷贝，多个HAP都引用同一个HAR会导致Ability重复
- Ability需要在系统中注册，重复注册会冲突
- 这是鸿蒙系统的限制，不是架构问题

### 5.2 场景2：Feature间需要通信

**原始方案问题**：

```typescript
// ❌ feature-user 和 feature-product 需要通信

// feature-user.har
import { ProductService } from 'feature-product/services/ProductService'
// 问题：编译时依赖，破坏了模块隔离

// 或者：
EventBus.emit('user_login', userId)
// 问题：两个HAR都是独立拷贝，事件无法跨HAR传递
```

**运行时隔离问题**：

```typescript
// 编译后的运行时
Entry HAP
├── feature-user.har 的拷贝
│   └── EventBus（独立实例A）
└── feature-product.har 的拷贝
    └── EventBus（独立实例B）  // 与A不互通！

// 结果：
// feature-user发出的事件，feature-product收不到
```

### 5.3 场景3：Common层膨胀问题仍然存在

```typescript
// ❌ Common作为HSP，但膨胀问题没有根本解决

common.hsp
├── common-core/
├── common-ui/
├── common-network/
├── common-utils/
└── ... （继续膨胀）

// 问题：
// 1. HSP仍然会整体加载，不管用不用
// 2. 修改Common的任何部分，都需要重新编译
// 3. 还是没有解决"Common职责不清"的架构问题
```

---

## 6. 优化建议方案

### 6.1 方案A：Feature改用HSP（推荐）

```
Product层（HAP）
    ├── Entry HAP（主入口）
    └── Feature HAP（可选特性）
            │
    ┌───────┴─────────┐
    │                 │
Feature层（HSP）      │
    ├── feature-user.hsp
    ├── feature-product.hsp
    ├── feature-order.hsp
    └── feature-cart.hsp
            │
    ┌───────┴─────────┐
    │                 │
Common层（HSP）       │
    └── common-core.hsp
```

**优点**：

| 优点 | 说明 |
|-----|------|
| **Feature可包含Ability** | HSP可以包含Ability，解决页面问题 |
| **运行时通信** | 多个HSP在同一进程，可通过EventBus通信 |
| **按需加载** | Feature HSP可在需要时才加载 |

**实现示例**：

```typescript
// ✅ feature-user.hsp 可以包含Ability
// module.json5
{
  "module": {
    "type": "hsp",  // Shared Library
    "abilities": [  // ✅ 支持Ability！
      {
        "name": "LoginAbility",
        "srcEntry": "./ets/entryability/LoginAbility.ets"
      }
    ]
  }
}

// ✅ 可以包含页面
// feature-user/pages/Login.ets
@Entry
@Component
struct LoginPage {
  build() {
    // 登录页面实现
  }
}

// ✅ Feature间通信
// feature-user/services/UserService.ts
EventBus.emit('user_login', { userId: '123' })

// feature-product/services/ProductService.ts
EventBus.on('user_login', (data) => {
  console.info(`用户${data.userId}登录了`)
  // 可以收到事件！
})
```

### 6.2 方案B：Common分层为HAR+HSP组合

```
Common层（分层设计）
├── common-core.har  // 核心基础（HAR，启动快）
├── common-ui.hsp    // UI组件（HSP，按需加载）
├── common-network.har  // 网络（HAR，启动时需要）
└── common-utils.hsp   // 工具（HSP，按需加载）
```

**优点**：

| 模块 | 类型 | 原因 |
|-----|-----|------|
| common-core | HAR | 启动必需，需快速加载 |
| common-network | HAR | 网络请求是核心能力 |
| common-ui | HSP | UI组件按需加载 |
| common-utils | HSP | 工具函数按需使用 |

### 6.3 方案C：综合方案（最佳实践）

```
Product层（HAP）
├── Entry HAP
│   └── 主入口、首页
└── Feature HAP
    ├── feature-user.hap
    └── feature-product.hap
          │
    ┌─────┴─────┐
    │           │
Feature层（HSP）│
├── feature-user-impl.hsp
├── feature-product-impl.hsp
└── ...
          │
    ┌─────┴─────┐
    │           │
Common层（混合）│
├── common-core.har
├── common-ui.hsp
└── common-network.har
```

**分层策略**：

| 层级 | 包类型 | 原因 |
|-----|-------|-----|
| **Product** | HAP | 应用入口，用户安装的包 |
| **Feature接口** | HAP | Feature模块入口，可按需安装 |
| **Feature实现** | HSP | 具体实现，动态加载 |
| **Common核心** | HAR | 启动必需，性能优先 |
| **Common扩展** | HSP | 按需加载，空间优先 |

---

## 7. 最佳实践指南

### 7.1 决策流程图

```
是否包含Ability？
    ├─ 是 → 使用HAP或HSP
    └─ 否 → 是否被大量复用？
            ├─ 是 → 使用HSP
            └─ 否 → 使用HAR
```

### 7.2 包类型选择清单

| 检查项 | 推荐类型 |
|-----|---------|
| 需要包含页面/Ability | HAP 或 HSP |
| 需要独立发布到OHPM | HAR |
| 被5个以上模块复用 | HSP |
| 启动时立即需要 | HAR |
| 按需使用的功能 | HSP |
| 需要跨模块通信 | HAP 或 HSP |

### 7.3 三层架构建议配置

```typescript
// 建议方案
common/
├── common-core/        // HAR - 基础能力
├── common-ui/          // HSP - UI组件
└── common-network/     // HAR - 网络能力

features/
├── feature-user/       // HAP - 用户模块
├── feature-product/    // HAP - 商品模块
└── feature-cart/       // HSP - 购物车（可选）

product/
├── main/               // HAP - 主应用
└── lite/               // HAP - 轻量版
```

---

## 总结

### 原始方案评价

| 维度 | 评分 | 说明 |
|-----|-----|-----|
| **架构清晰度** | ⭐⭐⭐⭐ | 三层边界清晰 |
| **可维护性** | ⭐⭐ | Feature作为HAR限制太多 |
| **可扩展性** | ⭐⭐ | Feature无法包含Ability |
| **性能** | ⭐⭐⭐ | HSP有启动开销 |
| **通信能力** | ⭐ | Feature间通信困难 |

**结论**：**原始方案理论可行，但存在重要限制**

**主要问题**：
1. ❌ Feature作为HAR无法包含Ability（页面）
2. ❌ Feature间通信困难
3. ⚠️ 启动性能有损耗

**建议改进**：
- Feature改用HSP（可包含Ability，可通信）
- Common核心用HAR（启动快），扩展用HSP（省空间）
- Product用HAP（作为入口）

这样可以充分发挥各种包类型的优势，又能避免各自的限制！
