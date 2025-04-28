import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/employee.dart';

final employeesProvider =
    StateNotifierProvider<EmployeesNotifier, List<Employee>>((ref) {
  return EmployeesNotifier();
});

class EmployeesNotifier extends StateNotifier<List<Employee>> {
  EmployeesNotifier() : super([]) {
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    final box = await Hive.openBox<Employee>('employees');
    state = box.values.toList();
  }

  Future<void> addEmployee(Employee employee) async {
    final box = await Hive.openBox<Employee>('employees');
    await box.add(employee);
    state = [...state, employee];
  }

  Future<void> updateEmployee(Employee employee) async {
    final box = await Hive.openBox<Employee>('employees');
    await employee.save();
    state = state.map((e) => e.id == employee.id ? employee : e).toList();
  }

  Future<void> deleteEmployee(Employee employee) async {
    final box = await Hive.openBox<Employee>('employees');
    await employee.delete();
    state = state.where((e) => e.id != employee.id).toList();
  }

  Future<void> toggleEmployeeStatus(Employee employee) async {
    final updatedEmployee = employee.copyWith(isActive: !employee.isActive);
    await updateEmployee(updatedEmployee);
  }

  List<Employee> getFilteredEmployees(String searchQuery, String roleFilter) {
    return state.where((employee) {
      final matchesSearch = searchQuery.isEmpty ||
          employee.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          employee.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
          employee.phone.contains(searchQuery);

      final matchesRole = roleFilter.isEmpty ||
          roleFilter == 'All' ||
          employee.role == roleFilter;

      return matchesSearch && matchesRole;
    }).toList();
  }

  List<String> get allRoles {
    final roles = state.map((e) => e.role).toSet().toList();
    return ['All', ...roles];
  }
}

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  String _searchQuery = '';
  String _roleFilter = 'All';
  bool _showActiveOnly = false;

  @override
  Widget build(BuildContext context) {
    final allEmployees = ref.watch(employeesProvider);

    // Apply filters
    List<Employee> filteredEmployees = ref
        .read(employeesProvider.notifier)
        .getFilteredEmployees(_searchQuery, _roleFilter);

    // Apply active/inactive filter
    if (_showActiveOnly) {
      filteredEmployees = filteredEmployees.where((e) => e.isActive).toList();
    }

    // Roles for filter dropdown
    final roles = ref.read(employeesProvider.notifier).allRoles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showEmployeeForm(context),
            tooltip: 'Add Employee',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(roles),
          Expanded(
            child: filteredEmployees.isEmpty
                ? _buildEmptyState()
                : _buildEmployeeList(filteredEmployees),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEmployeeForm(context),
        tooltip: 'Add New Employee',
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildFilterBar(List<String> roles) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search employees...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Filter by Role',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  value: _roleFilter,
                  items: roles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _roleFilter = value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              FilterChip(
                label: const Text('Active Only'),
                selected: _showActiveOnly,
                onSelected: (selected) {
                  setState(() => _showActiveOnly = selected);
                },
                avatar: Icon(
                  _showActiveOnly ? Icons.check_circle : Icons.person,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _roleFilter != 'All' || _showActiveOnly
                ? 'No employees match your filters'
                : 'No employees added yet',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (_searchQuery.isNotEmpty ||
              _roleFilter != 'All' ||
              _showActiveOnly)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _roleFilter = 'All';
                  _showActiveOnly = false;
                });
              },
              icon: const Icon(Icons.filter_alt_off),
              label: const Text('Clear Filters'),
            )
          else
            ElevatedButton.icon(
              onPressed: () => _showEmployeeForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Employee'),
            ),
        ],
      ),
    );
  }

  Widget _buildEmployeeList(List<Employee> employees) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        return EmployeeCard(
          employee: employee,
          onEdit: () => _showEmployeeForm(context, employee: employee),
          onDelete: () => _deleteEmployee(employee),
          onToggleStatus: () {
            ref.read(employeesProvider.notifier).toggleEmployeeStatus(employee);
          },
        );
      },
    );
  }

  void _showEmployeeForm(BuildContext context, {Employee? employee}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: employee?.name);
    final emailController = TextEditingController(text: employee?.email);
    final phoneController = TextEditingController(text: employee?.phone);
    final roleController = TextEditingController(text: employee?.role);
    final hourlyRateController =
        TextEditingController(text: employee?.hourlyRate.toString() ?? '0.0');
    final workingDays = employee?.workingDays.toList() ?? [];
    TimeOfDay startTime =
        employee?.startTime ?? const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime =
        employee?.endTime ?? const TimeOfDay(hour: 17, minute: 0);

    // Keep track of the current values of the time fields for display
    var startTimeString = _formatTimeOfDay(startTime);
    var endTimeString = _formatTimeOfDay(endTime);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(employee == null ? 'Add Employee' : 'Edit Employee'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter a name' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter an email' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please enter a phone number'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: roleController,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      prefixIcon: Icon(Icons.work),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter a role' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: hourlyRateController,
                    decoration: const InputDecoration(
                      labelText: 'Hourly Rate',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Please enter an hourly rate'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Working Days',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                        .map((day) {
                      return FilterChip(
                        label: Text(day),
                        selected: workingDays.contains(day),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              workingDays.add(day);
                            } else {
                              workingDays.remove(day);
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
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.access_time),
                          label: Text('Start: $startTimeString'),
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (time != null) {
                              setState(() {
                                startTime = time;
                                startTimeString = _formatTimeOfDay(time);
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.access_time),
                          label: Text('End: $endTimeString'),
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: endTime,
                            );
                            if (time != null) {
                              setState(() {
                                endTime = time;
                                endTimeString = _formatTimeOfDay(time);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final newEmployee = Employee.create(
                    name: nameController.text,
                    email: emailController.text,
                    phone: phoneController.text,
                    role: roleController.text,
                    hourlyRate: double.parse(hourlyRateController.text),
                    workingDays: workingDays,
                    startTime: startTime,
                    endTime: endTime,
                  );

                  if (employee == null) {
                    ref
                        .read(employeesProvider.notifier)
                        .addEmployee(newEmployee);
                  } else {
                    ref
                        .read(employeesProvider.notifier)
                        .updateEmployee(employee.copyWith(
                          name: nameController.text,
                          email: emailController.text,
                          phone: phoneController.text,
                          role: roleController.text,
                          hourlyRate: double.parse(hourlyRateController.text),
                          workingDays: workingDays,
                          startTime: startTime,
                          endTime: endTime,
                        ));
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteEmployee(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(employeesProvider.notifier).deleteEmployee(employee);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }
}

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: employee.isActive
              ? theme.colorScheme.primary.withOpacity(0.2)
              : theme.colorScheme.error.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: employee.isActive
                  ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                  : theme.colorScheme.errorContainer.withOpacity(0.3),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: employee.isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                  foregroundColor: employee.isActive
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onError,
                  child: Text(employee.name.isNotEmpty
                      ? employee.name[0].toUpperCase()
                      : '?'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        employee.role,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    employee.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: employee.isActive
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onError,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: employee.isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.email, employee.email),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.phone, employee.phone),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.schedule,
                    '${_formatTimeOfDay(employee.startTime, context)} - ${_formatTimeOfDay(employee.endTime, context)}'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.calendar_today,
                    'Working: ${employee.workingDays.join(", ")}'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.attach_money,
                    'Rate: \$${employee.hourlyRate.toStringAsFixed(2)}/hr'),
              ],
            ),
          ),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                icon: Icon(employee.isActive ? Icons.person_off : Icons.person),
                label: Text(employee.isActive ? 'Deactivate' : 'Activate'),
                onPressed: onToggleStatus,
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
                tooltip: 'Edit Employee',
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
                tooltip: 'Delete Employee',
                color: theme.colorScheme.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatTimeOfDay(TimeOfDay time, BuildContext context) {
    return time.format(context);
  }
}
