using SoftwareSecurity.Domain.Enums;

namespace SoftwareSecurity.Domain.Models;

public class UserModel
{
	public Ulid Id { get; set; }
	public string Email { get; set; } = string.Empty;
	public string Password { get; set; } = string.Empty;
	public Role Role { get; set; }
	public string FirstName { get; set; } = string.Empty;
	public string LastName { get; set; } = string.Empty;
	public string DateOfBirth { get; set; } = string.Empty;
	public AuthType AuthType { get; set; }

	public virtual RefreshTokenModel RefreshToken { get; set; } = null!;
	public virtual ICollection<ChatMessageModel> SentMessages { get; set; } = [];
	public virtual ICollection<ChatMessageModel> ReceivedMessages { get; set; } = [];

	public UserModel() { }

	public UserModel(
		string email,
		string password,
		Role role,
		AuthType authType,
		string? firstName = null,
		string? lastName = null,
		string? dateOfBirth = null)
	{
		Id = Ulid.NewUlid();
		Email = email;
		Password = password;
		Role = role;
		AuthType = authType;
		FirstName = firstName ?? string.Empty;
		LastName = lastName ?? string.Empty;
		DateOfBirth = dateOfBirth ?? string.Empty;
	}
}