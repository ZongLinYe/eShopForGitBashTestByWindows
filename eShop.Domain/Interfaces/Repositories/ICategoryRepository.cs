using System.Collections.Generic;
using eShop.Domain.Entities;

namespace eShop.Domain.Interfaces.Repositories
{
    /// <summary>
    /// 商品分類 Repository 介面，繼承 <see cref="IRepository{Category}"/> 並補充分類查詢操作。
    /// </summary>
    public interface ICategoryRepository : IRepository<Category>
    {
        /// <summary>
        /// 取得所有未刪除的分類，依 <c>DisplayOrder</c> 升冪排序。
        /// </summary>
        /// <returns>分類清單。</returns>
        IList<Category> GetAll();

        /// <summary>
        /// 依 URL Slug 取得未刪除的分類。
        /// </summary>
        /// <param name="slug">分類 Slug（URL 識別別名）。</param>
        /// <returns>找到的 <see cref="Category"/>；若不存在則回傳 <c>null</c>。</returns>
        Category GetBySlug(string slug);
    }
}
