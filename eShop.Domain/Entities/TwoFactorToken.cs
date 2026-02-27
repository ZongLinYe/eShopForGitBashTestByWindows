using System;

namespace eShop.Domain.Entities
{
    /// <summary>
    /// 雙因素驗證碼 Entity，對應資料表 <c>dbo.TwoFactorTokens</c>。
    /// </summary>
    /// <remarks>
    /// ⚠️ 導覽屬性（<see cref="User"/>）支援 EF6 Lazy Loading，
    /// 禁止在 Repository 以外的程式碼直接觸發；Repository 若需關聯資料必須明確呼叫 <c>.Include()</c>。
    /// </remarks>
    public class TwoFactorToken
    {
        /// <summary>主鍵，自動遞增整數。</summary>
        public int Id { get; set; }

        /// <summary>外鍵對應 Users.Id，擁有此驗證碼的使用者。</summary>
        public int UserId { get; set; }

        /// <summary>6 位數字驗證碼（字串格式，保留前導零）。</summary>
        public string Token { get; set; }

        /// <summary>驗證碼有效期限（UTC），通常為建立時間 +5 分鐘。</summary>
        public DateTime ExpiresAt { get; set; }

        /// <summary>是否已使用：false=未使用，true=已使用（使用後立即標記，防止重放攻擊）。</summary>
        public bool IsUsed { get; set; }

        /// <summary>記錄建立時間（UTC）。</summary>
        public DateTime CreatedAt { get; set; }

        /// <summary>擁有此驗證碼的使用者（EF6 Lazy Loading 導覽屬性）。</summary>
        public virtual User User { get; set; }
    }
}
