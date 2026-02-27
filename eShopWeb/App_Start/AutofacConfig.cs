using System.Reflection;
using System.Web.Mvc;
using Autofac;
using Autofac.Integration.Mvc;

namespace eShopWeb.App_Start
{
    /// <summary>
    /// Autofac 相依性注入容器的設定類別。
    /// 負責掃描各組件並依介面自動完成服務與 Repository 的註冊。
    /// 應於 Global.asax Application_Start 中呼叫 <see cref="Configure"/>。
    /// </summary>
    public static class AutofacConfig
    {
        /// <summary>
        /// 建立並設定 Autofac 容器，完成所有服務與 Repository 介面的自動註冊，
        /// 並將 MVC 的 DependencyResolver 替換為 Autofac 解析器。
        /// </summary>
        public static void Configure()
        {
            var builder = new ContainerBuilder();

            // 註冊目前 MVC 組件中的所有 Controller
            builder.RegisterControllers(Assembly.GetExecutingAssembly());

            // 掃描 eShop.Services 組件，將所有實作介面的類別以 InstancePerLifetimeScope 方式自動註冊
            var servicesAssembly = Assembly.Load("eShop.Services");
            builder.RegisterAssemblyTypes(servicesAssembly)
                   .AsImplementedInterfaces()
                   .InstancePerLifetimeScope();

            // 掃描 eShop.Repositories 組件，將所有實作介面的類別以 InstancePerLifetimeScope 方式自動註冊
            var repositoriesAssembly = Assembly.Load("eShop.Repositories");
            builder.RegisterAssemblyTypes(repositoriesAssembly)
                   .AsImplementedInterfaces()
                   .InstancePerLifetimeScope();

            // 建立容器並設定為 MVC 的 DependencyResolver
            var container = builder.Build();
            DependencyResolver.SetResolver(new AutofacDependencyResolver(container));
        }
    }
}
