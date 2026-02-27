namespace eShop.Domain.Enums
{
    /// <summary>
    /// 二階段驗證方式列舉。
    /// </summary>
    public enum TwoFactorMethod
    {
        /// <summary>以 Email 接收 OTP 驗證碼進行二階段驗證。</summary>
        Email,

        /// <summary>使用 TOTP（Time-based One-Time Password）驗證器 App 進行二階段驗證。</summary>
        Totp
    }
}
