# AutoParkIQ - Smart Parking Management System

## 🅿️ Project Overview

AutoParkIQ is an intelligent parking management system designed to efficiently handle vehicle entry/exit management, parking space allocation, and fee calculation for multi-floor parking lots. The system automatically assigns parking spots based on vehicle size and availability, tracks parking duration, and calculates fees upon exit.

## 🎯 Functional Requirements

### Core Features
- **Automatic Spot Allocation**: Assign available parking spots based on vehicle size (motorcycle, car, bus)
- **Check-In/Check-Out Management**: Record entry and exit times with ticket generation
- **Dynamic Fee Calculation**: Calculate fees based on duration and vehicle type
- **Real-Time Availability**: Update parking spot availability in real-time
- **Multi-Floor Support**: Handle multiple parking floors and spot types
- **Concurrency Handling**: Support multiple simultaneous vehicle operations

### Business Rules
- Vehicle size determines eligible spot types (motorcycle can park in any spot, car in car/large spots, bus only in large spots)
- Fee calculation based on hourly rates with different pricing for vehicle types
- Spot allocation follows configurable strategies (nearest first, random, etc.)
- Real-time tracking of parking lot capacity and availability

## 🏗️ System Architecture

### High-Level Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   REST API      │    │   Service       │    │   Repository    │
│   Controllers   │───▶│   Layer         │───▶│   Layer         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   DTOs &        │    │   Business      │    │   JPA           │
│   Validation    │    │   Logic         │    │   Entities      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                ▼                       ▼
                      ┌─────────────────┐    ┌─────────────────┐
                      │   Strategy      │    │   MySQL         │
                      │   Patterns      │    │   Database      │
                      └─────────────────┘    └─────────────────┘
```

### Design Patterns Used

#### 1. **Strategy Pattern**
- **ParkingSpotAllocationStrategy**: Different algorithms for spot allocation
  - `NearestSpotStrategy`: Allocate nearest available spot
  - `RandomSpotStrategy`: Random spot allocation
  - `FloorBasedStrategy`: Allocate by preferred floor

#### 2. **Factory Pattern**
- **VehicleFactory**: Create vehicle instances based on type
- **FeeCalculatorFactory**: Create appropriate fee calculators

#### 3. **Builder Pattern**
- **ParkingLotBuilder**: Configure parking lot with floors and spots
- **TicketBuilder**: Create parking tickets with validation

#### 4. **Repository Pattern**
- **Data Access Layer**: Abstract database operations
- **Custom Queries**: Optimized queries for spot allocation

#### 5. **Decorator Pattern**
- **FeeCalculatorDecorator**: Add additional charges (peak hours, holidays)

### Design Principles Applied

#### SOLID Principles
- **Single Responsibility**: Each class has one reason to change
- **Open/Closed**: Open for extension, closed for modification
- **Liskov Substitution**: Derived classes are substitutable for base classes
- **Interface Segregation**: Clients depend only on interfaces they use
- **Dependency Inversion**: Depend on abstractions, not concretions

#### Additional Principles
- **DRY (Don't Repeat Yourself)**: Eliminate code duplication
- **KISS (Keep It Simple, Stupid)**: Maintain simplicity
- **YAGNI (You Aren't Gonna Need It)**: Implement only required features

## 📊 Data Model

### Core Entities

#### Vehicle Hierarchy
```java
Vehicle (Abstract)
├── Motorcycle
├── Car  
└── Bus
```

#### Parking Infrastructure
```java
ParkingLot
├── List<ParkingFloor>
└── ParkingLotConfiguration

ParkingFloor
├── List<ParkingSpot>
└── FloorMetadata

ParkingSpot
├── SpotType (MOTORCYCLE, CAR, LARGE)
├── SpotStatus (AVAILABLE, OCCUPIED, MAINTENANCE)
└── Location details
```

#### Transaction Management
```java
ParkingTicket
├── Vehicle information
├── ParkingSpot assignment
├── Entry/Exit timestamps
├── Fee calculation
└── Payment status
```

### Database Schema
```sql
-- Core Tables
parking_lots (id, name, address, total_floors, created_at)
parking_floors (id, parking_lot_id, floor_number, total_spots)
parking_spots (id, floor_id, spot_number, spot_type, status, location_x, location_y)
vehicles (id, license_plate, vehicle_type, owner_info, created_at)
parking_tickets (id, vehicle_id, spot_id, entry_time, exit_time, total_fee, status)
payments (id, ticket_id, amount, payment_method, payment_time, status)

-- Configuration Tables
fee_configurations (id, vehicle_type, hourly_rate, daily_rate, created_at)
parking_rules (id, rule_type, rule_value, description, is_active)
```

## 🚀 API Endpoints

### Parking Operations
```http
POST   /api/v1/parking/entry          # Vehicle entry
POST   /api/v1/parking/exit           # Vehicle exit and payment
GET    /api/v1/parking/status/{plate} # Check parking status
```

### Real-time Information
```http
GET    /api/v1/parking/availability    # Current availability
GET    /api/v1/parking/floors/{id}     # Floor-wise availability
GET    /api/v1/parking/spots/{type}    # Available spots by type
```

### Administration
```http
POST   /api/v1/admin/parking-lot      # Create parking lot
PUT    /api/v1/admin/spots/{id}       # Update spot status
GET    /api/v1/admin/reports/daily    # Daily reports
GET    /api/v1/admin/revenue          # Revenue analytics
```

## 🔧 Technology Stack

### Backend Framework
- **Spring Boot 3.5.7**: Main application framework
- **Spring Data JPA**: Data persistence layer
- **Spring Web**: REST API development
- **Spring Security**: Authentication and authorization (future)

### Database
- **MySQL 8.0**: Primary database
- **HikariCP**: Connection pooling
- **Flyway**: Database migration (future)

### Development Tools
- **Lombok**: Reduce boilerplate code
- **Maven**: Build and dependency management
- **JUnit 5**: Unit and integration testing
- **Mockito**: Mocking framework

### Observability
- **Spring Actuator**: Application monitoring
- **Micrometer**: Metrics collection
- **SLF4J + Logback**: Logging

## 🛠️ Development Setup

### Prerequisites
- Java 17 or higher
- Maven 3.6+
- MySQL 8.0+
- IDE (IntelliJ IDEA/Eclipse)

### Local Development
```bash
# Clone repository
git clone <repository-url>
cd AutoParkIQ

# Configure database
mysql -u root -p
CREATE DATABASE autoparkiq_db;

# Update application.properties with your DB credentials
# Run application
mvn spring-boot:run

# Application will start on http://localhost:8089
```

### Database Configuration
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/autoparkiq_db
spring.datasource.username=root
spring.datasource.password=your_password
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
```

## 🧪 Testing Strategy

### Unit Tests
- Service layer business logic
- Repository layer data access
- Utility classes and algorithms

### Integration Tests
- REST API endpoints
- Database operations
- End-to-end parking scenarios

### Performance Tests
- Concurrent vehicle entry/exit
- Spot allocation under load
- Database query optimization

## 📋 Implementation Plan

### Phase 1: Core Infrastructure
1. ✅ Project setup and configuration
2. 🔄 Domain model and entities
3. 🔄 Database schema and repositories
4. 🔄 Basic service layer

### Phase 2: Business Logic
5. 🔄 Spot allocation algorithms
6. 🔄 Fee calculation logic
7. 🔄 Parking operations service
8. 🔄 Concurrency handling

### Phase 3: API Development
9. 🔄 REST controllers
10. 🔄 Error handling and validation
11. 🔄 API documentation
12. 🔄 Integration tests

### Phase 4: Advanced Features
13. ⏳ Real-time updates
14. ⏳ Reporting and analytics
15. ⏳ Performance optimization
16. ⏳ Security implementation

## 🔒 Concurrency Handling

### Strategies Implemented
- **Optimistic Locking**: JPA version-based locking for entities
- **Database Transactions**: ACID compliance for parking operations
- **Synchronized Methods**: Critical section protection for spot allocation
- **AtomicOperations**: Thread-safe counters and status updates

### Race Condition Prevention
- Spot allocation atomicity
- Payment processing integrity
- Real-time availability consistency

## 📈 Performance Considerations

### Database Optimization
- Proper indexing on frequently queried columns
- Connection pooling for concurrent access
- Query optimization for spot searches

### Caching Strategy
- Redis for real-time availability (future)
- Application-level caching for configuration data
- Database query result caching

### Scalability
- Stateless service design
- Horizontal scaling capability
- Load balancing support

## 🚦 Future Enhancements

### Short Term
- [ ] Mobile app integration APIs
- [ ] Payment gateway integration
- [ ] Email/SMS notifications
- [ ] Advanced reporting dashboard

### Long Term
- [ ] AI-based predictive parking
- [ ] IoT sensor integration
- [ ] Multi-location support
- [ ] Microservices architecture

## 📚 Documentation

### API Documentation
- Swagger/OpenAPI 3.0 integration
- Interactive API explorer
- Request/response examples

### Code Documentation
- Comprehensive JavaDoc
- Architecture decision records (ADRs)
- Development guidelines

## 🤝 Contributing

### Development Workflow
1. Fork the repository
2. Create feature branch
3. Implement changes with tests
4. Submit pull request
5. Code review and merge

### Code Standards
- Google Java Style Guide
- 80% minimum test coverage
- Comprehensive documentation
- Security best practices

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📧 Contact

For questions or support, please contact: [your-email@example.com]

---

**AutoParkIQ** - Making parking intelligent, one spot at a time! 🅿️✨