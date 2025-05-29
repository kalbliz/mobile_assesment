import 'package:flutter/material.dart';
import 'package:mobile_assessment/common/io/data.dart';
import 'package:mobile_assessment/common/models/employee_model.dart';
import 'package:mobile_assessment/modules/details/presentation/details_screen.dart';
import 'package:mobile_assessment/modules/widgets/button/app_button.dart';
import 'package:mobile_assessment/modules/widgets/inputs/app_textfield.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showButtons = true;
  bool isError = false;
  bool isSuccessLoading = false;
  bool isErrorLoading = false;

  final TextEditingController _searchController = TextEditingController();
  List<Employee> employees = [];
  List<Employee> filteredEmployees = [];

  void simulateSuccess() async {
    setState(() {
      isSuccessLoading = true;
    });
    await Future.delayed(const Duration(seconds: 3));

    final response = Api.successResponse;
    final allEmployees =
        (response['data'] as List).map((e) => Employee.fromJson(e)).toList();

    setState(() {
      isError = false;
      showButtons = false;
      isSuccessLoading = false;
      employees = allEmployees;
      filteredEmployees = allEmployees;
    });
  }

  void simulateError() async {
    setState(() {
      isErrorLoading = true;
    });
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      isError = true;
      showButtons = false;
      isErrorLoading = false;
      employees = [];
      filteredEmployees = [];
    });
  }

  int get promotionCount =>
      filteredEmployees.where((e) => e.productivityScore >= 80).length;

  void _filterEmployees(String query) {
    final lower = query.toLowerCase();

    setState(() {
      filteredEmployees = employees.where((e) {
        return e.fullName.toLowerCase().contains(lower) ||
            e.designation.toLowerCase().contains(lower) ||
            e.level.toString().contains(lower);
      }).toList();
    });
  }

  Set<String> selectedDesignations = {};
  Set<int> selectedLevels = {};

  List<String> get availableDesignations =>
      employees.map((e) => e.designation).toSet().toList();

  List<int> get availableLevels =>
      employees.map((e) => e.level).toSet().toList()..sort();

  void _applyFilters() {
    final nameQuery = _searchController.text.toLowerCase();

    setState(() {
      filteredEmployees = employees.where((e) {
        final matchesName = e.fullName.toLowerCase().contains(nameQuery);
        final matchesDesignation = selectedDesignations.isEmpty ||
            selectedDesignations.contains(e.designation);
        final matchesLevel =
            selectedLevels.isEmpty || selectedLevels.contains(e.level);
        return matchesName && matchesDesignation && matchesLevel;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      selectedDesignations.clear();
      selectedLevels.clear();
    });
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('XYZ Inc.',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEmployeeModal,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Welcome back!", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            Card(
              elevation: 1,
              child: ListTile(
                title: const Text("Statistics"),
                subtitle: Text(
                    "Total Employees: ${filteredEmployees.length} | Promotions: $promotionCount"),
              ),
            ),
            const SizedBox(height: 16),
            if (!showButtons && !isError)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                        child: CustomTextField(
                      controller: _searchController,
                      hintText: 'Search by name...',
                      labelText: 'Search',
                      onSaved: (_) {},
                      onChanged: (_) => _applyFilters(),
                    )),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _showFilterModal,
                      icon: const Icon(Icons.filter_list),
                      tooltip: "Filter",
                    )
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (showButtons) ...[
              AppButton(
                onTap: simulateSuccess,
                buttonText: 'Simulate Success',
                isLoading: isSuccessLoading,
                isPrimary: true,
              ),
              SizedBox(
                height: 10,
              ),
              AppButton(
                onTap: simulateError,
                buttonText: 'Simulate Error',
                isLoading: isErrorLoading,
                isPrimary: true,
              ),
            ] else if (isError) ...[
              const Icon(Icons.error, color: Colors.red, size: 40),
              const Text("An error occurred while fetching data."),
              TextButton(
                  onPressed: simulateSuccess, child: const Text("Retry")),
            ] else
              Expanded(
                child: filteredEmployees.isEmpty
                    ? const Center(child: Text("No employees found."))
                    : ListView.builder(
                        itemCount: filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final e = filteredEmployees[index];
                          return Card(
                            elevation: 0.5,
                            child: ListTile(
                              title: Text(e.fullName),
                              subtitle: Text("${e.designation}  "),
                              trailing: Text("Level ${e.level}"),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailsScreen(employee: e),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              )
          ],
        ),
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final tempSelectedDesignations = Set<String>.from(selectedDesignations);
        final tempSelectedLevels = Set<int>.from(selectedLevels);

        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Filter Employees",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text("Designation",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Wrap(
                    spacing: 10,
                    children: availableDesignations.map((designation) {
                      return FilterChip(
                        label: Text(designation),
                        selected:
                            tempSelectedDesignations.contains(designation),
                        onSelected: (selected) {
                          modalSetState(() {
                            if (selected) {
                              tempSelectedDesignations.add(designation);
                            } else {
                              tempSelectedDesignations.remove(designation);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text("Level",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Wrap(
                    spacing: 10,
                    children: availableLevels.map((level) {
                      return FilterChip(
                        label: Text("Level $level"),
                        selected: tempSelectedLevels.contains(level),
                        onSelected: (selected) {
                          modalSetState(() {
                            if (selected) {
                              tempSelectedLevels.add(level);
                            } else {
                              tempSelectedLevels.remove(level);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              selectedDesignations = tempSelectedDesignations;
                              selectedLevels = tempSelectedLevels;
                            });
                            _applyFilters();
                          },
                          buttonText: 'Apply Filters',
                          isLoading: isSuccessLoading,
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppTextButton(
                        buttonText: "Reset",
                        onTap: () {
                          Navigator.pop(context);
                          _resetFilters();
                        },
                      )
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddEmployeeModal() {
    final formKey = GlobalKey<FormState>();

    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final designationController = TextEditingController();
    final levelController = TextEditingController();
    final productivityController = TextEditingController();
    final salaryController = TextEditingController();
    final employmentStatusController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Add New Employee",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  CustomTextField(
                    labelText: "First Name",
                    hintText: "Enter first name",
                    controller: firstNameController,
                    onSaved: (_) {},
                    validator: (val) =>
                        val == null || val.isEmpty ? "Required" : null,
                  ),
                  CustomTextField(
                    labelText: "Last Name",
                    hintText: "Enter last name",
                    controller: lastNameController,
                    onSaved: (_) {},
                    validator: (val) =>
                        val == null || val.isEmpty ? "Required" : null,
                  ),
                  CustomTextField(
                    labelText: "Designation",
                    hintText: "Enter designation",
                    controller: designationController,
                    onSaved: (_) {},
                    validator: (val) =>
                        val == null || val.isEmpty ? "Required" : null,
                  ),
                  CustomTextField(
                    labelText: "Level",
                    hintText: "Enter level (e.g. 1)",
                    controller: levelController,
                    keyboardType: TextInputType.number,
                    onSaved: (_) {},
                    validator: (val) {
                      if (val == null || val.isEmpty) return "Required";
                      if (int.tryParse(val) == null) return "Must be a number";
                      return null;
                    },
                  ),
                  CustomTextField(
                    labelText: "Productivity Score",
                    hintText: "Enter productivity (0-100)",
                    controller: productivityController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    onSaved: (_) {},
                    validator: (val) {
                      if (val == null || val.isEmpty) return "Required";
                      final parsed = double.tryParse(val);
                      if (parsed == null || parsed < 0 || parsed > 100) {
                        return "Enter a value between 0 and 100";
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    labelText: "Current Salary",
                    hintText: "e.g. 3000",
                    controller: salaryController,
                    onSaved: (_) {},
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      if (val == null || val.isEmpty) return "Required";
                      return null;
                    },
                  ),
                  CustomTextField(
                    labelText: "Employment Status",
                    hintText: "e.g. 1 for Active, 0 for Inactive",
                    controller: employmentStatusController,
                    keyboardType: TextInputType.number,
                    onSaved: (_) {},
                    validator: (val) {
                      if (val == null || val.isEmpty) return "Required";
                      final parsed = int.tryParse(val);
                      if (parsed != 0 && parsed != 1) {
                        return "Must be 0 or 1";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        final newEmployee = Employee(
                          id: DateTime.now().millisecondsSinceEpoch,
                          firstName: firstNameController.text.trim(),
                          lastName: lastNameController.text.trim(),
                          designation: designationController.text.trim(),
                          level: int.parse(levelController.text),
                          productivityScore:
                              double.parse(productivityController.text),
                          currentSalary: salaryController.text.trim(),
                          employmentStatus:
                              int.parse(employmentStatusController.text),
                        );

                        setState(() {
                          employees.add(newEmployee);
                          _applyFilters();
                        });
                        Navigator.pop(context);
                      }
                    },
                    buttonText: "Add Employee",
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
