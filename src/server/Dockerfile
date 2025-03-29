FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /app

COPY ["server/UserService/SoftwareSecurity.API/SoftwareSecurity.API.csproj", "server/UserService/SoftwareSecurity.API/"]
COPY ["server/UserService/SoftwareSecurity.Domain/SoftwareSecurity.Domain.csproj", "server/UserService/SoftwareSecurity.Domain/"]
COPY ["server/UserService/SoftwareSecurity.Infrastructure/SoftwareSecurity.Infrastructure.csproj", "server/UserService/SoftwareSecurity.Infrastructure/"]
COPY ["server/UserService/SoftwareSecurity.Application/SoftwareSecurity.Application.csproj", "server/UserService/SoftwareSecurity.Application/"]
COPY ["server/UserService/SoftwareSecurity.Persistence/SoftwareSecurity.Persistence.csproj", "server/UserService/SoftwareSecurity.Persistence/"]

RUN dotnet restore "server/UserService/SoftwareSecurity.API/SoftwareSecurity.API.csproj"

COPY . . 

RUN dotnet publish "server/UserService/SoftwareSecurity.API/SoftwareSecurity.API.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS runtime
WORKDIR /app
EXPOSE 5000 5001

RUN apk add --no-cache ca-certificates \
    && update-ca-certificates

COPY --from=build /app/publish . 

ENTRYPOINT ["dotnet", "SoftwareSecurity.API.dll"]