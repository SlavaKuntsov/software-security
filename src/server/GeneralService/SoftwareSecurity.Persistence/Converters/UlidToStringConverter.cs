using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using System;

namespace SoftwareSecurity.Persistence.Converters;

public class UlidToStringConverter : ValueConverter<Ulid, string>
{
    public UlidToStringConverter()
        : base(
            v => v.ToString(),
            v => Ulid.Parse(v))
    {
    }
} 