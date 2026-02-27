using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using eShop.Domain.Entities;
using eShop.Domain.Enums;
using eShop.Domain.Interfaces.Repositories;
using eShop.Repositories.Data;

namespace eShop.Repositories.Repositories
{
    /// <summary>
    /// 訂單 Repository 實作，透過 <see cref="EShopDbContext"/> 存取 <c>dbo.Orders</c> 資料表。
    /// </summary>
    public class OrderRepository : IOrderRepository
    {
        private readonly EShopDbContext _context;

        /// <summary>
        /// 初始化 <see cref="OrderRepository"/>。
        /// </summary>
        /// <param name="context">EF6 DbContext。</param>
        public OrderRepository(EShopDbContext context)
        {
            _context = context;
        }

        /// <inheritdoc/>
        public Order GetById(int id)
        {
            return _context.Orders
                .FirstOrDefault(x => x.Id == id);
        }

        /// <inheritdoc/>
        public void Add(Order entity)
        {
            _context.Orders.Add(entity);
            _context.SaveChanges();
        }

        /// <inheritdoc/>
        public void Update(Order entity)
        {
            _context.Entry(entity).State = EntityState.Modified;
            _context.SaveChanges();
        }

        /// <inheritdoc/>
        public IList<Order> GetByUserId(int userId, int page, int pageSize)
        {
            // 依建立時間降冪（最新在上），頁碼為 1-based
            return _context.Orders
                .Where(x => x.UserId == userId)
                .OrderByDescending(x => x.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToList();
        }

        /// <inheritdoc/>
        public Order GetByIdWithItems(int orderId)
        {
            // 使用 .Include() 一次性載入 OrderItems，避免 N+1 查詢
            return _context.Orders
                .Include(o => o.OrderItems)
                .FirstOrDefault(x => x.Id == orderId);
        }

        /// <inheritdoc/>
        public void UpdateStatus(int orderId, OrderStatus status)
        {
            var order = _context.Orders.FirstOrDefault(x => x.Id == orderId);
            if (order == null)
            {
                return;
            }

            order.Status = status;
            order.UpdatedAt = DateTime.UtcNow;
            _context.SaveChanges();
        }
    }
}
