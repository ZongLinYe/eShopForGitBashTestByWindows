namespace eShop.Domain.Enums
{
    /// <summary>
    /// 訂單狀態列舉。
    /// </summary>
    public enum OrderStatus
    {
        /// <summary>待確認，訂單已建立但尚未確認。</summary>
        Pending,

        /// <summary>已確認，訂單已由管理員確認。</summary>
        Confirmed,

        /// <summary>已出貨，商品正在運送途中。</summary>
        Shipped,

        /// <summary>已送達，商品已成功送達收件人。</summary>
        Delivered,

        /// <summary>已取消，訂單已被取消。</summary>
        Cancelled
    }
}
