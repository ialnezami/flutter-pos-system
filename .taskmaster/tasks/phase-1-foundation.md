# Phase 1: Foundation Setup (Weeks 1-4)

## Overview
This phase establishes the core foundation for the offline-first Flutter POS application, including project setup, database architecture, authentication, and basic UI framework.

---

## Task 1: Project Setup & Core Dependencies
**Priority:** High  
**Dependencies:** None  
**Status:** Pending

### Description
Initialize Flutter project, configure `pubspec.yaml` with all core dependencies (Drift, Riverpod, Mobile Scanner, etc.), and set up basic project structure (e.g., `lib/src/core`, `lib/src/features`).

### Implementation Details
- Ensure `build_runner` is configured for Drift code generation
- Verify `sqlcipher_flutter_libs` is correctly integrated for database encryption
- Establish a clean architecture base (data, domain, presentation layers)
- Configure development environment and tooling

### Test Strategy
- Verify `pubspec.yaml` dependencies resolve successfully
- Run `flutter doctor` to ensure all development environment requirements are met
- Confirm a basic `main.dart` runs without errors on target platforms

---

## Task 2: Database Schema Implementation (Drift)
**Priority:** High  
**Dependencies:** Task 1  
**Status:** Pending

### Description
Implement the core database schema using Drift, including `Products`, `Sales`, `SaleItems`, `PaymentMethods`, `Categories`, `Customers`, `Users`, `AuditLog`, and `SyncQueue` tables as defined in the RPD.

### Implementation Details
- Use `drift` annotations for table definitions, ensuring proper data types and constraints
- Integrate `sqlcipher` for at-rest data encryption
- Define foreign key relationships and indices for performance
- Implement database migration system

### Test Strategy
- Write unit tests for `AppDatabase` to ensure tables are created correctly and relationships are defined
- Verify `sqlcipher` initialization and basic CRUD operations on a test database instance

---

## Task 3: Authentication System (PIN-based)
**Priority:** High  
**Dependencies:** Task 2  
**Status:** Pending

### Description
Implement user authentication with PIN-based login. This includes user registration (for admin), secure PIN hashing, and session management.

### Implementation Details
- Create `AuthRepository` and `AuthService` using Riverpod for state management
- Implement secure PIN hashing (e.g., bcrypt or similar)
- Develop UI for login, logout, and initial admin user setup
- Manage user sessions securely

### Test Strategy
- Write unit tests for `AuthRepository` (login, logout, PIN hashing, session management)
- Develop widget tests for the login screen UI
- Implement integration tests for a complete successful login and logout flow

---

## Task 4: Role-Based Access Control (RBAC)
**Priority:** High  
**Dependencies:** Task 3  
**Status:** Pending

### Description
Implement role-based access control (Admin, Manager, Cashier, Stock Manager) with granular permissions for different features and actions.

### Implementation Details
- Extend the `users` table with `role` and `permissions` fields (e.g., JSON array for permissions)
- Create a `PermissionService` to check user permissions before accessing specific features or performing sensitive actions
- Integrate with UI to enable/disable features based on role

### Test Strategy
- Write unit tests for `PermissionService` to verify role-permission mappings and access checks
- Develop widget tests to ensure UI elements (buttons, menu items) are correctly hidden or shown based on the logged-in user's role

---

## Phase 1 Deliverables
- [ ] Complete Flutter project setup with all dependencies
- [ ] Functional database schema with encryption
- [ ] Working authentication system
- [ ] Role-based access control implementation
- [ ] Basic project architecture established

## Success Criteria
- Project builds and runs without errors
- Database tables are created successfully with proper relationships
- Users can authenticate with PIN-based login
- Different user roles have appropriate access permissions
- Foundation is ready for Phase 2 development
