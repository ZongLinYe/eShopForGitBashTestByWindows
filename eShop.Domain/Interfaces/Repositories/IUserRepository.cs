using eShop.Domain.Entities;

namespace eShop.Domain.Interfaces.Repositories
{
    /// <summary>
    /// 使用者 Repository 介面，繼承 <see cref="IRepository{User}"/> 並補充使用者查詢操作。
    /// </summary>
    public interface IUserRepository : IRepository<User>
    {
        /// <summary>
        /// 依使用者名稱取得未刪除的使用者。
        /// </summary>
        /// <param name="username">登入帳號。</param>
        /// <returns>找到的 <see cref="User"/>；若不存在則回傳 <c>null</c>。</returns>
        User GetByUsername(string username);

        /// <summary>
        /// 依電子郵件取得未刪除的使用者。
        /// </summary>
        /// <param name="email">電子郵件地址。</param>
        /// <returns>找到的 <see cref="User"/>；若不存在則回傳 <c>null</c>。</returns>
        User GetByEmail(string email);

        /// <summary>
        /// 對指定使用者執行軟刪除（設定 <c>IsDeleted = true</c>）。
        /// </summary>
        /// <param name="id">使用者主鍵 Id。</param>
        void SoftDelete(int id);
    }
}
