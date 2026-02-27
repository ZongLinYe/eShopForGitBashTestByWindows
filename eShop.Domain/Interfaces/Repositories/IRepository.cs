namespace eShop.Domain.Interfaces.Repositories
{
    /// <summary>
    /// 泛型 Repository 基底介面，定義所有 Entity 通用的 CRUD 操作契約。
    /// </summary>
    /// <typeparam name="T">Entity 型別。</typeparam>
    public interface IRepository<T> where T : class
    {
        /// <summary>
        /// 依主鍵取得 Entity。
        /// </summary>
        /// <param name="id">主鍵 Id。</param>
        /// <returns>找到的 Entity；若不存在或已軟刪除則回傳 <c>null</c>。</returns>
        T GetById(int id);

        /// <summary>
        /// 新增 Entity 至資料庫。
        /// </summary>
        /// <param name="entity">要新增的 Entity 物件。</param>
        void Add(T entity);

        /// <summary>
        /// 更新已存在的 Entity。
        /// </summary>
        /// <param name="entity">含更新後資料的 Entity 物件。</param>
        void Update(T entity);
    }
}
