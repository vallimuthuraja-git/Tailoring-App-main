# Quality Control Service Documentation

## Overview
The `quality_control_service.dart` file contains the comprehensive quality management system for the AI-Enabled Tailoring Shop Management System. It provides structured quality checkpoints, issue tracking, performance analytics, and real-time monitoring to ensure consistent high-quality garment production throughout the tailoring process.

## Architecture

### Core Components
- **`QualityCheckpoint`**: Individual quality inspection points with detailed feedback
- **`QualityIssue`**: Quality problems and defects tracking with severity levels
- **`QualityControlService`**: Main service managing quality workflows and analytics
- **`QualityCheckpointTemplate`**: Predefined quality checkpoints for different work types

### Quality Control Workflow
1. **Automated Checkpoint Creation**: Quality checkpoints automatically generated for each work assignment
2. **Structured Inspection Process**: Step-by-step quality verification at each production stage
3. **Issue Documentation**: Comprehensive defect tracking with photographic evidence
4. **Performance Analytics**: Quality metrics and trends for continuous improvement
5. **Real-time Monitoring**: Live quality status updates and notifications

## Quality Checkpoint System

### Checkpoint Types
```dart
enum QualityCheckpointType {
  fabricInspection,    // Initial fabric quality check
  cuttingPrecision,    // Cutting accuracy verification
  stitchingQuality,    // Stitching quality assessment
  fittingCheck,        // Initial fitting verification
  finishingTouches,    // Final quality inspection
  finalApproval        // Final approval before delivery
}
```

### Quality Status Tracking
```dart
enum QualityStatus {
  pending,          // Awaiting inspection
  passed,           // Passed quality check
  failed,           // Failed quality check
  reworkRequired,   // Needs rework
  reworkCompleted,  // Rework done, needs recheck
  approved          // Final approval given
}
```

## QualityCheckpoint Class

### Comprehensive Quality Data Structure
```dart
class QualityCheckpoint {
  final String id;
  final String orderId;
  final String workAssignmentId;
  final QualityCheckpointType checkpointType;
  final String checkpointName;
  final String description;
  final QualityStatus status;
  final double? score;              // 0-10 quality rating
  final String? inspectorId;
  final String? inspectorName;
  final DateTime? inspectedAt;
  final String? feedback;
  final List<QualityIssue> issues;
  final String? photoUrl;
  final Map<String, dynamic> measurements;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Computed Properties
```dart
bool get hasIssues => issues.isNotEmpty;
bool get needsRework => status == QualityStatus.reworkRequired;
bool get isApproved => status == QualityStatus.approved;
bool get isFailed => status == QualityStatus.failed;

String get statusText {
  switch (status) {
    case QualityStatus.pending: return 'Pending Review';
    case QualityStatus.passed: return 'Passed';
    case QualityStatus.failed: return 'Failed';
    case QualityStatus.reworkRequired: return 'Rework Required';
    case QualityStatus.reworkCompleted: return 'Rework Completed';
    case QualityStatus.approved: return 'Approved';
  }
}
```

### Checkpoint Templates by Skill
```dart
final Map<EmployeeSkill, List<QualityCheckpointTemplate>> _checkpointTemplates = {
  EmployeeSkill.cutting: [
    QualityCheckpointTemplate(
      type: QualityCheckpointType.fabricInspection,
      name: 'Fabric Inspection',
      description: 'Check fabric quality, pattern alignment, and measurements',
      requiredMeasurements: ['length', 'width', 'thickness', 'pattern_alignment'],
    ),
    QualityCheckpointTemplate(
      type: QualityCheckpointType.cuttingPrecision,
      name: 'Cutting Precision',
      description: 'Verify cutting accuracy against pattern specifications',
      requiredMeasurements: ['accuracy', 'edge_straightness', 'corner_precision'],
    ),
  ],
  EmployeeSkill.stitching: [
    QualityCheckpointTemplate(
      type: QualityCheckpointType.stitchingQuality,
      name: 'Stitching Quality',
      description: 'Inspect stitch tension, seam allowance, and thread quality',
      requiredMeasurements: ['stitch_tension', 'seam_allowance', 'thread_strength'],
    ),
  ],
  EmployeeSkill.finishing: [
    QualityCheckpointTemplate(
      type: QualityCheckpointType.finishingTouches,
      name: 'Finishing Quality',
      description: 'Check buttons, hems, and final appearance',
      requiredMeasurements: ['button_alignment', 'hem_straightness', 'overall_finish'],
    ),
    QualityCheckpointTemplate(
      type: QualityCheckpointType.finalApproval,
      name: 'Final Approval',
      description: 'Final quality assessment before delivery',
      requiredMeasurements: ['overall_quality', 'customer_satisfaction'],
    ),
  ],
};
```

## Quality Issue Management

### Issue Severity Levels
```dart
enum QualityIssueSeverity {
  minor,     // Cosmetic issue, doesn't affect functionality
  moderate,  // Affects appearance but fixable
  major,     // Significant issue requiring rework
  critical   // Cannot be delivered, needs complete redo
}
```

### QualityIssue Class
```dart
class QualityIssue {
  final String id;
  final String description;
  final QualityIssueSeverity severity;
  final String? photoUrl;
  final DateTime reportedAt;
  final String reportedBy;
  final String? resolvedAt;
  final String? resolvedBy;
  final String? resolutionNotes;
}
```

### Issue Resolution Workflow
1. **Issue Reporting**: Quality issues documented with photographic evidence
2. **Severity Assessment**: Automatic classification based on impact
3. **Resolution Tracking**: Complete audit trail of fixes
4. **Status Updates**: Automatic checkpoint status updates based on issue resolution

## Quality Inspection Process

### Checkpoint Creation
```dart
Future<List<String>> createCheckpointsForAssignment({
  required String orderId,
  required String workAssignmentId,
  required EmployeeSkill skill,
})
```
**Automated Process:**
1. Retrieves appropriate checkpoint templates based on employee skill
2. Creates individual quality checkpoints for each required inspection
3. Links checkpoints to specific work assignments
4. Initializes checkpoints with pending status

### Quality Inspection Submission
```dart
Future<bool> submitQualityInspection({
  required String checkpointId,
  required String inspectorId,
  required String inspectorName,
  required QualityStatus status,
  required double score,
  required String feedback,
  required Map<String, dynamic> measurements,
  required List<QualityIssue> issues,
  String? photoUrl,
})
```
**Comprehensive Inspection Data:**
- Quality score (0-10 scale)
- Detailed feedback and observations
- Photographic evidence
- Structured measurements
- Associated quality issues
- Inspector identification

### Issue Management
```dart
Future<bool> addQualityIssue({
  required String checkpointId,
  required String description,
  required QualityIssueSeverity severity,
  required String reportedBy,
  String? photoUrl,
})
```
**Issue Tracking Features:**
- Automatic checkpoint status update to "failed"
- Photographic evidence support
- Severity-based prioritization
- Reporter identification

```dart
Future<bool> resolveQualityIssue({
  required String checkpointId,
  required String issueId,
  required String resolvedBy,
  required String resolutionNotes,
})
```
**Resolution Process:**
- Issue status update with resolution notes
- Automatic checkpoint status management
- Complete audit trail maintenance
- Bulk resolution status checking

## Quality Analytics and Reporting

### Employee Quality Statistics
```dart
Future<Map<String, dynamic>> getEmployeeQualityStats(String employeeId)
```
**Comprehensive Quality Metrics:**
- **Total Inspections**: Number of quality checkpoints completed
- **Average Score**: Mean quality score across all inspections
- **Pass Rate**: Percentage of inspections passed on first attempt
- **Rework Rate**: Percentage requiring rework
- **Quality Trend**: Monthly quality performance over time
- **Common Issues**: Most frequent quality problems

### Quality Trend Analysis
```dart
Future<List<Map<String, dynamic>>> _getQualityTrend(List<String> assignmentIds)
```
**Trend Analysis Features:**
- **Monthly Aggregation**: Quality metrics grouped by month
- **Historical Tracking**: 6-month quality performance history
- **Score Progression**: Average quality score trends
- **Pass Rate Monitoring**: First-time pass rate over time
- **Volume Tracking**: Inspection volume analysis

### Common Issues Identification
```dart
List<Map<String, dynamic>> _getCommonIssues(List<QualityCheckpoint> checkpoints)
```
**Issue Analysis:**
- **Frequency Counting**: Most common quality issues
- **Severity Correlation**: Issues grouped by severity level
- **Trend Identification**: Recurring quality problems
- **Prioritization**: Issues ranked by occurrence frequency

## Real-time Quality Monitoring

### Live Quality Updates
```dart
Stream<List<QualityCheckpoint>> getQualityUpdatesForOrder(String orderId)
```
**Real-time Features:**
- Live quality status updates
- Real-time issue reporting
- Instant rework notifications
- Continuous quality monitoring

### Pending Inspections Tracking
```dart
Future<List<QualityCheckpoint>> getPendingInspections()
```
**Workflow Management:**
- Pending quality checkpoints identification
- Priority-based inspection queue
- Workload distribution optimization
- Inspection scheduling support

### Rework Management
```dart
Future<List<QualityCheckpoint>> getReworkRequired()
```
**Rework Workflow:**
- Failed checkpoints requiring rework
- Priority-based rework scheduling
- Resource allocation for fixes
- Quality improvement tracking

## Firebase Integration

### Data Structure
```json
{
  "id": "checkpoint_123",
  "orderId": "order_456",
  "workAssignmentId": "assignment_789",
  "checkpointType": 1,
  "checkpointName": "Stitching Quality",
  "description": "Inspect stitch tension and seam quality",
  "status": 1,
  "score": 8.5,
  "inspectorId": "inspector_123",
  "inspectorName": "Quality Inspector",
  "inspectedAt": "Timestamp",
  "feedback": "Good stitching quality, minor tension adjustment needed",
  "issues": [
    {
      "id": "issue_123",
      "description": "Slight stitch tension variation",
      "severity": 0,
      "photoUrl": "photo_url",
      "reportedAt": "Timestamp",
      "reportedBy": "inspector_123",
      "resolvedAt": "Timestamp",
      "resolvedBy": "tailor_456",
      "resolutionNotes": "Tension adjusted on machine"
    }
  ],
  "photoUrl": "checkpoint_photo_url",
  "measurements": {
    "stitch_tension": "3.2",
    "seam_allowance": "1.5cm",
    "thread_strength": "high"
  },
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### Collections
- **`quality_checkpoints`**: Main quality inspection records
- **Relationships**: Linked to orders, work assignments, and employees

### Real-time Features
- **Live Updates**: Real-time quality status changes
- **Stream Processing**: Continuous quality monitoring
- **Instant Notifications**: Immediate quality issue alerts
- **Collaborative Workflow**: Multi-user quality inspection support

## Usage Examples

### Quality Inspection Workflow
```dart
class QualityInspectionScreen extends StatefulWidget {
  final String checkpointId;

  @override
  _QualityInspectionScreenState createState() => _QualityInspectionScreenState();
}

class _QualityInspectionScreenState extends State<QualityInspectionScreen> {
  final QualityControlService _qualityService = QualityControlService();
  QualityCheckpoint? _checkpoint;

  @override
  void initState() {
    super.initState();
    _loadCheckpoint();
  }

  Future<void> _loadCheckpoint() async {
    // Load checkpoint details
    final checkpoints = await _qualityService.getCheckpointsForAssignment('assignment_123');
    setState(() {
      _checkpoint = checkpoints.firstWhere((c) => c.id == widget.checkpointId);
    });
  }

  Future<void> _submitInspection() async {
    final success = await _qualityService.submitQualityInspection(
      checkpointId: widget.checkpointId,
      inspectorId: 'inspector_123',
      inspectorName: 'Quality Inspector',
      status: QualityStatus.passed,
      score: 9.0,
      feedback: 'Excellent stitching quality and attention to detail',
      measurements: {
        'stitch_tension': 'perfect',
        'seam_allowance': '1.5cm',
        'thread_quality': 'premium'
      },
      issues: [], // No issues found
    );

    if (success) {
      Navigator.pop(context);
    }
  }
}
```

### Quality Dashboard
```dart
class QualityDashboard extends StatefulWidget {
  @override
  _QualityDashboardState createState() => _QualityDashboardState();
}

class _QualityDashboardState extends State<QualityDashboard> {
  final QualityControlService _qualityService = QualityControlService();
  List<QualityCheckpoint> _pendingInspections = [];
  List<QualityCheckpoint> _reworkRequired = [];

  @override
  void initState() {
    super.initState();
    _loadQualityData();
  }

  Future<void> _loadQualityData() async {
    final pending = await _qualityService.getPendingInspections();
    final rework = await _qualityService.getReworkRequired();

    setState(() {
      _pendingInspections = pending;
      _reworkRequired = rework;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Quality Statistics
        Row(
          children: [
            Text('Pending: ${_pendingInspections.length}'),
            Text('Rework: ${_reworkRequired.length}'),
          ],
        ),

        // Pending Inspections List
        Expanded(
          child: ListView.builder(
            itemCount: _pendingInspections.length,
            itemBuilder: (context, index) {
              final checkpoint = _pendingInspections[index];
              return ListTile(
                title: Text(checkpoint.checkpointName),
                subtitle: Text('${checkpoint.orderId} - ${checkpoint.statusText}'),
                trailing: IconButton(
                  icon: Icon(Icons.check_circle),
                  onPressed: () => _performInspection(checkpoint),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

### Employee Quality Analytics
```dart
class EmployeeQualityReport extends StatefulWidget {
  final String employeeId;

  @override
  _EmployeeQualityReportState createState() => _EmployeeQualityReportState();
}

class _EmployeeQualityReportState extends State<EmployeeQualityReport> {
  final QualityControlService _qualityService = QualityControlService();
  Map<String, dynamic> _qualityStats = {};

  @override
  void initState() {
    super.initState();
    _loadQualityStats();
  }

  Future<void> _loadQualityStats() async {
    final stats = await _qualityService.getEmployeeQualityStats(widget.employeeId);
    setState(() => _qualityStats = stats);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Quality Statistics for Employee'),
        Text('Total Inspections: ${_qualityStats['totalInspections']}'),
        Text('Average Score: ${_qualityStats['averageScore']?.toStringAsFixed(1)}'),
        Text('Pass Rate: ${(_qualityStats['passRate'] * 100)?.toStringAsFixed(1)}%'),
        Text('Rework Rate: ${(_qualityStats['reworkRate'] * 100)?.toStringAsFixed(1)}%'),

        // Quality Trend Chart
        Expanded(
          child: LineChart(
            _buildTrendData(_qualityStats['qualityTrend']),
          ),
        ),

        // Common Issues
        ...(_qualityStats['commonIssues'] as List<Map<String, dynamic>>).map((issue) {
          return ListTile(
            title: Text(issue['issue']),
            subtitle: Text('${issue['severity']} - ${issue['count']} occurrences'),
          );
        }).toList(),
      ],
    );
  }
}
```

### Real-time Quality Monitoring
```dart
class OrderQualityMonitor extends StatefulWidget {
  final String orderId;

  @override
  _OrderQualityMonitorState createState() => _OrderQualityMonitorState();
}

class _OrderQualityMonitorState extends State<OrderQualityMonitor> {
  final QualityControlService _qualityService = QualityControlService();
  StreamSubscription<List<QualityCheckpoint>>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _qualityService.getQualityUpdatesForOrder(widget.orderId)
        .listen((checkpoints) {
      setState(() {
        // Update UI with real-time quality status
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<QualityCheckpoint>>(
      stream: _qualityService.getQualityUpdatesForOrder(widget.orderId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final checkpoints = snapshot.data!;
        return Column(
          children: checkpoints.map((checkpoint) {
            return Card(
              color: _getStatusColor(checkpoint.status),
              child: ListTile(
                title: Text(checkpoint.checkpointName),
                subtitle: Text(checkpoint.statusText),
                trailing: Text(checkpoint.score?.toStringAsFixed(1) ?? 'N/A'),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Color _getStatusColor(QualityStatus status) {
    switch (status) {
      case QualityStatus.passed:
      case QualityStatus.approved:
        return Colors.green;
      case QualityStatus.failed:
      case QualityStatus.reworkRequired:
        return Colors.red;
      case QualityStatus.pending:
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}
```

## Integration Points

### Related Components
- **Work Assignment Service**: Quality checkpoints linked to work assignments
- **Employee Provider**: Quality statistics integrated with employee performance
- **Order Provider**: Quality status affects order progression
- **Notification Service**: Quality issue alerts and updates
- **Image Service**: Photographic evidence for quality issues

### Dependencies
- **Firebase Firestore**: Quality data persistence and real-time updates
- **Employee Model**: Employee skills and performance integration
- **Order Model**: Order lifecycle and quality status integration
- **Flutter Foundation**: UI components and state management

## Performance Optimization

### Efficient Data Retrieval
- **Indexed Queries**: Optimized Firestore queries for quality data
- **Batch Operations**: Efficient bulk quality checkpoint creation
- **Stream Optimization**: Minimal data transfer in real-time updates
- **Caching Strategy**: Local caching of quality templates and statistics

### Scalability Features
- **Pagination Support**: Large dataset handling for quality history
- **Selective Loading**: Load only required quality data
- **Background Processing**: Non-blocking quality analytics
- **Memory Management**: Efficient cleanup of quality inspection data

## Security Considerations

### Quality Data Protection
- **Inspector Authentication**: Verified inspector identity for quality submissions
- **Data Integrity**: Secure quality data handling and validation
- **Audit Trail**: Complete history of quality inspections and changes
- **Access Control**: Role-based access to quality management features

### Business Logic Security
- **Quality Thresholds**: Configurable quality standards and requirements
- **Issue Validation**: Proper validation of quality issues and severity
- **Status Security**: Secure status transitions and approval processes
- **Data Consistency**: Maintain data integrity across quality checkpoints

## Business Logic

### Quality Assurance Workflow
- **Structured Inspections**: Systematic quality verification at each production stage
- **Defect Classification**: Categorized quality issues by severity and type
- **Rework Management**: Efficient handling of quality issues requiring rework
- **Performance Tracking**: Continuous monitoring of employee quality performance
- **Trend Analysis**: Identification of quality improvement opportunities

### Operational Excellence
- **Standardized Checkpoints**: Consistent quality standards across all work types
- **Skill-Based Inspections**: Specialized quality criteria for different skills
- **Real-time Feedback**: Immediate quality feedback for continuous improvement
- **Analytics-Driven Insights**: Data-driven quality improvement recommendations

### Customer Satisfaction
- **Quality Consistency**: Maintain high-quality standards for customer satisfaction
- **Issue Resolution**: Efficient resolution of quality issues before delivery
- **Transparency**: Clear communication of quality status to customers
- **Trust Building**: Demonstrated commitment to quality and craftsmanship

This comprehensive quality control service provides enterprise-grade quality management specifically designed for the tailoring industry's unique requirements, combining systematic inspection processes with advanced analytics to ensure consistent, high-quality garment production and customer satisfaction.