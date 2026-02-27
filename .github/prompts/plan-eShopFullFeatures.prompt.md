# eShop 電子商務完整功能實作計畫

## 前置準備（安裝額外 NuGet 套件）

需在建置前透過 NuGet Package Manager Console 安裝：
- `Otp.NET`（最新版）→ 安裝至 `eShop.Services` 專案（TOTP 驗證）
- `QRCoder`（最新版）→ 安裝至 `eShopWeb` 專案（TOTP 綁定 QR Code 產生）

密碼雜湊使用 .NET 內建 `Rfc2898DeriveBytes`（PBKDF2），無需額外套件。

---

## Commit 1 — `feat: 建立基礎架構`

建立全專案共用的核心結構：

1. **eShop.Domain/Enums/UserRole.cs**：`Member, VipMember, Admin, SuperAdmin`
2. **eShop.Domain/Enums/OrderStatus.cs**：`Pending, Confirmed, Shipped, Delivered, Cancelled`
3. **eShop.Domain/Enums/TwoFactorMethod.cs**：`Email, Totp`
4. **eShop.Services/Common/ServiceResult.cs**：含 `bool IsSuccess`、`string Message`、泛型 `ServiceResult<T>` with `T Data`
5. **eShop.Utility/Logging/AppLogger.cs**：封裝 Serilog，`Init(connectionString)`、`Info()`、`Warning()`、`Error()` 靜態方法
6. **eShopWeb/App_Start/AutofacConfig.cs**：Autofac 容器設定，掃描 Services / Repositories 組件並依介面自動註冊
7. **eShopWeb/Global.asax.cs** 更新：呼叫 `AutofacConfig.Configure()`、初始化 `AppLogger.Init(connectionString)`、加入 `Application_Error` 全域錯誤攔截、`Application_PostAuthenticateRequest` 設定自訂 `GenericPrincipal`（含角色）
8. **eShopWeb/Web.config** 更新：新增 `<connectionStrings name="eShopDB" connectionString="Server=.;Database=eShopDB;Integrated Security=True;"/>`、設定 `<customErrors mode="On">`、新增 SMTP `<mailSettings>`（appSettings 預留 Key：`SmtpHost`、`SmtpPort`、`SmtpUser`、`SmtpPassword`、`EmailFrom`）

---

## Commit 2 — `chore: 新增資料庫建立腳本`

建立 `DatabaseScripts/V001_CreateEShopDB.sql`，包含：

- `CREATE DATABASE eShopDB`
- **`Users`** 表：`Id, Username, Email, PasswordHash, PasswordSalt, Role(nvarchar), IsEmailVerified(bit), TwoFactorMethod(int), TotpSecret(nvarchar NULL), CreatedAt, UpdatedAt, IsDeleted`
- **`TwoFactorTokens`** 表：`Id, UserId(FK), Token(nvarchar 6), ExpiresAt(datetime2), IsUsed(bit), CreatedAt`
- **`Categories`** 表：`Id, Name, Slug, IconUrl(nvarchar NULL), DisplayOrder(int), CreatedAt, UpdatedAt, IsDeleted`
- **`Products`** 表：`Id, Name, Description, Price(decimal 18,2), StockQuantity(int), ImageUrl, CategoryId(FK), AverageRating(decimal 3,1), ReviewCount(int), CreatedAt, UpdatedAt, IsDeleted`
- **`Banners`** 表：`Id, Title, Subtitle, ImageUrl, ButtonText, ButtonUrl, DisplayOrder, IsActive(bit), CreatedAt, UpdatedAt`
- **`Orders`** 表：`Id, UserId(FK), TotalAmount(decimal 18,2), RecipientName, RecipientEmail, RecipientPhone, ShippingAddress, Status(int), Note(nvarchar NULL), CreatedAt, UpdatedAt`
- **`OrderItems`** 表：`Id, OrderId(FK), ProductId(FK), ProductName(nvarchar), UnitPrice(decimal), Quantity(int), CreatedAt`
- 插入測試用種子資料（4 個分類、8 個商品、2 個 Banner、1 個測試管理員帳號）

---

## Commit 3 — `feat: 實作 Domain 層 Entities 與 Repository 介面`

**eShop.Domain** 層新增：

1. **Entities/**：`User.cs`、`TwoFactorToken.cs`、`Category.cs`、`Product.cs`、`Banner.cs`、`Order.cs`、`OrderItem.cs`（每個實體一個檔案，各有完整 XML 文件）
   - Entity 屬性名稱 **MUST** 與資料表欄位名稱完全一致
   - 允許加入 `virtual` 導覽屬性（例如 `Product.Category`、`Order.OrderItems`），以支援 EF6 Lazy Loading；但所有導覽屬性的載入 **MUST** 在 Repository 層以 `.Include()` 明確控制，**⚠️ 嚴禁** Repository 外部觸發 Lazy Load，防止 N+1 查詢性能問題
2. **Interfaces/Repositories/IRepository.cs**：泛型基底介面，定義 `T GetById(int id)`、`void Add(T entity)`、`void Update(T entity)` 三個通用方法
3. **Interfaces/Repositories/**：`IUserRepository.cs`、`ICategoryRepository.cs`、`IProductRepository.cs`、`IBannerRepository.cs`、`IOrderRepository.cs`，各自繼承 `IRepository<T>` 並補充專屬查詢方法（如 `GetByUsername`、`GetBySlug`、`GetActiveAll` 等）

**eShop.Repositories** 層新增：

4. **eShop.Repositories/Data/EShopDbContext.cs**：繼承 `DbContext`，宣告所有 `DbSet<T>`，`OnModelCreating` 中設定表名映射（不使用 EF6 攔截器做全域軟刪除過濾）
5. **eShop.Repositories/Repositories/**：`UserRepository.cs`、`CategoryRepository.cs`、`ProductRepository.cs`、`BannerRepository.cs`、`OrderRepository.cs`，各自實作對應介面
   - 每個查詢方法 **MUST** 明確加上 `.Where(x => !x.IsDeleted)` 軟刪除過濾
   - 需載入關聯資料時 **MUST** 使用 `.Include()` 一次性載入，禁止讓 Lazy Loading 在迴圈中觸發（N+1 問題）

> **⚠️ .csproj 注意事項**：.NET Framework 4.6.2 不自動掃描新檔案。上述每個新增的 `.cs` 檔案均須在對應 `.csproj` 的 `<ItemGroup>` 中加入 `<Compile Include="..." />` 條目，否則 msbuild 不會編譯。

---

## Commit 4 — `feat: 實作 Utility 層 Email 發送工具`

1. **eShop.Utility/Email/IEmailSender.cs**：介面，`SendAsync(to, subject, body)`
2. **eShop.Utility/Email/SmtpEmailSender.cs**：使用 `System.Net.Mail.SmtpClient` 實作，從 `Web.config` appSettings 讀取 SMTP 設定

---

## Commit 5 — `feat: 實作會員登入與二階段驗證`

**eShop.Domain** 新增 Service 介面：

1. **eShop.Domain/Interfaces/Services/IAuthService.cs**

**eShop.Services** 新增：

2. **eShop.Services/Auth/AuthService.cs**：
   - `Register()`：PBKDF2 密碼雜湊、存入 `Users` 表
   - `Login()`：驗證密碼，成功後回傳 `ServiceResult<User>`（不設 cookie，由 Controller 處理 2FA 流程）
   - `SendEmailOtp(userId)`：產生 6 位隨機數字，存 `TwoFactorTokens`，呼叫 `IEmailSender` 寄出
   - `VerifyEmailOtp(userId, token)`：驗證 token 有效性與時效（5 分鐘）
   - `GenerateTotpSecret()`：使用 `Otp.NET` 產生 secret
   - `GetTotpQrCodeUri(email, secret)`：回傳 `otpauth://totp/...` URI
   - `VerifyTotp(secret, code)`：驗證 6 位 TOTP 碼
   - `BindTotp(userId, secret)`：儲存 TOTP secret，切換 TwoFactorMethod 至 Totp
3. **eShop.Services/Auth/Validators/RegisterValidator.cs**：FluentValidation，帳號格式、密碼強度、Email 格式規則

**eShopWeb** 新增：

4. **Models/Account/**：`LoginViewModel.cs`、`RegisterViewModel.cs`、`TwoFactorEmailViewModel.cs`、`TwoFactorTotpViewModel.cs`、`BindTotpViewModel.cs`
5. **eShopWeb/Controllers/AccountController.cs**：
   - `GET/POST Login`：登入後設 Session `TwoFactorPendingUserId`，依 TwoFactorMethod 導向 Email OTP 或 TOTP 驗證
   - `GET/POST TwoFactorEmail`：顯示/驗證 Email OTP，成功後 `FormsAuthentication.SetAuthCookie`、清除暫存 Session、寫入 Role 至 Session
   - `GET/POST TwoFactorTotp`：同上但驗證 TOTP 碼
   - `GET/POST Register`
   - `GET/POST BindTotp`（需 `[Authorize]`）：顯示 QR Code URI，使用 `QRCoder` 產生 PNG base64 圖片
   - `POST Logout`：`FormsAuthentication.SignOut()` + `Session.Clear()`
6. **Views/Account/**：`Login.cshtml`、`Register.cshtml`、`TwoFactorEmail.cshtml`、`TwoFactorTotp.cshtml`、`BindTotp.cshtml`（套用 Lumina & Bloom 風格，居中卡片佈局）
7. **eShopWeb/Helpers/SessionHelper.cs**：讀取/寫入 Session 角色資訊的靜態輔助方法

---

## Commit 6 — `feat: 實作商品分類與商品列表功能`

**eShop.Domain** 新增 Service 介面：

1. `IProductService.cs`、`ICategoryService.cs`

**eShop.Services** 新增：

2. **eShop.Services/Products/ProductService.cs**：`GetBestSellers()`、`GetByCategory(categorySlug, page, pageSize)`、`GetById(id)`、`Search(keyword, page, pageSize)`
3. **eShop.Services/Categories/CategoryService.cs**：`GetAll()`、`GetBySlug(slug)`

**eShopWeb** 新增：

4. **Models/Product/**：`ProductCardViewModel.cs`、`ProductListViewModel.cs`（含分頁資訊）、`ProductDetailViewModel.cs`
5. **Models/Category/**：`CategoryViewModel.cs`
6. **eShopWeb/Controllers/ProductController.cs**：`List(categorySlug, page)`、`Detail(id)`、`Search(keyword, page)`
7. **Views/Product/**：`List.cshtml`（商品格狀列表 + 分頁）、`Detail.cshtml`（商品圖、名稱、價格、加入購物車按鈕）

---

## Commit 7 — `feat: 實作首頁（廣告輪播、分類列、暢銷商品）`

1. **eShop.Domain/Interfaces/Services/IBannerService.cs**
2. **eShop.Services/Banners/BannerService.cs**：`GetActiveOrderedBanners()`
3. **Models/Home/HomeViewModel.cs**（包含 `Banners`、`Categories`、`BestSellers` 三個集合）
4. **eShopWeb/Controllers/HomeController.cs** 重寫：注入 `IBannerService`、`ICategoryService`、`IProductService`，組裝 `HomeViewModel`
5. **eShopWeb/Views/Home/Index.cshtml** 重寫：
   - **Hero Banner 輪播**：純 CSS + VanillaJS 自動切換，全寬背景圖加文字疊加
   - **分類圖示橫列**：使用 flexbox，圓形圖示 + 分類名稱
   - **暢銷商品區塊**：4 欄格狀商品卡

---

## Commit 8 — `feat: 實作 Session 購物車`

1. **eShop.Domain/Models/CartItem.cs**：`ProductId, ProductName, Price, ImageUrl, Quantity`（Session 用，非 Entity）
2. **eShop.Domain/Interfaces/Services/ICartService.cs**
3. **eShop.Services/Cart/CartService.cs**：`GetCart(session)`、`AddItem(session, productId)`、`UpdateQuantity(session, productId, qty)`、`RemoveItem(session, productId)`、`Clear(session)`、`GetTotalAmount(session)`，使用 `System.Web.SessionState.HttpSessionState` 儲存 `List<CartItem>`
4. **Models/Cart/**：`CartViewModel.cs`、`CartSummaryViewModel.cs`（導覽列小圖示用）
5. **eShopWeb/Controllers/CartController.cs**：`GET Index`、`POST Add`（AJAX JSON）、`POST Update`（AJAX JSON）、`POST Remove`（AJAX JSON）
6. **Views/Cart/Index.cshtml**（購物車清單，含數量調整、移除按鈕，RWD 表格佈局）

---

## Commit 9 — `feat: 實作訂單結帳流程`

1. **eShop.Domain/Interfaces/Services/IOrderService.cs**
2. **eShop.Services/Orders/OrderService.cs**：`CreateOrder(userId, cartItems, checkoutDto)`、`GetOrdersByUser(userId)`、`GetOrderById(orderId)`
3. **eShop.Services/Orders/Validators/CheckoutValidator.cs**：FluentValidation 驗證收件人資料
4. **Models/Order/**：`CheckoutViewModel.cs`（收件資料表單）、`OrderConfirmViewModel.cs`（訂單完成頁）、`OrderListViewModel.cs`
5. **eShopWeb/Controllers/OrderController.cs**：
   - `GET Checkout`（需 `[Authorize]`）：顯示結帳表單（帶入已登入用戶資訊）
   - `POST Checkout`：呼叫 `IOrderService.CreateOrder()`，成功後清空購物車，導向確認頁
   - `GET Confirmation(orderId)`：顯示訂單完成訊息
   - `GET MyOrders`：個人訂單列表
6. **Views/Order/**：`Checkout.cshtml`、`Confirmation.cshtml`、`MyOrders.cshtml`

---

## Commit 10 — `feat: 套用 Lumina & Bloom 前端風格（RWD）`

### 設計語言總覽

整體視覺語言拋棄傳統電商的冰冷深藍與亮橘色調，改以**柔和玫瑰粉 × 金沙色 × 乳白色 × 奶油桃色**四色系貫穿全站，傳達「溫暖、精緻、日常美學」的品牌感受。分類圖標採用**細線條（Thin-stroke）手繪插畫風格**，以 SVG inline 嵌入，線條粗細統一為 1.5px，配合玫瑰金色填充，避免使用任何 icon-font，確保在高 DPI 螢幕上的清晰度。

### 色彩系統

| 名稱 | CSS 變數 | Hex | 用途 |
|------|----------|-----|------|
| 玫瑰粉 | `--color-primary` | `#C8957A` | CTA 按鈕、active 狀態、強調邊框 |
| 奶油桃 | `--color-accent` | `#B8956A` | hover 狀態、連結 underline、badge |
| 乳白底 | `--color-bg` | `#FAF7F4` | 全站背景色 |
| 象牙白 | `--color-surface` | `#FFFFFF` | 卡片背景、表單區塊 |
| 金沙色 | `--color-gold` | `#D4A96A` | 星星評分、價格文字、品牌 logo 字 |
| 深棕文字 | `--color-text` | `#3C3028` | 主要文字、標題 |
| 中棕輔助 | `--color-muted` | `#7D6658` | 副標題、說明文字、label |
| 淡粉邊框 | `--color-border` | `#EDE0D8` | 卡片框線、分隔線、input border |

> **禁止**在任何元件中使用純黑（`#000000`）或純白（`#FFFFFF`）作為頁面背景或主文字色，一律採用上表色系，確保視覺柔和一致。

### 字體排版

- **品牌名稱 / 大標題**：`Cormorant Garamond`（serif，Google Fonts 引入），`letter-spacing: 0.05em`，傳達精緻感
- **副標題 / 導覽列**：`Jost` 或 `Nunito Sans`（sans-serif，Google Fonts 引入），weight 300–400，全大寫 `text-transform: uppercase`
- **內文 / 商品描述**：`Jost` weight 400，`line-height: 1.7`，`color: var(--color-text)`
- **價格數字**：`Cormorant Garamond` italic，`color: var(--color-gold)`，`font-size: 1.25rem`

### 1. **eShopWeb/Content/Site.css** 完全重寫

#### 全域基礎

```css
/* 乳白底色覆蓋 Bootstrap 預設白底 */
body { background-color: var(--color-bg); color: var(--color-text); }
/* 所有陰影改為暖色調，禁止使用預設 rgba(0,0,0,...) 灰黑陰影 */
--shadow-card: 0 4px 20px rgba(200, 149, 122, 0.12);
--shadow-hover: 0 8px 32px rgba(200, 149, 122, 0.22);
```

#### 導覽列（Navbar）

- 背景色：`#FAF7F4`（乳白），底部細線：`1px solid var(--color-border)`
- 品牌文字：`Cormorant Garamond`，`font-size: 1.4rem`，`letter-spacing: 0.1em`，`color: var(--color-text)`
- 中間分類連結：`text-transform: uppercase`，`font-size: 0.75rem`，`letter-spacing: 0.12em`，`color: var(--color-muted)`；hover 時底線滑入動畫（`::after` pseudo-element，`var(--color-primary)` 色）
- 右側圖示（搜尋、帳號、購物車）：使用 SVG 細線條，尺寸 `20×20px`，`stroke: var(--color-text)`，hover 時 `stroke: var(--color-primary)`
- 購物車徽章（badge）：`background: var(--color-primary)`，`color: #FAF7F4`，圓形 `18px`，絕對定位貼附右上角

#### Hero Banner 輪播

- 容器高度：桌面 `560px`，平板 `400px`，手機 `280px`
- 背景圖以 `object-fit: cover` 填滿，疊加漸層遮罩：`linear-gradient(to right, rgba(250,247,244,0.7) 40%, transparent 80%)`，使文字在左側清晰可讀
- 標題文字：`Cormorant Garamond`，`font-size: clamp(2rem, 5vw, 3.5rem)`，`color: var(--color-text)`
- 副標題：`Jost` weight 300，`color: var(--color-muted)`
- CTA 按鈕：`background: var(--color-primary)`，`color: #FAF7F4`，`border-radius: 2px`，`letter-spacing: 0.15em`，`text-transform: uppercase`，`font-size: 0.75rem`；hover 時背景加深至 `var(--color-accent)`
- 輪播指示圓點：乳白色空心圓，active 時填充 `var(--color-primary)`
- 前後箭頭：SVG 細線條，`opacity: 0.6`，hover `opacity: 1`

#### 分類圖示橫列

- 容器背景：`#FFFFFF`，上下 `padding: 2.5rem 0`，細底線分隔
- 每個分類卡片：`display: flex; flex-direction: column; align-items: center; gap: 0.75rem`
- **圖示容器**：圓角矩形（`border-radius: 16px`），`background: #FDF3EE`（淡粉橘），`padding: 1.25rem`，`width: 90px; height: 90px`；hover 時背景色加深至 `#F5E4DA`，微上移 `transform: translateY(-3px)`，過渡 `transition: all 0.25s ease`
- **SVG 細線條圖標**（每個分類各一支獨立 SVG 檔，放置於 `Content/icons/`）：
  - Fine Jewelry（珠寶）：項鍊輪廓 + 吊墜，細線條
  - Beauty（美妝）：香水瓶或精華液滴管
  - Home Decor（家居）：蠟燭或花瓶
  - Lifestyle（生活）：皮革手提包輪廓
  - 所有 SVG：`stroke: var(--color-primary)`，`fill: none`，`stroke-width: 1.5`，`stroke-linecap: round`，`stroke-linejoin: round`
- 分類名稱文字：`text-transform: uppercase`，`font-size: 0.7rem`，`letter-spacing: 0.1em`，`color: var(--color-muted)`

#### 商品卡（Product Card）

- 背景：`#FFFFFF`，`border: 1px solid var(--color-border)`，`border-radius: 4px`
- hover 整張卡片：`box-shadow: var(--shadow-hover)`；商品圖輕微放大 `transform: scale(1.03)`，`transition: transform 0.35s ease`
- 商品圖容器：正方形，`overflow: hidden`，`background: #F9F4F1`（極淺暖灰，讓商品圖有柔和底板）
- 商品名稱：`Jost` weight 400，`font-size: 0.9rem`，`color: var(--color-text)`，兩行截斷（`-webkit-line-clamp: 2`）
- 星星評分：使用 Unicode `★` 與 CSS 控制金色（`var(--color-gold)`），空心星以 `☆` + `color: var(--color-border)` 呈現，禁止使用任何 icon-font
- 價格文字：`Cormorant Garamond` italic，`color: var(--color-gold)`，`font-size: 1.1rem`
- **ADD TO CART 按鈕**：全寬，`background: transparent`，`border: 1px solid var(--color-primary)`，`color: var(--color-primary)`，`text-transform: uppercase`，`letter-spacing: 0.12em`，`font-size: 0.7rem`；hover 時 `background: var(--color-primary); color: #FAF7F4`

#### 表單元件（登入、結帳、搜尋）

- 所有 `input`、`select`、`textarea`：`border: 1px solid var(--color-border)`，`border-radius: 4px`，`background: #FFFFFF`，focus 時 `border-color: var(--color-primary)`，`box-shadow: 0 0 0 3px rgba(200,149,122,0.15)`（柔和玫瑰光暈取代 Bootstrap 預設藍色 outline）
- 主要送出按鈕：`background: var(--color-primary)`，`color: #FAF7F4`，與 CTA 按鈕一致
- 輔助按鈕（取消、返回）：`background: transparent`，`border: 1px solid var(--color-border)`，`color: var(--color-muted)`

#### 頁尾（Footer）

- 背景：`#3C3028`（深棕），`color: #EDE0D8`（淡粉文字）
- 三欄 flex 佈局：公司資訊、連結導覽、社群媒體圖示（SVG 細線條，`stroke: #EDE0D8`）
- 分隔線：`1px solid rgba(237,224,216,0.2)`
- 品牌名稱重複出現於頁尾：`Cormorant Garamond`，`color: var(--color-gold)`

#### RWD 斷點

| 斷點 | 寬度 | 調整項目 |
|------|------|---------|
| 桌面 | ≥ 1024px | 四欄商品格 / 全寬 Banner / 完整導覽列 |
| 平板 | 768–1023px | 兩欄商品格 / Banner 高度縮減 / 漢堡選單 |
| 手機 | < 768px | 單欄商品格 / Banner 文字縮小 / 底部固定購物車 bar |

### 2. **eShopWeb/Scripts/site.js** 重寫

- `BannerCarousel`：純 VanillaJS，自動輪播（4 秒間隔）+ 前後箭頭控制 + 小圓點指示器；圖片切換採 `opacity` + `transform: translateX` 交叉淡入，禁止 `innerHTML`
- `CartBadge`：`fetch('/Cart/GetCount')` 更新導覽列購物車數量徽章，以 `textContent` 寫入數字
- `AddToCartButton`：商品頁「加入購物車」`fetch` POST + 成功時按鈕文字暫時變為 `✓ ADDED`（`textContent`），1.5 秒後復原
- `QuantityControl`：購物車頁 +/- 按鈕，每次點擊呼叫 `fetch` 更新後端 Session，再以 `textContent` 刷新頁面數量與小計
- `NavbarScroll`：頁面向下滾動超過 `80px` 時，導覽列加上 `box-shadow: var(--shadow-card)`，增添層次感

### 3. **eShopWeb/Views/Shared/_Layout.cshtml** 重寫

- Lumina & Bloom 導覽列語意結構（`<header>` → `<nav>`）
- Google Fonts 引入：在 `<head>` 加入 `Cormorant Garamond:ital,wght@0,400;0,600;1,400` 與 `Jost:wght@300;400;500`
- 移除所有 jQuery bundle 引用，改用 `<script src="~/Scripts/site.js">`
- 加入 `<meta name="viewport" content="width=device-width, initial-scale=1.0">` RWD 支援
- Bootstrap 5.2.3 的 CSS 僅保留 Grid（`bootstrap-grid.min.css`），其餘視覺樣式全部由 `Site.css` 自訂，避免 Bootstrap 預設藍色/灰色 token 污染整體色系

### 4. **eShopWeb/Views/Shared/Error.cshtml** 更新

- 404 頁面：居中顯示大字 `404`（`Cormorant Garamond`，`color: var(--color-border)`，`font-size: 8rem`），下方一句溫柔提示文字與「返回首頁」CTA 按鈕
- 500 頁面：相同佈局，改為道歉文案，不暴露技術錯誤細節

---

## Verification（每個 commit 之前執行）

```bash
cd d:\VSCodeProject\GitBashWithMsbuildTest\eShop
msbuild eShop.slnx /p:Configuration=Debug
```

建置成功（0 個錯誤）後才 `git commit`。

功能驗證順序：
1. 資料庫腳本執行後，SQL Server 中確認 `eShopDB` 建立完成
2. 首頁正常顯示輪播、分類、商品
3. 會員註冊 → Email OTP 驗證 → 登入成功
4. 綁定 TOTP → 掃描 QR Code → 下次登入以 TOTP 驗證
5. 加入商品至購物車 → 前往結帳 → 訂單成立確認頁
6. RWD：縮小瀏覽器至 768px 以下，確認版面正常折疊

---

## Decisions

- **密碼雜湊**：選用內建 PBKDF2（`Rfc2898DeriveBytes`），不額外安裝 BCrypt，降低依賴
- **CartService 設計**：Session base（`HttpSessionState`）而非資料庫 Cart，符合 MVP 原則；登入後不合併 Session Cart（後續迭代）
- **TOTP QR Code**：使用 `QRCoder` 在後端產生 PNG base64，嵌入 `<img>` tag，不呼叫外部 Google Charts API
- **FormsAuthentication**：透過 `FormsAuthentication.SetAuthCookie` + `Application_PostAuthenticateRequest` 設定 `GenericPrincipal` 含角色，與 `[Authorize(Roles="...")]` 相容
- **前端框架**：保留 Bootstrap 5.2.3 的 Grid/Layout 功能，視覺風格完全由 Site.css 自訂變數覆蓋，禁止 jQuery
