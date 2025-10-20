package com.example.kaiburr.repository;

import java.util.List;
import org.springframework.data.mongodb.repository.MongoRepository;
import com.example.kaiburr.model.Task;

public interface TaskRepository extends MongoRepository<Task, String> {
    List<Task> findByNameContainingIgnoreCase(String name);
}
