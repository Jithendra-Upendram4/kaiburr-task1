package com.example.kaiburr.controller;

import com.example.kaiburr.model.Task;
import com.example.kaiburr.model.TaskExecution;
import com.example.kaiburr.service.TaskService;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/tasks")
public class TaskController {
    private final TaskService svc;
    public TaskController(TaskService svc) { this.svc = svc; }

    @GetMapping
    public ResponseEntity<?> getTasks(@RequestParam(name="id", required=false) String id) {
        if (id != null) {
            var opt = svc.findById(id);
            if (opt.isPresent()) return ResponseEntity.ok(opt.get());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Not found");
        }
        return ResponseEntity.ok(svc.findAll());
    }

    @GetMapping("/search")
    public ResponseEntity<?> searchByName(@RequestParam("name") String name) {
        List<Task> list = svc.findByName(name);
        if (list.isEmpty()) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("No tasks found");
        return ResponseEntity.ok(list);
    }

    @PutMapping
    public ResponseEntity<?> createOrUpdate(@RequestBody @Valid Task task) {
        try {
            Task saved = svc.save(task);
            return ResponseEntity.ok(saved);
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(ex.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable String id) {
        svc.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}/execute")
    public ResponseEntity<?> execute(@PathVariable String id) {
        try {
            TaskExecution exec = svc.executeTask(id);
            return ResponseEntity.ok(exec);
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(ex.getMessage());
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(ex.getMessage());
        }
    }
}
