using SoftwareSecurity.Domain.Enums;

namespace SoftwareSecurity.Application.DTOs;

public record UserRoleDTO(
	Ulid Id,
	Role Role);