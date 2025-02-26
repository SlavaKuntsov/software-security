FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /app

COPY ["server/SoftwareSecurity.API/SoftwareSecurity.API.csproj", "server/SoftwareSecurity.API/"]
COPY ["server/SoftwareSecurity.Domain/SoftwareSecurity.Domain.csproj", "server/SoftwareSecurity.Domain/"]
COPY ["server/SoftwareSecurity.Infrastructure/SoftwareSecurity.Infrastructure.csproj", "server/SoftwareSecurity.Infrastructure/"]
COPY ["server/SoftwareSecurity.Application/SoftwareSecurity.Application.csproj", "server/SoftwareSecurity.Application/"]
COPY ["server/SoftwareSecurity.Persistence/SoftwareSecurity.Persistence.csproj", "server/SoftwareSecurity.Persistence/"]

RUN dotnet restore "server/Microservices/SoftwareSecurity/SoftwareSecurity.API/SoftwareSecurity.API.csproj"

COPY . . 

RUN dotnet publish "server/SoftwareSecurity.API/SoftwareSecurity.API.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS runtime
WORKDIR /app
EXPOSE 7001

COPY --from=build /app/publish . 

# ENV ASPNETCORE_URLS=https://+:7001

ENTRYPOINT ["dotnet", "SoftwareSecurity.API.dll"]