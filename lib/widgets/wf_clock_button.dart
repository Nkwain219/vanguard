import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vanguard/core/constants/constants.dart';
import 'package:vanguard/core/services/location_service.dart';

class WFClockButton extends StatefulWidget {
  final bool isClockedIn;
  final String? clockInTime;
  final Future<void> Function() onClockIn;
  final Future<void> Function() onClockOut;
  final bool isLoading;

  const WFClockButton({
    super.key,
    required this.isClockedIn,
    this.clockInTime,
    required this.onClockIn,
    required this.onClockOut,
    this.isLoading = false,
  });

  @override
  State<WFClockButton> createState() => _WFClockButtonState();
}

class _WFClockButtonState extends State<WFClockButton>
    with TickerProviderStateMixin {
  double _dragPosition = 0;
  bool _isVerifying = false;
  bool _showSuccess = false;
  bool? _isWithinPerimeter;
  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;
  DateTime? _clockInDateTime;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _successController;

  static const double _trackWidth = 280;
  static const double _knobSize = 56;
  static const double _maxDrag = _trackWidth - _knobSize - 12;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _checkLocation();
    _initElapsedTimer();
  }

  @override
  void didUpdateWidget(covariant WFClockButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isClockedIn != oldWidget.isClockedIn) {
      _initElapsedTimer();
    }
  }

  void _initElapsedTimer() {
    _elapsedTimer?.cancel();
    if (widget.isClockedIn && widget.clockInTime != null) {
      _clockInDateTime = DateTime.tryParse(widget.clockInTime!);
      if (_clockInDateTime != null) {
        _updateElapsed();
        _elapsedTimer = Timer.periodic(
          const Duration(seconds: 30),
          (_) => _updateElapsed(),
        );
      }
    } else {
      _elapsed = Duration.zero;
      _clockInDateTime = null;
    }
  }

  void _updateElapsed() {
    if (_clockInDateTime != null && mounted) {
      setState(() {
        _elapsed = DateTime.now().difference(_clockInDateTime!);
      });
    }
  }

  Future<void> _checkLocation() async {
    try {
      final position = await LocationService.instance.getCurrentPosition();
      if (mounted) {
        setState(() {
          _isWithinPerimeter = position != null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isWithinPerimeter = false);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _successController.dispose();
    _elapsedTimer?.cancel();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (widget.isLoading || _isVerifying) return;
    setState(() {
      _dragPosition = (_dragPosition + details.delta.dx).clamp(0, _maxDrag);
    });
  }

  Future<void> _onDragEnd(DragEndDetails details) async {
    if (widget.isLoading || _isVerifying) return;

    final threshold = _maxDrag * 0.7;
    if (_dragPosition >= threshold) {
      HapticFeedback.mediumImpact();
      setState(() => _isVerifying = true);

      try {
        if (widget.isClockedIn) {
          await widget.onClockOut();
        } else {
          await _checkLocation();
          if (_isWithinPerimeter != true) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.location_off, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            'You must be at your work location to clock in'),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              );
            }
            setState(() {
              _isVerifying = false;
              _dragPosition = 0;
            });
            return;
          }
          await widget.onClockIn();
        }

        setState(() {
          _showSuccess = true;
          _isVerifying = false;
        });
        _successController.forward();
        HapticFeedback.heavyImpact();

        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          setState(() => _showSuccess = false);
          _successController.reset();
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isVerifying = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }

    setState(() => _dragPosition = 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isClockedIn = widget.isClockedIn;

    final trackColor = isClockedIn
        ? AppColors.error.withValues(alpha: 0.08)
        : AppColors.success.withValues(alpha: 0.08);
    final knobColor = isClockedIn ? AppColors.error : AppColors.success;
    final dragProgress = _dragPosition / _maxDrag;

    return Column(
      children: [
        _LocationBadge(isWithinPerimeter: _isWithinPerimeter),
        const SizedBox(height: 12),
        Container(
          width: _trackWidth,
          height: 68,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : trackColor,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: knobColor.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              AnimatedContainer(
                duration:
                    _dragPosition == 0 ? AppDurations.normal : Duration.zero,
                width: _dragPosition + _knobSize + 6,
                height: 68,
                decoration: BoxDecoration(
                  color:
                      knobColor.withValues(alpha: 0.08 + dragProgress * 0.12),
                  borderRadius: BorderRadius.circular(34),
                ),
              ),
              Center(
                child: AnimatedOpacity(
                  opacity: 1.0 - dragProgress * 2,
                  duration: Duration.zero,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 40),
                      Text(
                        isClockedIn
                            ? 'Slide to Clock Out'
                            : 'Slide to Clock In',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: knobColor.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: knobColor.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedPositioned(
                duration:
                    _dragPosition == 0 ? AppDurations.normal : Duration.zero,
                curve: AppCurves.standard,
                left: _dragPosition + 6,
                child: GestureDetector(
                  onHorizontalDragUpdate: _onDragUpdate,
                  onHorizontalDragEnd: _onDragEnd,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _dragPosition == 0 ? _pulseAnimation.value : 1.0,
                        child: child,
                      );
                    },
                    child: Container(
                      width: _knobSize,
                      height: _knobSize,
                      decoration: BoxDecoration(
                        color: knobColor,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.colored(knobColor, opacity: 0.4),
                      ),
                      child: _buildKnobContent(knobColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isClockedIn && _elapsed.inMinutes > 0) ...[
          const SizedBox(height: 12),
          _ElapsedTimeBadge(elapsed: _elapsed),
        ],
      ],
    );
  }

  Widget _buildKnobContent(Color color) {
    if (_showSuccess) {
      return const Icon(Icons.check, color: Colors.white, size: 28);
    }
    if (_isVerifying || widget.isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2.5,
        ),
      );
    }
    return Icon(
      widget.isClockedIn ? Icons.logout : Icons.login,
      color: Colors.white,
      size: 24,
    );
  }
}

class _LocationBadge extends StatelessWidget {
  final bool? isWithinPerimeter;
  const _LocationBadge({this.isWithinPerimeter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isInside = isWithinPerimeter == true;
    final color = isWithinPerimeter == null
        ? AppColors.warning
        : isInside
            ? AppColors.success
            : AppColors.error;
    final label = isWithinPerimeter == null
        ? 'Checking location...'
        : isInside
            ? 'At Work Location'
            : 'Outside Work Area';
    final icon = isWithinPerimeter == null
        ? Icons.my_location
        : isInside
            ? Icons.location_on
            : Icons.location_off;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ElapsedTimeBadge extends StatelessWidget {
  final Duration elapsed;
  const _ElapsedTimeBadge({required this.elapsed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes.remainder(60);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, size: 16, color: AppColors.success),
          const SizedBox(width: 6),
          Text(
            '${hours}h ${minutes}m worked today',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
