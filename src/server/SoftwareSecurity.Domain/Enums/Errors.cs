using System.ComponentModel;

namespace SoftwareSecurity.Domain.Enums;

public enum ErrorType
{
	[Description(nameof(AlreadyExists))]
	AlreadyExists,
	[Description(nameof(Failure))]
	Failure,
	[Description(nameof(Validation))]
	Validation,
	[Description(nameof(Arguments))]
	Arguments,
	[Description(nameof(NotFound))]
	NotFound,
	[Description(nameof(Conflict))]
	Conflict,
	[Description(nameof(Unauthorized))]
	Unauthorized,
	[Description(nameof(Forbidden))]
	Forbidden,
	[Description(nameof(Internal))]
	Internal,
	[Description(nameof(Invalid))]
	Invalid,
	[Description(nameof(None))]
	None
}