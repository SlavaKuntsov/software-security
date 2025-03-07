using System.ComponentModel;

namespace SoftwareSecurity.Domain.Enums;

public enum AuthType
{
	[Description(nameof(Login))]
	Login = 0,
	[Description(nameof(Google))]
	Google = 1
}