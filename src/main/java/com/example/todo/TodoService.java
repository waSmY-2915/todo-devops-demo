package com.example.todo;

import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

/**
 * In-memory store. State is per-instance: with several Kubernetes replicas each pod
 * keeps its own list (fine for a demo, a real app would use a database).
 */
@Service
public class TodoService {

    private final Map<Long, Todo> todos = new ConcurrentHashMap<>();
    private final AtomicLong sequence = new AtomicLong();

    public TodoService() {
        create("Learn Git branching");
        create("Set up the Jenkins pipeline");
    }

    public List<Todo> findAll() {
        return todos.values().stream()
                .sorted(Comparator.comparingLong(Todo::id))
                .toList();
    }

    public Optional<Todo> findById(long id) {
        return Optional.ofNullable(todos.get(id));
    }

    public Todo create(String title) {
        long id = sequence.incrementAndGet();
        Todo todo = new Todo(id, title.trim(), false);
        todos.put(id, todo);
        return todo;
    }
}
