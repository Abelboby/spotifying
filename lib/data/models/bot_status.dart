import '../../core/constants/app_constants.dart';

enum BotState {
  offline,
  error,
  initializing,
  running,
}

class BotStatus {
  final BotState state;
  final bool isInitialized;
  final double uptime;
  final DateTime? lastUpdated;
  final bool isReinitializing;
  final bool isStarting;

  BotStatus({
    required this.state,
    required this.isInitialized,
    required this.uptime,
    this.lastUpdated,
    this.isReinitializing = false,
    this.isStarting = false,
  });

  factory BotStatus.initial() {
    return BotStatus(
      state: BotState.offline,
      isInitialized: false,
      uptime: 0,
    );
  }

  factory BotStatus.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String?;
    return BotStatus(
      state: _parseState(status),
      isInitialized: json['initialized'] ?? false,
      uptime: (json['uptime'] ?? 0).toDouble(),
      lastUpdated: DateTime.now(),
    );
  }

  static BotState _parseState(String? status) {
    switch (status?.toLowerCase()) {
      case 'running':
        return BotState.running;
      case 'initializing':
        return BotState.initializing;
      case 'error':
        return BotState.error;
      default:
        return BotState.offline;
    }
  }

  String getStatusText() {
    if (state == BotState.error) return AppConstants.botErrorStatus;
    if (state == BotState.offline) return AppConstants.botOfflineStatus;
    if (state == BotState.initializing) return AppConstants.botStartingStatus;
    if (state == BotState.running && !isInitialized)
      return AppConstants.botLoadingStatus;
    return AppConstants.botActiveStatus;
  }

  BotStatus copyWith({
    BotState? state,
    bool? isInitialized,
    double? uptime,
    DateTime? lastUpdated,
    bool? isReinitializing,
    bool? isStarting,
  }) {
    return BotStatus(
      state: state ?? this.state,
      isInitialized: isInitialized ?? this.isInitialized,
      uptime: uptime ?? this.uptime,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isReinitializing: isReinitializing ?? this.isReinitializing,
      isStarting: isStarting ?? this.isStarting,
    );
  }

  @override
  String toString() {
    return 'BotStatus(state: $state, isInitialized: $isInitialized, uptime: $uptime, '
        'lastUpdated: $lastUpdated, isReinitializing: $isReinitializing, isStarting: $isStarting)';
  }
}
