import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StatusIndicator extends StatelessWidget {
  final bool isOnline;
  final DateTime? lastUpdate;

  const StatusIndicator({
    super.key,
    required this.isOnline,
    this.lastUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isOnline ? Colors.green : Colors.red;
    final statusText = isOnline ? 'System Online' : 'System Offline';
    final statusIcon = isOnline ? Icons.check_circle : Icons.error;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.2, 1.2),
                    duration: 1000.ms,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(1.0, 1.0),
                    duration: 1000.ms,
                  ),
              
              const SizedBox(width: 8),
              
              Icon(
                statusIcon,
                color: statusColor,
                size: 20,
              ),
              
              const SizedBox(width: 8),
              
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
