# Package Boundaries – MuthoBazar

## Core Principle
Every file must answer:

> "Am I app-specific, shared reusable, or backend?"

If unclear → wrong placement.

---

## App Packages

### apps/customer_app
Owns:
- routes, bindings, middleware
- shell, startup flow
- controllers, pages, widgets
- UI state

Must NOT contain:
- repositories
- business workflows
- Firestore logic

---

### apps/staff_app
Owns:
- staff UI (rider, technician, ops)
- role-based flows
- task screens

Must NOT contain:
- business logic
- workflow engines
- database rules

---

### apps/admin_web
Owns:
- admin UI (dashboard, tables, filters)
- operations screens
- permission-based UI

Must NOT contain:
- business rules
- transaction logic
- inventory/order engine

---

## Shared Packages

### shared_core
- constants, enums, helpers
- Firebase wrappers
- base utilities

❌ No business logic

---

### shared_models
- entities (Product, Order, Stock, etc.)
- serialization

❌ No logic

---

### shared_contracts
- API / Cloud Function payloads
- request/response DTOs

---

### shared_repositories
- Firestore queries
- CRUD operations

❌ No workflows

---

### shared_services
- reusable utilities (upload, export, analytics)

---

### shared_workflows
- business orchestration
- multi-step logic
- lifecycle rules

---

### shared_ui
- theme, colors, spacing
- reusable widgets

❌ No logic

---

### shared_usecases (optional)
- explicit business actions
- thin layer over workflows

---

### shared_testkit
- testing utilities only

---

## Firebase Layer

### firebase/functions
- secure backend logic
- privileged operations

### firestore.rules
- access control only

---

## Ownership Summary

| Concern | Location |
|--------|--------|
| UI | apps / shared_ui |
| Models | shared_models |
| Data access | shared_repositories |
| Business logic | shared_workflows |
| Utilities | shared_services |
| Backend secure ops | firebase/functions |