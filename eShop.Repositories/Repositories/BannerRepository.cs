using System.Collections.Generic;
using System.Linq;
using eShop.Domain.Entities;
using eShop.Domain.Interfaces.Repositories;
using eShop.Repositories.Data;

namespace eShop.Repositories.Repositories
{
    /// <summary>
    /// 廣告 Banner Repository 實作，透過 <see cref="EShopDbContext"/> 存取 <c>dbo.Banners</c> 資料表。
    /// </summary>
    /// <remarks>
    /// <c>Banners</c> 資料表無 <c>IsDeleted</c> 欄位，改由 <see cref="Banner.IsActive"/> 控制顯示狀態。
    /// </remarks>
    public class BannerRepository : IBannerRepository
    {
        private readonly EShopDbContext _context;

        /// <summary>
        /// 初始化 <see cref="BannerRepository"/>。
        /// </summary>
        /// <param name="context">EF6 DbContext。</param>
        public BannerRepository(EShopDbContext context)
        {
            _context = context;
        }

        /// <inheritdoc/>
        public Banner GetById(int id)
        {
            return _context.Banners
                .FirstOrDefault(x => x.Id == id);
        }

        /// <inheritdoc/>
        public void Add(Banner entity)
        {
            _context.Banners.Add(entity);
            _context.SaveChanges();
        }

        /// <inheritdoc/>
        public void Update(Banner entity)
        {
            _context.Entry(entity).State = System.Data.Entity.EntityState.Modified;
            _context.SaveChanges();
        }

        /// <inheritdoc/>
        public IList<Banner> GetActiveOrdered()
        {
            // 篩選啟用中的 Banner，依 DisplayOrder 升冪排序
            return _context.Banners
                .Where(x => x.IsActive)
                .OrderBy(x => x.DisplayOrder)
                .ToList();
        }
    }
}
