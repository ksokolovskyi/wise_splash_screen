import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:wise_splash_screen/app.dart';
import 'package:wise_splash_screen/app_data.dart';
import 'package:wise_splash_screen/wise_splash_screen.dart';

class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  final _isSplashScreenVisible = ValueNotifier(true);

  final _data = ValueNotifier<AppData?>(null);

  late final _controller = WiseSplashScreen.createController(this);

  Future<void>? _loader;

  @override
  void initState() {
    super.initState();

    _controller.addStatusListener(
      (AnimationStatus status) {
        _isSplashScreenVisible.value = !status.isCompleted;
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loader ??= _load(context);
  }

  @override
  void dispose() {
    _isSplashScreenVisible.dispose();
    _data.dispose();
    _controller.dispose();

    super.dispose();
  }

  Future<void> _load(BuildContext context) async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));

    _data.value = const AppData();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.forward().ignore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ValueListenableBuilder(
              valueListenable: _data,
              builder: (context, data, _) {
                if (data == null) {
                  return const SizedBox.shrink();
                }

                return App(data: data);
              },
            ),
            ValueListenableBuilder(
              valueListenable: _isSplashScreenVisible,
              builder: (context, isSplashScreenVisible, splashScreen) {
                if (isSplashScreenVisible) {
                  return splashScreen!;
                }

                return const SizedBox.shrink();
              },
              child: WiseSplashScreen(controller: _controller),
            ),
          ],
        ),
      ),
    );
  }
}
