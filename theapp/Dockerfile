# Builder
FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS builder 
WORKDIR /source
COPY theapp.csproj .
RUN dotnet restore
COPY . .
RUN dotnet publish --output package --configuration release # --no-restore

# Production
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-alpine
WORKDIR /app
COPY --from=builder /source/package .
ENTRYPOINT ["dotnet", "theapp.dll"]
