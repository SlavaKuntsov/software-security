﻿using System.ComponentModel;

namespace SoftwareSecurity.Domain.Enums;

public enum Role
{
	[Description("User")]
	User = 0,
	[Description("Admin")]
	Admin = 1
}