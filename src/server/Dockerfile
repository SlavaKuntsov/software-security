# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src

# Copy solution file first
COPY ["server/SoftwareSecurity.sln", "."]
COPY ["server/SoftwareSecurity.API/SoftwareSecurity.API.csproj", "SoftwareSecurity.API/"]
COPY ["server/SoftwareSecurity.Domain/SoftwareSecurity.Domain.csproj", "SoftwareSecurity.Domain/"]
COPY ["server/SoftwareSecurity.Infrastructure/SoftwareSecurity.Infrastructure.csproj", "SoftwareSecurity.Infrastructure/"]
COPY ["server/SoftwareSecurity.Application/SoftwareSecurity.Application.csproj", "SoftwareSecurity.Application/"]
COPY ["server/SoftwareSecurity.Persistence/SoftwareSecurity.Persistence.csproj", "SoftwareSecurity.Persistence/"]
COPY ["server/SoftwareSecurity.Tests/SoftwareSecurity.Tests.csproj", "SoftwareSecurity.Tests/"]

# Restore all projects
RUN dotnet restore "SoftwareSecurity.sln"

# Copy everything else
COPY . .

# Build and publish
WORKDIR "/src/SoftwareSecurity.API"
RUN dotnet publish "SoftwareSecurity.API.csproj" -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS runtime
WORKDIR /app
EXPOSE 5000
ENV ASPNETCORE_URLS=http://+:5000

COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "SoftwareSecurity.API.dll"]