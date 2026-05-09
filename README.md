# pos_system

Flutter foundation for an Inventory Management System with POS integration, dashboard-driven operations, and audit-first business design.

## Current Scope

- Single dashboard ERP-style Flutter app
- Feature-based Clean Architecture structure
- Material 3 light/dark enterprise theme
- Inventory, PO, POS, GRN, production, waste, stock count, and audit scaffolding

## Business Logic Reference

The core business rules for inventory + POS correctness live in:

- [docs/inventory_pos_business_logic.md](docs/inventory_pos_business_logic.md)

This document defines:

- PO -> GRN -> Stock -> Production -> Waste -> POS flow
- FIFO and weighted average costing rules
- stock movement audit requirements
- POS reconciliation rules
- edge-case handling for partial receipts, cancelled PO after receipt, negative stock prevention, and sync failures

## Domain Building Blocks Added

Shared domain entities and services now include:

- stock costing methods
- stock movement model
- audit log entry model
- domain event model
- reconciliation issue model
- inventory policy service
- inventory event factory

These are intended as the business-rule base for future repository and backend integration work.
