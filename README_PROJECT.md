# Enterprise Microservices Application

## Project Overview

This is a complete enterprise-ready, production-grade application using **Spring Boot microservices** for the backend and **React** for the frontend. The system is designed for local execution and ready for containerization using Docker.

## Architecture

### Backend Services (Spring Boot)
1. **API Gateway** (Port 8080) - Entry point, routes requests to microservices
2. **Auth Service** (Port 8082) - Authentication and authorization with JWT
3. **User Service** (Port 8081) - User management CRUD operations
4. **Product Service** (Port 8083) - Product management CRUD operations

### Frontend
- **React Client** (Port 3000) - Modern UI with React, routing, and state management

### Database
- **PostgreSQL** (Port 5432) - Relational database for all services

## Directory Structure

```
springboot-microservices-react/
├── backend/
│   ├── api-gateway/
│   │   ├── src/
│   │   ├── pom.xml
│   │   └── Dockerfile
│   ├── auth-service/
│   │   ├── src/
│   │   ├── pom.xml
│   │   └── Dockerfile
│   ├── user-service/
│   │   ├── src/
│   │   ├── pom.xml
│   │   └── Dockerfile
│   └── product-service/
│       ├── src/
│       ├── pom.xml
│       └── Dockerfile
├── frontend/
│   └── react-client/
│       ├── src/
│       ├── public/
│       ├── package.json
│       └── Dockerfile
├── docker-compose.yml
└── README.md
```

## Technologies Used

### Backend
- Java 17
- Spring Boot 3.x
- Spring Data JPA
- Spring Cloud Gateway
- Spring Security with JWT
- PostgreSQL
- Maven
- JUnit & Mockito

### Frontend
- React 18
- React Router
- Axios
- Node.js 20

### DevOps
- Docker
- Docker Compose

## Getting Started

### Prerequisites
- JDK 17 or higher
- Maven 3.8+
- Node.js 20+ and npm
- Docker and Docker Compose (for containerized deployment)
- PostgreSQL (for local development without Docker)

## Running Locally (Without Docker)

### 1. Setup PostgreSQL Database

```bash
# Create databases
createdb userdb
createdb productdb
createdb authdb
```

### 2. Run Backend Services

```bash
# User Service
cd backend/user-service
mvn spring-boot:run

# Product Service
cd backend/product-service
mvn spring-boot:run

# Auth Service
cd backend/auth-service
mvn spring-boot:run

# API Gateway
cd backend/api-gateway
mvn spring-boot:run
```

### 3. Run Frontend

```bash
cd frontend/react-client
npm install
npm start
```

## Running with Docker

### Build and Run All Services

```bash
# Build and start all services
docker-compose up --build

# Run in detached mode
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f
```

### Access the Application

- **Frontend**: http://localhost:3000
- **API Gateway**: http://localhost:8080
- **User Service**: http://localhost:8081
- **Auth Service**: http://localhost:8082
- **Product Service**: http://localhost:8083
- **PostgreSQL**: localhost:5432

## API Endpoints

### User Service (via API Gateway: /api/users)

```
GET    /api/users        - Get all users
GET    /api/users/{id}   - Get user by ID
POST   /api/users        - Create new user
PUT    /api/users/{id}   - Update user
DELETE /api/users/{id}   - Delete user
```

### Product Service (via API Gateway: /api/products)

```
GET    /api/products        - Get all products
GET    /api/products/{id}   - Get product by ID
POST   /api/products        - Create new product
PUT    /api/products/{id}   - Update product
DELETE /api/products/{id}   - Delete product
```

### Auth Service (via API Gateway: /api/auth)

```
POST   /api/auth/register   - Register new user
POST   /api/auth/login      - Login user (returns JWT)
POST   /api/auth/refresh    - Refresh JWT token
```

## Testing

### Backend Tests

```bash
# Run tests for each service
cd backend/user-service
mvn test

cd backend/product-service
mvn test

cd backend/auth-service
mvn test
```

### Frontend Tests

```bash
cd frontend/react-client
npm test
```

## Features

### Backend Features
- ✅ RESTful API design
- ✅ JWT-based authentication
- ✅ Global exception handling
- ✅ Input validation
- ✅ Centralized logging
- ✅ JPA/Hibernate ORM
- ✅ Database migrations
- ✅ Unit and integration tests
- ✅ Docker support
- ✅ Environment-based configuration

### Frontend Features
- ✅ Modern React with hooks
- ✅ React Router for navigation
- ✅ Axios for API calls
- ✅ Reusable components
- ✅ Environment configuration
- ✅ Docker support
- ✅ Production-ready build

## Configuration

### Environment Variables

Each service can be configured using environment variables:

```bash
# Database Configuration
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/dbname
SPRING_DATASOURCE_USERNAME=postgres
SPRING_DATASOURCE_PASSWORD=postgres

# Service Ports
SERVER_PORT=8081

# JWT Configuration (Auth Service)
JWT_SECRET=your-secret-key
JWT_EXPIRATION=86400000
```

### Frontend Configuration (.env)

```bash
REACT_APP_API_BASE_URL=http://localhost:8080
```

## Docker Configuration

The `docker-compose.yml` orchestrates all services:

- **Networks**: All services communicate via a bridge network
- **Volumes**: Database data persists across restarts
- **Health Checks**: Services wait for dependencies
- **Auto-restart**: Services restart on failure

## Development Guidelines

### Code Quality
- Follow Java coding standards
- Use meaningful variable/method names
- Write unit tests for all business logic
- Document complex logic with comments
- Use DTOs for API requests/responses

### Git Workflow
1. Create feature branch from main
2. Make changes and commit frequently
3. Write descriptive commit messages
4. Create pull request for review
5. Merge after approval

## Troubleshooting

### Common Issues

**Port Already in Use**
```bash
# Check what's using the port
lsof -i :8080
# Kill the process
kill -9 <PID>
```

**Database Connection Failed**
- Verify PostgreSQL is running
- Check database credentials
- Ensure database exists

**Docker Issues**
```bash
# Remove all containers and volumes
docker-compose down -v

# Rebuild images
docker-compose build --no-cache
```

## Performance Optimization

- Use connection pooling for database
- Implement caching with Redis (future enhancement)
- Use async processing for heavy operations
- Optimize database queries with indexes
- Implement pagination for large datasets

## Security Considerations

- ✅ JWT token-based authentication
- ✅ Password encryption (BCrypt)
- ✅ Input validation and sanitization
- ✅ SQL injection prevention (JPA)
- ✅ CORS configuration
- ⚠️ HTTPS recommended for production
- ⚠️ Rate limiting recommended

## Future Enhancements

- [ ] Service discovery with Eureka
- [ ] Circuit breaker with Resilience4j
- [ ] Distributed tracing with Zipkin
- [ ] Centralized logging with ELK stack
- [ ] Redis caching
- [ ] Message queue with RabbitMQ/Kafka
- [ ] Kubernetes deployment
- [ ] CI/CD pipeline with Jenkins/GitHub Actions
- [ ] API documentation with Swagger/OpenAPI
- [ ] Monitoring with Prometheus & Grafana

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

Project Link: https://github.com/omkar-khot/springboot-microservices-react

## Acknowledgments

- Spring Boot Documentation
- React Documentation
- Docker Documentation
- PostgreSQL Documentation
