﻿namespace SoftwareSecurity.Application.Data;

public interface IApplicationDbContext
{
	Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}