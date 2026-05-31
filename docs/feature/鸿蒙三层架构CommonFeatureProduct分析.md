# 鸿蒙应用三层架构（Common/Feature/Product）深度分析

> 作者：鸿蒙应用开发架构师  
> 版本：v1.0  
> 日期：2026-05-31

---

## 目录

1. [三层架构概述](#1-三层架构概述)
2. [Common层设计与优化](#2-common层设计与优化)
3. [Feature层解耦策略](#3-feature层解耦策略)
4. [Product层组合编排](#4-product层组合编排)
5. [交叉依赖解决方案](#5-交叉依赖解决方案)
6. [性能优化方案](#6-性能优化方案)
7. [实践案例与代码示例](#7-实践案例与代码示例)
8. [演进路径与最佳实践](#8-演进路径与最佳实践)

---

## 1. 三层架构概述

### 1.1 架构分层定义

```
┌─────────────────────────────────────────────────────────┐
│                     Product 层                          │
│  （产品特定配置与入口）                                   │
├─────────────────────────────────────────────────────────┤
│                     Feature 层                          │
│  （业务特性模块，可独立编译）                              │
├─────────────────────────────────────────────────────────┤
│                     Common 层                          │
│  （公共能力基座）                                        │
└─────────────────────────────────────────────────────────┘
```

### 1.2 各层职责划分

#### Common层 - 公共能力基座

**职责定位**：
- 提供不依赖业务的基础能力
- 跨Feature共享的工具和组件
- 平台能力封装（网络、存储、埋点等）

**包含内容**：

```typescript
// Common层目录结构
common/
├── base/                    // 基础能力
│   ├── utils/              // 通用工具
│   │   ├── logger.ts       // 日志工具
│   │   ├── date.ts         // 日期处理
│   │   ├── string.ts       // 字符串处理
│   │   └── validator.ts    // 数据校验
│   ├── extensions/         // 扩展方法
│   │   ├── array.ts        // 数组扩展
│   │   ├── object.ts       // 对象扩展
│   │   └── string.ts       // 字符串扩展
│   └── constants/          // 常量定义
│       ├── colors.ts       // 颜色常量
│       ├── dimensions.ts   // 尺寸常量
│       └── api.ts          // API常量
│
├── components/              // 通用UI组件
│   ├── Button/
│   ├── Input/
│   ├── Card/
│   ├── List/
│   └── Empty/
│
├── network/                // 网络层
│   ├── client.ts          // HTTP客户端
│   ├── interceptor.ts     // 拦截器
│   ├── error.ts           // 错误处理
│   └── types.ts           // 网络类型
│
├── storage/               // 存储层
│   ├── preference.ts      // 首选项存储
│   ├── database.ts        // 数据库封装
│   └── cache.ts           // 缓存管理
│
├── tracking/              // 埋点与分析
│   ├── tracker.ts         // 埋点SDK封装
│   ├── analytics.ts       // 事件分析
│   └── performance.ts    // 性能监控
│
└── platform/              // 平台能力封装
    ├── ability.ts         // Ability工具
    ├── device.ts         // 设备信息
    └── permission.ts     // 权限管理
```

#### Feature层 - 业务特性模块

**职责定位**：
- 独立的业务功能单元
- 可按需加载的模块化设计
- Feature内自包含完整业务逻辑

**包含内容**：

```typescript
// Feature层目录结构
features/
├── feature-user/          // 用户模块
│   ├── entry/
│   │   └── FeatureUser.ets
│   ├── pages/
│   │   ├── Login.ets
│   │   ├── Register.ets
│   │   └── Profile.ets
│   ├── components/
│   │   ├── LoginForm.ets
│   │   └── UserAvatar.ets
│   ├── viewmodels/
│   │   └── UserViewModel.ets
│   ├── services/
│   │   └── UserService.ets
│   ├── repository/
│   │   └── UserRepository.ets
│   └── models/
│       └── User.ets
│
├── feature-order/         // 订单模块
│   ├── entry/
│   │   └── FeatureOrder.ets
│   ├── pages/
│   │   ├── OrderList.ets
│   │   ├── OrderDetail.ets
│   │   └── Checkout.ets
│   ├── components/
│   │   ├── OrderCard.ets
│   │   └── AddressPicker.ets
│   ├── services/
│   │   └── OrderService.ets
│   └── ...
│
├── feature-product/       // 商品模块
│   ├── entry/
│   │   └── FeatureProduct.ets
│   ├── pages/
│   │   ├── ProductList.ets
│   │   ├── ProductDetail.ets
│   │   └── Search.ets
│   ├── components/
│   │   ├── ProductCard.ets
│   │   └── PriceTag.ets
│   ├── services/
│   │   └── ProductService.ets
│   └── ...
│
└── feature-cart/          // 购物车模块
    ├── entry/
    │   └── FeatureCart.ets
    ├── pages/
    │   ├── CartList.ets
    │   └── CartSettle.ets
    ├── components/
    │   ├── CartItem.ets
    │   └── CartSummary.ets
    ├── services/
    │   └── CartService.ets
    └── ...
```

#### Product层 - 产品配置层

**职责定位**：
- 应用入口配置
- Feature模块注册
- 产品特定定制
- 路由与导航编排

**包含内容**：

```typescript
// Product层目录结构
product/
├── app/
│   ├── App.ets            // 应用入口
│   ├── AppStorage.ets     // 全局存储
│   └── AppLifecycle.ets   // 应用生命周期
│
├── main/                  // 主产品
│   ├── main.ets           // 主入口
│   ├── pages/             // 主App页面
│   └── router/            // 路由配置
│
├── lite/                  // 轻量版
│   ├── lite.ets           // 轻量入口
│   └── pages/
│
└── tablet/                // 平板版
    ├── tablet.ets         // 平板入口
    └── pages/
```

### 1.3 模块间依赖关系

```
                    Product 层
                   ┌────────────┐
                   │ Main Entry │
                   └─────┬──────┘
                         │
          ┌──────────────┼──────────────┐
          │              │              │
    Feature A       Feature B      Feature C
    (用户模块)      (订单模块)      (商品模块)
          │              │              │
          └──────────────┼──────────────┘
                         │
                   Common 层
              ┌──────────┼──────────┐
              │          │          │
          Base库     组件库     工具库
```

---

## 2. Common层设计与优化

### 2.1 Common层膨胀问题分析

#### 2.1.1 常见问题

| 问题类型 | 具体表现 | 影响 |
|---------|---------|-----|
| **功能堆砌** | 多个Feature都往Common中添加"通用"代码 | Common边界模糊，难以维护 |
| **循环依赖** | Feature A依赖Common，Feature B依赖Common，Common依赖Feature | 编译失败 |
| **启动变慢** | Common模块过大，首次加载时间长 | 首屏渲染延迟 |
| **版本耦合** | 所有Feature共用同一Common版本 | Feature升级受限 |
| **职责扩散** | Common包含业务逻辑 | 违背单一职责原则 |

#### 2.1.2 膨胀原因分析

**场景1：过早抽象**

```typescript
// ❌ Common层中过早抽象的接口
// common/interfaces/UserInterface.ts
export interface UserInterface {
  getUserInfo(): Promise<User>
  updateProfile(profile: UserProfile): Promise<void>
  uploadAvatar(uri: string): Promise<string>
  getFollowers(): Promise<User[]>
  followUser(userId: string): Promise<void>
  unfollowUser(userId: string): Promise<void>
  getUserSettings(): Promise<UserSettings>
  updateUserSettings(settings: UserSettings): Promise<void>
  // ... 更多业务方法
}

// 原因：UserInterface包含了过多业务细节
// 实际：UserInterface应该属于Feature层，Common层只需要基础数据结构
```

**场景2：共享组件滥用**

```typescript
// ❌ Common层中业务相关的组件
// common/components/UserCard.ts
@Component
export struct UserCard {
  @Prop user: User
  @Prop showFollowButton: boolean = false
  @Prop showStatistics: boolean = false
  
  build() {
    Column() {
      // 用户头像、昵称
      // 关注按钮
      // 统计数据（粉丝数、获赞数）
      // 作品列表预览
      // ...
    }
  }
}

// 问题：UserCard包含过多业务逻辑，属于Feature-User模块
```

### 2.2 Common层分层设计

#### 2.2.1 推荐的Common层分层

```
Common层（分层设计）
├── common-core              // 核心基础（最小集合）
│   ├── types/              // 基础类型定义
│   ├── constants/          // 全局常量
│   └── utils/              // 纯工具函数
│
├── common-ui               // 通用UI组件
│   ├── Button/
│   ├── Input/
│   ├── Card/
│   ├── List/
│   └── Empty/
│
├── common-network          // 网络能力
│   ├── http/               // HTTP客户端
│   ├── websocket/          // WebSocket
│   └── types/              // 网络类型
│
├── common-storage          // 存储能力
│   ├── preference/         // 首选项
│   ├── database/           // 数据库
│   └── cache/              // 缓存
│
└── common-platform         // 平台能力
    ├── device/             // 设备信息
    ├── permission/          // 权限管理
    └── ability/            // Ability工具
```

#### 2.2.2 依赖规则定义

```
依赖规则：
1. common-core 可以被所有模块依赖
2. common-ui 依赖 common-core
3. common-network 依赖 common-core
4. common-storage 依赖 common-core
5. common-platform 依赖 common-core
6. Feature层可以依赖任意Common子模块
7. Common层禁止依赖Feature层
8. 禁止循环依赖
```

### 2.3 Common层边界管控

#### 2.3.1 判断标准：Should-Be-In-Common

**应该放入Common的情况**：

```typescript
// ✅ 1. 基础数据类型
// common-core/types/response.ts
export interface Response<T> {
  code: number
  data: T
  message: string
}

// ✅ 2. 纯工具函数（无业务依赖）
// common-core/utils/date.ts
export function formatDate(date: Date, pattern: string): string {
  // 日期格式化逻辑
}

// ✅ 3. 通用UI组件（无业务状态）
// common-ui/components/Loading.ts
@Component
export struct Loading {
  @Prop message: string = '加载中...'
  
  build() {
    Row() {
      LoadingProgress()
      Text(this.message)
    }
  }
}

// ✅ 4. 平台能力封装
// common-platform/ability/screen.ts
export function getScreenDensity(): number {
  const display = display.getDefaultDisplaySync()
  return display.densityDPI
}
```

**不应该放入Common的情况**：

```typescript
// ❌ 1. 业务模型
// 应该放在对应的Feature层
// feature-user/models/User.ts
export class User {
  id: string
  nickname: string
  followerCount: number  // 业务相关
}

// ❌ 2. 业务组件
// feature-user/components/UserProfileCard.ts
@Component
export struct UserProfileCard {
  @ObjectLink user: User
  // 包含关注、点赞等业务逻辑
}

// ❌ 3. 业务服务
// feature-order/services/OrderService.ts
// 包含订单相关的业务逻辑

// ❌ 4. API接口定义（属于具体Feature）
// feature-product/api/product.ts
```

#### 2.3.2 Common层膨胀检测

```typescript
// scripts/check-common-size.ts
import fs from 'fs'
import path from 'path'

interface ModuleInfo {
  name: string
  size: number
  fileCount: number
  lastModified: Date
}

function analyzeCommonModule(commonPath: string): ModuleInfo[] {
  const modules: ModuleInfo[] = []
  
  const dirs = fs.readdirSync(commonPath)
  dirs.forEach(dir => {
    const dirPath = path.join(commonPath, dir)
    if (fs.statSync(dirPath).isDirectory()) {
      const stats = calculateDirSize(dirPath)
      modules.push({
        name: dir,
        ...stats
      })
    }
  })
  
  return modules.sort((a, b) => b.size - a.size)
}

function calculateDirSize(dirPath: string): { size: number, fileCount: number } {
  let size = 0
  let fileCount = 0
  
  function traverse(currentPath: string) {
    const files = fs.readdirSync(currentPath)
    files.forEach(file => {
      const filePath = path.join(currentPath, file)
      const stat = fs.statSync(filePath)
      if (stat.isDirectory()) {
        traverse(filePath)
      } else {
        size += stat.size
        fileCount++
      }
    })
  }
  
  traverse(dirPath)
  return { size, fileCount }
}

// 膨胀检测规则
function checkBloat(modules: ModuleInfo[]): string[] {
  const warnings: string[] = []
  const maxSize = 5 * 1024 * 1024 // 5MB
  
  modules.forEach(module => {
    if (module.size > maxSize) {
      warnings.push(`⚠️ ${module.name} 模块过大: ${formatSize(module.size)}`)
    }
    
    if (module.fileCount > 500) {
      warnings.push(`⚠️ ${module.name} 文件过多: ${module.fileCount} 个文件`)
    }
  })
  
  return warnings
}
```

---

## 3. Feature层解耦策略

### 3.1 Feature层交叉依赖问题

#### 3.1.1 问题场景

**场景1：View组件交叉依赖**

```typescript
// ❌ Feature-A的组件依赖Feature-B的组件
// feature-user/components/UserProfileCard.ts
import { ProductCard } from 'feature-product/components/ProductCard'

@Component
export struct UserProfileCard {
  @ObjectLink user: User
  
  build() {
    Column() {
      // 用户信息...
      
      // 问题：用户资料卡需要展示用户喜欢的商品
      // 直接依赖了ProductCard组件
      ForEach(this.user.favoriteProducts, (product) => {
        ProductCard({ product: product })  // 跨Feature依赖
      })
    }
  }
}
```

**场景2：接口交叉依赖**

```typescript
// ❌ Feature-A的服务调用Feature-B的服务
// feature-order/services/OrderService.ts
import { ProductService } from 'feature-product/services/ProductService'
import { UserService } from 'feature-user/services/UserService'

export class OrderService {
  async createOrder(userId: string, productIds: string[]): Promise<Order> {
    // 调用ProductService获取商品信息
    const products = await ProductService.getProducts(productIds)
    
    // 调用UserService获取用户信息
    const user = await UserService.getUser(userId)
    
    // 创建订单逻辑...
  }
}

// 问题：OrderService依赖了多个Feature的服务
// 导致Feature间强耦合
```

**场景3：类型交叉依赖**

```typescript
// ❌ 共享类型定义混乱
// common/types/Order.ts - 本该属于Feature层
export class Order {
  userId: string
  products: Product[]  // Product是ProductFeature的类型
  address: Address     // Address可能又是另一个Feature的类型
}

// 导致：所有Feature的类型都往Common里堆
```

### 3.2 Feature解耦核心原则

| 原则 | 说明 | 示例 |
|-----|------|------|
| **单向依赖** | Feature之间禁止直接依赖，通过接口抽象 | UserFeature定义IUser接口，OrderFeature使用 |
| **共享类型下沉** | 共享类型放到Common层 | Response<T>、PageResult<T> |
| **业务类型内聚** | 业务模型放在对应Feature层 | User属于UserFeature，Order属于OrderFeature |
| **服务接口隔离** | 服务交互通过接口定义 | IUserService、IOrderService |
| **ViewModel暴露** | ViewModel可跨Feature使用，View禁止 | 允许调用UserViewModel，不允许引用UserCard组件 |

### 3.3 Feature解耦架构设计

#### 3.3.1 接口抽象层

```typescript
// feature-user/interfaces/index.ts
// Feature对外暴露的接口定义

// 用户信息服务接口
export interface IUserInfoService {
  getUserInfo(userId: string): Promise<UserInfo>
  updateUserProfile(profile: UserProfile): Promise<void>
  getUserSettings(): Promise<UserSettings>
}

// 用户关系服务接口
export interface IUserRelationService {
  followUser(userId: string): Promise<void>
  unfollowUser(userId: string): Promise<void>
  getFollowers(userId: string): Promise<User[]>
  getFollowing(userId: string): Promise<User[]>
}

// 用户统计数据接口
export interface IUserStatsService {
  getUserStats(userId: string): Promise<UserStats>
  incrementViewCount(userId: string): Promise<void>
}

// 统一导出
export {
  IUserInfoService,
  IUserRelationService,
  IUserStatsService
}
```

#### 3.3.2 Feature入口封装

```typescript
// feature-user/entry/FeatureUser.ts
import { IUserInfoService, IUserRelationService } from '../interfaces'

// Feature内部服务实现
import { UserInfoService } from '../services/UserInfoService'
import { UserRelationService } from '../services/UserRelationService'

// Feature对外暴露的能力
export class FeatureUser {
  private static instance: FeatureUser
  
  // 服务实例
  private userInfoService: IUserInfoService
  private userRelationService: IUserRelationService
  
  static getInstance(): FeatureUser {
    if (!FeatureUser.instance) {
      FeatureUser.instance = new FeatureUser()
    }
    return FeatureUser.instance
  }
  
  constructor() {
    // 初始化服务
    this.userInfoService = new UserInfoService()
    this.userRelationService = new UserRelationService()
  }
  
  // 获取服务实例
  getUserInfoService(): IUserInfoService {
    return this.userInfoService
  }
  
  getUserRelationService(): IUserRelationService {
    return this.userRelationService
  }
  
  // 初始化Feature
  async init(): Promise<void> {
    await this.userInfoService.init()
  }
  
  // 清理Feature资源
  destroy(): void {
    this.userInfoService = null
    this.userRelationService = null
  }
}
```

---

## 4. Product层组合编排

### 4.1 Product层职责

```
Product 层职责：
1. 应用入口配置
2. Feature模块注册
3. 路由与导航编排
4. 产品特定定制
5. 全局状态初始化
```

### 4.2 Feature注册机制

```typescript
// product/main/App.ets
import { FeatureRegistry } from 'common-core/feature/FeatureRegistry'
import { FeatureUser } from 'feature-user/entry/FeatureUser'
import { FeatureProduct } from 'feature-product/entry/FeatureProduct'
import { FeatureOrder } from 'feature-order/entry/FeatureOrder'
import { FeatureCart } from 'feature-cart/entry/FeatureCart'

// Feature注册
FeatureRegistry.register({
  name: 'user',
  entry: FeatureUser.getInstance(),
  lazy: false,  // 是否延迟加载
  dependencies: []  // 依赖的其他Feature
})

FeatureRegistry.register({
  name: 'product',
  entry: FeatureProduct.getInstance(),
  lazy: true,
  dependencies: []
})

FeatureRegistry.register({
  name: 'order',
  entry: FeatureOrder.getInstance(),
  lazy: true,
  dependencies: ['user', 'product', 'cart']
})

FeatureRegistry.register({
  name: 'cart',
  entry: FeatureCart.getInstance(),
  lazy: true,
  dependencies: ['user', 'product']
})

// 应用启动
@Entry
struct App {
  onCreate() {
    // 按依赖顺序初始化非延迟加载的Feature
    FeatureRegistry.initialize()
  }
}
```

### 4.3 Feature懒加载策略

```typescript
// common-core/feature/FeatureRegistry.ts
export class FeatureRegistry {
  private static instance: FeatureRegistry
  private features: Map<string, FeatureConfig> = new Map()
  private initialized: Set<string> = new Set()
  
  // 注册Feature
  static register(config: FeatureConfig): void {
    this.instance.features.set(config.name, config)
  }
  
  // 获取Feature实例
  static async getFeature<T>(name: string): Promise<T> {
    const config = this.features.get(name)
    if (!config) {
      throw new Error(`Feature ${name} not registered`)
    }
    
    // 检查是否已初始化
    if (!this.initialized.has(name)) {
      // 检查依赖是否已初始化
      await this.ensureDependencies(config)
      
      // 懒加载或初始化
      await config.entry.init()
      this.initialized.add(name)
    }
    
    return config.entry as T
  }
  
  // 确保依赖已初始化
  private static async ensureDependencies(config: FeatureConfig): Promise<void> {
    for (const dep of config.dependencies || []) {
      if (!this.initialized.has(dep)) {
        const depConfig = this.features.get(dep)
        if (depConfig) {
          await this.ensureDependencies(depConfig)
          await depConfig.entry.init()
          this.initialized.add(dep)
        }
      }
    }
  }
  
  // 初始化所有非懒加载的Feature
  static async initialize(): Promise<void> {
    for (const [name, config] of this.features) {
      if (!config.lazy) {
        await this.getFeature(name)
      }
    }
  }
}
```

---

## 5. 交叉依赖解决方案

### 5.1 View组件交叉依赖解决方案

#### 方案一：组合插槽模式

**核心思想**：将业务组件需要的子组件通过插槽传入

```typescript
// ✅ 解决方案：UserProfileCard通过插槽接收ProductCard
// feature-user/components/UserProfileCard.ts
@Component
export struct UserProfileCard {
  @ObjectLink user: User
  
  // 插槽：用户喜欢的商品列表
  @BuilderParam favoriteProductsBuilder?: (products: Product[]) => void
  
  // 插槽：用户作品列表
  @BuilderParam userWorksBuilder?: (works: Work[]) => void
  
  build() {
    Column() {
      // 用户基础信息
      this.buildUserInfo()
      
      // 用户喜欢的商品（通过插槽渲染）
      if (this.favoriteProductsBuilder && this.user.favoriteProducts) {
        Column() {
          Text('喜欢的商品')
          this.favoriteProductsBuilder(this.user.favoriteProducts)
        }
      }
      
      // 用户作品列表（通过插槽渲染）
      if (this.userWorksBuilder && this.user.works) {
        Column() {
          Text('作品')
          this.userWorksBuilder(this.user.works)
        }
      }
    }
  }
  
  @Builder
  buildUserInfo() {
    Row() {
      Image(this.user.avatar)
        .width(60)
        .height(60)
      Column() {
        Text(this.user.nickname)
        Text(`粉丝 ${this.user.followerCount}`)
      }
    }
  }
}

// 使用方（ProductFeature或MainEntry）负责组合
// main/pages/UserPage.ts
import { UserProfileCard } from 'feature-user/components/UserProfileCard'
import { ProductCard } from 'feature-product/components/ProductCard'
import { WorkCard } from 'feature-work/components/WorkCard'

@Component
struct UserPage {
  @State user: User = new User()
  
  build() {
    UserProfileCard({
      user: this.user,
      
      favoriteProductsBuilder: (products) => {
        ForEach(products, (product) => {
          ProductCard({ product: product })
        })
      },
      
      userWorksBuilder: (works) => {
        ForEach(works, (work) => {
          WorkCard({ work: work })
        })
      }
    })
  }
}
```

#### 方案二：数据驱动渲染

**核心思想**：ViewModel返回渲染数据，不直接依赖其他Feature的组件

```typescript
// ✅ 解决方案：UserViewModel返回可序列化的渲染数据
// feature-user/viewmodels/UserViewModel.ts
export interface UserCardRenderData {
  avatar: string
  nickname: string
  followerCount: number
  // 使用基础类型，不引用ProductFeature的Product类型
  favoriteProductIds: string[]
  favoriteProductTitles: string[]
  favoriteProductImages: string[]
}

export class UserViewModel {
  @State user: User = new User()
  @State renderData: UserCardRenderData | null = null
  
  async loadUser(userId: string): Promise<void> {
    this.user = await UserService.getUser(userId)
    
    // 构造渲染数据（使用基础类型）
    this.renderData = {
      avatar: this.user.avatar,
      nickname: this.user.nickname,
      followerCount: this.user.followerCount,
      favoriteProductIds: this.user.favoriteProducts.map(p => p.id),
      favoriteProductTitles: this.user.favoriteProducts.map(p => p.title),
      favoriteProductImages: this.user.favoriteProducts.map(p => p.image)
    }
  }
}

// feature-user/components/UserCard.ts
// 只依赖基础类型和Common组件
@Component
export struct UserCard {
  @ObjectLink renderData: UserCardRenderData
  
  build() {
    Column() {
      Image(this.renderData.avatar)
      Text(this.renderData.nickname)
      
      // 商品预览（图片+标题，不包含ProductCard组件）
      ForEach(this.renderData.favoriteProductIds, (id, index) => {
        Row() {
          Image(this.renderData.favoriteProductImages[index])
            .width(30)
            .height(30)
          Text(this.renderData.favoriteProductTitles[index])
        }
      })
    }
  }
}
```

### 5.2 接口交叉依赖解决方案

#### 方案三：共享接口层（Interface Module）

**核心思想**：创建独立的接口定义模块

```typescript
// interfaces/ (独立的接口定义模块)
// 注意：这是独立模块，不是Common层的一部分

// interfaces/user/IUserInfoService.ts
export interface IUserInfoService {
  getUserInfo(userId: string): Promise<UserInfo>
  updateProfile(profile: UserProfile): Promise<void>
}

// interfaces/product/IProductService.ts
export interface IProductService {
  getProduct(productId: string): Promise<Product>
  searchProducts(keyword: string): Promise<Product[]>
}

// interfaces/order/IOrderService.ts
export interface IOrderService {
  createOrder(orderInfo: OrderInfo): Promise<Order>
  getOrders(userId: string): Promise<Order[]>
}
```

#### 方案四：事件总线解耦

**核心思想**：通过事件进行Feature间通信

```typescript
// common-core/event/EventBus.ts
type EventHandler = (data: any) => void

export class EventBus {
  private static instance: EventBus
  private handlers: Map<string, EventHandler[]> = new Map()
  
  static getInstance(): EventBus {
    if (!EventBus.instance) {
      EventBus.instance = new EventBus()
    }
    return EventBus.instance
  }
  
  // 订阅事件
  on(event: string, handler: EventHandler): void {
    if (!this.handlers.has(event)) {
      this.handlers.set(event, [])
    }
    this.handlers.get(event)!.push(handler)
  }
  
  // 取消订阅
  off(event: string, handler: EventHandler): void {
    const handlers = this.handlers.get(event)
    if (handlers) {
      const index = handlers.indexOf(handler)
      if (index > -1) {
        handlers.splice(index, 1)
      }
    }
  }
  
  // 触发事件
  emit(event: string, data: any): void {
    const handlers = this.handlers.get(event)
    if (handlers) {
      handlers.forEach(handler => handler(data))
    }
  }
}

// Feature间事件定义
export const FeatureEvents = {
  // 订单相关事件
  ORDER_CREATED: 'order:created',
  ORDER_PAID: 'order:paid',
  ORDER_CANCELLED: 'order:cancelled',
  
  // 用户相关事件
  USER_LOGIN: 'user:login',
  USER_LOGOUT: 'user:logout',
  USER_PROFILE_UPDATED: 'user:profile_updated',
  
  // 购物车相关事件
  CART_UPDATED: 'cart:updated',
  CART_ITEM_ADDED: 'cart:item_added',
  CART_ITEM_REMOVED: 'cart:item_removed'
}

// 使用示例
// feature-cart/services/CartService.ts
export class CartService {
  async addToCart(productId: string, quantity: number): Promise<void> {
    // 添加商品到购物车
    await this.repository.add(productId, quantity)
    
    // 发布事件
    EventBus.getInstance().emit(FeatureEvents.CART_ITEM_ADDED, {
      productId,
      quantity
    })
  }
}

// feature-order/services/OrderService.ts
export class OrderService {
  constructor() {
    // 订阅购物车更新事件
    EventBus.getInstance().on(FeatureEvents.CART_ITEM_ADDED, this.onCartUpdated.bind(this))
  }
  
  private onCartUpdated(data: { productId: string, quantity: number }): void {
    // 购物车更新时的业务逻辑
    console.info(`商品 ${data.productId} 已添加到购物车`)
  }
  
  async createOrder(): Promise<Order> {
    // 创建订单逻辑...
    
    // 发布订单创建事件
    EventBus.getInstance().emit(FeatureEvents.ORDER_CREATED, {
      orderId: order.id,
      userId: order.userId
    })
  }
}

// feature-user/services/UserService.ts
export class UserService {
  constructor() {
    // 订阅订单创建事件
    EventBus.getInstance().on(FeatureEvents.ORDER_CREATED, this.onOrderCreated.bind(this))
  }
  
  private onOrderCreated(data: { orderId: string, userId: string }): void {
    // 更新用户订单统计
    await this.updateUserOrderStats(data.userId)
  }
}
```

#### 方案五：服务代理模式

**核心思想**：通过Product层统一编排服务依赖

```typescript
// product/main/services/ServiceOrchestrator.ts
// Product层负责协调各Feature服务

export class ServiceOrchestrator {
  private static instance: ServiceOrchestrator
  
  private userService: UserService
  private productService: ProductService
  private orderService: OrderService
  private cartService: CartService
  
  static getInstance(): ServiceOrchestrator {
    if (!ServiceOrchestrator.instance) {
      ServiceOrchestrator.instance = new ServiceOrchestrator()
    }
    return ServiceOrchestrator.instance
  }
  
  // 创建订单（Product层协调多个Feature服务）
  async createOrder(userId: string, cartItems: CartItem[]): Promise<Order> {
    // 1. 获取用户信息
    const user = await this.userService.getUser(userId)
    
    // 2. 获取商品信息
    const productIds = cartItems.map(item => item.productId)
    const products = await this.productService.getProducts(productIds)
    
    // 3. 验证库存
    await this.validateInventory(products, cartItems)
    
    // 4. 计算价格
    const totalAmount = this.calculateTotal(products, cartItems)
    
    // 5. 创建订单
    const order = await this.orderService.createOrder({
      userId,
      products: cartItems,
      totalAmount,
      shippingAddress: user.defaultAddress
    })
    
    // 6. 清空购物车
    await this.cartService.clearCart(userId)
    
    return order
  }
}
```

### 5.3 类型交叉依赖解决方案

#### 方案六：共享类型定义（Shared Types）

**核心思想**：创建独立的类型定义包

```
项目结构：
├── shared/                  // 共享类型定义
│   ├── types/              // 基础类型
│   │   ├── response.ts     // 通用响应结构
│   │   ├── page.ts         // 分页类型
│   │   └── common.ts       // 通用类型
│   │
│   ├── user/               // 用户相关类型
│   │   └── user.ts
│   │
│   ├── product/            // 商品相关类型
│   │   └── product.ts
│   │
│   └── order/              // 订单相关类型
│       └── order.ts
│
├── feature-user/
│   └── models/             // 业务模型（引用shared类型）
│
├── feature-product/
│   └── models/             // 业务模型（引用shared类型）
```

```typescript
// shared/types/response.ts
export interface ApiResponse<T> {
  code: number
  data: T
  message: string
  success: boolean
}

export interface PageRequest {
  page: number
  pageSize: number
}

export interface PageResult<T> {
  list: T[]
  total: number
  page: number
  pageSize: number
  hasMore: boolean
}

// shared/user/user.ts
export interface UserBasicInfo {
  id: string
  nickname: string
  avatar: string
}

export interface UserProfile extends UserBasicInfo {
  phone: string
  email: string
  gender: number
  birthday: string
  bio: string
}

// shared/product/product.ts
export interface ProductBasicInfo {
  id: string
  title: string
  price: number
  image: string
}

export interface ProductDetail extends ProductBasicInfo {
  description: string
  category: string
  stock: number
  images: string[]
}

// feature-user/models/User.ts
import { UserBasicInfo, UserProfile } from 'shared/user/user'

// 业务模型继承共享类型
export class User implements UserProfile {
  id: string
  nickname: string
  avatar: string
  phone: string
  email: string
  gender: number
  birthday: string
  bio: string
  
  // 业务特有属性
  followerCount: number
  followingCount: number
  favoriteProductIds: string[]
  
  constructor(data: UserProfile) {
    // 初始化共享属性
    this.id = data.id
    this.nickname = data.nickname
    // ...
  }
}
```

---

## 6. 性能优化方案

### 6.1 Common层启动性能优化

#### 问题分析

```
应用启动时间 = Common层加载时间 + Feature初始化时间 + 首屏渲染时间

问题：
1. Common层过大 → 加载时间长
2. Feature全部同步初始化 → 启动阻塞
3. 首屏不需要的模块也加载了 → 资源浪费
```

#### 解决方案一：Common层按需加载

```typescript
// common-core/loader/ModuleLoader.ts
type ModuleLoader = () => Promise<any>

export class ModuleLoader {
  private static cache: Map<string, any> = new Map()
  
  static async load<T>(modulePath: string, loader: ModuleLoader): Promise<T> {
    // 检查缓存
    if (this.cache.has(modulePath)) {
      return this.cache.get(modulePath)
    }
    
    // 动态加载
    const module = await loader()
    this.cache.set(modulePath, module)
    
    return module as T
  }
}

// 使用示例
export class CommonStorage {
  static async getDatabase(): Promise<Database> {
    return ModuleLoader.load('common-storage/database', async () => {
      return import('common-storage/database')
    })
  }
}
```

#### 解决方案二：Common层代码分割

```typescript
// common/ index.ts 懒加载导出
// 注意：不在主bundle中加载

// common-ui/components/index.ts
export const Button = 'common-ui/components/Button'
export const Input = 'common-ui/components/Input'
export const Card = 'common-ui/components/Card'

// 使用时动态导入
async function loadButton(): Promise<typeof Button> {
  return import('common-ui/components/Button')
}

// 而不是
// import { Button } from 'common-ui/components'  // 这会全部导入
```

#### 解决方案三：Feature延迟初始化

```typescript
// common-core/feature/LazyFeatureLoader.ts
export class LazyFeatureLoader {
  private static pendingFeatures: Set<string> = new Set()
  
  // 预加载（空闲时）
  static async preload(features: string[]): Promise<void> {
    const loadPromises = features.map(name => this.load(name))
    await Promise.all(loadPromises)
  }
  
  // 按需加载
  static async load(featureName: string): Promise<void> {
    if (this.pendingFeatures.has(featureName)) {
      return
    }
    
    this.pendingFeatures.add(featureName)
    
    // 动态import
    switch (featureName) {
      case 'user':
        await import('feature-user/entry/FeatureUser')
        break
      case 'product':
        await import('feature-product/entry/FeatureProduct')
        break
      case 'order':
        await import('feature-order/entry/FeatureOrder')
        break
    }
  }
}

// 使用示例：首屏不需要的Feature延迟加载
@Entry
@Component
struct MainPage {
  aboutToAppear() {
    // 首屏只需要UserFeature
    // Product、Order延迟加载
    setTimeout(() => {
      LazyFeatureLoader.load('product')
      LazyFeatureLoader.load('order')
    }, 3000)
  }
}
```

### 6.2 Feature间依赖优化

#### 依赖分析工具

```typescript
// scripts/analyze-dependencies.ts
interface DependencyGraph {
  [moduleName: string]: {
    dependencies: string[]
    dependents: string[]
    size: number
  }
}

function buildDependencyGraph(): DependencyGraph {
  const graph: DependencyGraph = {}
  
  // 扫描所有Feature
  const features = ['feature-user', 'feature-product', 'feature-order', 'feature-cart']
  
  features.forEach(feature => {
    const deps = extractImports(feature)
    graph[feature] = {
      dependencies: deps,
      dependents: [],
      size: calculateModuleSize(feature)
    }
  })
  
  // 计算反向依赖
  Object.entries(graph).forEach(([module, info]) => {
    info.dependencies.forEach(dep => {
      if (graph[dep]) {
        graph[dep].dependents.push(module)
      }
    })
  })
  
  return graph
}

function findCircularDependencies(graph: DependencyGraph): string[][] {
  const cycles: string[][] = []
  
  Object.keys(graph).forEach(module => {
    const visited = new Set<string>()
    const path: string[] = []
    
    function dfs(current: string): boolean {
      if (path.includes(current)) {
        const cycleStart = path.indexOf(current)
        cycles.push([...path.slice(cycleStart), current])
        return true
      }
      
      if (visited.has(current)) {
        return false
      }
      
      visited.add(current)
      path.push(current)
      
      const deps = graph[current]?.dependencies || []
      for (const dep of deps) {
        if (dep in graph) {
          dfs(dep)
        }
      }
      
      path.pop()
      return false
    }
    
    dfs(module)
  })
  
  return cycles
}

function findCrossDependencies(graph: DependencyGraph): { module: string, dependencies: string[] }[] {
  return Object.entries(graph)
    .filter(([module, info]) => {
      // 筛选出依赖其他Feature的模块
      return info.dependencies.some(dep => dep.startsWith('feature-'))
    })
    .map(([module, info]) => ({
      module,
      dependencies: info.dependencies.filter(dep => dep.startsWith('feature-'))
    }))
}
```

### 6.3 包体积优化

#### 分层打包策略

```json5
// module.json5
{
  "module": {
    "name": "entry",
    "type": "entry",
    "dependencies": [
      "common-core",
      "feature-user"
    ]
  },
  "buildOption": {
    "strictMode": {
      "useNormalizedBrowserBundle": true
    }
  }
}

// feature-user/ module.json5
{
  "module": {
    "name": "feature-user",
    "type": "feature",
    "dependencies": [
      "common-core",
      "common-ui"
    ]
  }
}
```

---

## 7. 实践案例与代码示例

### 7.1 完整项目结构示例

```
myapp/
├── common/                      # Common层
│   ├── common-core/             # 核心基础
│   │   ├── src/
│   │   │   ├── types/          # 基础类型
│   │   │   ├── utils/         # 工具函数
│   │   │   ├── constants/      # 常量
│   │   │   └── extensions/    # 扩展方法
│   │   └── index.ts
│   │
│   ├── common-ui/              # 通用UI
│   │   ├── src/
│   │   │   ├── components/    # 通用组件
│   │   │   └── styles/        # 通用样式
│   │   └── index.ts
│   │
│   ├── common-network/        # 网络能力
│   │   ├── src/
│   │   │   ├── client.ts
│   │   │   ├── interceptor.ts
│   │   │   └── error.ts
│   │   └── index.ts
│   │
│   └── common-platform/        # 平台能力
│       ├── src/
│       │   ├── device.ts
│       │   ├── permission.ts
│       │   └── ability.ts
│       └── index.ts
│
├── features/                    # Feature层
│   ├── feature-user/
│   │   ├── src/
│   │   │   ├── entry/         # Feature入口
│   │   │   ├── pages/        # 页面
│   │   │   ├── components/   # 业务组件
│   │   │   ├── viewmodels/   # 视图模型
│   │   │   ├── services/    # 业务服务
│   │   │   ├── repository/   # 数据仓库
│   │   │   ├── models/       # 业务模型
│   │   │   └── interfaces/   # 对外接口
│   │   ├── oh-package.json5
│   │   └── index.ts
│   │
│   ├── feature-product/
│   │   └── ...
│   │
│   ├── feature-order/
│   │   └── ...
│   │
│   └── feature-cart/
│       └── ...
│
├── product/                      # Product层
│   ├── main/                    # 主产品
│   │   ├── App.ets
│   │   ├── pages/
│   │   ├── router/
│   │   └── services/           # 编排服务
│   │
│   ├── lite/                    # 轻量版
│   │   └── ...
│   │
│   └── tablet/                  # 平板版
│       └── ...
│
└── shared/                       # 共享类型
    ├── types/
    ├── user/
    ├── product/
    └── order/
```

### 7.2 Feature间服务调用示例

#### 场景：订单模块需要获取用户信息

**反例（错误做法）**：

```typescript
// ❌ feature-order/services/OrderService.ts
import { UserService } from 'feature-user/services/UserService'

export class OrderService {
  async createOrder(userId: string): Promise<Order> {
    // 直接依赖UserService
    const user = await UserService.getInstance().getUser(userId)  // 强耦合
    
    // 创建订单...
  }
}
```

**正例（正确做法）**：

```typescript
// ✅ feature-user/interfaces/index.ts
export interface IUserService {
  getUser(userId: string): Promise<User>
  getUserAddress(userId: string): Promise<Address>
}

// ✅ feature-user/entry/FeatureUser.ts
export class FeatureUser implements IFeatureEntry {
  private userService: UserService
  
  getUserService(): IUserService {
    return this.userService
  }
}

// ✅ product/main/services/OrderService.ts
// Product层负责注入依赖
export class ProductOrderService {
  async createOrder(userId: string): Promise<Order> {
    // 通过接口获取用户信息
    const userService = FeatureRegistry.getFeature<IUserService>('user')
    const user = await userService.getUser(userId)
    
    // 创建订单...
  }
}

// ✅ 或者使用事件解耦
// feature-order/services/OrderService.ts
export class OrderService {
  async createOrder(orderData: OrderData): Promise<Order> {
    // 通过事件获取用户ID，不直接调用UserService
    const userId = orderData.userId
    // 创建订单...
  }
  
  onOrderCreated(order: Order): void {
    // 发布事件
    EventBus.emit(FeatureEvents.ORDER_CREATED, { orderId: order.id })
  }
}

// feature-user/services/UserService.ts
export class UserService {
  constructor() {
    // 订阅订单创建事件
    EventBus.on(FeatureEvents.ORDER_CREATED, this.onOrderCreated)
  }
  
  private onOrderCreated(data: { orderId: string }): void {
    // 更新用户订单统计
  }
}
```

---

## 8. 演进路径与最佳实践

### 8.1 架构演进阶段

| 阶段 | 架构形态 | 特点 | 适用场景 |
|-----|---------|------|---------|
| **阶段一** | 单体应用 | 所有代码在一个模块 | MVP、快速验证 |
| **阶段二** | Common + Features | 分离公共代码和业务模块 | 业务增长、团队扩大 |
| **阶段三** | Feature独立编译 | 按需编译、按需加载 | 大型应用、性能敏感 |
| **阶段四** | 动态Feature | 运行时下载Feature | 超级App、插件化 |

### 8.2 Common层治理最佳实践

**实践1：Common层准入审核**

```typescript
// PR审核清单 - 添加到Common的条件
✅ 是否有2个以上的Feature需要使用？
✅ 是否不包含任何业务逻辑？
✅ 是否不依赖任何Feature模块？
✅ 是否经过性能测试（Bundle大小 < 100KB）？
✅ 是否有完整的单元测试？
```

**实践2：Common层定期清理**

```typescript
// 每季度Common层审查
// 1. 识别不再使用的模块
// 2. 识别应该属于Feature的模块
// 3. 识别过大的模块进行拆分
// 4. 更新文档和依赖关系图
```

**实践3：Common层性能监控**

```typescript
// 性能监控
export class CommonMetrics {
  static recordLoadTime(module: string, duration: number): void {
    // 上报到监控平台
    Analytics.track('common_load_time', {
      module,
      duration,
      timestamp: Date.now()
    })
  }
  
  static getBloatScore(): number {
    // 计算膨胀指数
    // 总大小 / 理想大小
  }
}
```

### 8.3 Feature层解耦最佳实践

**实践1：Feature边界定义文档**

```markdown
# Feature边界定义文档

## feature-user
- **职责**：用户账户管理、个人信息
- **对外接口**：IUserService
- **依赖**：common-*
- **被依赖**：feature-order, feature-cart, feature-product

## feature-product
- **职责**：商品信息、搜索、推荐
- **对外接口**：IProductService
- **依赖**：common-*
- **被依赖**：feature-cart, feature-order
```

**实践2：接口版本管理**

```typescript
// interfaces/user/v1/IUserService.ts
export interface IUserServiceV1 {
  getUser(userId: string): Promise<User>
}

// interfaces/user/v2/IUserService.ts
export interface IUserServiceV2 extends IUserServiceV1 {
  getUserWithStatistics(userId: string): Promise<UserWithStats>
}

// Feature可以声明它需要的接口版本
FeatureRegistry.register({
  name: 'order',
  requiredInterfaces: {
    'user': 'v1'
  }
})
```

**实践3：循环依赖检测**

```typescript
// 在CI中集成循环依赖检测
// package.json
{
  "scripts": {
    "check-circular": "ts-node scripts/check-circular-deps.ts",
    "check-dependencies": "npm run check-circular && npm run analyze-deps"
  }
}
```

### 8.4 总结

**解决Common层膨胀问题**：

1. **分层设计**：将Common拆分为common-core、common-ui等子模块
2. **严格准入**：建立Common层代码审核机制
3. **按需加载**：Common模块支持懒加载
4. **定期清理**：定期审查和清理Common层
5. **监控预警**：建立Common层大小监控

**解决Feature间交叉依赖问题**：

1. **接口抽象**：通过接口定义解耦依赖
2. **事件总线**：通过事件实现异步通信
3. **服务编排**：Product层统一编排服务依赖
4. **组合插槽**：View组件通过插槽接收子组件
5. **共享类型**：独立的类型定义包

**核心原则**：

- **Common层保持纯净**：只包含基础能力，不含业务逻辑
- **Feature保持内聚**：每个Feature职责单一，对外通过接口暴露能力
- **Product层负责编排**：在Product层协调Feature间的依赖关系
- **渐进式演进**：根据业务规模选择合适的架构阶段

通过以上策略，可以在保持代码复用性的同时，有效控制Common层膨胀和Feature间耦合度，实现应用的高性能和高可维护性。

---

**附录：相关工具与资源**

- 依赖分析工具：[dependency-cruiser](https://github.com/sverweij/dependency-cruiser)
- 包大小分析：[source-map-explorer](https://github.com/danvk/source-map-explorer)
- 鸿蒙官方模块化指南
