FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /app

COPY ["server/GeneralService/SoftwareSecurity.API/SoftwareSecurity.API.csproj", "server/GeneralService/SoftwareSecurity.API/"]
COPY ["server/GeneralService/SoftwareSecurity.Domain/SoftwareSecurity.Domain.csproj", "server/GeneralService/SoftwareSecurity.Domain/"]
COPY ["server/GeneralService/SoftwareSecurity.Infrastructure/SoftwareSecurity.Infrastructure.csproj", "server/GeneralService/SoftwareSecurity.Infrastructure/"]
COPY ["server/GeneralService/SoftwareSecurity.Application/SoftwareSecurity.Application.csproj", "server/GeneralService/SoftwareSecurity.Application/"]
COPY ["server/GeneralService/SoftwareSecurity.Persistence/SoftwareSecurity.Persistence.csproj", "server/GeneralService/SoftwareSecurity.Persistence/"]

RUN dotnet restore "server/GeneralService/SoftwareSecurity.API/SoftwareSecurity.API.csproj"

COPY . . 

RUN dotnet publish "server/GeneralService/SoftwareSecurity.API/SoftwareSecurity.API.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS runtime
WORKDIR /app
EXPOSE 5000 5001

RUN apk add --no-cache ca-certificates \
    && update-ca-certificates

COPY --from=build /app/publish . 

ENTRYPOINT ["dotnet", "SoftwareSecurity.API.dll"]