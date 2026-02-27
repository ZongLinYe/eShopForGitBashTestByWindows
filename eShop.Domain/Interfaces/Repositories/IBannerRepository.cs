using System.Collections.Generic;
using eShop.Domain.Entities;

namespace eShop.Domain.Interfaces.Repositories
{
    /// <summary>
    /// 廣告 Banner Repository 介面，繼承 <see cref="IRepository{Banner}"/> 並補充 Banner 查詢操作。
    /// </summary>
    public interface IBannerRepository : IRepository<Banner>
    {
        /// <summary>
        /// 取得所有啟用中的 Banner，依 <c>DisplayOrder</c> 升冪排序。
        /// </summary>
        /// <returns>啟用中的 Banner 清單。</returns>
        IList<Banner> GetActiveOrdered();
    }
}
