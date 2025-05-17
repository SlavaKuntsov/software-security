using MediatR;

using SoftwareSecurity.Application.Data;
using SoftwareSecurity.Application.DTOs;
using SoftwareSecurity.Application.Interfaces.Auth;
using SoftwareSecurity.Domain.Interfaces.Repositories;
using SoftwareSecurity.Domain.Models;


namespace SoftwareSecurity.Application.Handlers.Commands.Tokens.GenerateTokens;

public class GenerateTokensCommandHandler(
	ITokensRepository tokensRepository,
	IApplicationDbContext context,
	IJwt jwt) 
	: IRequestHandler<GenerateTokensCommand, AuthDTO>
{
	private readonly ITokensRepository _tokensRepository = tokensRepository;
	private readonly IApplicationDbContext _context = context;
	private readonly IJwt _jwt = jwt;

	public async Task<AuthDTO> Handle(GenerateTokensCommand request, CancellationToken cancellationToken)
	{
		var accessToken = _jwt.GenerateAccessToken(request.Id, request.Role);
		var newRefreshToken = _jwt.GenerateRefreshToken();

		var newRefreshTokenModel = new RefreshTokenModel(
				request.Id,
				newRefreshToken,
				_jwt.GetRefreshTokenExpirationDays());

		var existRefreshToken = await _tokensRepository.GetAsync(
			request.Id,
			cancellationToken);

		if (existRefreshToken is not null)
		{
			existRefreshToken.Token = newRefreshTokenModel.Token;
			existRefreshToken.ExpiresAt = newRefreshTokenModel.ExpiresAt;

			_tokensRepository.Update(existRefreshToken);
		}
		else
		{
			await _tokensRepository.CreateAsync(
				newRefreshTokenModel,
				cancellationToken);
		}

		await _context.SaveChangesAsync(cancellationToken);

		return new AuthDTO(accessToken, newRefreshToken);
	}
}