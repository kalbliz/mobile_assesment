class Employee {
  final int id;
  final String firstName;
  final String lastName;
  final String designation;
  final int level;
  final double productivityScore;
  final String currentSalary;
  final int employmentStatus;

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.designation,
    required this.level,
    required this.productivityScore,
    required this.currentSalary,
    required this.employmentStatus,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: json['id'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        designation: json['designation'],
        level: json['level'],
        productivityScore: (json['productivity_score']).toDouble(),
        currentSalary: json['current_salary'],
        employmentStatus: json['employment_status'],
      );

  String get fullName => '$firstName $lastName';
}
