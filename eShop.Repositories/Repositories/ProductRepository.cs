using System.Collections.Generic;
using System.Linq;
using eShop.Domain.Entities;
using eShop.Domain.Interfaces.Repositories;
using eShop.Repositories.Data;

namespace eShop.Repositories.Repositories
{
    /// <summary>
    /// 商品 Repository 實作，透過 <see cref="EShopDbContext"/> 存取 <c>dbo.Products</c> 資料表。
    /// </summary>
    public class ProductRepository : IProductRepository
    {
        private readonly EShopDbContext _context;

        /// <summary>
        /// 初始化 <see cref="ProductRepository"/>。
        /// </summary>
        /// <param name="context">EF6 DbContext。</param>
        public ProductRepository(EShopDbContext context)
        {
            _context = context;
        }

        /// <inheritdoc/>
        public Product GetById(int id)
        {
            return _context.Products
                .Where(x => !x.IsDeleted && x.Id == id)
                .FirstOrDefault();
        }

        /// <inheritdoc/>
        public void Add(Product entity)
        {
            _context.Products.Add(entity);
            _context.SaveChanges();
        }

        /// <inheritdoc/>
        public void Update(Product entity)
        {
            _context.Entry(entity).State = System.Data.Entity.EntityState.Modified;
            _context.SaveChanges();
        }

        /// <inheritdoc/>
        public IList<Product> GetByCategory(int categoryId, int page, int pageSize)
        {
            // 頁碼為 1-based，跳過前面頁數的資料
            return _context.Products
                .Where(x => !x.IsDeleted && x.CategoryId == categoryId)
                .OrderBy(x => x.Id)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToList();
        }

        /// <inheritdoc/>
        public IList<Product> GetBestSellers(int count)
        {
            // 依平均評分降冪，取前 count 筆未刪除商品
            return _context.Products
                .Where(x => !x.IsDeleted)
                .OrderByDescending(x => x.AverageRating)
                .Take(count)
                .ToList();
        }

        /// <inheritdoc/>
        public IList<Product> Search(string keyword, int page, int pageSize)
        {
            // 依商品名稱模糊搜尋，頁碼為 1-based
            return _context.Products
                .Where(x => !x.IsDeleted && x.Name.Contains(keyword))
                .OrderBy(x => x.Id)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToList();
        }

        /// <inheritdoc/>
        public int CountByCategory(int categoryId)
        {
            return _context.Products
                .Where(x => !x.IsDeleted && x.CategoryId == categoryId)
                .Count();
        }

        /// <inheritdoc/>
        public int CountByKeyword(string keyword)
        {
            return _context.Products
                .Where(x => !x.IsDeleted && x.Name.Contains(keyword))
                .Count();
        }
    }
}
