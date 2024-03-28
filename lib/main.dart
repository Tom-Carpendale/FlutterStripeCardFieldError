import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  Stripe.publishableKey = 'key';
  await Stripe.instance.applySettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: const Column(
        children: [
          DelayedSlideIn(
            child: CardField(
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            )
          )
        ]
      )
    );
  }
}

class DelayedSlideIn extends StatefulWidget {
  final Widget child;

  const DelayedSlideIn({super.key, 
    required this.child,
  });

  @override
  DelayedSlideInState createState() =>
    DelayedSlideInState();
}

class DelayedSlideInState extends State<DelayedSlideIn> 
  with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
    
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation1;
  late Animation<double> _fadeAnimation2;
  late Animation<double> _constAnimation1;
  late Animation<double> _constAnimation2;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // This animation does not cause the card-element to break
    _fadeAnimation1 = Tween<double>(
      begin: 0.001975, // A value just below this causes the card-element to break 
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // This animation breaks the card-element
    _fadeAnimation2 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // This does not break the card-element
    _constAnimation1 = ConstantTween<double>(0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // This does break the card-element
    _constAnimation2 = ConstantTween<double>(0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (mounted) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Only play the animation once
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Column(
          children: [
            FadeTransition(
              // Change this animation between the 4 above to see the error for
              // _constAnimation2 and _fadeAnimation2
              opacity: _fadeAnimation2,
              child: child!,
            ),
          ]
        );
      },
      child: widget.child,
    );
  }
}