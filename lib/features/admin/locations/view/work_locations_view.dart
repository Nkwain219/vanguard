import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanguard/core/constants/constants.dart';
import 'package:vanguard/core/models/work_location.dart';
import 'package:vanguard/core/repositories/firebase/firebase_work_location_repository.dart';
import 'package:vanguard/core/services/location_service.dart';

class WorkLocationsScreen extends ConsumerStatefulWidget {
  const WorkLocationsScreen({super.key});

  @override
  ConsumerState<WorkLocationsScreen> createState() =>
      _WorkLocationsScreenState();
}

class _WorkLocationsScreenState extends ConsumerState<WorkLocationsScreen> {
  final _repo = FirebaseWorkLocationRepository();
  List<WorkLocation> _locations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() => _isLoading = true);
    try {
      _locations = await _repo.getAllLocations();
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Locations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLocations,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Add Location'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _locations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_off,
                          size: 64, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text('No work locations configured',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Add a location to enable geofence-based clock-in',
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLocations,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _locations.length,
                    itemBuilder: (context, index) {
                      final loc = _locations[index];
                      return _LocationCard(
                        location: loc,
                        onEdit: () => _showEditDialog(loc),
                        onToggle: () => _toggleActive(loc),
                        onDelete: () => _deleteLocation(loc),
                      );
                    },
                  ),
                ),
    );
  }

  Future<void> _showAddDialog() async {
    final result = await showDialog<WorkLocation>(
      context: context,
      builder: (context) => _LocationFormDialog(),
    );
    if (result != null) {
      await _repo.createLocation(result);
      _loadLocations();
    }
  }

  Future<void> _showEditDialog(WorkLocation loc) async {
    final result = await showDialog<WorkLocation>(
      context: context,
      builder: (context) => _LocationFormDialog(location: loc),
    );
    if (result != null) {
      await _repo.updateLocation(result);
      _loadLocations();
    }
  }

  Future<void> _toggleActive(WorkLocation loc) async {
    await _repo.updateLocation(loc.copyWith(isActive: !loc.isActive));
    _loadLocations();
  }

  Future<void> _deleteLocation(WorkLocation loc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Location'),
        content: Text('Delete "${loc.name}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _repo.deleteLocation(loc.id);
      _loadLocations();
    }
  }
}

class _LocationCard extends StatelessWidget {
  final WorkLocation location;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _LocationCard({
    required this.location,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (location.isActive
                            ? AppColors.success
                            : AppColors.error)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    location.isActive ? Icons.location_on : Icons.location_off,
                    color:
                        location.isActive ? AppColors.success : AppColors.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                      case 'toggle':
                        onToggle();
                      case 'delete':
                        onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(
                      value: 'toggle',
                      child:
                          Text(location.isActive ? 'Deactivate' : 'Activate'),
                    ),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete',
                            style: TextStyle(color: AppColors.error))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.radar,
                  label: '${location.radiusMeters.toInt()}m radius',
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: location.isActive ? Icons.check_circle : Icons.cancel,
                  label: location.isActive ? 'Active' : 'Inactive',
                  color:
                      location.isActive ? AppColors.success : AppColors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 4),
          Text(label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: c,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

class _LocationFormDialog extends StatefulWidget {
  final WorkLocation? location;
  const _LocationFormDialog({this.location});

  @override
  State<_LocationFormDialog> createState() => _LocationFormDialogState();
}

class _LocationFormDialogState extends State<_LocationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late final TextEditingController _radiusCtrl;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    final loc = widget.location;
    _nameCtrl = TextEditingController(text: loc?.name ?? '');
    _latCtrl = TextEditingController(text: loc?.latitude.toString() ?? '');
    _lngCtrl = TextEditingController(text: loc?.longitude.toString() ?? '');
    _radiusCtrl =
        TextEditingController(text: (loc?.radiusMeters ?? 100).toString());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _radiusCtrl.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final position = await LocationService.instance.getCurrentPosition();
      if (position != null && mounted) {
        _latCtrl.text = position.latitude.toStringAsFixed(6);
        _lngCtrl.text = position.longitude.toStringAsFixed(6);
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingLocation = false);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final location = WorkLocation(
      id: widget.location?.id ?? 'loc_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      latitude: double.parse(_latCtrl.text.trim()),
      longitude: double.parse(_lngCtrl.text.trim()),
      radiusMeters: double.parse(_radiusCtrl.text.trim()),
      isActive: widget.location?.isActive ?? true,
    );

    Navigator.pop(context, location);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.location != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Location' : 'Add Work Location'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Location Name',
                  hintText: 'e.g. Head Office',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _isLoadingLocation ? null : _useCurrentLocation,
                icon: _isLoadingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location, size: 18),
                label: const Text('Use My Current Location'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        prefixIcon: Icon(Icons.north, size: 18),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final d = double.tryParse(v);
                        if (d == null || d < -90 || d > 90) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        prefixIcon: Icon(Icons.east, size: 18),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final d = double.tryParse(v);
                        if (d == null || d < -180 || d > 180) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _radiusCtrl,
                decoration: const InputDecoration(
                  labelText: 'Radius (meters)',
                  hintText: '100',
                  prefixIcon: Icon(Icons.radar),
                  suffixText: 'm',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final d = double.tryParse(v);
                  if (d == null || d < 10 || d > 5000) return '10-5000m';
                  return null;
                },
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
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
