import 'dart:async';

import 'package:flutter/material.dart';

/// 앱 초기 로딩 시 표시되는 스플래시 화면 (라벤더 배경, Feely 브랜딩)
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.progress = 0.0,
    this.onComplete,
    this.minimumDuration = const Duration(milliseconds: 2200),
  });

  /// 0.0 ~ 1.0 진행률 (애니메이션용)
  final double progress;
  /// 최소 표시 시간이 지나고 진행률 1일 때 호출
  final VoidCallback? onComplete;
  /// 최소 표시 시간
  final Duration minimumDuration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _minTimeElapsed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.minimumDuration, () {
      if (mounted) setState(() => _minTimeElapsed = true);
    });
  }

  @override
  void didUpdateWidget(SplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_minTimeElapsed && widget.progress >= 1.0 && widget.onComplete != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onComplete?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FeelySplashColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              Text(
                'Feely',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: FeelySplashColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'How are you today?',
                style: TextStyle(
                  fontSize: 16,
                  color: FeelySplashColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(flex: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: widget.progress,
                  minHeight: 4,
                  backgroundColor: FeelySplashColors.progressTrack,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    FeelySplashColors.progressFill,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '로딩 중 ...',
                style: TextStyle(
                  fontSize: 14,
                  color: FeelySplashColors.textSecondary,
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

/// 스플래시 후 메인으로 전환하는 래퍼 (최소 표시 시간 + 진행률 애니메이션)
class SplashThenMain extends StatefulWidget {
  const SplashThenMain({
    super.key,
    required this.child,
    this.minDuration = const Duration(milliseconds: 2200),
  });

  final Widget child;
  final Duration minDuration;

  @override
  State<SplashThenMain> createState() => _SplashThenMainState();
}

class _SplashThenMainState extends State<SplashThenMain>
    with SingleTickerProviderStateMixin {
  bool _showMain = false;
  bool _completionScheduled = false;
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_completionScheduled) {
        _completionScheduled = true;
        if (mounted) setState(() => _showMain = true);
      }
    });
    Future.delayed(widget.minDuration, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showMain) return widget.child;
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, _) => SplashScreen(
        progress: _progressAnimation.value,
        minimumDuration: widget.minDuration,
      ),
    );
  }
}

abstract class FeelySplashColors {
  static const Color background = Color(0xFFCFC7E7);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFF5F5F5);
  static const Color progressTrack = Color(0xFFB8A9C9);
  static const Color progressFill = Color(0xFFFFFFFF);
}
