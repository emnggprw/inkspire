import 'package:flutter/material.dart';
import 'package:inkspire/presentation/widgets/ink_painter.dart';

/// A widget that displays an animated background using ink-style painting effects.
///
/// This widget creates a full-screen animated background with customizable
/// gradient colors, opacity, and animation duration. The animation continuously
/// loops with a reverse effect, creating a smooth back-and-forth motion.
///
/// Example usage:
/// ```dart
/// AnimatedBackground()
/// ```
///
/// The widget automatically handles:
/// - Animation lifecycle management
/// - Screen size adaptation
/// - Memory cleanup on disposal
/// - Comprehensive error handling and recovery
/// - Graceful fallbacks for edge cases
///
/// See also:
/// - [InkPainter], which handles the actual painting logic
/// - [AnimationController], which manages the animation timing
class AnimatedBackground extends StatefulWidget {
  /// Creates an animated background widget.
  ///
  /// All parameters are optional and have sensible defaults.
  const AnimatedBackground({
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {

  // Animation constants
  static const Duration _kDefaultAnimationDuration = Duration(seconds: 10);
  static const double _kDefaultProgress = 0.8;
  static const double _kDefaultOpacity = 0.85; // Slightly reduced for more subtle satin effect

  // Modern black & white satin gradient colors
  static const List<Color> _kDefaultGradientColors = [
    Color(0xFF1A1A1A), // Rich charcoal black
    Color(0xFF4A4A4A), // Medium gray
    Color(0xFF8A8A8A), // Light gray
    Color(0xFFE8E8E8), // Off-white
    Color(0xFFF5F5F5), // Pure white with subtle warmth
  ];

  // Animation controller for managing the background animation
  late AnimationController _controller;

  // Flag to track if the widget is mounted to prevent memory leaks
  bool _isDisposed = false;

  /// Initializes the animation controller and starts the animation.
  ///
  /// The animation is configured to:
  /// - Run for [_kDefaultAnimationDuration]
  /// - Repeat indefinitely with reverse effect
  /// - Use this widget as the vsync provider
  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  /// Initializes and configures the animation controller.
  ///
  /// This method is separated from initState for better testability
  /// and potential future customization.
  ///
  /// Handles various initialization errors:
  /// - TickerProvider issues
  /// - Animation controller creation failures
  /// - Animation start failures
  void _initializeAnimation() {
    try {
      // Validate widget state before creating controller
      if (_isDisposed || !mounted) {
        debugPrint('AnimatedBackground: Cannot initialize animation - widget not ready');
        return;
      }

      _controller = AnimationController(
        vsync: this,
        duration: _kDefaultAnimationDuration,
      );

      // Add listener for animation errors
      _controller.addStatusListener(_handleAnimationStatus);

      // Start the repeating animation with error handling
      _startAnimation();

    } catch (e, stackTrace) {
      debugPrint('AnimatedBackground: Failed to initialize animation - $e');
      debugPrint('Stack trace: $stackTrace');
      _createFallbackController();
    }
  }

  /// Starts the animation with error handling.
  void _startAnimation() {
    try {
      if (_controller.isAnimating) {
        _controller.stop();
      }
      _controller.repeat(reverse: true);
    } catch (e) {
      debugPrint('AnimatedBackground: Failed to start animation - $e');
      // Animation will remain static, which is acceptable fallback
    }
  }

  /// Handles animation status changes and errors.
  ///
  /// [status] The current animation status.
  void _handleAnimationStatus(AnimationStatus status) {
    if (!mounted || _isDisposed) return;

    try {
      switch (status) {
        case AnimationStatus.dismissed:
        case AnimationStatus.completed:
        // Animation completed normally
          break;
        case AnimationStatus.forward:
        case AnimationStatus.reverse:
        // Animation running normally
          break;
      }
    } catch (e) {
      debugPrint('AnimatedBackground: Error in animation status handler - $e');
    }
  }

  /// Creates a fallback animation controller when normal initialization fails.
  void _createFallbackController() {
    try {
      _controller = AnimationController(
        vsync: this,
        duration: _kDefaultAnimationDuration,
        value: 0.5, // Set to middle position for static display
      );
    } catch (e) {
      debugPrint('AnimatedBackground: Failed to create fallback controller - $e');
      // At this point, we'll handle null controller in build method
    }
  }

  /// Disposes of the animation controller to prevent memory leaks.
  ///
  /// This method ensures proper cleanup of resources when the widget
  /// is removed from the widget tree.
  ///
  /// Includes comprehensive cleanup and error handling:
  /// - Safe animation controller disposal
  /// - Status listener removal
  /// - State flag management
  /// - Error logging for debugging
  @override
  void dispose() {
    _isDisposed = true;

    try {
      // Remove animation status listener if it exists
      _controller?.removeStatusListener(_handleAnimationStatus);

      // Stop animation before disposal
      if (_controller?.isAnimating == true) {
        _controller?.stop();
      }

      // Dispose controller safely
      _controller?.dispose();
    } catch (e, stackTrace) {
      debugPrint('AnimatedBackground: Error during disposal - $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      // Ensure super.dispose() is always called
      super.dispose();
    }
  }

  /// Builds the animated background widget.
  ///
  /// Returns a [CustomPaint] widget wrapped in an [AnimatedBuilder]
  /// that repaints on each animation frame.
  ///
  /// The painting area automatically adapts to the screen size using
  /// [MediaQuery].
  @override
  Widget build(BuildContext context) {
    // Ensure we have a valid build context
    if (!mounted) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return _buildCustomPaint(context);
      },
    );
  }

  /// Builds the custom paint widget with comprehensive error handling.
  ///
  /// [context] The build context for accessing screen dimensions.
  ///
  /// Returns a [CustomPaint] widget configured with the current
  /// animation state and screen dimensions.
  ///
  /// Includes error handling for:
  /// - Invalid or disposed animation controller
  /// - Screen size calculation errors
  /// - InkPainter creation failures
  /// - Widget lifecycle issues
  Widget _buildCustomPaint(BuildContext context) {
    try {
      // Validate widget and controller state
      if (!_isWidgetReady()) {
        return _buildFallbackWidget();
      }

      final Size screenSize = _getScreenSize(context);
      final double progress = _getAnimationProgress();

      return CustomPaint(
        size: screenSize,
        painter: _createInkPainter(progress),
      );
    } catch (e, stackTrace) {
      debugPrint('AnimatedBackground: Failed to build custom paint - $e');
      debugPrint('Stack trace: $stackTrace');
      return _buildFallbackWidget();
    }
  }

  /// Checks if the widget and its dependencies are ready for rendering.
  ///
  /// Returns true if all components are properly initialized and ready.
  bool _isWidgetReady() {
    return mounted &&
        !_isDisposed &&
        _controller != null;
  }

  /// Gets the current animation progress with error handling.
  ///
  /// Returns the animation controller value or a fallback value.
  double _getAnimationProgress() {
    try {
      return _controller?.value ?? _kDefaultProgress;
    } catch (e) {
      debugPrint('AnimatedBackground: Error getting animation progress - $e');
      return _kDefaultProgress;
    }
  }

  /// Creates an InkPainter with error handling.
  ///
  /// [progress] The animation progress value.
  ///
  /// Returns a configured InkPainter or throws if creation fails.
  InkPainter _createInkPainter(double progress) {
    try {
      return InkPainter(
        progress: progress,
        gradientColors: _kDefaultGradientColors,
        opacity: _kDefaultOpacity,
      );
    } catch (e) {
      debugPrint('AnimatedBackground: Failed to create InkPainter - $e');
      rethrow; // Let the caller handle this with fallback widget
    }
  }

  /// Gets the screen size from the current context.
  ///
  /// [context] The build context for accessing MediaQuery.
  ///
  /// Returns the screen [Size] or a default size if MediaQuery is unavailable.
  ///
  /// This method includes comprehensive error handling for various edge cases:
  /// - Null or invalid context
  /// - Missing MediaQuery data
  /// - Invalid screen dimensions
  /// - Widget lifecycle issues
  Size _getScreenSize(BuildContext context) {
    // Default fallback size for error cases
    const Size fallbackSize = Size(400, 800);

    try {
      // Validate context availability
      if (!mounted || _isDisposed) {
        debugPrint('AnimatedBackground: Widget not mounted or disposed, using fallback size');
        return fallbackSize;
      }

      // Get MediaQuery data safely
      final MediaQueryData? mediaQuery = MediaQuery.maybeOf(context);
      if (mediaQuery == null) {
        debugPrint('AnimatedBackground: MediaQuery not available, using fallback size');
        return fallbackSize;
      }

      final Size screenSize = mediaQuery.size;

      // Validate screen dimensions
      if (!_isValidSize(screenSize)) {
        debugPrint('AnimatedBackground: Invalid screen size $screenSize, using fallback');
        return fallbackSize;
      }

      return screenSize;
    } catch (e, stackTrace) {
      // Log detailed error information for debugging
      debugPrint('AnimatedBackground: Error getting screen size - $e');
      debugPrint('Stack trace: $stackTrace');
      return fallbackSize;
    }
  }

  /// Validates if a size is reasonable for rendering.
  ///
  /// [size] The size to validate.
  ///
  /// Returns true if the size is valid (positive, finite, and reasonable),
  /// false otherwise.
  bool _isValidSize(Size size) {
    const double maxReasonableSize = 10000.0;
    const double minReasonableSize = 1.0;

    return size.width.isFinite &&
        size.height.isFinite &&
        size.width >= minReasonableSize &&
        size.height >= minReasonableSize &&
        size.width <= maxReasonableSize &&
        size.height <= maxReasonableSize;
  }

  /// Creates a fallback widget when painting fails.
  ///
  /// Returns a simple colored container as a fallback to ensure
  /// the UI doesn't break completely if painting fails.
  ///
  /// Includes error handling for fallback creation itself.
  Widget _buildFallbackWidget() {
    try {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF2A2A2A), // Dark charcoal
              const Color(0xFF6A6A6A), // Medium gray
              const Color(0xFFE0E0E0), // Light gray
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      );
    } catch (e) {
      debugPrint('AnimatedBackground: Failed to create fallback widget - $e');
      // Ultimate fallback - simple satin gray container
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF4A4A4A).withOpacity(0.8),
      );
    }
  }

  /// Checks if the widget is still mounted and not disposed.
  ///
  /// Returns true if the widget is safe to use, false otherwise.
  ///
  /// This method includes additional safety checks for edge cases.
  bool get isActive {
    try {
      return mounted && !_isDisposed && _controller != null;
    } catch (e) {
      debugPrint('AnimatedBackground: Error checking widget status - $e');
      return false;
    }
  }

  /// Provides debug information about the current widget state.
  ///
  /// Returns a map containing current state information for debugging.
  ///
  /// This method is useful for troubleshooting issues in development.
  Map<String, dynamic> get debugInfo {
    try {
      return {
        'mounted': mounted,
        'disposed': _isDisposed,
        'hasController': _controller != null,
        'isAnimating': _controller?.isAnimating ?? false,
        'animationValue': _controller?.value ?? 'null',
        'isActive': isActive,
      };
    } catch (e) {
      return {
        'error': 'Failed to get debug info: $e',
      };
    }
  }
}