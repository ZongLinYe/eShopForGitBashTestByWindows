using System;
using System.Collections.Generic;
using eShop.Domain.Entities;

namespace eShop.Domain.Entities
{
    /// <summary>
    /// 會員帳號 Entity，對應資料表 <c>dbo.Users</c>。
    /// </summary>
    /// <remarks>
    /// ⚠️ 導覽屬性（<see cref="Orders"/>、<see cref="TwoFactorTokens"/>）支援 EF6 Lazy Loading，
    /// 禁止在 Repository 以外的程式碼直接觸發；Repository 若需關聯資料必須明確呼叫 <c>.Include()</c>。
    /// </remarks>
    public class User
    {
        /// <summary>主鍵，自動遞增整數。</summary>
        public int Id { get; set; }

        /// <summary>登入帳號（唯一），3–50 字元，僅允許英數字與底線。</summary>
        public string Username { get; set; }

        /// <summary>電子郵件地址（唯一），格式須符合 Email 規範。</summary>
        public string Email { get; set; }

        /// <summary>密碼 PBKDF2-SHA256 雜湊值（Base64 編碼）。</summary>
        public string PasswordHash { get; set; }

        /// <summary>密碼加鹽值（Base64 編碼，128-bit 隨機產生）。</summary>
        public string PasswordSalt { get; set; }

        /// <summary>使用者角色：Member / VipMember / Admin / SuperAdmin。</summary>
        public string Role { get; set; }

        /// <summary>Email 驗證狀態：false=未驗證，true=已驗證。</summary>
        public bool IsEmailVerified { get; set; }

        /// <summary>雙因素驗證方式：0=Email OTP，1=TOTP。</summary>
        public int TwoFactorMethod { get; set; }

        /// <summary>TOTP 應用程式綁定後的密鑰（可為 null，未啟用時為 null）。</summary>
        public string TotpSecret { get; set; }

        /// <summary>記錄建立時間（UTC）。</summary>
        public DateTime CreatedAt { get; set; }

        /// <summary>最後更新時間（UTC），每次 UPDATE 應同步修改。</summary>
        public DateTime UpdatedAt { get; set; }

        /// <summary>軟刪除旗標：false=正常，true=已刪除（禁止直接 DELETE 資料列）。</summary>
        public bool IsDeleted { get; set; }

        /// <summary>該使用者的所有訂單（EF6 Lazy Loading 導覽屬性）。</summary>
        public virtual ICollection<Order> Orders { get; set; }

        /// <summary>該使用者的所有雙因素驗證碼（EF6 Lazy Loading 導覽屬性）。</summary>
        public virtual ICollection<TwoFactorToken> TwoFactorTokens { get; set; }
    }
}
