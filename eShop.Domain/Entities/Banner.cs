using System;

namespace eShop.Domain.Entities
{
    /// <summary>
    /// 首頁輪播廣告 Entity，對應資料表 <c>dbo.Banners</c>。
    /// </summary>
    /// <remarks>
    /// 此資料表無 <c>IsDeleted</c> 欄位，以 <see cref="IsActive"/> 控制顯示狀態。
    /// </remarks>
    public class Banner
    {
        /// <summary>主鍵，自動遞增整數。</summary>
        public int Id { get; set; }

        /// <summary>廣告主標題，顯示於 Banner 圖片上。</summary>
        public string Title { get; set; }

        /// <summary>廣告副標題（可為 null），顯示於主標題下方。</summary>
        public string Subtitle { get; set; }

        /// <summary>廣告圖片的相對路徑或 URL。</summary>
        public string ImageUrl { get; set; }

        /// <summary>行動呼籲按鈕文字（可為 null），例如「立即選購」。</summary>
        public string ButtonText { get; set; }

        /// <summary>行動呼籲按鈕連結 URL（可為 null），點擊後跳轉目標頁面。</summary>
        public string ButtonUrl { get; set; }

        /// <summary>輪播顯示排序（數字越小越前面）。</summary>
        public int DisplayOrder { get; set; }

        /// <summary>是否啟用：false=停用（不顯示於前台），true=啟用。</summary>
        public bool IsActive { get; set; }

        /// <summary>記錄建立時間（UTC）。</summary>
        public DateTime CreatedAt { get; set; }

        /// <summary>最後更新時間（UTC），每次 UPDATE 應同步修改。</summary>
        public DateTime UpdatedAt { get; set; }
    }
}
