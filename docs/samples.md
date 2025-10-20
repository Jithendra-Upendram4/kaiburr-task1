# API samples

These are sample request/response pairs captured from a running instance.

Create task (request body):
```json
{
  "name": "Sample Echo",
  "owner": "CI Bot",
  "command": "echo Hello from sample"
}
```

Create task (response):
```json
{
  "id": "68f67ffd7cc033fe15a26e96",
  "name": "Sample Echo",
  "owner": "CI Bot",
  "command": "echo Hello from sample",
  "taskExecutions": []
}
```

Execute task (response):
```json
{
  "startTime": "2025-10-20T18:31:25.228689046Z",
  "endTime": "2025-10-20T18:31:25.253797197Z",
  "output": "Hello from sample"
}
```
