using System.Collections.Generic;
using eShop.Domain.Entities;

namespace eShop.Domain.Interfaces.Repositories
{
    /// <summary>
    /// 商品 Repository 介面，繼承 <see cref="IRepository{Product}"/> 並補充商品查詢操作。
    /// </summary>
    public interface IProductRepository : IRepository<Product>
    {
        /// <summary>
        /// 依分類取得分頁商品清單（僅回傳未刪除商品）。
        /// </summary>
        /// <param name="categoryId">分類主鍵 Id。</param>
        /// <param name="page">頁碼（1-based）。</param>
        /// <param name="pageSize">每頁筆數。</param>
        /// <returns>符合條件的商品清單。</returns>
        IList<Product> GetByCategory(int categoryId, int page, int pageSize);

        /// <summary>
        /// 取得依平均評分降冪排列的暢銷商品（僅回傳未刪除商品）。
        /// </summary>
        /// <param name="count">取得筆數上限。</param>
        /// <returns>暢銷商品清單。</returns>
        IList<Product> GetBestSellers(int count);

        /// <summary>
        /// 依關鍵字搜尋商品名稱，回傳分頁結果（僅回傳未刪除商品）。
        /// </summary>
        /// <param name="keyword">搜尋關鍵字。</param>
        /// <param name="page">頁碼（1-based）。</param>
        /// <param name="pageSize">每頁筆數。</param>
        /// <returns>符合條件的商品清單。</returns>
        IList<Product> Search(string keyword, int page, int pageSize);

        /// <summary>
        /// 計算指定分類下未刪除的商品總數（分頁時使用）。
        /// </summary>
        /// <param name="categoryId">分類主鍵 Id。</param>
        /// <returns>商品總數。</returns>
        int CountByCategory(int categoryId);

        /// <summary>
        /// 計算符合關鍵字搜尋的未刪除商品總數（分頁時使用）。
        /// </summary>
        /// <param name="keyword">搜尋關鍵字。</param>
        /// <returns>商品總數。</returns>
        int CountByKeyword(string keyword);
    }
}
