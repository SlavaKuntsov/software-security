using MediatR;

namespace SoftwareSecurity.Application.Handlers.Commands.Users.DeleteUser;

public partial class DeleteUserCommand(Ulid id) : IRequest
{
    public Ulid Id { get; private set; } = id;
}