# Transactions Module

## Folder Structure

```text
lib/features/transactions/
├── data/
│   ├── models/
│   │   ├── transaction_header_model.dart
│   │   └── transaction_line_model.dart
│   └── repositories/
│       └── mock_transaction_repository.dart
├── domain/
│   ├── entities/
│   │   ├── transaction_header.dart
│   │   ├── transaction_line.dart
│   │   ├── transaction_status.dart
│   │   └── transaction_type.dart
│   ├── repositories/
│   │   └── transaction_repository.dart
│   └── usecases/
│       ├── approve_transaction.dart
│       ├── create_transaction.dart
│       ├── post_transaction.dart
│       └── update_transaction.dart
└── presentation/
    ├── bloc/
    │   ├── transaction_bloc.dart
    │   ├── transaction_event.dart
    │   └── transaction_state.dart
    └── pages/
        └── transaction_screen.dart
```

## Example Transaction Payload

```json
{
  "transactionId": "txn-20260423-001",
  "transactionType": "grn",
  "status": "draft",
  "warehouseId": "wh-main",
  "createdAt": "2026-04-23T12:00:00.000Z",
  "createdBy": "warehouse.supervisor",
  "notes": "Inbound chilled inventory",
  "referenceNumber": "GRN-2026-1402",
  "lines": [
    {
      "productId": "SKU-1001",
      "productName": "Chicken Breast Fillet",
      "quantity": 12.0,
      "unitPrice": 12.5,
      "totalPrice": 150.0,
      "unitOfMeasure": "kg",
      "batchNumber": "B-CH-241",
      "expiryDate": null,
      "metadata": {
        "temperatureZone": "cold"
      }
    },
    {
      "productId": "SKU-1002",
      "productName": "Mozzarella Cheese",
      "quantity": 4.0,
      "unitPrice": 36.0,
      "totalPrice": 144.0,
      "unitOfMeasure": "box",
      "batchNumber": "B-MZ-118",
      "expiryDate": null,
      "metadata": {
        "supplierRef": "SUP-8802"
      }
    }
  ]
}
```

## Example Data Flow

1. UI dispatches `AddLine`, `UpdateLineQuantity`, or `UpdateHeaderFields`.
2. `TransactionBloc` updates the in-memory editing state.
3. `SaveTransaction` calls `CreateTransaction` or `UpdateTransaction`.
4. `ApproveTransactionRequested` moves the header to `approved`.
5. `PostTransactionRequested` posts inventory movements through the repository.
6. Repository emits audit records and stock movements while keeping the UI isolated from data concerns.
