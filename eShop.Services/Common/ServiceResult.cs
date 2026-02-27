namespace eShop.Services.Common
{
    /// <summary>
    /// 服務層操作的回傳結果，封裝成功/失敗狀態與訊息。
    /// </summary>
    public class ServiceResult
    {
        /// <summary>
        /// 取得或設定操作是否成功。
        /// </summary>
        public bool IsSuccess { get; set; }

        /// <summary>
        /// 取得或設定操作結果的說明訊息。
        /// </summary>
        public string Message { get; set; }

        /// <summary>
        /// 建立成功的 <see cref="ServiceResult"/>。
        /// </summary>
        /// <param name="message">成功訊息（可選）。</param>
        /// <returns>表示成功的 <see cref="ServiceResult"/> 執行個體。</returns>
        public static ServiceResult Success(string message = null)
        {
            return new ServiceResult { IsSuccess = true, Message = message };
        }

        /// <summary>
        /// 建立失敗的 <see cref="ServiceResult"/>。
        /// </summary>
        /// <param name="message">失敗原因訊息。</param>
        /// <returns>表示失敗的 <see cref="ServiceResult"/> 執行個體。</returns>
        public static ServiceResult Failure(string message)
        {
            return new ServiceResult { IsSuccess = false, Message = message };
        }
    }
}
