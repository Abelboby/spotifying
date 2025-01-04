class AppConstants {
  // App Info
  static const String appName = 'Spotify Family Plans';
  static const String appVersion = '1.0.0';

  // Collection Names
  static const String groupsCollection = 'groups';
  static const String membersCollection = 'members';

  // Bot API
  static const String botApiBaseUrl = 'http://localhost:3000';
  static const String botTestMessage =
      'Test message from Spotify Family Plans app';

  // Bot Status Messages
  static const String botOfflineStatus = 'Bot is offline';
  static const String botStartingStatus = 'Bot is starting...';
  static const String botLoadingStatus = 'Bot is loading...';
  static const String botActiveStatus = 'Bot is active';
  static const String botErrorStatus = 'Bot error';

  // Dialog Messages
  static const String startBotPrompt =
      'Please start the WhatsApp bot to enable automatic payment tracking.';
  static const String reinitializeConfirmation =
      'Are you sure you want to reinitialize the bot? This will restart the bot and may take a few minutes.';
  static const String deleteGroupConfirmation =
      'Are you sure you want to delete this group? This action cannot be undone.';
  static const String deleteMemberConfirmation =
      'Are you sure you want to remove this member? This action cannot be undone.';

  // Loading Messages
  static const String loadingGroups = 'Loading your Spotify family plans...';
  static const String loadingMembers = 'Loading group members...';
  static const String processingPayments = 'Processing automatic payments...';
  static const String updatingStatus = 'Updating bot status...';

  // Success Messages
  static const String paymentMarked = 'Payment marked successfully';
  static const String memberAdded = 'Member added successfully';
  static const String memberUpdated = 'Member updated successfully';
  static const String groupCreated = 'Group created successfully';
  static const String groupRenamed = 'Group renamed successfully';

  // Error Messages
  static const String genericError = 'An error occurred. Please try again.';
  static const String smsPermissionError =
      'SMS permission is required to track payments automatically.';
  static const String botConnectionError =
      'Could not connect to the WhatsApp bot.';
  static const String invalidAmount = 'Please enter a valid amount.';
  static const String invalidPhoneNumber = 'Please enter a valid phone number.';

  // UI Text
  static const String noGroups = 'No Spotify family plans yet';
  static const String addGroupHint = 'Add your first Spotify family plan';
  static const String noMembers = 'No members in this group';
  static const String addMemberHint = 'Add members to track their payments';
  static const String allPaid = 'All payments received';
  static const String pendingPayments = 'Pending payments';
}
