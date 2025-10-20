package com.example.kaiburr;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.junit.jupiter.api.Tag;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.JsonNode;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
    properties = {"spring.data.mongodb.uri=${TEST_MONGO_URI:mongodb://host.docker.internal:27017/kaiburrdb}"})
public class EmbeddedTaskIntegrationTest {

    @LocalServerPort
    int port;

    @Autowired
    TestRestTemplate rest;

    @Test
    void createAndExecuteWithEmbeddedMongo() throws Exception {
        String base = "http://localhost:" + port + "/tasks";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        String body = "{ \"name\":\"Print Hello\", \"owner\":\"Local\", \"command\":\"echo Hello Embedded\" }";

    ResponseEntity<String> createResp = rest.exchange(base, org.springframework.http.HttpMethod.PUT, new HttpEntity<>(body, headers), String.class);
    assertThat(createResp.getStatusCode().is2xxSuccessful()).isTrue();

        // extract id
    String json = createResp.getBody();
    assertThat(json).contains("id");
    ObjectMapper mapper = new ObjectMapper();
    JsonNode node = mapper.readTree(json);
    String id = node.get("id").asText();

        ResponseEntity<String> execResp = rest.exchange(base + "/" + id + "/execute", org.springframework.http.HttpMethod.PUT, null, String.class);
        assertThat(execResp.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(execResp.getBody()).contains("Hello Embedded");
    }
}
