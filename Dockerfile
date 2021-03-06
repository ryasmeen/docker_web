#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
WORKDIR /src
COPY ["docker_web.fsproj", "docker_web/"]
RUN dotnet restore "docker_web/docker_web.fsproj"
COPY . /src/docker_web/.
WORKDIR "/src/docker_web"
RUN dotnet build "docker_web.fsproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "docker_web.fsproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "docker_web.dll"]
