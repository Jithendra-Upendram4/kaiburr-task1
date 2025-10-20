# Kaiburr Task 1 - REST API

Minimal Spring Boot REST API for Task objects stored in MongoDB.

## What
This app exposes simple CRUD + execute endpoints for `Task` objects stored in MongoDB.

## Run locally

1. Start MongoDB (using docker-compose):

```powershell
docker compose up -d
```

2. Build the app

Option A — using local Maven (requires Java 21 and Maven installed):

```powershell
# from repo root
mvn clean package -DskipTests
```

Option B — build without installing Maven locally using Docker (recommended if you don't have mvn):

```powershell
# from repo root
./scripts/build-with-docker-maven.ps1
```

3. Run the app (optionally set MONGODB_URI):

```powershell
$env:MONGODB_URI = 'mongodb://localhost:27017/kaiburrdb'
java -jar target/kaiburr-task1-0.0.1-SNAPSHOT.jar
```

## Endpoints

- GET /tasks
- GET /tasks?id={id}
- GET /tasks/search?name={name}
- PUT /tasks  (create/update) body: Task JSON
- DELETE /tasks/{id}
- PUT /tasks/{id}/execute

## Quick curl tests (PowerShell)

Create a task:

```powershell
curl -s -X PUT http://localhost:8080/tasks -H 'Content-Type: application/json' -d '{"name":"Print Hello","owner":"Your Name","command":"echo Hello World"}' | ConvertFrom-Json
```

List tasks:

```powershell
curl http://localhost:8080/tasks | ConvertFrom-Json
```

Execute a task (replace ID):

```powershell
curl -X PUT http://localhost:8080/tasks/<THE_ID>/execute | ConvertFrom-Json
```

Delete a task:

```powershell
curl -X DELETE http://localhost:8080/tasks/<THE_ID>
```

## Docker Compose (Mongo)

Run `docker compose up -d` to start MongoDB on port 27017.

## Notes

- Commands executed by the server are validated against a whitelist and executed without a shell to reduce risk. Do not expose this service publicly in production without additional safeguards.
- The project now targets Java 21; ensure your environment uses Java 21.

## Quick reproducible run

I provide an `auto-run.ps1` script that builds, starts required containers, and runs integration smoke tests locally.

How to run (Windows PowerShell):

1. Open PowerShell as Administrator.
2. From repo root:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\auto-run.ps1
```

`auto-run.ps1` will:

- build the project,
- start MongoDB and the application in Docker,
- run the integration smoke tests,
- save useful logs into `docs/` and `artifacts/` (if present).

Note: The script modifies local Docker resources and may overwrite containers named `kaiburr-mongo` / `kaiburr-app`. Make sure you don't have important containers with those names.
