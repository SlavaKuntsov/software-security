namespace SoftwareSecurity.Domain.Models;

public class RefreshTokenModel
{
	public Ulid Id { get; set; }
	public string Token { get; set; } = string.Empty;
	public DateTime ExpiresAt { get; set; }
	public DateTime CreatedAt { get; set; }
	public bool IsRevoked { get; set; } = false;
	public Ulid? UserId { get; set; }

	public virtual UserModel User { get; set; } = null!;

	public RefreshTokenModel() { }

	public RefreshTokenModel(
		Ulid userId,
		string token,
		int refreshTokenExpirationDays)
	{
		Id = Ulid.NewUlid();
		Token = token;
		ExpiresAt = DateTime.UtcNow.Add(TimeSpan.FromDays(refreshTokenExpirationDays));
		CreatedAt = DateTime.UtcNow;
		IsRevoked = false;
		UserId = userId;
	}
}