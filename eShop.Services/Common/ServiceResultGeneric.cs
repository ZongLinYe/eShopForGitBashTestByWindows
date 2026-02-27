namespace eShop.Services.Common
{
    /// <summary>
    /// 服務層操作的泛型回傳結果，除成功/失敗狀態與訊息外，另包含回傳資料。
    /// </summary>
    /// <typeparam name="T">回傳資料的型別。</typeparam>
    public class ServiceResult<T> : ServiceResult
    {
        /// <summary>
        /// 取得或設定操作成功時回傳的資料。
        /// </summary>
        public T Data { get; set; }

        /// <summary>
        /// 建立含資料的成功 <see cref="ServiceResult{T}"/>。
        /// </summary>
        /// <param name="data">成功時回傳的資料。</param>
        /// <param name="message">成功訊息（可選）。</param>
        /// <returns>表示成功並含資料的 <see cref="ServiceResult{T}"/> 執行個體。</returns>
        public static ServiceResult<T> Success(T data, string message = null)
        {
            return new ServiceResult<T> { IsSuccess = true, Message = message, Data = data };
        }

        /// <summary>
        /// 建立失敗的 <see cref="ServiceResult{T}"/>。
        /// </summary>
        /// <param name="message">失敗原因訊息。</param>
        /// <returns>表示失敗的 <see cref="ServiceResult{T}"/> 執行個體。</returns>
        public new static ServiceResult<T> Failure(string message)
        {
            return new ServiceResult<T> { IsSuccess = false, Message = message };
        }
    }
}
