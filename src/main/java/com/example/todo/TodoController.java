package com.example.todo;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import java.net.URI;
import java.util.List;

@RestController
@RequestMapping("/todos")
public class TodoController {

    private final TodoService service;

    public TodoController(TodoService service) {
        this.service = service;
    }

    @GetMapping
    public List<Todo> list() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public Todo get(@PathVariable long id) {
        return service.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Todo " + id + " not found"));
    }

    @PostMapping
    public ResponseEntity<Todo> create(@Valid @RequestBody CreateTodoRequest request) {
        Todo created = service.create(request.title());
        return ResponseEntity.created(URI.create("/todos/" + created.id())).body(created);
    }
}
