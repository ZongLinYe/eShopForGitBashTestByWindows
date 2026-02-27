using System;

namespace eShop.Domain.Entities
{
    /// <summary>
    /// 訂單明細 Entity，對應資料表 <c>dbo.OrderItems</c>。
    /// </summary>
    /// <remarks>
    /// <see cref="ProductId"/> 允許 null：商品被軟刪除後設為 null，但 <see cref="ProductName"/> 與
    /// <see cref="UnitPrice"/> 快照仍保留，確保歷史訂單資料完整。<br/>
    /// ⚠️ 導覽屬性（<see cref="Order"/>、<see cref="Product"/>）支援 EF6 Lazy Loading，
    /// 禁止在 Repository 以外的程式碼直接觸發。
    /// </remarks>
    public class OrderItem
    {
        /// <summary>主鍵，自動遞增整數。</summary>
        public int Id { get; set; }

        /// <summary>外鍵對應 Orders.Id，此明細所屬的訂單。</summary>
        public int OrderId { get; set; }

        /// <summary>外鍵對應 Products.Id（允許 null）：商品被刪除後設為 null，但快照欄位仍保留。</summary>
        public int? ProductId { get; set; }

        /// <summary>下單當下商品名稱快照，即使商品改名後歷史訂單仍顯示原名。</summary>
        public string ProductName { get; set; }

        /// <summary>下單當下商品單價快照（需大於等於 0），即使售價調整後歷史訂單仍顯示原價。</summary>
        public decimal UnitPrice { get; set; }

        /// <summary>購買數量（需大於等於 1）。</summary>
        public int Quantity { get; set; }

        /// <summary>記錄建立時間（UTC）。</summary>
        public DateTime CreatedAt { get; set; }

        /// <summary>此明細所屬的訂單（EF6 Lazy Loading 導覽屬性）。</summary>
        public virtual Order Order { get; set; }

        /// <summary>對應的商品（EF6 Lazy Loading 導覽屬性，商品刪除後可為 null）。</summary>
        public virtual Product Product { get; set; }
    }
}
