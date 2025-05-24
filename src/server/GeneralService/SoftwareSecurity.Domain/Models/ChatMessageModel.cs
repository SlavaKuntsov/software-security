namespace SoftwareSecurity.Domain.Models;

public class ChatMessageModel
{
	public Ulid Id { get; set; }
	public Ulid SenderId { get; set; }
	public Ulid ReceiverId { get; set; }
	public string Content { get; set; } = string.Empty;
	public DateTime Timestamp { get; set; }
	public bool IsRead { get; set; }

	public virtual UserModel Sender { get; set; } = null!;
	public virtual UserModel Receiver { get; set; } = null!;

	public ChatMessageModel() {}

	public ChatMessageModel(
		Ulid senderId,
		Ulid receiverId,
		string content)
	{
		Id = Ulid.NewUlid();
		SenderId = senderId;
		ReceiverId = receiverId;
		Content = content;
		Timestamp = DateTime.UtcNow;
		IsRead = false;
	}
}