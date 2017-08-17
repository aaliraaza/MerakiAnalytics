using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(MerakiApp.Startup))]
namespace MerakiApp
{
    public partial class Startup {
        public void Configuration(IAppBuilder app) {
            ConfigureAuth(app);
        }
    }
}
