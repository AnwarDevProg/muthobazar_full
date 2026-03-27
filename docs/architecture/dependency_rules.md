# Dependency Rules – MuthoBazar

## Allowed Dependency Flow

apps/*
 → shared_ui
 → shared_core
 → shared_models
 → shared_services
 → shared_repositories
 → shared_workflows
 → shared_contracts
 → shared_usecases

---

shared_workflows
 → shared_repositories
 → shared_models
 → shared_core
 → shared_services
 → shared_contracts

---

shared_repositories
 → shared_models
 → shared_core
 → shared_contracts

---

shared_services
 → shared_core
 → shared_models (only if needed)

---

shared_ui
 → shared_core (light only)

---

## Forbidden Dependencies

❌ shared_* → apps/*
❌ shared_models → repositories
❌ shared_ui → repositories/workflows
❌ shared_repositories → workflows
❌ apps → other apps

---

## Critical Rules

### Rule 1
No shared package may import from apps.

### Rule 2
No UI layer may access repositories directly (must go through controller).

### Rule 3
No business logic inside apps.

### Rule 4
Repositories = data access only.

### Rule 5
Workflows = business logic only.

### Rule 6
If logic is used by multiple apps → move to shared.

---

## Backend Rules

- Sensitive operations → firebase/functions
- Client must NOT control:
  - stock
  - payments
  - refunds
  - permissions