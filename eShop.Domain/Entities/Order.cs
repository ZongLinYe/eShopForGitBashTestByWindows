using System;
using System.Collections.Generic;
using eShop.Domain.Enums;

namespace eShop.Domain.Entities
{
    /// <summary>
    /// 訂單主檔 Entity，對應資料表 <c>dbo.Orders</c>。
    /// </summary>
    /// <remarks>
    /// ⚠️ 導覽屬性（<see cref="User"/>、<see cref="OrderItems"/>）支援 EF6 Lazy Loading，
    /// 禁止在 Repository 以外的程式碼直接觸發；Repository 若需關聯資料必須明確呼叫 <c>.Include()</c>。
    /// </remarks>
    public class Order
    {
        /// <summary>主鍵，自動遞增整數。</summary>
        public int Id { get; set; }

        /// <summary>外鍵對應 Users.Id，下訂單的會員。</summary>
        public int UserId { get; set; }

        /// <summary>訂單總金額（所有訂單明細的 UnitPrice × Quantity 加總），幣別為新台幣。</summary>
        public decimal TotalAmount { get; set; }

        /// <summary>收件人姓名（快照，允許與帳號姓名不同）。</summary>
        public string RecipientName { get; set; }

        /// <summary>收件人電子郵件（快照，用於寄送出貨通知）。</summary>
        public string RecipientEmail { get; set; }

        /// <summary>收件人聯絡電話（快照）。</summary>
        public string RecipientPhone { get; set; }

        /// <summary>收件地址（快照，完整地址含縣市、郵遞區號）。</summary>
        public string ShippingAddress { get; set; }

        /// <summary>訂單狀態，對應 <see cref="OrderStatus"/> 列舉。</summary>
        public OrderStatus Status { get; set; }

        /// <summary>訂單備註（可為 null），顧客下單時填寫的特殊需求。</summary>
        public string Note { get; set; }

        /// <summary>記錄建立時間（UTC）。</summary>
        public DateTime CreatedAt { get; set; }

        /// <summary>最後更新時間（UTC），訂單狀態異動時應同步修改。</summary>
        public DateTime UpdatedAt { get; set; }

        /// <summary>下訂單的使用者（EF6 Lazy Loading 導覽屬性）。</summary>
        public virtual User User { get; set; }

        /// <summary>訂單明細集合（EF6 Lazy Loading 導覽屬性）。</summary>
        public virtual ICollection<OrderItem> OrderItems { get; set; }
    }
}
