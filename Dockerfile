FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 5000

ENV ASPNETCORE_URLS=http://+:5000

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /functions/demo-functions
COPY ["functions/demo-function/demo-function.csproj", "functions/demo-function/"]
RUN dotnet restore "functions/demo-function/demo-function.csproj"
COPY . .
WORKDIR "/src/functions/demo-function"
RUN dotnet build "demo-function.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "demo-function.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "demo-function.dll"]
