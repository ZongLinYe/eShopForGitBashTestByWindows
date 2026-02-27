using System;
using Serilog;
using Serilog.Sinks.MSSqlServer;

namespace eShop.Utility.Logging
{
    /// <summary>
    /// 封裝 Serilog 的靜態應用程式記錄器，提供全域統一的日誌寫入介面。
    /// </summary>
    public static class AppLogger
    {
        // 標記是否已初始化，防止重複初始化
        private static bool _isInitialized = false;

        /// <summary>
        /// 初始化 Serilog Logger，同時設定檔案 Sink 與 SQL Server Sink。
        /// 應於應用程式啟動時呼叫一次（例如 Global.asax Application_Start）。
        /// </summary>
        /// <param name="connectionString">SQL Server 連線字串，用於寫入日誌至 Logs 資料表。</param>
        public static void Init(string connectionString)
        {
            if (_isInitialized)
            {
                return;
            }

            var columnOptions = new ColumnOptions();
            // 移除預設的 Properties 欄位，減少不必要的儲存
            columnOptions.Store.Remove(StandardColumn.Properties);
            columnOptions.Store.Add(StandardColumn.LogEvent);

            Log.Logger = new LoggerConfiguration()
                .MinimumLevel.Information()
                .WriteTo.File(
                    path: "Logs/eshop-.log",
                    rollingInterval: RollingInterval.Day,
                    outputTemplate: "{Timestamp:yyyy-MM-dd HH:mm:ss} [{Level:u3}] {Message:lj}{NewLine}{Exception}")
                .WriteTo.MSSqlServer(
                    connectionString: connectionString,
                    sinkOptions: new MSSqlServerSinkOptions
                    {
                        TableName = "Logs",
                        AutoCreateSqlTable = true
                    },
                    columnOptions: columnOptions)
                .CreateLogger();

            _isInitialized = true;
        }

        /// <summary>
        /// 寫入 Information 等級的日誌訊息。
        /// </summary>
        /// <param name="message">日誌訊息範本。</param>
        /// <param name="propertyValues">訊息範本的參數值（可選）。</param>
        public static void Info(string message, params object[] propertyValues)
        {
            Log.Information(message, propertyValues);
        }

        /// <summary>
        /// 寫入 Warning 等級的日誌訊息。
        /// </summary>
        /// <param name="message">日誌訊息範本。</param>
        /// <param name="propertyValues">訊息範本的參數值（可選）。</param>
        public static void Warning(string message, params object[] propertyValues)
        {
            Log.Warning(message, propertyValues);
        }

        /// <summary>
        /// 寫入 Error 等級的日誌訊息（無例外）。
        /// </summary>
        /// <param name="message">日誌訊息範本。</param>
        /// <param name="propertyValues">訊息範本的參數值（可選）。</param>
        public static void Error(string message, params object[] propertyValues)
        {
            Log.Error(message, propertyValues);
        }

        /// <summary>
        /// 寫入 Error 等級的日誌訊息（含例外資訊）。
        /// </summary>
        /// <param name="exception">發生的例外物件。</param>
        /// <param name="message">日誌訊息範本。</param>
        /// <param name="propertyValues">訊息範本的參數值（可選）。</param>
        public static void Error(Exception exception, string message, params object[] propertyValues)
        {
            Log.Error(exception, message, propertyValues);
        }

        /// <summary>
        /// 安全關閉 Serilog，確保所有緩衝的日誌都被寫出。
        /// 應於應用程式結束時呼叫（例如 Global.asax Application_End）。
        /// </summary>
        public static void CloseAndFlush()
        {
            Log.CloseAndFlush();
        }
    }
}
