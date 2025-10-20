package com.example.kaiburr.service;

import com.example.kaiburr.model.Task;
import com.example.kaiburr.model.TaskExecution;
import com.example.kaiburr.repository.TaskRepository;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.time.Instant;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class TaskService {
    private final TaskRepository repo;

    // Whitelisted base commands
    private final List<String> ALLOWED_BASE_CMDS = Arrays.asList("echo", "ls", "pwd", "date", "whoami", "cat");

    public TaskService(TaskRepository repo) {
        this.repo = repo;
    }

    public List<Task> findAll() { return repo.findAll(); }

    public Optional<Task> findById(String id) { return repo.findById(id); }

    public Task save(Task t) {
        if (!StringUtils.hasText(t.getId())) t.setId(null);
        validateCommand(t.getCommand());
        return repo.save(t);
    }

    public void delete(String id) { repo.deleteById(id); }

    public List<Task> findByName(String name) { return repo.findByNameContainingIgnoreCase(name); }

    private void validateCommand(String command) {
        if (!StringUtils.hasText(command)) throw new IllegalArgumentException("command must not be empty");
        String base = command.trim().split("\\s+")[0];
        if (!ALLOWED_BASE_CMDS.contains(base)) {
            throw new IllegalArgumentException("Command not allowed: " + base);
        }
    }

    public TaskExecution executeTask(String taskId) throws Exception {
        Task t = repo.findById(taskId).orElseThrow(() -> new IllegalArgumentException("Task not found"));
        validateCommand(t.getCommand());

        Instant start = Instant.now();

        String[] tokens = t.getCommand().split("\\s+");
        ProcessBuilder pb = new ProcessBuilder(tokens);
        pb.redirectErrorStream(true);
        Process p = pb.start();

        StringBuilder out = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()))) {
            String line;
            while ((line = br.readLine()) != null) {
                out.append(line).append("\n");
            }
        }
        int exit = p.waitFor();
        Instant end = Instant.now();

        TaskExecution exec = new TaskExecution(start, end, out.toString().trim());
        t.getTaskExecutions().add(exec);
        repo.save(t);
        return exec;
    }
}
