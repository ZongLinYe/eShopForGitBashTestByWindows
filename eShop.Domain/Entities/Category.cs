using System;
using System.Collections.Generic;

namespace eShop.Domain.Entities
{
    /// <summary>
    /// 商品分類 Entity，對應資料表 <c>dbo.Categories</c>。
    /// </summary>
    /// <remarks>
    /// ⚠️ 導覽屬性（<see cref="Products"/>）支援 EF6 Lazy Loading，
    /// 禁止在 Repository 以外的程式碼直接觸發；Repository 若需關聯資料必須明確呼叫 <c>.Include()</c>。
    /// </remarks>
    public class Category
    {
        /// <summary>主鍵，自動遞增整數。</summary>
        public int Id { get; set; }

        /// <summary>分類顯示名稱，例如「Fine Jewelry」。</summary>
        public string Name { get; set; }

        /// <summary>URL 識別別名（唯一），英文小寫連字號格式，例如「fine-jewelry」。</summary>
        public string Slug { get; set; }

        /// <summary>分類圖示的相對路徑或 URL（可為 null，未設定時不顯示圖示）。</summary>
        public string IconUrl { get; set; }

        /// <summary>前端導覽列顯示排序（數字越小越前面）。</summary>
        public int DisplayOrder { get; set; }

        /// <summary>記錄建立時間（UTC）。</summary>
        public DateTime CreatedAt { get; set; }

        /// <summary>最後更新時間（UTC），每次 UPDATE 應同步修改。</summary>
        public DateTime UpdatedAt { get; set; }

        /// <summary>軟刪除旗標：false=正常，true=已刪除（禁止直接 DELETE 資料列）。</summary>
        public bool IsDeleted { get; set; }

        /// <summary>屬於此分類的商品集合（EF6 Lazy Loading 導覽屬性）。</summary>
        public virtual ICollection<Product> Products { get; set; }
    }
}
