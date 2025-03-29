using Microsoft.OpenApi.Any;
using Microsoft.OpenApi.Models;

using Swashbuckle.AspNetCore.SwaggerGen;

namespace SoftwareSecurity.API.Extensions;

public class ApiVersionHeaderOperationFilter : IOperationFilter
{
	public void Apply(OpenApiOperation operation, OperationFilterContext context)
	{
		operation.Parameters ??= [];

		operation.Parameters.Add(new OpenApiParameter
		{
			Name = "api-version",
			In = ParameterLocation.Header,
			Required = true,
			Schema = new OpenApiSchema
			{
				Type = "string",
				Default = new OpenApiString("1.0")
			},
			Description = "API version"
		});
	}
}