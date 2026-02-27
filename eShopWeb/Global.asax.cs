using System;
using System.Configuration;
using System.Security.Principal;
using System.Web;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;
using System.Web.Security;
using eShop.Utility.Logging;
using eShopWeb.App_Start;

namespace eShopWeb
{
    /// <summary>
    /// ASP.NET MVC 應用程式全域事件處理類別。
    /// 負責應用程式生命週期管理，包含 DI 容器初始化、日誌初始化與全域錯誤攔截。
    /// </summary>
    public class MvcApplication : System.Web.HttpApplication
    {
        /// <summary>
        /// 應用程式啟動事件：初始化 Autofac DI 容器、Serilog 日誌、MVC 路由與 Bundle。
        /// </summary>
        protected void Application_Start()
        {
            AreaRegistration.RegisterAllAreas();
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);

            // 初始化 Autofac 相依性注入容器
            AutofacConfig.Configure();

            // 初始化 Serilog 日誌（同時寫入檔案與 SQL Server）
            var connectionString = ConfigurationManager.ConnectionStrings["eShopDB"]?.ConnectionString;
            AppLogger.Init(connectionString);

            AppLogger.Info("eShop 應用程式啟動");
        }

        /// <summary>
        /// 應用程式結束事件：安全關閉 Serilog，確保所有緩衝日誌寫出。
        /// </summary>
        protected void Application_End()
        {
            AppLogger.Info("eShop 應用程式結束");
            AppLogger.CloseAndFlush();
        }

        /// <summary>
        /// 全域未攔截例外處理：記錄錯誤並導向自訂錯誤頁面。
        /// 此為系統最後一道防線，處理所有未被 try-catch 攔截的例外。
        /// </summary>
        protected void Application_Error()
        {
            var exception = Server.GetLastError();
            if (exception == null)
            {
                return;
            }

            // 記錄未處理例外
            AppLogger.Error(exception, "未處理的全域例外：{Message}", exception.Message);

            // 清除例外，由 Web.config customErrors 接手導向錯誤頁面
            Server.ClearError();

            var httpException = exception as HttpException;
            var statusCode = httpException?.GetHttpCode() ?? 500;

            // 導向錯誤頁面
            Response.Redirect(statusCode == 404 ? "~/Error/NotFound" : "~/Error/ServerError");
        }

        /// <summary>
        /// 驗證完成後重建含角色的 <see cref="GenericPrincipal"/>，
        /// 使 <c>[Authorize(Roles="...")]</c> 能正確運作。
        /// 角色資訊儲存於 <see cref="FormsAuthenticationTicket.UserData"/>。
        /// </summary>
        protected void Application_PostAuthenticateRequest()
        {
            var authCookie = Request.Cookies[FormsAuthentication.FormsCookieName];
            if (authCookie == null)
            {
                return;
            }

            FormsAuthenticationTicket ticket;
            try
            {
                ticket = FormsAuthentication.Decrypt(authCookie.Value);
            }
            catch
            {
                // 票證解密失敗（例如票證已過期或遭竄改），略過不處理
                return;
            }

            if (ticket == null || ticket.Expired)
            {
                return;
            }

            // UserData 存放角色名稱（單一角色字串，例如 "Member"）
            var roles = string.IsNullOrEmpty(ticket.UserData)
                ? new string[0]
                : new[] { ticket.UserData };

            var identity = new FormsIdentity(ticket);
            var principal = new GenericPrincipal(identity, roles);

            // 同時設定 HttpContext 與 Thread 的 Principal
            HttpContext.Current.User = principal;
        }
    }
}

