import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thirikkale_driver/core/utils/app_styles.dart';

class SlidingGoButton extends StatefulWidget {
  final bool isOnline;
  final VoidCallback onToggle;
  final double width;
  final double height;
  final Duration animationDuration;
  final Color onlineColor;
  final Color offlineColor;
  final Color backgroundColor;
  final double outlineWidth;
  final String onlineText;
  final String offlineText;
  final IconData onlineIcon;
  final IconData offlineIcon;

  const SlidingGoButton({
    super.key,
    required this.isOnline,
    required this.onToggle,
    this.width = 300,
    this.height = 70,
    this.animationDuration = const Duration(milliseconds: 300),
    this.onlineColor = AppColors.primaryGreen,
    this.offlineColor = AppColors.primaryBlue,
    this.backgroundColor = AppColors.surfaceLight,
    this.outlineWidth = 2.0,
    this.onlineText = 'SLIDE TO GO OFFLINE',
    this.offlineText = 'SLIDE TO GO ONLINE',
    this.onlineIcon = Icons.pause,
    this.offlineIcon = Icons.play_arrow,
  });

  @override
  State<SlidingGoButton> createState() => _SlidingGoButtonState();
}

class _SlidingGoButtonState extends State<SlidingGoButton>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  double _dragPosition = 0;
  bool _isDragging = false;
  bool _isAnimating = false;

  // Threshold for activation (80% of available space)
  double get _activationThreshold => (widget.width - 60) * 0.8;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start pulsing animation for offline state
    if (!widget.isOnline) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SlidingGoButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isOnline != widget.isOnline) {
      if (widget.isOnline) {
        _pulseController.stop();
        _pulseController.reset();
      } else {
        _pulseController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (_isAnimating) return;

    setState(() {
      _isDragging = true;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;

    setState(() {
      _dragPosition = (_dragPosition + details.delta.dx).clamp(
        0,
        widget.width - 60,
      );
    });

    // Haptic feedback when approaching threshold
    if (_dragPosition >= _activationThreshold * 0.9 &&
        _dragPosition <= _activationThreshold * 1.1) {
      HapticFeedback.selectionClick();
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAnimating) return;

    setState(() {
      _isDragging = false;
    });

    if (_dragPosition >= _activationThreshold) {
      _activateButton();
    } else {
      _resetPosition();
    }
  }

  void _activateButton() async {
    setState(() {
      _isAnimating = true;
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Call the callback immediately
    widget.onToggle();

    // Smoothly reset to beginning
    await Future.delayed(const Duration(milliseconds: 100));

    // Animate back to start position
    final resetController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    final resetAnimation = Tween<double>(
      begin: _dragPosition,
      end: 0,
    ).animate(CurvedAnimation(parent: resetController, curve: Curves.easeOut));

    resetAnimation.addListener(() {
      setState(() {
        _dragPosition = resetAnimation.value;
      });
    });

    await resetController.forward();
    resetController.dispose();

    setState(() {
      _dragPosition = 0;
      _isAnimating = false;
    });
  }

  void _resetPosition() {
    setState(() {
      _dragPosition = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentColor =
        widget.isOnline ? widget.onlineColor : widget.offlineColor;
    final currentText =
        widget.isOnline ? widget.onlineText : widget.offlineText;
    final currentIcon =
        widget.isOnline ? widget.onlineIcon : widget.offlineIcon;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isOnline ? 1.0 : _pulseAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.height / 2),
              border: Border.all(
                color: widget.isOnline ? AppColors.primaryGreen : AppColors.primaryBlue,
                width: widget.outlineWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: currentColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background progress indicator
                AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    final progress = _dragPosition / (widget.width - 60);

                    return Container(
                      width: widget.width * progress,
                      height: widget.height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            currentColor.withOpacity(0.2),
                            currentColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(widget.height / 2),
                      ),
                    );
                  },
                ),

                // Text label with proper spacing to avoid overlap with thumb
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: _dragPosition + 70, // Add space after the thumb
                      right: 20,
                    ),
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: _isDragging ? 0.7 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          currentText,
                          style: TextStyle(
                            color: currentColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),

                // Sliding thumb with enhanced outline
                AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    final thumbPosition = _dragPosition;

                    return Positioned(
                      left: thumbPosition + 3,
                      top: 3,
                      child: GestureDetector(
                        onPanStart: _onPanStart,
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        child: AnimatedContainer(
                          duration:
                              _isDragging
                                  ? Duration.zero
                                  : const Duration(milliseconds: 200),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: currentColor,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                              BoxShadow(
                                color: currentColor.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            currentIcon,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Shimmer effect when dragging
                if (_isDragging)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(widget.height / 2),
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
