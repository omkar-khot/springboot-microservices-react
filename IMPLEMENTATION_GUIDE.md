# Backend Microservices Implementation Guide

This guide provides complete implementation details for all backend microservices.

## ✅ Current Implementation Status

### User Service
- **Location**: `backend/user-service/`
- **Status**: Structure created
- **Files Added**:
  - `pom.xml` - Maven dependencies configured
  - `src/main/resources/application.yml` - Database and server configuration

### Required Java Source Files

Create the following files in `backend/user-service/src/main/java/com/microservices/userservice/`:

#### 1. Main Application Class
**File**: `UserServiceApplication.java`
```java
package com.microservices.userservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class UserServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(UserServiceApplication.class, args);
    }
}
```

#### 2. Entity
**File**: `model/User.java`
```java
package com.microservices.userservice.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, unique = true)
    private String username;
    
    @Column(nullable = false, unique = true)
    private String email;
    
    @Column(nullable = false)
    private String password;
    
    private String firstName;
    private String lastName;
    private Boolean enabled = true;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt = LocalDateTime.now();
}
```

#### 3. Repository
**File**: `repository/UserRepository.java`
```java
package com.microservices.userservice.repository;

import com.microservices.userservice.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
}
```

#### 4. DTO
**File**: `dto/UserDto.java`
```java
package com.microservices.userservice.dto;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class UserDto {
    private Long id;
    
    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 50)
    private String username;
    
    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    private String email;
    
    @NotBlank(message = "Password is required")
    @Size(min = 6, message = "Password must be at least 6 characters")
    private String password;
    
    private String firstName;
    private String lastName;
}
```

#### 5. Service
**File**: `service/UserService.java`
```java
package com.microservices.userservice.service;

import com.microservices.userservice.dto.UserDto;
import com.microservices.userservice.model.User;
import com.microservices.userservice.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }
    
    public User getUserById(Long id) {
        return userRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("User not found with id: " + id));
    }
    
    public User createUser(UserDto userDto) {
        User user = new User();
        user.setUsername(userDto.getUsername());
        user.setEmail(userDto.getEmail());
        user.setPassword(userDto.getPassword());
        user.setFirstName(userDto.getFirstName());
        user.setLastName(userDto.getLastName());
        return userRepository.save(user);
    }
    
    public User updateUser(Long id, UserDto userDto) {
        User user = getUserById(id);
        user.setUsername(userDto.getUsername());
        user.setEmail(userDto.getEmail());
        user.setFirstName(userDto.getFirstName());
        user.setLastName(userDto.getLastName());
        return userRepository.save(user);
    }
    
    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }
}
```

#### 6. Controller
**File**: `controller/UserController.java`
```java
package com.microservices.userservice.controller;

import com.microservices.userservice.dto.UserDto;
import com.microservices.userservice.model.User;
import com.microservices.userservice.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;
    
    @GetMapping
    public ResponseEntity<List<User>> getAllUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        return ResponseEntity.ok(userService.getUserById(id));
    }
    
    @PostMapping
    public ResponseEntity<User> createUser(@Valid @RequestBody UserDto userDto) {
        return new ResponseEntity<>(userService.createUser(userDto), HttpStatus.CREATED);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<User> updateUser(@PathVariable Long id, @Valid @RequestBody UserDto userDto) {
        return ResponseEntity.ok(userService.updateUser(id, userDto));
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }
}
```

#### 7. Exception Handler
**File**: `exception/GlobalExceptionHandler.java`
```java
package com.microservices.userservice.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Map<String, String>> handleRuntimeException(RuntimeException ex) {
        Map<String, String> error = new HashMap<>();
        error.put("error", ex.getMessage());
        return new ResponseEntity<>(error, HttpStatus.NOT_FOUND);
    }
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> handleValidationExceptions(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(error -> 
            errors.put(error.getField(), error.getDefaultMessage())
        );
        return new ResponseEntity<>(errors, HttpStatus.BAD_REQUEST);
    }
}
```

## 📦 Dockerfile for User Service

**File**: `backend/user-service/Dockerfile`
```dockerfile
FROM maven:3.9-amazoncorretto-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM amazoncorretto:17-alpine
WORKDIR /app
COPY --from=build /app/target/user-service.jar app.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "app.jar"]
```

## 🔄 Product Service

The Product Service follows the same structure as User Service. Replace "User" with "Product" and add these fields to Product entity:
- `name` (String)
- `description` (String)
- `price` (BigDecimal)
- `quantity` (Integer)
- `category` (String)
- `sku` (String)

Copy the User Service structure and modify accordingly.

## 🔐 Auth Service 

Requires additional dependencies in pom.xml:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.11.5</version>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-impl</artifactId>
    <version>0.11.5</version>
    <scope>runtime</scope>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-jackson</artifactId>
    <version>0.11.5</version>
    <scope>runtime</scope>
</dependency>
```

## 🚪 API Gateway

Use Spring Cloud Gateway. Add to pom.xml:
```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-gateway</artifactId>
</dependency>
```

Configuration in `application.yml`:
```yaml
spring:
  cloud:
    gateway:
      routes:
        - id: user-service
          uri: http://user-service:8081
          predicates:
            - Path=/api/users/**
        - id: product-service
          uri: http://product-service:8083
          predicates:
            - Path=/api/products/**
        - id: auth-service
          uri: http://auth-service:8082
          predicates:
            - Path=/api/auth/**
```

## ✅ Quick Setup Commands

```bash
# Build User Service
cd backend/user-service
mvn clean install

# Run User Service
mvn spring-boot:run

# Or with Docker
docker build -t user-service .
docker run -p 8081:8081 user-service
```

## 🧪 Testing

Test endpoint:
```bash
curl http://localhost:8081/api/users
```

## 📝 Notes

1. All services follow the same layered architecture
2. Use Spring Initializr (https://start.spring.io/) to generate additional services
3. Copy the User Service structure for Product Service
4. Auth Service needs JWT implementation
5. API Gateway routes all requests to appropriate services
6. Database tables are auto-created from init-db.sql
7. Use Postman or cURL to test endpoints

## 🔗 Related Files

- `docker-compose.yml` - Orchestrates all services
- `init-db.sql` - Initializes database with sample data
- `README_PROJECT.md` - Comprehensive project documentation
