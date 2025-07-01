import 'package:flutter/material.dart';
import 'package:plan_ease/model/polling.dart' as PollingModel;
import 'package:intl/intl.dart';
import 'package:plan_ease/service/auth_service.dart';
import 'package:plan_ease/service/polling_service.dart';

class PollingItem extends StatefulWidget {
  final PollingModel.Polling polling;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onPollingUpdated;

  const PollingItem({
    super.key,
    required this.polling,
    required this.isExpanded,
    required this.onToggle,
    required this.onPollingUpdated,
  });

  @override
  State<PollingItem> createState() => _PollingItemState();
}

class _PollingItemState extends State<PollingItem> {
  late final AuthService _authService;
  late final PollingService _pollingService;
  
  int? _selectedOptionId;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _pollingService = PollingService(_authService);
    _checkIfUserVoted();
  }

  // Helper method to check if DateTime is in the past
  bool _isDateTimeInPast(DateTime dateTime) {
    return dateTime.isBefore(DateTime.now());
  }

  Future<void> _checkIfUserVoted() async {
    try {
      final results = await _pollingService.getPollingResults(widget.polling.id);
      if (results.containsKey('options') && results['options'] is List) {
        for (var optionData in results['options']) {
          // Add your vote checking logic here
        }
      }
    } catch (e) {
      print('Error checking user vote status: $e');
    }
  }

  void _handleOptionTap(PollingModel.PollingOption option) async {
    // Use the helper method instead of isPast
    if (_isDateTimeInPast(widget.polling.deadline)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Polling ini sudah berakhir.')),
      );
      return;
    }

    setState(() {
      _selectedOptionId = option.id;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mengirim pilihan Anda: ${option.optionText} ...')),
    );

    try {
      final result = await _pollingService.votePolling(
        widget.polling.id,
        option.id,
      );

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
          widget.onPollingUpdated();
        }
      } else {
        if (mounted) {
          setState(() {
            _selectedOptionId = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
        }
      }
    } catch (e) {
      print('Error casting vote: $e');
      if (mounted) {
        setState(() {
          _selectedOptionId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memberikan suara: ${e.toString().replaceFirst('Exception: ', '')}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalVotes = widget.polling.options.fold(0, (sum, option) => sum + (option.voteCount ?? 0));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6EC),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Container(
              width: 28,
              height: 28,
              color: const Color(0xFF1E8C7A),
            ),
            title: Text(widget.polling.title),
            subtitle: Text("Berakhir: ${widget.polling.deadline.day}/${widget.polling.deadline.month}/${widget.polling.deadline.year}"),
            trailing: IconButton(
              icon: Icon(
                widget.isExpanded ? Icons.expand_less : Icons.expand_more,
              ),
              onPressed: widget.onToggle,
            ),
          ),
          if (widget.isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.polling.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(widget.polling.description),
                    ),
                  ...widget.polling.options.map((option) {
                    double percentage = totalVotes == 0 ? 0.0 : (option.voteCount ?? 0) / totalVotes;
                    bool isSelected = _selectedOptionId == option.id;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: PollingOptionBar(
                        title: option.optionText,
                        percentage: percentage,
                        color: const Color(0xFF1E8C7A),
                        isSelected: isSelected,
                        onTap: () => _handleOptionTap(option),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                  if (_selectedOptionId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Anda telah memilih: "${widget.polling.options.firstWhere((opt) => opt.id == _selectedOptionId).optionText}"',
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.green),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Suara: $totalVotes',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.polling.isOpen ? 'Status: Aktif' : 'Status: Berakhir',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: widget.polling.isOpen ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Sisa Waktu: ${widget.polling.timeRemaining}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class PollingOptionBar extends StatelessWidget {
  final String title;
  final double percentage;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const PollingOptionBar({
    super.key,
    required this.title,
    required this.percentage,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: isSelected ? 1.5 : 0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 4),
            Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      height: 10,
                      width: constraints.maxWidth * percentage,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.topRight,
              child: Text(
                '${(percentage * 100).toInt()}%',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}