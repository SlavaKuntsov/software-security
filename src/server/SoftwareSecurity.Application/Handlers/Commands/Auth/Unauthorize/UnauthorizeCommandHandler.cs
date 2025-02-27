using MediatR;

using SoftwareSecurity.Application.Data;
using SoftwareSecurity.Domain.Interfaces.Repositories;


namespace SoftwareSecurity.Application.Handlers.Commands.Auth.Unauthorize;

public class UnauthorizeCommandHandler(
	ITokensRepository tokensRepository,
	IApplicationDbContext context) 
	: IRequestHandler<UnauthorizeCommand>
{
	private readonly ITokensRepository _tokensRepository = tokensRepository;
	private readonly IApplicationDbContext _context = context;

	public async Task Handle(UnauthorizeCommand request, CancellationToken cancellationToken)
	{
		var existRefreshToken = await _tokensRepository.GetAsync(
			request.Id,
			cancellationToken);

		existRefreshToken!.IsRevoked = true;

		_tokensRepository.Update(existRefreshToken);

		await _context.SaveChangesAsync(cancellationToken);

		return;
	}
}