# Feature间View组件依赖问题深度剖析

> 场景：Feature A的二级页面需要展示Feature B的列表组件

---

## 目录

1. [问题场景定义](#1-问题场景定义)
2. [问题本质分析](#2-问题本质分析)
3. [解决方案一：组合插槽模式](#3-解决方案一组合插槽模式)
4. [解决方案二：数据驱动渲染](#4-解决方案二数据驱动渲染)
5. [解决方案三：路由导航跳转](#5-解决方案三路由导航跳转)
6. [解决方案四：共享组件库](#6-解决方案四共享组件库)
7. [方案对比与选择建议](#7-方案对比与选择建议)
8. [实践案例：完整实现](#8-实践案例完整实现)

---

## 1. 问题场景定义

### 1.1 场景描述

**Feature A**（用户模块）：包含用户详情二级页面  
**Feature B**（商品模块）：包含商品列表组件  

**业务需求**：在用户详情页面中展示该用户收藏的商品列表

### 1.2 项目结构

```
features/
├── feature-user/                    # Feature A - 用户模块
│   ├── pages/
│   │   └── UserDetailPage.ets      # 用户详情页面（二级页面）
│   ├── components/
│   │   └── UserInfoCard.ets        # 用户信息卡片
│   └── viewmodels/
│       └── UserDetailViewModel.ets # 用户详情视图模型
│
└── feature-product/                 # Feature B - 商品模块
    ├── components/
    │   └── ProductList.ets         # 商品列表组件（被依赖）
    ├── viewmodels/
    │   └── ProductListViewModel.ets
    └── services/
        └── ProductService.ets
```

### 1.3 错误做法（直接依赖）

```typescript
// ❌ 错误：feature-user直接导入feature-product的组件
// feature-user/pages/UserDetailPage.ets
import { ProductList } from 'feature-product/components/ProductList'

@Entry
@Component
struct UserDetailPage {
  @State userId: string = ''
  @State favoriteProductIds: string[] = []
  
  build() {
    Column() {
      // 用户信息
      UserInfoCard({ userId: this.userId })
      
      // ❌ 直接使用Feature B的组件 - 造成强耦合
      Text('收藏的商品')
      ProductList({
        productIds: this.favoriteProductIds,
        mode: 'horizontal'
      })
    }
  }
}

// 问题分析：
// 1. Feature A依赖Feature B的View组件 → 编译时依赖
// 2. Feature B的组件样式变更会影响Feature A
// 3. Feature B无法独立编译和发布
// 4. 可能导致循环依赖（如ProductList依赖User相关组件）
```

---

## 2. 问题本质分析

### 2.1 View组件依赖的问题根源

| 问题类型 | 具体表现 | 影响 |
|---------|---------|-----|
| **编译时依赖** | Feature A的编译必须等待Feature B编译完成 | 构建时间延长 |
| **耦合度高** | 组件样式、结构变更会影响依赖方 | 维护成本增加 |
| **可测试性差** | 单元测试需要mock整个依赖组件 | 测试复杂度高 |
| **部署限制** | 无法独立部署Feature | 发布灵活性受限 |
| **循环依赖风险** | Feature间互相依赖导致编译失败 | 架构不稳定 |

### 2.2 组件依赖vs服务依赖

```
组件依赖（View层）
├── 特点：直接引用UI组件，耦合度高
├── 影响：样式、布局、交互变更都会影响依赖方
└── 推荐：避免直接依赖

服务依赖（数据层）
├── 特点：通过接口获取数据，耦合度低
├── 影响：只有数据结构变更才会影响依赖方
└── 推荐：优先使用服务依赖
```

---

## 3. 解决方案一：组合插槽模式

### 3.1 核心思想

Feature A的页面提供插槽（Slot），由调用方（Product层或父页面）负责填充Feature B的组件。

### 3.2 实现步骤

**步骤1：Feature A定义插槽**

```typescript
// feature-user/pages/UserDetailPage.ets
@Component
struct UserDetailPage {
  @State userId: string = ''
  @State userName: string = ''
  @State avatar: string = ''
  
  // 定义插槽：收藏商品列表
  @BuilderParam favoriteProductsSlot?: () => void
  
  // 定义插槽：用户作品列表（可选）
  @BuilderParam userWorksSlot?: () => void
  
  build() {
    Column() {
      // 用户基本信息
      Row() {
        Image(this.avatar)
          .width(80)
          .height(80)
          .borderRadius(40)
        Column() {
          Text(this.userName)
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
          Text(`用户ID: ${this.userId}`)
            .fontSize(12)
            .fontColor(Color.Gray)
        }
        .layoutWeight(1)
      }
      .padding(16)
      
      // 收藏商品区域（通过插槽渲染）
      if (this.favoriteProductsSlot) {
        Column() {
          Text('收藏的商品')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .padding({ top: 16, bottom: 8 })
          this.favoriteProductsSlot()
        }
      }
      
      // 用户作品区域（通过插槽渲染）
      if (this.userWorksSlot) {
        Column() {
          Text('用户作品')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .padding({ top: 16, bottom: 8 })
          this.userWorksSlot()
        }
      }
    }
  }
}
```

**步骤2：Product层负责组合**

```typescript
// product/main/pages/MainUserDetailPage.ets
import { UserDetailPage } from 'feature-user/pages/UserDetailPage'
import { ProductList } from 'feature-product/components/ProductList'
import { WorkList } from 'feature-work/components/WorkList'

@Entry
@Component
struct MainUserDetailPage {
  @State userId: string = ''
  
  build() {
    UserDetailPage({
      userId: this.userId,
      userName: '张三',
      avatar: '/avatars/user.png',
      
      // 填充收藏商品列表插槽
      favoriteProductsSlot: () => {
        ProductList({
          productIds: ['p001', 'p002', 'p003'],
          displayMode: 'horizontal'
        })
      },
      
      // 填充用户作品列表插槽
      userWorksSlot: () => {
        WorkList({
          userId: this.userId,
          limit: 5
        })
      }
    })
  }
}
```

### 3.3 方案优势

| 优势 | 说明 |
|-----|------|
| **解耦彻底** | Feature A完全不依赖Feature B |
| **灵活组合** | 不同Product可以提供不同的子组件 |
| **可测试性好** | Feature A可以独立测试，插槽可以mock |
| **样式隔离** | 各Feature的样式互不影响 |

---

## 4. 解决方案二：数据驱动渲染

### 4.1 核心思想

Feature A的ViewModel返回纯数据（无组件依赖），Feature A的页面使用Common层的通用组件渲染。

### 4.2 实现步骤

**步骤1：定义共享数据类型**

```typescript
// shared/product/product.ts
export interface ProductPreview {
  id: string
  title: string
  price: number
  imageUrl: string
}
```

**步骤2：Feature A的ViewModel获取数据**

```typescript
// feature-user/viewmodels/UserDetailViewModel.ets
import { ProductPreview } from 'shared/product/product'

export class UserDetailViewModel {
  @State user: User = new User()
  @State favoriteProducts: ProductPreview[] = []
  
  async loadUser(userId: string): Promise<void> {
    // 获取用户信息
    this.user = await UserService.getUser(userId)
    
    // 获取用户收藏的商品预览数据（通过服务调用）
    const productService = await FeatureRegistry.getFeature('product')
    const products = await productService.getFavoriteProducts(userId)
    
    // 转换为预览数据（只包含基础信息）
    this.favoriteProducts = products.map(p => ({
      id: p.id,
      title: p.title,
      price: p.price,
      imageUrl: p.images[0]
    }))
  }
}
```

**步骤3：Feature A使用通用组件渲染**

```typescript
// feature-user/pages/UserDetailPage.ets
import { ProductPreview } from 'shared/product/product'

@Component
struct UserDetailPage {
  @State viewModel: UserDetailViewModel = new UserDetailViewModel()
  
  build() {
    Column() {
      // 用户信息
      UserInfoCard({ user: this.viewModel.user })
      
      // 收藏商品列表（使用通用列表组件）
      if (this.viewModel.favoriteProducts.length > 0) {
        Column() {
          Text('收藏的商品')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .padding({ top: 16, bottom: 8 })
          
          // 使用Common层的通用列表组件
          HorizontalList({
            items: this.viewModel.favoriteProducts,
            itemBuilder: (item: ProductPreview) => this.buildProductItem(item)
          })
        }
      }
    }
  }
  
  @Builder
  buildProductItem(product: ProductPreview) {
    Row() {
      Image(product.imageUrl)
        .width(60)
        .height(60)
        .borderRadius(8)
      Column() {
        Text(product.title)
          .fontSize(14)
          .maxLines(1)
        Text(`¥${product.price}`)
          .fontSize(12)
          .fontColor(Color.Red)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width(120)
    .padding(8)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ right: 12 })
  }
}
```

### 4.3 方案优势

| 优势 | 说明 |
|-----|------|
| **数据解耦** | 只依赖数据类型，不依赖组件 |
| **样式可控** | Feature A完全控制展示样式 |
| **性能优化** | 只传递必要数据，减少内存占用 |
| **扩展性好** | 数据格式变更只影响数据层 |

---

## 5. 解决方案三：路由导航跳转

### 5.1 核心思想

不在当前页面嵌入组件，而是通过路由跳转到Feature B的页面。

### 5.2 实现步骤

**步骤1：Feature A提供跳转入口**

```typescript
// feature-user/pages/UserDetailPage.ets
import router from '@ohos.router'

@Component
struct UserDetailPage {
  @State userId: string = ''
  @State favoriteCount: number = 0
  
  build() {
    Column() {
      // 用户信息
      UserInfoCard({ userId: this.userId })
      
      // 收藏商品入口（跳转而非嵌入）
      Row() {
        Column() {
          Text('收藏商品')
            .fontSize(16)
          Text(`${this.favoriteCount} 件`)
            .fontSize(12)
            .fontColor(Color.Gray)
        }
        .layoutWeight(1)
        
        // 跳转箭头
        Image($r('app.media.arrow_right'))
          .width(20)
          .height(20)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
      .onClick(() => {
        // 跳转到Feature B的商品列表页面
        router.pushUrl({
          url: 'pages/ProductListPage',
          params: {
            userId: this.userId,
            source: 'user_detail'
          }
        })
      })
    }
  }
}
```

**步骤2：Feature B接收参数**

```typescript
// feature-product/pages/ProductListPage.ets
import router from '@ohos.router'

@Entry
@Component
struct ProductListPage {
  @State userId: string = ''
  @State source: string = ''
  
  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, string>
    this.userId = params.userId || ''
    this.source = params.source || ''
    
    // 根据来源加载数据
    if (this.userId && this.source === 'user_detail') {
      // 加载用户收藏的商品
      this.loadUserFavoriteProducts(this.userId)
    } else {
      // 加载全部商品
      this.loadAllProducts()
    }
  }
  
  async loadUserFavoriteProducts(userId: string): Promise<void> {
    // 调用服务获取用户收藏的商品
    const products = await ProductService.getUserFavorites(userId)
    this.productList = products
  }
  
  build() {
    Column() {
      // 返回按钮（根据来源决定是否显示）
      if (this.source === 'user_detail') {
        Row() {
          Image($r('app.media.arrow_left'))
            .width(20)
            .height(20)
            .onClick(() => router.back())
          Text('返回')
        }
        .padding(12)
      }
      
      // 商品列表
      ProductListComponent({
        products: this.productList
      })
    }
  }
}
```

### 5.3 方案优势

| 优势 | 说明 |
|-----|------|
| **完全解耦** | Feature间无任何依赖 |
| **职责清晰** | 每个页面职责单一 |
| **用户体验好** | 全屏体验，操作更流畅 |
| **易于统计** | 便于追踪用户行为 |

---

## 6. 解决方案四：共享组件库

### 6.1 核心思想

将通用的列表组件提取到Common层，所有Feature都使用Common层的组件。

### 6.2 实现步骤

**步骤1：Common层定义通用列表组件**

```typescript
// common-ui/components/GenericList.ets
export interface GenericListItem {
  id: string
  title: string
  subtitle?: string
  imageUrl?: string
  icon?: string
}

@Component
export struct GenericList {
  @Prop items: GenericListItem[] = []
  @Prop layout: 'horizontal' | 'vertical' = 'vertical'
  @Prop itemWidth?: number = 120
  @Prop itemHeight?: number = 80
  
  // 自定义Item构建器（可选）
  @BuilderParam customItemBuilder?: (item: GenericListItem) => void
  
  build() {
    if (this.layout === 'horizontal') {
      Scroll() {
        Row() {
          ForEach(this.items, (item) => {
            if (this.customItemBuilder) {
              this.customItemBuilder(item)
            } else {
              this.buildDefaultItem(item)
            }
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    } else {
      List() {
        ForEach(this.items, (item) => {
          ListItem() {
            if (this.customItemBuilder) {
              this.customItemBuilder(item)
            } else {
              this.buildDefaultItem(item)
            }
          }
        })
      }
    }
  }
  
  @Builder
  buildDefaultItem(item: GenericListItem) {
    Row() {
      if (item.imageUrl) {
        Image(item.imageUrl)
          .width(this.itemWidth * 0.4)
          .height(this.itemHeight * 0.8)
          .borderRadius(8)
      }
      Column() {
        Text(item.title)
          .fontSize(14)
          .maxLines(1)
        if (item.subtitle) {
          Text(item.subtitle)
            .fontSize(12)
            .fontColor(Color.Gray)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width(this.itemWidth)
    .height(this.itemHeight)
    .padding(8)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .margin({ right: 12 })
  }
}
```

**步骤2：Feature A使用Common层组件**

```typescript
// feature-user/pages/UserDetailPage.ets
import { GenericList, GenericListItem } from 'common-ui/components/GenericList'

@Component
struct UserDetailPage {
  @State viewModel: UserDetailViewModel = new UserDetailViewModel()
  
  build() {
    Column() {
      // 用户信息
      UserInfoCard({ user: this.viewModel.user })
      
      // 收藏商品列表（使用Common层的通用列表）
      if (this.viewModel.favoriteProducts.length > 0) {
        Column() {
          Text('收藏的商品')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .padding({ top: 16, bottom: 8 })
          
          // 使用通用列表组件
          GenericList({
            items: this.viewModel.favoriteProducts.map(p => ({
              id: p.id,
              title: p.title,
              subtitle: `¥${p.price}`,
              imageUrl: p.imageUrl
            })),
            layout: 'horizontal',
            itemWidth: 140
          })
        }
      }
    }
  }
}
```

### 6.3 方案优势

| 优势 | 说明 |
|-----|------|
| **统一风格** | 所有Feature使用一致的列表样式 |
| **代码复用** | 减少重复代码 |
| **易于维护** | 样式变更只需修改一处 |
| **Feature解耦** | Feature间通过Common层间接依赖 |

---

## 7. 方案对比与选择建议

### 7.1 方案对比矩阵

| 维度 | 组合插槽 | 数据驱动渲染 | 路由跳转 | 共享组件库 |
|-----|---------|------------|---------|-----------|
| **耦合度** | 低 | 中 | 无 | 低 |
| **样式控制** | 调用方控制 | Feature控制 | 跳转页面控制 | Common控制 |
| **用户体验** | 内联展示 | 内联展示 | 新页面 | 内联展示 |
| **代码复杂度** | 中 | 中 | 低 | 低 |
| **适用场景** | 复杂嵌入场景 | 简单列表展示 | 独立功能页面 | 统一风格列表 |
| **可测试性** | 高 | 高 | 高 | 高 |

### 7.2 选择决策流程

```
是否需要在当前页面内展示？
    ├─ 是 → 是否需要自定义样式？
    │       ├─ 是 → 数据驱动渲染
    │       └─ 否 → 共享组件库
    │
    └─ 否 → 路由导航跳转
```

### 7.3 最佳实践建议

| 场景 | 推荐方案 |
|-----|---------|
| 用户详情页展示收藏商品 | 数据驱动渲染 |
| 用户主页展示多种内容卡片 | 组合插槽模式 |
| 查看完整商品列表 | 路由导航跳转 |
| 统一风格的列表展示 | 共享组件库 |

---

## 8. 实践案例：完整实现

### 8.1 场景：用户详情页展示收藏商品列表

**最终架构**：

```
Product层（组合协调）
    │
    ├── Feature A（用户模块）
    │   └── UserDetailPage（提供数据和插槽）
    │
    └── Feature B（商品模块）
        └── ProductService（提供数据）
```

**实现代码**：

```typescript
// 1. shared类型定义
export interface ProductPreview {
  id: string
  title: string
  price: number
  imageUrl: string
}

// 2. Feature B服务接口
export interface IProductService {
  getUserFavoriteProducts(userId: string): Promise<ProductPreview[]>
}

// 3. Feature A ViewModel
export class UserDetailViewModel {
  @State user: User = new User()
  @State favoriteProducts: ProductPreview[] = []
  
  async loadData(userId: string): Promise<void> {
    // 获取用户信息
    this.user = await UserService.getUser(userId)
    
    // 通过Feature Registry获取ProductService
    const productFeature = await FeatureRegistry.getFeature<IProductService>('product')
    this.favoriteProducts = await productFeature.getUserFavoriteProducts(userId)
  }
}

// 4. Feature A页面
@Component
struct UserDetailPage {
  @State viewModel: UserDetailViewModel = new UserDetailViewModel()
  
  build() {
    Column() {
      UserInfoCard({ user: this.viewModel.user })
      
      if (this.viewModel.favoriteProducts.length > 0) {
        Column() {
          Text('收藏的商品')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
          
          GenericList({
            items: this.viewModel.favoriteProducts.map(p => ({
              id: p.id,
              title: p.title,
              subtitle: `¥${p.price}`,
              imageUrl: p.imageUrl
            })),
            layout: 'horizontal'
          })
        }
      }
    }
  }
}

// 5. Product层入口
@Entry
@Component
struct MainUserDetailPage {
  @State userId: string = ''
  
  build() {
    UserDetailPage({ userId: this.userId })
  }
}
```

### 8.2 关键要点总结

1. **数据层交互**：通过Service接口获取数据，不直接依赖组件
2. **View层隔离**：Feature间不互相引用View组件
3. **Product层协调**：负责Feature的组合和路由管理
4. **类型共享**：通过shared包定义共享数据类型

---

## 总结

Feature间View组件依赖问题的核心是**避免编译时的组件引用**，通过以下方式解决：

1. **组合插槽模式**：让调用方负责组件组合
2. **数据驱动渲染**：只传递数据，不传递组件
3. **路由导航跳转**：通过页面跳转替代组件嵌入
4. **共享组件库**：通过Common层间接依赖

选择哪种方案取决于具体的业务场景和用户体验需求，但核心原则是**保持Feature间的低耦合和高内聚**。
