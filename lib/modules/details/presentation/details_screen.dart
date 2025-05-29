import 'package:flutter/material.dart';
import 'package:mobile_assessment/common/models/employee_model.dart';

class DetailsScreen extends StatelessWidget {
  final Employee employee;

  const DetailsScreen({Key? key, required this.employee}) : super(key: key);

  String getEmploymentStatus(double score) {
    if (score >= 80) return "Promotion";
    if (score >= 50) return "No Change";
    if (score >= 40) return "Demotion";
    return "Termination";
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Promotion":
        return Colors.green;
      case "Demotion":
        return Colors.orange;
      case "Termination":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = getEmploymentStatus(employee.productivityScore);
    final statusColor = getStatusColor(status);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Employee Details"),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 50, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              _buildDetailCard(
                  "Name", "${employee.firstName} ${employee.lastName}"),
              _buildDetailCard("Designation", employee.designation),
              _buildDetailCard("Level", employee.level.toString()),
              _buildDetailCard("Productivity Score",
                  employee.productivityScore.toStringAsFixed(1)),
              _buildDetailCard("Current Salary", "₦${employee.currentSalary}"),
              _buildDetailCard(
                "Employment Status",
                status,
                color: statusColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, {Color? color}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0.5,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          value,
          style: TextStyle(
            color: color ?? Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
