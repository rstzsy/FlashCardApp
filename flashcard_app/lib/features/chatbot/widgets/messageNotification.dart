import 'package:flutter/material.dart';

class AppNotification {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // should get overlay directly from NavigatorState
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // saving a reference to the currently displayed entry, used for safe cleanup.
  static OverlayEntry? _currentEntry;

  static void show(
    String message, {
    IconData icon = Icons.auto_awesome_rounded,
  }) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    // if having an old notification, remove it immediately (no need to animate out since
    // the new one will replace it), as long as it's still mounted in the overlay.
    final oldEntry = _currentEntry;
    if (oldEntry != null && oldEntry.mounted) {
      oldEntry.remove();
    }
    _currentEntry = null;

    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _CuteNotificationBanner(
        message: message,
        icon: icon,
        onDismissed: () {
          // jusy remove the entry if it's still the current one, otherwise do nothing.
          if (identical(_currentEntry, entry)) {
            if (entry.mounted) entry.remove();
            _currentEntry = null;
          }
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }
}

class _CuteNotificationBanner extends StatefulWidget {
  final String message;
  final IconData icon;
  final VoidCallback onDismissed;

  const _CuteNotificationBanner({
    required this.message,
    required this.icon,
    required this.onDismissed,
  });

  @override
  State<_CuteNotificationBanner> createState() =>
      _CuteNotificationBannerState();
}

class _CuteNotificationBannerState extends State<_CuteNotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  bool _dismissed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 250),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();

    // after 5s animated out and then remove overlay
    Future.delayed(const Duration(seconds: 5), _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted || _dismissed) return;
    _dismissed = true;
    await _controller.reverse();
    // state can be unmounted during the animation, so check again.
    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 16,
      right: 16,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: _dismiss,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFE1EC), // pink pastel
                          Color(0xFFFFF3E0), // yellow pastel
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFFC1D9),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB3C6).withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.icon,
                            size: 16,
                            color: const Color(0xFFFF8FAB),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            widget.message,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B4F5A),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}