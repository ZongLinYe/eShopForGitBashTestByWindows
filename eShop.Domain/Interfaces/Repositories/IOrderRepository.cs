using System.Collections.Generic;
using eShop.Domain.Entities;
using eShop.Domain.Enums;

namespace eShop.Domain.Interfaces.Repositories
{
    /// <summary>
    /// 訂單 Repository 介面，繼承 <see cref="IRepository{Order}"/> 並補充訂單查詢操作。
    /// </summary>
    public interface IOrderRepository : IRepository<Order>
    {
        /// <summary>
        /// 依使用者取得分頁訂單清單，依建立時間降冪排列（最新在上）。
        /// </summary>
        /// <param name="userId">使用者主鍵 Id。</param>
        /// <param name="page">頁碼（1-based）。</param>
        /// <param name="pageSize">每頁筆數。</param>
        /// <returns>該使用者的訂單清單。</returns>
        IList<Order> GetByUserId(int userId, int page, int pageSize);

        /// <summary>
        /// 依訂單主鍵取得訂單，並一次性載入 <c>OrderItems</c> 明細（使用 <c>.Include()</c>）。
        /// </summary>
        /// <param name="orderId">訂單主鍵 Id。</param>
        /// <returns>含明細的 <see cref="Order"/>；若不存在則回傳 <c>null</c>。</returns>
        Order GetByIdWithItems(int orderId);

        /// <summary>
        /// 更新指定訂單的狀態。
        /// </summary>
        /// <param name="orderId">訂單主鍵 Id。</param>
        /// <param name="status">新的訂單狀態。</param>
        void UpdateStatus(int orderId, OrderStatus status);
    }
}
