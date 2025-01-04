import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/service_locator.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/group.dart';
import '../../data/models/member.dart';
import '../../data/services/member_service.dart';
import '../../data/services/payment_service.dart';
import '../widgets/bot_status_button.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;

  const GroupDetailScreen({
    super.key,
    required this.group,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final _memberService = serviceLocator<MemberService>();
  final _paymentService = serviceLocator<PaymentService>();
  bool _isLoading = false;
  String _selectedMonth = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      final months = await _memberService.getAvailableMonths(widget.group.id);
      if (mounted && months.isNotEmpty) {
        setState(() => _selectedMonth = months.first);
        await _processAutomaticPayments();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _processAutomaticPayments() async {
    setState(() => _isLoading = true);
    try {
      await _paymentService.processAutomaticPayments(
        widget.group.id,
        _selectedMonth,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddMemberDialog() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final bankingNameController = TextEditingController();
    final amountController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter member name',
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter phone number',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: bankingNameController,
                decoration: const InputDecoration(
                  labelText: 'Banking Name',
                  hintText: 'Name that appears in bank transfers',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Payment Amount',
                  hintText: 'Enter payment amount',
                  prefixText: '₹',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  phoneController.text.trim().isEmpty) {
                return;
              }

              final amount = double.tryParse(amountController.text);
              if (amountController.text.isNotEmpty && amount == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AppConstants.invalidAmount)),
                );
                return;
              }

              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await _memberService.addMember(
                  groupId: widget.group.id,
                  name: nameController.text.trim(),
                  phoneNumber: phoneController.text.trim(),
                  bankingName: bankingNameController.text.trim(),
                  paymentAmount: amount,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppConstants.memberAdded)),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppConstants.genericError)),
                  );
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showMemberActions(Member member) async {
    return showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Member'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditMemberDialog(member);
                },
              ),
              if (member.isPaymentPending(_selectedMonth))
                ListTile(
                  leading: const Icon(Icons.check_circle),
                  title: const Text('Mark as Paid'),
                  onTap: () {
                    Navigator.pop(context);
                    _showPaymentNoteDialog(member);
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text('Mark as Unpaid'),
                  onTap: () async {
                    Navigator.pop(context);
                    setState(() => _isLoading = true);
                    try {
                      await _memberService.markPayment(
                        groupId: widget.group.id,
                        memberId: member.id,
                        month: _selectedMonth,
                        isPaid: false,
                      );
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Member',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(member);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditMemberDialog(Member member) async {
    final nameController = TextEditingController(text: member.name);
    final phoneController = TextEditingController(text: member.phoneNumber);
    final bankingNameController =
        TextEditingController(text: member.bankingName ?? '');
    final amountController = TextEditingController(
      text: member.paymentAmount?.toString() ?? '',
    );

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter member name',
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter phone number',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: bankingNameController,
                decoration: const InputDecoration(
                  labelText: 'Banking Name',
                  hintText: 'Name that appears in bank transfers',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Payment Amount',
                  hintText: 'Enter payment amount',
                  prefixText: '₹',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  phoneController.text.trim().isEmpty) {
                return;
              }

              final amount = double.tryParse(amountController.text);
              if (amountController.text.isNotEmpty && amount == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AppConstants.invalidAmount)),
                );
                return;
              }

              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await _memberService.updateMember(
                  widget.group.id,
                  member.copyWith(
                    name: nameController.text.trim(),
                    phoneNumber: phoneController.text.trim(),
                    bankingName: bankingNameController.text.trim(),
                    paymentAmount: amount,
                  ),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppConstants.memberUpdated)),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppConstants.genericError)),
                  );
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPaymentNoteDialog(Member member) async {
    final noteController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Note'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            labelText: 'Note',
            hintText: 'Enter a note about this payment',
          ),
          autofocus: true,
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await _memberService.markPayment(
                  groupId: widget.group.id,
                  memberId: member.id,
                  month: _selectedMonth,
                  isPaid: true,
                  note: noteController.text.trim(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppConstants.paymentMarked)),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppConstants.genericError)),
                  );
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text('Mark as Paid'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(Member member) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: const Text(AppConstants.deleteMemberConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await _memberService.deleteMember(widget.group.id, member.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Member removed successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppConstants.genericError)),
                  );
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              StreamBuilder<List<String>>(
                stream: Stream.fromFuture(
                  _memberService.getAvailableMonths(widget.group.id),
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();

                  final months = snapshot.data!;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: months.map((month) {
                        final isSelected = month == _selectedMonth;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(month),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedMonth = month);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<List<Member>>(
                  stream: _memberService.getPendingMembers(
                    widget.group.id,
                    _selectedMonth,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          AppConstants.genericError,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final members = snapshot.data!;
                    if (members.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppConstants.noMembers,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppConstants.addMemberHint,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 96),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            title: Text(member.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(member.phoneNumber),
                                if (member.bankingName != null)
                                  Text('Bank: ${member.bankingName}'),
                                if (member.paymentAmount != null)
                                  Text('Amount: ₹${member.paymentAmount}'),
                                if (member.getPaymentNote(_selectedMonth) !=
                                    null)
                                  Text(
                                    'Note: ${member.getPaymentNote(_selectedMonth)}',
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () => _showMemberActions(member),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: BotStatusButton(),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMemberDialog,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
