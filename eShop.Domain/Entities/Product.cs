using System;

namespace eShop.Domain.Entities
{
    /// <summary>
    /// 商品 Entity，對應資料表 <c>dbo.Products</c>。
    /// </summary>
    /// <remarks>
    /// ⚠️ 導覽屬性（<see cref="Category"/>）支援 EF6 Lazy Loading，
    /// 禁止在 Repository 以外的程式碼直接觸發；Repository 若需關聯資料必須明確呼叫 <c>.Include()</c>。
    /// </remarks>
    public class Product
    {
        /// <summary>主鍵，自動遞增整數。</summary>
        public int Id { get; set; }

        /// <summary>商品名稱，前台顯示用。</summary>
        public string Name { get; set; }

        /// <summary>商品詳細描述（可為 null，支援 HTML 或長文）。</summary>
        public string Description { get; set; }

        /// <summary>商品售價（需大於 0），幣別為新台幣。</summary>
        public decimal Price { get; set; }

        /// <summary>目前庫存數量（需大於等於 0），下訂單時須扣減。</summary>
        public int StockQuantity { get; set; }

        /// <summary>商品主圖的相對路徑或 URL（可為 null，未設定時顯示預設圖片）。</summary>
        public string ImageUrl { get; set; }

        /// <summary>外鍵對應 Categories.Id，商品所屬分類。</summary>
        public int CategoryId { get; set; }

        /// <summary>平均評分（0.0–5.0），由評論系統自動計算更新。</summary>
        public decimal AverageRating { get; set; }

        /// <summary>評論總數，與 AverageRating 同步更新。</summary>
        public int ReviewCount { get; set; }

        /// <summary>記錄建立時間（UTC）。</summary>
        public DateTime CreatedAt { get; set; }

        /// <summary>最後更新時間（UTC），每次 UPDATE 應同步修改。</summary>
        public DateTime UpdatedAt { get; set; }

        /// <summary>軟刪除旗標：false=正常，true=已刪除（禁止直接 DELETE 資料列）。</summary>
        public bool IsDeleted { get; set; }

        /// <summary>商品所屬分類（EF6 Lazy Loading 導覽屬性）。</summary>
        public virtual Category Category { get; set; }
    }
}
