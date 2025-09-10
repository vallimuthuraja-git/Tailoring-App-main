# Comprehensive Backend Architecture Design for Service Ordering System

## Overview

This document outlines a comprehensive backend architecture for the tailoring service ordering system, built on Firebase with Flutter frontend. The design addresses identified gaps in data persistence, enhanced queries, proper error handling, security, scalability, and offline support.

## Current State Analysis

### Existing Collections
- `users` - User authentication and roles
- `customers` - Customer profiles with measurements and preferences
- `orders` - Order data with status tracking and payment information
- `products` - Service catalog items
- `measurements` - Customer measurement data
- `notifications` - Notification system
- `chat` - Customer support chat system

### Identified Gaps
1. **Security**: Basic authentication-only access control, no role-based permissions
2. **Performance**: No compound indexes for efficient queries
3. **Offline Support**: No explicit offline capabilities designed
4. **Business Logic**: Limited server-side processing (all client-side)
5. **Scalability**: No sharding strategy or data optimization
6. **Integration**: No external service integrations (payment gateways, SMS)

## Architecture Design

### Entity Relationship Diagram (Text Format)

```
+----------------+     +----------------+     +------------------+
|    Customer    | --> |     Order      | <-- |   Order Item     |
+----------------+     +----------------+     +------------------+
        |                 |       |                    |
        |                 |       |                    |
        v                 v       v                    v
+----------------+     +----------------+     +------------------+
|  Measurements  |     |   Payment      |     |     Product      |
+----------------+     +----------------+     +------------------+
        ^                 |       |
        |                 |       |
        +-----------------+       v
                    +------------------+
                    |  Notification    |
                    +------------------+
                              |
                              v
                    +------------------+
                    |    Employee      |
                    +------------------+
```

### Detailed Collection Schemas

#### 1. Users Collection (`/users/{userId}`)
```json
{
  "userId": "string (Firebase Auth UID)",
  "email": "string",
  "displayName": "string",
  "photoUrl": "string?",
  "role": "enum (customer,employee,admin)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "preferences": {
    "notifications": "boolean",
    "language": "string",
    "timezone": "string"
  },
  "stats": {
    "totalOrders": "integer",
    "loyaltyPoints": "integer",
    "averageRating": "float"
  },
  "metadata": {
    "lastLogin": "timestamp",
    "deviceInfo": "object",
    "ipAddress": "string"
  }
}
```

#### 2. Customers Collection (`/customers/{customerId}`)
```json
{
  "customerId": "string",
  "userId": "string (references users)",
  "personalInfo": {
    "name": "string",
    "email": "string",
    "phone": "string",
    "dateOfBirth": "timestamp?",
    "gender": "enum?"
  },
  "measurements": {
    "chest": "float?",
    "waist": "float?",
    "hips": "float?",
    "length": "float?",
    "shoulder": "float?",
    "sleeve": "float?",
    "inseam": "float?",
    "customMeasurements": "map<string,float>"
  },
  "preferences": {
    "preferredServices": "array<string>",
    "fabricPreferences": "array<string>",
    "budgetRange": "map<float>",
    "urgencyLevel": "enum"
  },
  "loyalty": {
    "tier": "enum (bronze,silver,gold,platinum)",
    "points": "integer",
    "totalSpent": "float",
    "joinDate": "timestamp"
  },
  "addressBook": "array<Address>",
  "emergencyContact": {
    "name": "string?",
    "phone": "string?",
    "relationship": "string?"
  },
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### 3. Orders Collection (`/orders/{orderId}`)
```json
{
  "orderId": "string",
  "customerId": "string (references customers)",
  "assignedEmployeeId": "string? (references employees)",
  "serviceItems": "array<OrderServiceItem>",
  "customItems": "array<OrderCustomItem>",
  "measurements": "map<string,dynamic>",
  "pricing": {
    "subtotal": "float",
    "discounts": "array<Discount>",
    "taxes": "array<Tax>",
    "totalAmount": "float",
    "advanceRequired": "float",
    "remainingAmount": "float"
  },
  "timeline": {
    "orderDate": "timestamp",
    "deliveryDate": "timestamp?",
    "urgent": "boolean"
  },
  "status": {
    "current": "enum",
    "history": "array<StatusHistory>",
    "lastUpdated": "timestamp"
  },
  "payment": {
    "status": "enum (pending,partially_paid,paid,refunded,failed)",
    "transactions": "array<PaymentTransaction>",
    "method": "string",
    "gatewayId": "string?"
  },
  "attachments": {
    "images": "array<ImageReference>",
    "documents": "array<DocumentReference>"
  },
  "specialInstructions": "string?",
  "workAssignments": "map<string,dynamic>",
  "qualityChecks": "array<QualityCheck>",
  "feedback": {
    "rating": "integer?",
    "comments": "string?",
    "submittedAt": "timestamp?"
  },
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### 4. Services Collection (`/services/{serviceId}`)
```json
{
  "serviceId": "string",
  "name": "string",
  "category": "enum",
  "type": "enum",
  "pricing": {
    "basePrice": "float",
    "tierPricing": "map<string,float>",
    "minPrice": "float?",
    "maxPrice": "float?"
  },
  "capacity": {
    "dailyLimit": "integer",
    "queueLimit": "integer",
    "currentQueue": "integer"
  },
  "requirements": {
    "materials": "array<string>",
    "tools": "array<string>",
    "skills": "array<string>",
    "experience": "integer"
  },
  "scheduling": {
    "estimatedDuration": "integer (minutes)",
    "bufferTime": "integer (minutes)",
    "leadTime": "integer (days)"
  },
  "isActive": "boolean",
  "isPopular": "boolean",
  "rating": {
    "average": "float",
    "count": "integer",
    "distribution": "map<string,integer>"
  },
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### 5. Employees Collection (`/employees/{employeeId}`)
```json
{
  "employeeId": "string",
  "userId": "string (references users)",
  "personalInfo": {
    "name": "string",
    "email": "string",
    "phone": "string"
  },
  "professional": {
    "specializations": "array<string>",
    "experience": "integer (years)",
    "certifications": "array<string>",
    "skillLevel": "enum"
  },
  "schedule": {
    "workingHours": "map<string,string>",
    "availability": "array<string>",
    "exceptions": "array<DateException>"
  },
  "workload": {
    "currentOrders": "integer",
    "capacity": "integer",
    "utilization": "float"
  },
  "performance": {
    "rating": "float",
    "completedOrders": "integer",
    "averageTurnaround": "integer (days)",
    "customerFeedback": "float"
  },
  "status": "enum (active,on_leave,inactive)",
  "location": "geoPoint?",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### 6. Notifications Collection (`/notifications/{notificationId}`)
```json
{
  "notificationId": "string",
  "recipientId": "string",
  "type": "enum",
  "priority": "enum (low,medium,high,urgent)",
  "title": "string",
  "message": "string",
  "data": "map<string,dynamic>",
  "channels": "array<enum> (in_app,sms,email,push)",
  "status": {
    "sent": "boolean",
    "delivered": "boolean",
    "read": "boolean",
    "sentAt": "timestamp?",
    "deliveredAt": "timestamp?",
    "readAt": "timestamp?"
  },
  "expiry": "timestamp?",
  "createdAt": "timestamp"
}
```

## Cloud Functions Architecture

### Business Logic Functions

#### 1. Order Processing Function
```typescript
export const processOrder = functions.firestore
  .document('orders/{orderId}')
  .onCreate(async (snap, context) => {
    const orderData = snap.data();
    const orderId = context.params.orderId;

    // Validate order data
    // Assign employee based on workload and skills
    // Create payment intent for advance payment
    // Send confirmation notifications
    // Update customer statistics
  });
```

#### 2. Payment Processing Function
```typescript
export const processPayment = functions.firestore
  .document('payments/{paymentId}')
  .onCreate(async (snap, context) => {
    const paymentData = snap.data();

    // Validate payment amount with Stripe/PayPal
    // Update order payment status
    // Send payment confirmation notifications
    // Trigger inventory updates for materials
  });
```

#### 3. Employee Assignment Function
```typescript
export const assignEmployee = functions.firestore
  .document('orders/{orderId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Check if status changed to 'confirmed' or 'assigned'
    // Find best employee based on skills, workload, location
    // Update employee workload
    // Send assignment notifications
  });
```

### Scheduled Functions

#### Cleanup Function
```typescript
export const dailyCleanup = functions.pubsub
  .schedule('0 0 * * *')  // Daily at midnight
  .onRun(async () => {
    // Clean up expired sessions
    // Update order statuses based on due dates
    // Generate daily reports
    // Clean up old notifications
  });
```

### HTTP Endpoints

#### External API Integration
```typescript
export const stripeWebhook = functions.https.onRequest(async (req, res) => {
  // Handle Stripe webhook for payment confirmations
  // Update payment status in Firestore
  // Send appropriate notifications
});
```

## Firestore Security Rules

### Role-Based Access Control

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    function hasRole(role) {
      return isAuthenticated() &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == role;
    }

    function canAccessCustomerData(customerId) {
      return isOwner(customerId) ||
        hasRole('admin') ||
        hasRole('employee');
    }

    function canAccessOrder(orderId) {
      return isAuthenticated() &&
        (get(/databases/$(database)/documents/orders/$(orderId)).data.customerId == request.auth.uid ||
         hasRole('admin') ||
         hasRole('employee'));
    }

    // Users collection
    match /users/{userId} {
      allow read: if isOwner(userId) || hasRole('admin');
      allow write: if isOwner(userId) || hasRole('admin');
    }

    // Customers collection
    match /customers/{customerId} {
      allow read: if canAccessCustomerData(customerId);
      allow write: if isOwner(customerId) && isAuthenticated() ||
        hasRole('admin') || hasRole('employee');
    }

    // Orders collection
    match /orders/{orderId} {
      allow read: if canAccessOrder(orderId);
      allow create: if isAuthenticated() && request.auth.uid == resource.data.customerId;
      allow update: if hasRole('admin') || hasRole('employee') ||
        (isOwner(resource.data.customerId) && resource.data.status < 2); // Only pending/confirmed status
      allow delete: if hasRole('admin');
    }

    // Services collection - read-only for customers, full access for employees/admins
    match /services/{serviceId} {
      allow read: if isAuthenticated();
      allow write: if hasRole('admin') || hasRole('employee');
    }

    // Employees collection
    match /employees/{employeeId} {
      allow read: if isAuthenticated();
      allow write: if hasRole('admin') || isOwner(employeeId);
    }

    // Notifications collection
    match /notifications/{notificationId} {
      allow read, write: if true; // Controlled by Cloud Functions
    }

    // Chat collection
    match /chat/{conversationId}/messages/{messageId} {
      allow read: if canAccessOrder(conversationId) || hasRole('admin');
      allow write: if canAccessOrder(conversationId) || hasRole('admin');
    }

    // Reject all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## Offline Synchronization Architecture

### Offline-First Design Principles

1. **Local Storage Strategy**
   - Use Firestore offline persistence
   - Implement local state management with Redux/MobX
   - Cache frequently accessed data (services, user profile)

2. **Conflict Resolution**
   - Last-write-wins for simple fields
   - Field-level merging for complex updates
   - Manual resolution for conflicting assignments

3. **Queue Management**
   - Implement offline queue for mutations
   - Automatic retry on reconnection
   - Queue prioritization (payments first, then status updates)

### Implementation Strategy

```typescript
// Firestore offline configuration
const db = firebase.firestore();
db.enablePersistence({
  synchronizeTabs: true
}).catch((err) => {
  console.error('Persistence failed:', err);
});

// Connection status monitoring
const connectionRef = db.doc('.info/connected');
connectionRef.onSnapshot((doc) => {
  const connected = doc.data()?.connected;
  if (connected) {
    // Process queued mutations
    processOfflineQueue();
  }
});
```

## Database Performance Optimization

### Compound Indexes Configuration

```json
{
  "indexes": [
    {
      "collectionGroup": "orders",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "customerId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "orders",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "assignedEmployeeId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "services",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "category",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "isActive",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "rating.average",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "customers",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "loyalty.tier",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "totalSpent",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "employees",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "workload.utilization",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "performance.rating",
          "order": "DESCENDING"
        }
      ]
    }
  ],
  "fieldOverrides": [
    {
      "collectionGroup": "orders",
      "fieldPath": "status",
      "indexes": [
        {
          "order": "ASCENDING",
          "queryScope": "COLLECTION"
        },
        {
          "order": "DESCENDING",
          "queryScope": "COLLECTION"
        }
      ]
    }
  ]
}
```

### Query Optimization Patterns

1. **Pagination Implementation**
```typescript
const query = db.collection('orders')
  .where('customerId', '==', userId)
  .orderBy('createdAt', 'desc')
  .limit(10);

const snapshot = await query.get();
const lastDoc = snapshot.docs[snapshot.docs.length - 1];
```

2. **Composite Queries for Analytics**
```typescript
const orderStatsQuery = db.collection('orders')
  .where('createdAt', '>=', startDate)
  .where('createdAt', '<=', endDate)
  .where('status', '==', 'completed')
  .orderBy('createdAt');
```

## Scalability Design

### Data Partitioning Strategy

1. **Time-based Partitioning**
   - Orders partitioned by month/year
   - Analytics data aggregated at different granularities
   - Archival strategy for old data

2. **Geographic Distribution**
   - Employee assignment based on location
   - Regional service offerings
   - Multi-region deployment for Firebase

3. **Sharding Strategy**
   - Customer data sharded by region
   - Order data sharded by creation year
   - Service catalog replicated globally

### Caching Layer

1. **Application-level Caching**
   - Redis for session data
   - In-memory cache for service catalog
   - CDN for static assets

2. **Database Caching**
   - Firestore in-memory cache
   - Materialized views for analytics
   - Denormalized data for performance

### Performance Monitoring

```typescript
// Custom performance metrics
const trace = performance.trace('order-creation');
trace.start();

// Order creation logic

trace.putMetric('orders_created', 1);
trace.stop();
```

## Integration Architecture

### Payment Gateway Integration

```typescript
interface PaymentGateway {
  createPaymentIntent(amount: number, currency: string): Promise<PaymentIntent>;
  confirmPayment(paymentId: string): Promise<PaymentResult>;
  refundPayment(paymentId: string, amount: number): Promise<RefundResult>;
}

// Stripe Implementation
export class StripeGateway implements PaymentGateway {
  private stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

  async createPaymentIntent(amount: number, currency: string) {
    const intent = await this.stripe.paymentIntents.create({
      amount: amount * 100, // Convert to cents
      currency: currency.toLowerCase(),
      payment_method_types: ['card'],
    });

    // Store in Firestore
    await db.collection('paymentIntents').doc(intent.id).set({
      orderId: orderId,
      stripePaymentIntentId: intent.id,
      amount,
      currency,
      createdAt: Timestamp.now()
    });

    return intent;
  }
}
```

### External Service Integrations

1. **SMS Notifications (Twilio)**
```typescript
const twilioClient = twilio(accountSid, authToken);

async function sendSMS(to: string, message: string) {
  return twilioClient.messages.create({
    body: message,
    to,
    from: process.env.TWILIO_PHONE_NUMBER
  });
}
```

2. **Email Service (SendGrid)**
```typescript
const sgMail = require('@sendgrid/mail');
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

async function sendEmail(to: string, templateId: string, data: any) {
  const msg = {
    to,
    from: 'noreply@tailorapp.com',
    templateId,
    dynamic_template_data: data
  };

  return sgMail.send(msg);
}
```

3. **Push Notifications (Firebase Cloud Messaging)**
```typescript
async function sendPushNotification(token: string, title: string, body: string) {
  const message = {
    notification: {
      title,
      body
    },
    token
  };

  return admin.messaging().send(message);
}
```

## Implementation Recommendations

### Phase 1: Core Infrastructure
1. Implement role-based security rules
2. Set up Cloud Functions for business logic
3. Deploy compound indexes
4. Configure offline persistence

### Phase 2: Enhanced Features
1. Payment gateway integration
2. Push notification system
3. Advanced analytics dashboard
4. Employee management enhancements

### Phase 3: Advanced Scaling
1. Multi-region deployment
2. Sharding strategy implementation
3. Performance monitoring and alerting
4. Automated backup and recovery

### Testing Strategy
- Unit tests for Cloud Functions
- Integration tests for payment flows
- Load testing for scalability validation
- Offline mode testing scenarios

This comprehensive design addresses all identified gaps while providing a solid foundation for scalable, secure, and maintainable backend architecture.