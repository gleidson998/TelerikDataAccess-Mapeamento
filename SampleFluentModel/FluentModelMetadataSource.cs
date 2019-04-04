using System.Collections.Generic;
using Telerik.OpenAccess.Metadata.Fluent;

namespace SampleFluentModel
{
    public partial class FluentModelMetadataSource : FluentMetadataSource
    {
        protected override IList<MappingConfiguration> PrepareMapping()
        {
            List<MappingConfiguration> configurations = new List<MappingConfiguration>();

            var customerMapping = new MappingConfiguration<Customer>();
            customerMapping.MapType(customer => new
            {
                ID = customer.Codigo,
                Name = customer.CodigoEgemai,
                DiamExt = customer.DiamExtMaior
                //DateCreated = customer.DateCreated
            }).ToTable("produtos");

            customerMapping.HasProperty(c => c.Codigo).IsIdentity();

            configurations.Add(customerMapping);

            return configurations;
        }
    }
}
