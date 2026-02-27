using System;
using System.Collections.Generic;
using System.Linq;
using eShop.Domain.Entities;
using eShop.Domain.Interfaces.Repositories;
using eShop.Repositories.Data;

namespace eShop.Repositories.Repositories
{
    /// <summary>
    /// 商品分類 Repository 實作，透過 <see cref="EShopDbContext"/> 存取 <c>dbo.Categories</c> 資料表。
    /// </summary>
    public class CategoryRepository : ICategoryRepository
    {
        private readonly EShopDbContext _context;

        /// <summary>
        /// 初始化 <see cref="CategoryRepository"/>。
        /// </summary>
        /// <param name="context">EF6 DbContext。</param>
        public CategoryRepository(EShopDbContext context)
        {
            _context = context;
        }

        /// <inheritdoc/>
        public Category GetById(int id)
        {
            return _context.Categories
                .Where(x => !x.IsDeleted && x.Id == id)
                .FirstOrDefault();
        }

        /// <inheritdoc/>
        public void Add(Category entity)
        {
            _context.Categories.Add(entity);
            _context.SaveChanges();
        }

        /// <inheritdoc/>
        public void Update(Category entity)
        {
            _context.Entry(entity).State = System.Data.Entity.EntityState.Modified;
            _context.SaveChanges();
        }

        /// <inheritdoc/>
        public IList<Category> GetAll()
        {
            return _context.Categories
                .Where(x => !x.IsDeleted)
                .OrderBy(x => x.DisplayOrder)
                .ToList();
        }

        /// <inheritdoc/>
        public Category GetBySlug(string slug)
        {
            return _context.Categories
                .Where(x => !x.IsDeleted && x.Slug == slug)
                .FirstOrDefault();
        }
    }
}
