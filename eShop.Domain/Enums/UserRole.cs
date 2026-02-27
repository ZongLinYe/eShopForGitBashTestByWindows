namespace eShop.Domain.Enums
{
    /// <summary>
    /// 系統會員角色列舉。
    /// </summary>
    public enum UserRole
    {
        /// <summary>一般會員，可瀏覽商品、下訂單、管理個人資料。</summary>
        Member,

        /// <summary>VIP 會員，享有 VIP 專屬折扣與功能。</summary>
        VipMember,

        /// <summary>一般管理員，可管理商品、訂單、一般會員資料。</summary>
        Admin,

        /// <summary>最高管理員，擁有所有功能，另可管理管理員帳號與系統設定。</summary>
        SuperAdmin
    }
}
