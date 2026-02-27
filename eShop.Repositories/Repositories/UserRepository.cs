using System;
using System.Linq;
using eShop.Domain.Entities;
using eShop.Domain.Interfaces.Repositories;
using eShop.Repositories.Data;

namespace eShop.Repositories.Repositories
{
    /// <summary>
    /// 使用者 Repository 實作，透過 <see cref="EShopDbContext"/> 存取 <c>dbo.Users</c> 資料表。
    /// </summary>
    public class UserRepository : IUserRepository
    {
        private readonly EShopDbContext _context;

        /// <summary>
        /// 初始化 <see cref="UserRepository"/>。
        /// </summary>
        /// <param name="context">EF6 DbContext。</param>
        public UserRepository(EShopDbContext context)
        {
            _context = context;
        }

        /// <inheritdoc/>
        public User GetById(int id)
        {
            return _context.Users
                .Where(x => !x.IsDeleted && x.Id == id)
                .FirstOrDefault();
        }

        /// <inheritdoc/>
        public void Add(User entity)
        {
            _context.Users.Add(entity);
            _context.SaveChanges();
        }

        /// <inheritdoc/>
        public void Update(User entity)
        {
            _context.Entry(entity).State = System.Data.Entity.EntityState.Modified;
            _context.SaveChanges();
        }

        /// <inheritdoc/>
        public User GetByUsername(string username)
        {
            return _context.Users
                .Where(x => !x.IsDeleted && x.Username == username)
                .FirstOrDefault();
        }

        /// <inheritdoc/>
        public User GetByEmail(string email)
        {
            return _context.Users
                .Where(x => !x.IsDeleted && x.Email == email)
                .FirstOrDefault();
        }

        /// <inheritdoc/>
        public void SoftDelete(int id)
        {
            // 查詢目標使用者（不含已刪除），更新軟刪除旗標
            var user = _context.Users
                .Where(x => !x.IsDeleted && x.Id == id)
                .FirstOrDefault();

            if (user == null)
            {
                return;
            }

            user.IsDeleted = true;
            user.UpdatedAt = DateTime.UtcNow;
            _context.SaveChanges();
        }
    }
}
