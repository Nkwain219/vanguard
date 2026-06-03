import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vanguard/core/models/volunteer.dart';
import 'package:vanguard/core/providers/viewmodel_providers.dart';

class CreateEditVolunteerScreen extends ConsumerStatefulWidget {
  final String? volunteerId;

  const CreateEditVolunteerScreen({super.key, this.volunteerId});

  bool get isEditing => volunteerId != null;

  @override
  ConsumerState<CreateEditVolunteerScreen> createState() =>
      _CreateEditVolunteerScreenState();
}

class _CreateEditVolunteerScreenState
    extends ConsumerState<CreateEditVolunteerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _positionController = TextEditingController();
  final _idCardController = TextEditingController();
  final _stipendController = TextEditingController();
  bool _isActive = true;
  bool _isSaving = false;
  Volunteer? _existingVolunteer;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      Future.microtask(() async {
        await ref
            .read(volunteerViewModelProvider.notifier)
            .selectVolunteer(widget.volunteerId!);
        final volunteer =
            ref.read(volunteerViewModelProvider).selectedVolunteer;
        if (volunteer != null && mounted) {
          _populateFields(volunteer);
        }
      });
    }
  }

  void _populateFields(Volunteer volunteer) {
    setState(() {
      _existingVolunteer = volunteer;
      _firstNameController.text = volunteer.firstName;
      _lastNameController.text = volunteer.lastName;
      _emailController.text = volunteer.email;
      _phoneController.text = volunteer.phone;
      _departmentController.text = volunteer.department;
      _positionController.text = volunteer.position;
      _idCardController.text = volunteer.idCard;
      _stipendController.text = volunteer.stipend?.toString() ?? '';
      _isActive = volunteer.isActive;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    _idCardController.dispose();
    _stipendController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final volunteer = Volunteer(
      id: _existingVolunteer?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      department: _departmentController.text.trim(),
      position: _positionController.text.trim(),
      idCard: _idCardController.text.trim(),
      stipend: _stipendController.text.isNotEmpty
          ? int.tryParse(_stipendController.text.trim())
          : null,
      joinDate: _existingVolunteer?.joinDate ?? DateTime.now(),
      profileImageUrl: _existingVolunteer?.profileImageUrl,
      isActive: _isActive,
    );

    bool success;
    if (widget.isEditing) {
      success = await ref
          .read(volunteerViewModelProvider.notifier)
          .updateVolunteer(volunteer);
    } else {
      success = await ref
          .read(volunteerViewModelProvider.notifier)
          .createVolunteer(volunteer);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing
                ? 'Volunteer updated successfully'
                : 'Volunteer created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else {
        final error = ref.read(volunteerViewModelProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to save volunteer'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Volunteer' : 'Add Volunteer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name *',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (!v.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone *',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _idCardController,
                decoration: const InputDecoration(
                  labelText: 'ID Card Number *',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              Text(
                'Work Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department *',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: 'Position *',
                  prefixIcon: Icon(Icons.work),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stipendController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monthly Stipend (optional)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 50000',
                  suffixText: 'XAF',
                ),
              ),
              const SizedBox(height: 16),
              if (widget.isEditing)
                SwitchListTile(
                  title: const Text('Active'),
                  subtitle: Text(_isActive
                      ? 'Volunteer is active'
                      : 'Volunteer is inactive'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(widget.isEditing
                          ? 'Update Volunteer'
                          : 'Create Volunteer'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
