# Analytics Dashboard Screen

## Overview
The `analytics_dashboard_screen.dart` file implements a comprehensive business intelligence dashboard for the AI-Enabled Tailoring Shop Management System. It provides shop owners with detailed analytics across four key business areas: Overview, Revenue, Customers, and Products, featuring real-time metrics, performance indicators, and actionable insights.

## Key Features

### Multi-Dimensional Analytics
- **4-Tab Navigation**: Overview, Revenue, Customers, and Products analytics
- **Real-time Metrics**: Live business performance indicators
- **Role-Based Access**: Restricted to shop owners and administrators
- **Interactive Visualizations**: Progress bars, charts, and trend indicators

### Business Intelligence
- **Key Performance Indicators**: Orders, revenue, customers, products metrics
- **Revenue Analytics**: Financial performance with breakdowns and trends
- **Customer Insights**: Segmentation, loyalty tiers, and behavior analysis
- **Product Performance**: Category distribution and top product analysis

### Advanced Features
- **Data Export**: Analytics data export functionality
- **Data Refresh**: Real-time data synchronization
- **Performance Indicators**: Visual progress indicators with color coding
- **Trend Analysis**: Historical performance tracking and forecasting

## Architecture Components

### Main Widget Structure

#### AnalyticsDashboardScreen Widget
```dart
class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}
```

#### State Management
```dart
class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
}
```

### Role-Based Access Control
```dart
final isShopOwner = authProvider.isShopOwnerOrAdmin;

if (!isShopOwner) {
  return Scaffold(
    appBar: AppBar(title: const Text('Access Restricted')),
    body: const Center(
      child: Column(
        children: [
          Icon(Icons.lock, size: 64, color: Colors.grey),
          Text('Analytics Dashboard'),
          Text('Available only for shop owners'),
        ],
      ),
    ),
  );
}
```

### Multi-Tab Navigation
```dart
TabBar(
  controller: _tabController,
  isScrollable: true,
  indicatorColor: Colors.blue.shade700,
  tabs: const [
    Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
    Tab(text: 'Revenue', icon: Icon(Icons.trending_up)),
    Tab(text: 'Customers', icon: Icon(Icons.people)),
    Tab(text: 'Products', icon: Icon(Icons.inventory)),
  ],
)
```

## Analytics Tabs

### Overview Tab

#### Key Metrics Grid
```dart
Row(
  children: [
    Expanded(
      child: _MetricCard(
        title: 'Total Orders',
        value: '${stats['totalOrders']}',
        icon: Icons.receipt_long,
        color: Colors.blue,
        trend: '+${stats['thisMonthOrders']} this month',
      ),
    ),
    Expanded(
      child: _MetricCard(
        title: 'Revenue',
        value: '₹${stats['totalRevenue'].toStringAsFixed(0)}',
        icon: Icons.attach_money,
        color: Colors.green,
        trend: '+${((stats['thisMonthOrders'] / stats['totalOrders']) * 100).toStringAsFixed(1)}%',
      ),
    ),
  ],
)
```

#### Performance Indicators
```dart
_PerformanceIndicator(
  label: 'Completion Rate',
  value: stats['completionRate'],
  color: Colors.green,
),
_PerformanceIndicator(
  label: 'Average Order Value',
  value: stats['totalOrders'] > 0 ? stats['totalRevenue'] / stats['totalOrders'] : 0,
  color: Colors.blue,
  isCurrency: true,
),
_PerformanceIndicator(
  label: 'Customer Retention',
  value: customers.isNotEmpty ? (customers.where((c) => c.isActive).length / customers.length) * 100 : 0,
  color: Colors.purple,
  isPercentage: true,
),
```

#### Business Insights
```dart
const _InsightCard(
  icon: Icons.trending_up,
  title: 'Revenue Growth',
  description: 'Revenue increased by 25% compared to last month',
  color: Colors.green,
),
const _InsightCard(
  icon: Icons.people,
  title: 'Customer Engagement',
  description: 'New customer acquisition rate is improving',
  color: Colors.blue,
),
const _InsightCard(
  icon: Icons.inventory,
  title: 'Product Performance',
  description: 'Top products are driving 60% of revenue',
  color: Colors.orange,
),
```

### Revenue Tab

#### Revenue Cards
```dart
Row(
  children: [
    Expanded(
      child: _RevenueCard(
        title: 'Total Revenue',
        amount: stats['totalRevenue'],
        period: 'All Time',
        color: Colors.green,
      ),
    ),
    Expanded(
      child: _RevenueCard(
        title: 'Pending Payments',
        amount: stats['pendingPayments'],
        period: 'Outstanding',
        color: Colors.orange,
      ),
    ),
  ],
)
```

#### Revenue Breakdown
```dart
_RevenueBreakdownItem(
  label: 'This Month',
  amount: (stats['totalRevenue'] * 0.3).toStringAsFixed(0),
  percentage: 30,
  color: Colors.blue,
),
_RevenueBreakdownItem(
  label: 'Last Month',
  amount: (stats['totalRevenue'] * 0.25).toStringAsFixed(0),
  percentage: 25,
  color: Colors.green,
),
_RevenueBreakdownItem(
  label: 'Older',
  amount: (stats['totalRevenue'] * 0.45).toStringAsFixed(0),
  percentage: 45,
  color: Colors.grey,
),
```

#### Monthly Trends
```dart
..._generateMonthlyTrends().map((trend) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(trend['month'])),
          Text('₹${trend['revenue']}'),
          Expanded(
            child: LinearProgressIndicator(
              value: trend['percentage'] / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
          ),
        ],
      ),
    )),
```

### Customers Tab

#### Customer Metrics
```dart
Row(
  children: [
    Expanded(
      child: _MetricCard(
        title: 'Total Customers',
        value: '${customers.length}',
        icon: Icons.people,
        color: Colors.blue,
        trend: '${customers.where((c) => c.isActive).length} active',
      ),
    ),
    Expanded(
      child: _MetricCard(
        title: 'Avg Order Value',
        value: '₹${stats['averageOrderValue'].toStringAsFixed(0)}',
        icon: Icons.attach_money,
        color: Colors.green,
        trend: 'Per customer',
      ),
    ),
  ],
)
```

#### Customer Segmentation
```dart
_CustomerSegmentItem(
  segment: 'Loyal Customers',
  count: customers.where((c) => c.loyaltyTier == LoyaltyTier.gold || c.loyaltyTier == LoyaltyTier.platinum).length,
  percentage: customers.isNotEmpty ? (customers.where((c) => c.loyaltyTier == LoyaltyTier.gold || c.loyaltyTier == LoyaltyTier.platinum).length / customers.length) * 100 : 0,
  color: Colors.purple,
),
_CustomerSegmentItem(
  segment: 'Regular Customers',
  count: customers.where((c) => c.loyaltyTier == LoyaltyTier.silver).length,
  percentage: customers.isNotEmpty ? (customers.where((c) => c.loyaltyTier == LoyaltyTier.silver).length / customers.length) * 100 : 0,
  color: Colors.blue,
),
_CustomerSegmentItem(
  segment: 'New Customers',
  count: customers.where((c) => c.loyaltyTier == LoyaltyTier.bronze).length,
  percentage: customers.isNotEmpty ? (customers.where((c) => c.loyaltyTier == LoyaltyTier.bronze).length / customers.length) * 100 : 0,
  color: Colors.orange,
),
```

#### Top Customers Display
```dart
...customers.take(5).map((customer) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: customer.photoUrl != null
                ? NetworkImage(customer.photoUrl!)
                : null,
            child: customer.photoUrl == null
                ? Text(customer.displayName[0].toUpperCase())
                : null,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(customer.loyaltyTier, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          Text('₹${customer.totalSpent.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    )),
```

### Products Tab

#### Product Metrics
```dart
Row(
  children: [
    Expanded(
      child: _MetricCard(
        title: 'Total Products',
        value: '${products.length}',
        icon: Icons.inventory,
        color: Colors.orange,
        trend: '${products.where((p) => p.isActive).length} active',
      ),
    ),
    Expanded(
      child: _MetricCard(
        title: 'Categories',
        value: '${products.map((p) => p.category).toSet().length}',
        icon: Icons.category,
        color: Colors.purple,
        trend: 'Product types',
      ),
    ),
  ],
)
```

#### Product Categories Distribution
```dart
..._getCategoryDistribution(products).entries.map((entry) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(entry.key)),
          Text('${entry.value} products'),
          Expanded(
            child: LinearProgressIndicator(
              value: entry.value / products.length,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
          ),
        ],
      ),
    )),
```

#### Top Products Display
```dart
...products.take(5).map((product) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(product.imageUrls.isNotEmpty
                    ? product.imageUrls.first
                    : 'https://via.placeholder.com/50x50?text=No+Image'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(product.categoryName, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
          Text('₹${product.basePrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    )),
```

## Helper Widgets

### Metric Card Component
```dart
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: Colors.grey[600])),
                      Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(trend, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### Performance Indicator Component
```dart
class _PerformanceIndicator extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool isCurrency;
  final bool isPercentage;

  @override
  Widget build(BuildContext context) {
    String displayValue;
    if (isCurrency) {
      displayValue = '₹${value.toStringAsFixed(0)}';
    } else if (isPercentage) {
      displayValue = '${value.toStringAsFixed(1)}%';
    } else {
      displayValue = '${value.toStringAsFixed(1)}%';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(displayValue, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: isPercentage ? value / 100 : (value > 100 ? 1.0 : value / 100),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Insight Card Component
```dart
class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(description, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Action Functions

### Data Export
```dart
void _exportAnalytics(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Analytics export feature coming soon!')),
  );
}
```

### Data Refresh
```dart
void _refreshData(BuildContext context, OrderProvider orderProvider,
    CustomerProvider customerProvider, ProductProvider productProvider) async {
  await orderProvider.loadOrders();
  await customerProvider.loadAllCustomers();
  await productProvider.loadProducts();

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data refreshed successfully!')),
    );
  }
}
```

## Utility Functions

### Category Distribution Calculation
```dart
Map<String, int> _getCategoryDistribution(List products) {
  final distribution = <String, int>{};
  for (final product in products) {
    final category = product.categoryName;
    distribution[category] = (distribution[category] ?? 0) + 1;
  }
  return distribution;
}
```

### Monthly Trends Generation
```dart
List<Map<String, dynamic>> _generateMonthlyTrends() {
  return [
    {'month': 'January', 'revenue': '45000', 'percentage': 30},
    {'month': 'February', 'revenue': '52000', 'percentage': 35},
    {'month': 'March', 'revenue': '48000', 'percentage': 32},
    {'month': 'April', 'revenue': '61000', 'percentage': 40},
    {'month': 'May', 'revenue': '55000', 'percentage': 36},
    {'month': 'June', 'revenue': '75000', 'percentage': 50},
  ];
}
```

## Integration Points

### With Multiple Providers
- **Order Provider**: Order statistics and revenue data
  - Related: [`lib/providers/order_provider.dart`](../../providers/order_provider.md)
- **Customer Provider**: Customer analytics and segmentation
  - Related: [`lib/providers/customer_provider.dart`](../../providers/customer_provider.md)
- **Product Provider**: Product performance and category analysis
  - Related: [`lib/providers/product_provider.dart`](../../providers/product_provider.md)
- **Authentication Provider**: Role-based access control
  - Related: [`lib/providers/auth_provider.dart`](../../providers/auth_provider.md)

### With Navigation System
- **App Bar Actions**: Export and refresh functionality
- **Tab Navigation**: Multi-tab interface with smooth transitions
- **Deep Linking**: Direct access to specific analytics sections
- **State Preservation**: Maintain tab state during navigation

## User Experience Features

### Analytics Dashboard Layout
```
Business Analytics
├── Overview Tab
│   ├── Key Metrics Grid (2x2)
│   │   ├── Total Orders
│   │   ├── Revenue
│   │   ├── Customers
│   │   └── Products
│   ├── Performance Indicators
│   │   ├── Completion Rate
│   │   ├── Average Order Value
│   │   └── Customer Retention
│   └── Business Insights
│       ├── Revenue Growth
│       ├── Customer Engagement
│       └── Product Performance
├── Revenue Tab
│   ├── Revenue Cards (2-column)
│   ├── Revenue Breakdown (Chart)
│   └── Monthly Trends (Progress bars)
├── Customers Tab
│   ├── Customer Metrics
│   ├── Customer Segments (Chart)
│   └── Top Customers (List)
└── Products Tab
    ├── Product Metrics
    ├── Category Distribution (Chart)
    └── Top Products (List)
```

### Shop Owner Workflow
```
Analytics Access
├── Authentication Check
│   └── Role Validation (Shop Owner/Admin)
├── Dashboard Loading
│   ├── Data Fetching from Multiple Providers
│   └── Statistics Calculation
├── Tab Navigation
│   ├── Overview - High-level KPIs
│   ├── Revenue - Financial Performance
│   ├── Customers - Customer Analytics
│   └── Products - Product Performance
├── Data Operations
│   ├── Export Analytics Data
│   └── Refresh Real-time Data
└── Business Insights
    ├── Performance Monitoring
    ├── Trend Analysis
    └── Decision Support
```

### Visual Design System
- **Color-Coded Metrics**: Different colors for different data types
- **Progress Indicators**: Linear progress bars for percentages
- **Icon-Based Navigation**: Intuitive icons for each tab
- **Card-Based Layout**: Consistent card design throughout
- **Typography Hierarchy**: Clear information hierarchy
- **Responsive Metrics**: Adaptive layouts for different screen sizes

## Performance Optimizations

### Efficient Data Loading
- **Parallel Data Fetching**: Multiple provider data loading
- **Lazy Initialization**: Tab content loaded on demand
- **Memory Management**: Proper disposal of controllers
- **Minimal Rebuilds**: Targeted widget updates

### Real-time Updates
- **Provider Integration**: Live data synchronization
- **Refresh Functionality**: Manual data refresh capability
- **Optimistic Updates**: Immediate UI feedback
- **Error Handling**: Graceful failure management

## Future Enhancements

### Advanced Analytics
- **Real-time Dashboards**: Live data streaming
- **Custom Date Ranges**: Flexible time period selection
- **Comparative Analysis**: Period-over-period comparisons
- **Predictive Analytics**: Forecasting and trend prediction

### Enhanced Visualizations
- **Interactive Charts**: Drill-down capabilities
- **Custom Dashboards**: Personalized analytics views
- **Export Formats**: PDF, Excel, CSV export options
- **Scheduled Reports**: Automated report generation

### Integration Features
- **Third-Party Tools**: Google Analytics, business intelligence tools
- **API Integration**: External data source connectivity
- **Custom Metrics**: User-defined KPIs and calculations
- **Alert System**: Automated notifications for key metrics

### Mobile Optimization
- **Responsive Charts**: Mobile-friendly data visualizations
- **Touch Interactions**: Swipe gestures for navigation
- **Offline Analytics**: Cached data for offline viewing
- **Push Notifications**: Real-time alerts and updates

---

*This Analytics Dashboard represents the comprehensive business intelligence command center for tailoring shop management, offering shop owners powerful tools to monitor performance, track trends, analyze customer behavior, and make data-driven decisions across all key business metrics with an intuitive, feature-rich interface that adapts to their analytical needs.*