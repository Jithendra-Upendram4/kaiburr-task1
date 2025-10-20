package com.example.kaiburr;

import com.example.kaiburr.model.Task;
import com.example.kaiburr.model.TaskExecution;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.core.env.Environment;
import org.springframework.http.*;
import org.testcontainers.containers.MongoDBContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.util.Map;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
public class TaskIntegrationTest {

    @Container
    static MongoDBContainer mongo = new MongoDBContainer("mongo:6.0.26");

    @Autowired
    private TestRestTemplate rest;

    @Autowired
    private Environment env;

    @Test
    @Tag("docker")
    public void createAndExecuteTask() throws Exception {
        // Ensure Testcontainers started
        Assertions.assertTrue(mongo.isRunning());

        // Create task
        Task t = new Task();
        t.setName("IT Print");
        t.setOwner("tester");
        t.setCommand("echo Hello IT");

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Task> req = new HttpEntity<>(t, headers);

        ResponseEntity<Map> createResp = rest.exchange("/tasks", HttpMethod.PUT, req, Map.class);
        Assertions.assertEquals(HttpStatus.OK, createResp.getStatusCode());
        Map body = createResp.getBody();
        Assertions.assertNotNull(body.get("id"));
        String id = body.get("id").toString();

        // Execute
        ResponseEntity<TaskExecution> execResp = rest.exchange("/tasks/"+id+"/execute", HttpMethod.PUT, null, TaskExecution.class);
        Assertions.assertEquals(HttpStatus.OK, execResp.getStatusCode());
        TaskExecution exec = execResp.getBody();
        Assertions.assertNotNull(exec.getOutput());
        Assertions.assertTrue(exec.getOutput().contains("Hello IT") || exec.getOutput().contains("Hello IT\n"));
    }
}
