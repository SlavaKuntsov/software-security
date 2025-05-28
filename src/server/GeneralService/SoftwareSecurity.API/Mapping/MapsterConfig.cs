using System.Globalization;
using Mapster;
using SoftwareSecurity.Application.Handlers.Commands.Users.UpdateUser;
using SoftwareSecurity.Domain.Constants;
using SoftwareSecurity.Domain.Models;

namespace SoftwareSecurity.API.Mapping;

public class MapsterConfig : IRegister
{
	public void Register(TypeAdapterConfig config)
	{

		config.NewConfig<UpdateUserCommand, UserModel>()
			.Map(dest => dest.FirstName, src => src.FirstName)
			.Map(dest => dest.LastName, src => src.LastName)
			.Map(dest => dest.DateOfBirth, src => ParseDateOrDefault(src.DateOfBirth));
	}

	private static DateTime ParseDateOrDefault(string dateOfBirthString)
	{
		return DateTime.TryParseExact(
			dateOfBirthString,
			DateTimeConstants.DATE_FORMAT,
			CultureInfo.InvariantCulture,
			DateTimeStyles.None,
			out var parsedDateTime)
			? parsedDateTime
			: DateTime.MinValue;
	}
}