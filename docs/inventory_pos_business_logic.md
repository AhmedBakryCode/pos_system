# Inventory + POS Business Logic

## Core Flow

```text
Purchase Order
-> Goods Receipt Note
-> Available Stock
-> Production Consumption / Production Output
-> Waste Posting
-> POS Sales / Returns
-> Audit + Reconciliation
```

The system must treat stock as a ledger, not as a mutable counter only. Every inventory-affecting action creates:

1. a business transaction
2. one or more stock movements
3. an audit event

## System Rules

### 1. Purchase Orders

- A `PO` reserves expected inbound quantity only. It does not increase on-hand stock.
- A PO can be `draft`, `approved`, `partially_received`, `fully_received`, `cancelled`, or `closed`.
- After any GRN is posted, the PO can no longer be hard-cancelled.
- If cancellation is needed after partial receipt, the system cancels only the unreceived balance.

### 2. GRN Posting

- A `GRN` creates real inbound stock.
- Each GRN line references:
  - PO line if applicable
  - product
  - warehouse
  - quantity received
  - unit cost
  - batch or lot metadata where required
- Partial receipt is allowed.
- Over-receipt is blocked unless the user has an explicit override permission and the variance is audit-logged.
- A GRN updates:
  - stock batches
  - stock ledger
  - inventory valuation
  - PO receiving status

### 3. Stock Availability

- `OnHand` = physically posted stock in inventory.
- `Reserved` = stock committed to open production, transfers, or validated outbound requests.
- `Available` = `OnHand - Reserved`.
- POS and production consume from `Available`, never from raw `OnHand`.

### 4. Production

- Starting production creates a reservation for required raw materials.
- Releasing materials posts actual consumption movements.
- Finishing production posts finished goods inbound movements.
- Any loss, spoilage, or yield variance must be posted separately as waste or production variance.

### 5. Waste

- Waste always reduces on-hand stock and must have:
  - reason code
  - user
  - warehouse
  - timestamp
  - financial impact
- Waste cannot bypass stock validation rules.
- If waste would create negative stock, the transaction is blocked unless a controlled override flow exists.

### 6. POS Sales

- Completed POS orders reduce stock only after the order reaches a stock-impacting status such as `paid`, `served`, or `fulfilled`.
- Voided, draft, or suspended POS orders do not reduce stock.
- Returns create reverse inventory movements when goods are physically returned to inventory.
- Duplicate POS event ingestion must be prevented using idempotency keys.

## Stock Calculation Methods

### FIFO

- Each GRN creates or updates a cost layer.
- Outbound stock is consumed from the oldest available cost layer first.
- FIFO is best for:
  - expiry-sensitive goods
  - food and beverage
  - audit-friendly cost traceability

FIFO sale issue example:

```text
Layer A: 10 units @ 5.00
Layer B: 20 units @ 6.00

Sale of 12 units
-> consume 10 from Layer A
-> consume 2 from Layer B
COGS = (10 * 5.00) + (2 * 6.00)
```

### Weighted Average Cost

- Each inbound GRN recalculates unit cost:

```text
new_average_cost =
((current_qty * current_avg_cost) + (received_qty * received_cost))
/ (current_qty + received_qty)
```

- Outbound movements use the current average cost at posting time.
- Weighted average is simpler operationally but less traceable than FIFO for physical batch consumption.

### Method Rule

- Choose one accounting method per legal entity or warehouse policy.
- Do not mix FIFO and weighted average for the same stock ledger scope.
- For F&B, use FIFO for batch-managed goods and allow weighted average only where finance policy permits it.

## Audit System

### Every stock movement must capture

- movement id
- event id
- transaction id
- source module
- product id
- warehouse id
- quantity in or out
- valuation method used
- unit cost
- before quantity
- after quantity
- user or system actor
- device or integration source
- created timestamp

### User action logging

Log:

- create, edit, approve, cancel, post, reverse
- before and after values for sensitive changes
- permission overrides
- sync retries and manual interventions

### POS vs Inventory mismatch detection

Detect mismatches when:

- POS sale exists but no inventory movement exists after sync window
- inventory movement exists with no POS order reference
- POS quantity differs from posted stock deduction
- return posted in POS but not returned to stock

### Reconciliation rules

- reconcile by `pos_order_id`, `branch_id`, `business_date`, `product_id`
- tolerance must be zero for quantity mismatches unless a formal variance rule exists
- if mismatch remains unresolved after SLA:
  - raise audit exception
  - freeze auto-close of the business date
  - require manual review

## Data Consistency Rules

- Never update stock totals directly without a stock movement row.
- Never delete posted financial or stock events; use reversal events.
- Every outbound movement must reference a valid stock source according to costing policy.
- Every integration event must be idempotent.
- Every aggregate stock balance must be derivable from the ledger.
- Local offline writes must be assigned sync state: `pending`, `synced`, `failed`, `conflict`.

## Edge Cases

### Partial GRN receipt

- PO remains `partially_received`.
- only received quantity becomes stock
- remaining quantity stays open
- costing applies only to received quantity

### Cancelled PO after GRN

- disallow full cancel if any quantity already received
- system changes state to `partially_received_cancelled_remainder`
- remaining open quantity becomes zero
- received stock remains valid unless separately returned

### Negative stock prevention

- block outbound movement if `available < requested`
- allow override only via privileged emergency flow
- every override creates critical audit event and reconciliation task

### POS sync failure

- queue POS event locally or in integration inbox
- mark affected order as `inventory_pending`
- prevent silent data loss
- reprocess until success or manual escalation
- if retry window expires, create audit discrepancy alert

## Suggested Backend Structure

```text
backend/
├── modules/
│   ├── purchase_orders/
│   ├── goods_receipts/
│   ├── inventory/
│   ├── production/
│   ├── waste/
│   ├── pos_integration/
│   └── audit/
├── shared/
│   ├── events/
│   ├── auth/
│   ├── permissions/
│   ├── idempotency/
│   └── reconciliation/
├── projections/
│   ├── stock_balance_projection
│   ├── stock_valuation_projection
│   └── audit_exception_projection
└── jobs/
    ├── pos_reconciliation_job
    ├── sync_retry_job
    └── audit_exception_job
```

Recommended storage model:

- `stock_movements`
- `stock_batches`
- `inventory_balances`
- `purchase_orders`
- `purchase_order_lines`
- `grns`
- `grn_lines`
- `production_orders`
- `waste_records`
- `pos_orders`
- `integration_events`
- `audit_events`
- `reconciliation_cases`

## Event-Driven Approach

Recommended domain events:

- `PurchaseOrderApproved`
- `GoodsReceiptPosted`
- `StockReserved`
- `ProductionStarted`
- `ProductionConsumed`
- `ProductionCompleted`
- `WastePosted`
- `PosOrderCompleted`
- `PosOrderReturned`
- `StockMovementPosted`
- `InventorySyncFailed`
- `AuditMismatchDetected`

Processing model:

```text
Command
-> validate business rules
-> persist transaction
-> append domain event
-> generate stock movements
-> update projections
-> trigger reconciliation/audit checks
```

Why event-driven:

- better auditability
- easier integration with POS
- safer retries via idempotent event handling
- clean separation between write model and reporting projections

## Recommended Final Policy

- inventory is ledger-driven
- posted events are immutable
- reversals are explicit
- outbound stock respects availability and costing policy
- POS integration is idempotent and reconciled
- audit exceptions are first-class records, not logs only
