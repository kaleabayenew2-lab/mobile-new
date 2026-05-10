import 'package:flutter/material.dart';

class AgentManagementPage extends StatefulWidget {
  const AgentManagementPage({super.key});

  @override
  State<AgentManagementPage> createState() => _AgentManagementPageState();
}

class _AgentManagementPageState extends State<AgentManagementPage> {

  // Mock management tasks
  final List<Map<String, dynamic>> _tasks = [
    {
      'title': 'Verify Patient Documents',
      'description': 'Review and verify submitted patient documents',
      'status': 'Pending',
      'priority': 'High',
      'dueDate': 'Today',
      'assignee': 'Dr. Sarah Johnson',
    },
    {
      'title': 'Coordinate with Clinic',
      'description': 'Schedule appointment with cardiology department',
      'status': 'In Progress',
      'priority': 'Medium',
      'dueDate': 'Tomorrow',
      'assignee': 'Admin Team',
    },
    {
      'title': 'Approve Booking Requests',
      'description': 'Review pending booking requests for next week',
      'status': 'Pending',
      'priority': 'High',
      'dueDate': 'Today',
      'assignee': 'Front Desk',
    },
    {
      'title': 'Update Facility Information',
      'description': 'Update emergency contact information',
      'status': 'Completed',
      'priority': 'Low',
      'dueDate': 'Yesterday',
      'assignee': 'Management',
    },
    {
      'title': 'Staff Meeting Preparation',
      'description': 'Prepare agenda for weekly staff meeting',
      'status': 'In Progress',
      'priority': 'Medium',
      'dueDate': 'Dec 15',
      'assignee': 'Team Lead',
    },
  ];

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'In Progress', 'Completed'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewTask,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Cards
          Container(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 64, // Account for padding
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Tasks',
                      _tasks.length.toString(),
                      Icons.task,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Pending',
                      _tasks.where((task) => task['status'] == 'Pending').length.toString(),
                      Icons.schedule,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Completed',
                      _tasks.where((task) => task['status'] == 'Completed').length.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 64, // Account for padding
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      backgroundColor: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
                      checkmarkColor: Colors.blue,
                    ),
                  );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Tasks List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredTasks.length,
              itemBuilder: (context, index) {
                final task = _filteredTasks[index];
                return _buildTaskCard(task);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredTasks {
    if (_selectedFilter == 'All') {
      return _tasks;
    }
    return _tasks.where((task) => task['status'] == _selectedFilter).toList();
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final status = task['status'] as String;
    final priority = task['priority'] as String;
    final statusColor = _getStatusColor(status);
    final priorityColor = _getPriorityColor(priority);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Icon(
            _getStatusIcon(status),
            color: statusColor,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                task['title'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                priority,
                style: TextStyle(
                  color: priorityColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(task['description']),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  task['assignee'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  task['dueDate'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow('Priority', priority, priorityColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDetailRow('Due Date', task['dueDate'], Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Assignee', task['assignee'], Colors.blue),
                const SizedBox(height: 12),
                _buildDetailRow('Description', task['description'], Colors.grey),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (status == 'Pending') ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _startTask(task),
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: const Text('Start'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _editTask(task),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                        ),
                      ),
                    ] else if (status == 'In Progress') ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _completeTask(task),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Complete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pauseTask(task),
                          icon: const Icon(Icons.pause, size: 16),
                          label: const Text('Pause'),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _viewDetails(task),
                          icon: const Icon(Icons.info, size: 16),
                          label: const Text('View Details'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.schedule;
      case 'In Progress':
        return Icons.play_arrow;
      case 'Completed':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  void _addNewTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task added successfully')),
              );
            },
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  void _refreshTasks() {
    // TODO: Implement refresh functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tasks refreshed')),
    );
  }

  void _startTask(Map<String, dynamic> task) {
    setState(() {
      task['status'] = 'In Progress';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task "${task['title']}" started')),
    );
  }

  void _completeTask(Map<String, dynamic> task) {
    setState(() {
      task['status'] = 'Completed';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task "${task['title']}" completed')),
    );
  }

  void _pauseTask(Map<String, dynamic> task) {
    setState(() {
      task['status'] = 'Pending';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task "${task['title']}" paused')),
    );
  }

  void _editTask(Map<String, dynamic> task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing task "${task['title']}"...')),
    );
  }

  void _viewDetails(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Task Details - ${task['title']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${task['description']}'),
            const SizedBox(height: 8),
            Text('Status: ${task['status']}'),
            const SizedBox(height: 8),
            Text('Priority: ${task['priority']}'),
            const SizedBox(height: 8),
            Text('Due Date: ${task['dueDate']}'),
            const SizedBox(height: 8),
            Text('Assignee: ${task['assignee']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}