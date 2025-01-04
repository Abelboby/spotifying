import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/service_locator.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/bot_status.dart';
import '../../data/services/bot_service.dart';

class BotStatusButton extends StatefulWidget {
  const BotStatusButton({super.key});

  @override
  State<BotStatusButton> createState() => _BotStatusButtonState();
}

class _BotStatusButtonState extends State<BotStatusButton> {
  final _botService = serviceLocator<BotService>();
  Timer? _statusTimer;
  BotStatus _status = BotStatus.initial();

  @override
  void initState() {
    super.initState();
    _checkStatus();
    _statusTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkStatus(),
    );
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    final status = await _botService.getStatus();
    if (mounted) setState(() => _status = status);
  }

  Future<void> _showBotDetails() async {
    return showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _status.getStatusText(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_status.state == BotState.running && _status.isInitialized)
                Text(
                  'Uptime: ${PaymentDateUtils.formatUptime(_status.uptime)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              if (_status.lastUpdated != null)
                Text(
                  'Last checked: ${_status.lastUpdated!.hour}:${_status.lastUpdated!.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilledButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _checkStatus();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Status'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Reinitialize Bot'),
                          content:
                              const Text(AppConstants.reinitializeConfirmation),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Reinitialize'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && mounted) {
                        setState(() =>
                            _status = _status.copyWith(isReinitializing: true));
                        await _botService.reinitialize();
                        await _checkStatus();
                      }
                    },
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reinitialize Bot'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _botService.testBot();
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Test Bot'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    if (_status.state == BotState.error) return Icons.error;
    if (_status.state == BotState.offline) return Icons.cloud_off;
    if (_status.state == BotState.initializing || !_status.isInitialized) {
      return Icons.hourglass_empty;
    }
    return Icons.cloud_done;
  }

  Color _getStatusColor() {
    if (_status.state == BotState.error) return Colors.red;
    if (_status.state == BotState.offline) return Colors.grey;
    if (_status.state == BotState.initializing || !_status.isInitialized) {
      return Colors.orange;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: _showBotDetails,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _status.getStatusText(),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
