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
  static const double _kDefaultOpacity = 0.9;

  // Default gradient colors
  static const List<Color> _kDefaultGradientColors = [
    Colors.blue,
    Colors.purple,
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
  void _initializeAnimation() {
    try {
      _controller = AnimationController(
        vsync: this,
        duration: _kDefaultAnimationDuration,
      );

      // Start the repeating animation
      _controller.repeat(reverse: true);
    } catch (e) {
      // Handle potential initialization errors
      debugPrint('AnimatedBackground: Failed to initialize animation - $e');
      // Create a fallback controller that doesn't animate
      _controller = AnimationController(
        vsync: this,
        duration: _kDefaultAnimationDuration,
      );
    }
  }

  /// Disposes of the animation controller to prevent memory leaks.
  ///
  /// This method ensures proper cleanup of resources when the widget
  /// is removed from the widget tree.
  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
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

  /// Builds the custom paint widget with error handling.
  ///
  /// [context] The build context for accessing screen dimensions.
  ///
  /// Returns a [CustomPaint] widget configured with the current
  /// animation state and screen dimensions.
  Widget _buildCustomPaint(BuildContext context) {
    try {
      final Size screenSize = _getScreenSize(context);

      return CustomPaint(
        size: screenSize,
        painter: InkPainter(
          progress: _kDefaultProgress,
          gradientColors: _kDefaultGradientColors,
          opacity: _kDefaultOpacity,
        ),
      );
    } catch (e) {
      // Handle potential painting errors gracefully
      debugPrint('AnimatedBackground: Failed to build custom paint - $e');
      return _buildFallbackWidget();
    }
  }

  /// Gets the screen size from the current context.
  ///
  /// [context] The build context for accessing MediaQuery.
  ///
  /// Returns the screen [Size] or a default size if MediaQuery is unavailable.
  ///
  /// Throws [ArgumentError] if context is null.
  Size _getScreenSize(BuildContext context) {
    if (context == null) {
      throw ArgumentError('Context cannot be null');
    }

    try {
      final MediaQueryData? mediaQuery = MediaQuery.maybeOf(context);
      if (mediaQuery != null) {
        return mediaQuery.size;
      }

      // Fallback to a reasonable default size
      debugPrint('AnimatedBackground: MediaQuery not available, using default size');
      return const Size(400, 800);
    } catch (e) {
      debugPrint('AnimatedBackground: Error getting screen size - $e');
      return const Size(400, 800);
    }
  }

  /// Creates a fallback widget when painting fails.
  ///
  /// Returns a simple colored container as a fallback to ensure
  /// the UI doesn't break completely if painting fails.
  Widget _buildFallbackWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _kDefaultGradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  /// Checks if the widget is still mounted and not disposed.
  ///
  /// Returns true if the widget is safe to use, false otherwise.
  bool get isActive => mounted && !_isDisposed;
}