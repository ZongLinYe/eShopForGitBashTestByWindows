using System.Data.Entity;
using eShop.Domain.Entities;

namespace eShop.Repositories.Data
{
    /// <summary>
    /// EShop 專案的 Entity Framework 6 DbContext，管理所有資料表的存取。
    /// </summary>
    /// <remarks>
    /// 採用 Code First on Existing DB 方式：手寫 Entity 類別與 DbContext，
    /// 不使用 EDMX 或 EF Migration。資料庫結構由 DatabaseScripts/ 腳本管理。<br/>
    /// 連線字串來自 <c>eShopWeb/Web.config</c> 的 <c>connectionStrings</c> 區段（名稱 <c>eShopDB</c>）。
    /// </remarks>
    public class EShopDbContext : DbContext
    {
        /// <summary>
        /// 初始化 <see cref="EShopDbContext"/>，使用名稱為 <c>eShopDB</c> 的連線字串。
        /// </summary>
        public EShopDbContext()
            : base("name=eShopDB")
        {
        }

        /// <summary>使用者帳號資料表。</summary>
        public DbSet<User> Users { get; set; }

        /// <summary>雙因素驗證碼資料表。</summary>
        public DbSet<TwoFactorToken> TwoFactorTokens { get; set; }

        /// <summary>商品分類資料表。</summary>
        public DbSet<Category> Categories { get; set; }

        /// <summary>商品資料表。</summary>
        public DbSet<Product> Products { get; set; }

        /// <summary>首頁輪播廣告資料表。</summary>
        public DbSet<Banner> Banners { get; set; }

        /// <summary>訂單主檔資料表。</summary>
        public DbSet<Order> Orders { get; set; }

        /// <summary>訂單明細資料表。</summary>
        public DbSet<OrderItem> OrderItems { get; set; }

        /// <summary>
        /// 設定 Entity 與資料表的對應關係。
        /// </summary>
        /// <param name="modelBuilder">EF6 Model 建構器。</param>
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // 明確設定資料表名稱映射，確保 EF6 不自動加複數或其他前綴
            modelBuilder.Entity<User>().ToTable("Users");
            modelBuilder.Entity<TwoFactorToken>().ToTable("TwoFactorTokens");
            modelBuilder.Entity<Category>().ToTable("Categories");
            modelBuilder.Entity<Product>().ToTable("Products");
            modelBuilder.Entity<Banner>().ToTable("Banners");
            modelBuilder.Entity<Order>().ToTable("Orders");
            modelBuilder.Entity<OrderItem>().ToTable("OrderItems");
        }
    }
}
