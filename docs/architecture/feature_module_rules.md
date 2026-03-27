# Feature Module Rules – MuthoBazar

## Feature Structure

Each feature inside apps must follow:


feature/
├── controllers/
├── pages/
├── widgets/
├── presenters/ (optional)
├── states/ (optional)
└── mappers/ (optional)


---

## Responsibilities

### controllers/
- manage UI state
- call repositories/workflows
- no business logic

---

### pages/
- compose UI
- bind controller

---

### widgets/
- reusable UI pieces (feature-level)

---

### presenters/
- UI formatting logic

---

### states/
- view models
- UI state containers

---

### mappers/
- convert models → UI data

---

## Repository Rule

❌ DO NOT create repositories inside features

Allowed only if:
- thin adapter
- UI query wrapper

Rename as:
- `*_screen_adapter.dart`
- `*_query_adapter.dart`

---

## Strict Rules

### Rule 1
Controllers are NOT services.

### Rule 2
No Firestore calls in UI.

### Rule 3
No business workflows in controllers.

### Rule 4
Controllers = coordination only.

---

## Flow Example

UI → Controller → Workflow → Repository → Firestore

---

## Anti-Patterns (Forbidden)

❌ Controller calling Firestore directly
❌ Business logic inside widget
❌ Repository inside feature
❌ Cross-feature imports

---

## Golden Rule

> Feature = UI + state + coordination
> NOT business logic