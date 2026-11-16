package com.example.todo;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Map;
import java.util.Optional;

@RestController
public class StatusController {

    // Values come from application.properties or, in Kubernetes, from the ConfigMap
    // (env vars APP_NAME, APP_ENVIRONMENT, APP_VERSION map to app.name, etc.).
    @Value("${app.name:todo-api}")
    private String name;

    @Value("${app.environment:local}")
    private String environment;

    @Value("${app.version:1.0.0}")
    private String version;

    @GetMapping("/")
    public Map<String, Object> status() {
        return Map.of(
                "service", name,
                "status", "UP",
                "environment", environment,
                "version", version,
                "instance", Optional.ofNullable(System.getenv("HOSTNAME")).orElse("local"),
                "timestamp", Instant.now().toString());
    }
}
