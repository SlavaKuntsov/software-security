using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using System;
using System.Linq;

namespace SoftwareSecurity.Persistence;

public static class ModelBuilderExtensions
{
    public static ModelBuilder UseValueConverter(this ModelBuilder modelBuilder, ValueConverter converter)
    {
        // Get all entity types from the model
        var entityTypes = modelBuilder.Model.GetEntityTypes();
        
        // Get the CLR type that the converter is for
        Type converterType = null;
        var valueConverterType = typeof(ValueConverter<,>);
        
        // Find the ValueConverter interface in the converter's inheritance hierarchy
        foreach (var interfaceType in converter.GetType().GetInterfaces())
        {
            if (interfaceType.IsGenericType && 
                interfaceType.GetGenericTypeDefinition() == valueConverterType)
            {
                converterType = interfaceType.GetGenericArguments()[0];
                break;
            }
        }
        
        // If we couldn't determine the type, use Ulid as a fallback
        if (converterType == null)
        {
            converterType = typeof(Ulid);
        }
        
        // Find properties of the type and apply the converter
        foreach (var entityType in entityTypes)
        {
            var properties = entityType.GetProperties()
                .Where(p => p.ClrType == converterType);
                
            foreach (var property in properties)
            {
                if (property.GetValueConverter() == null)
                {
                    property.SetValueConverter(converter);
                }
            }
        }
        
        return modelBuilder;
    }
} 