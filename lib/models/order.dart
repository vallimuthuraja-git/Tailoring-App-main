import 'package:flutter/material.dart';

enum OrderStatus {
  pending,
  confirmed,
  inProgress,
  assigned,        // Order assigned to employee
  inProduction,    // Employee working on order
  qualityCheck,    // Under quality review
  readyForFitting,
  completed,
  delivered,
  cancelled
}

extension OrderStatusExtension on OrderStatus {
  String get statusText {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.assigned:
        return 'Assigned to Employee';
      case OrderStatus.inProduction:
        return 'In Production';
      case OrderStatus.qualityCheck:
        return 'Quality Check';
      case OrderStatus.readyForFitting:
        return 'Ready for Fitting';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.inProgress:
      case OrderStatus.assigned:
      case OrderStatus.inProduction:
        return Colors.purple;
      case OrderStatus.qualityCheck:
        return Colors.amber;
      case OrderStatus.readyForFitting:
        return Colors.teal;
      case OrderStatus.completed:
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded
}

class Order {
  final String id;
  final String customerId;
  final List<OrderItem> items;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final double totalAmount;
  final double advanceAmount;
  final double remainingAmount;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String? specialInstructions;
  final Map<String, dynamic> measurements;
  final List<String> orderImages;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Employee Assignment Fields
  final String? assignedEmployeeId;
  final String? assignedEmployeeName;
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic> workAssignments; // Employee assignments for this order

  Order({
    required this.id,
    required this.customerId,
    required this.items,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.advanceAmount,
    required this.remainingAmount,
    required this.orderDate,
    this.deliveryDate,
    this.specialInstructions,
    required this.measurements,
    required this.orderImages,
    required this.createdAt,
    required this.updatedAt,
    this.assignedEmployeeId,
    this.assignedEmployeeName,
    this.assignedAt,
    this.startedAt,
    this.completedAt,
    Map<String, dynamic>? workAssignments,
  }) : workAssignments = workAssignments ?? {};

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerId: json['customerId'],
      items: (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList(),
      status: OrderStatus.values[json['status']],
      paymentStatus: PaymentStatus.values[json['paymentStatus']],
      totalAmount: json['totalAmount'].toDouble(),
      advanceAmount: json['advanceAmount'].toDouble(),
      remainingAmount: json['remainingAmount'].toDouble(),
      orderDate: DateTime.parse(json['orderDate']),
      deliveryDate: json['deliveryDate'] != null ? DateTime.parse(json['deliveryDate']) : null,
      specialInstructions: json['specialInstructions'],
      measurements: Map<String, dynamic>.from(json['measurements'] ?? {}),
      orderImages: List<String>.from(json['orderImages'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      assignedEmployeeId: json['assignedEmployeeId'],
      assignedEmployeeName: json['assignedEmployeeName'],
      assignedAt: json['assignedAt'] != null ? DateTime.parse(json['assignedAt']) : null,
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      workAssignments: Map<String, dynamic>.from(json['workAssignments'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status.index,
      'paymentStatus': paymentStatus.index,
      'totalAmount': totalAmount,
      'advanceAmount': advanceAmount,
      'remainingAmount': remainingAmount,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'specialInstructions': specialInstructions,
      'measurements': measurements,
      'orderImages': orderImages,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'assignedEmployeeId': assignedEmployeeId,
      'assignedEmployeeName': assignedEmployeeName,
      'assignedAt': assignedAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'workAssignments': workAssignments,
    };
  }

  // Helper getters for easier access
  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.assigned:
        return 'Assigned to Employee';
      case OrderStatus.inProduction:
        return 'In Production';
      case OrderStatus.qualityCheck:
        return 'Quality Check';
      case OrderStatus.readyForFitting:
        return 'Ready for Fitting';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  // This will need to be populated from customer data
  String get customerName => 'Customer'; // Placeholder - will be set by provider
}

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String category;
  final double price;
  final int quantity;
  final Map<String, dynamic> customizations;
  final String? notes;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.category,
    required this.price,
    required this.quantity,
    required this.customizations,
    this.notes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      category: json['category'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      customizations: Map<String, dynamic>.from(json['customizations'] ?? {}),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'category': category,
      'price': price,
      'quantity': quantity,
      'customizations': customizations,
      'notes': notes,
    };
  }
}
