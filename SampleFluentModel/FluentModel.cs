using System.Linq;
using Telerik.OpenAccess;
using Telerik.OpenAccess.Metadata;

namespace SampleFluentModel
{
    public partial class FluentModel : OpenAccessContext
    {
        private static string connectionStringName = @"connectionId";

        private static BackendConfiguration backend = GetBackendConfiguration();

        private static MetadataSource metadataSource = new FluentModelMetadataSource();

        public FluentModel() : base(connectionStringName, backend, metadataSource) { }

        public IQueryable<Customer> Customers
        {
            get
            {
                return this.GetAll<Customer>();
            }
        }

        public static BackendConfiguration GetBackendConfiguration()
        {
            #region Mysql
            //BackendConfiguration backend = new BackendConfiguration
            //{
            //    Backend = "mysql",
            //    ProviderName = "MySql.Data.MySqlClient"
            //};
            #endregion

            #region Sql Server
            BackendConfiguration backend = new BackendConfiguration
            {
                Backend = "MsSql",
                ProviderName = "System.Data.SqlClient"
            };
            #endregion

            return backend;
        }
    }
}
