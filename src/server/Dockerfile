FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src

COPY ["server/SoftwareSecurity.API/SoftwareSecurity.API.csproj", "SoftwareSecurity.API/"]
COPY ["server/SoftwareSecurity.Domain/SoftwareSecurity.Domain.csproj", "SoftwareSecurity.Domain/"]
COPY ["server/SoftwareSecurity.Infrastructure/SoftwareSecurity.Infrastructure.csproj", "SoftwareSecurity.Infrastructure/"]
COPY ["server/SoftwareSecurity.Application/SoftwareSecurity.Application.csproj", "SoftwareSecurity.Application/"]
COPY ["server/SoftwareSecurity.Persistence/SoftwareSecurity.Persistence.csproj", "SoftwareSecurity.Persistence/"]

RUN dotnet restore "SoftwareSecurity.API/SoftwareSecurity.API.csproj" \
    --verbosity detailed \
    --disable-parallel \
    --source https://api.nuget.org/v3/index.json

COPY . .

WORKDIR "/src/SoftwareSecurity.API"
RUN dotnet publish "SoftwareSecurity.API.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS runtime
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "SoftwareSecurity.API.dll"]