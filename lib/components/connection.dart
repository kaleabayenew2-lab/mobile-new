import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class ConnectionStatus extends StatefulWidget {
  final Widget child;
  final Widget Function()? onDisconnected;
  final Widget Function()? onConnected;
  
  const ConnectionStatus({
    super.key,
    required this.child,
    this.onDisconnected,
    this.onConnected,
  });

  @override
  State<ConnectionStatus> createState() => _ConnectionStatusState();
}

class _ConnectionStatusState extends State<ConnectionStatus> {
  bool _isConnected = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkConnection());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (!_isConnected) {
          setState(() {
            _isConnected = true;
          });
        }
      }
    } on SocketException catch (_) {
      if (_isConnected) {
        setState(() {
          _isConnected = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return widget.onDisconnected?.call() ?? const _NoConnectionWidget();
    }
    
    return widget.onConnected?.call() ?? widget.child;
  }
}

class _NoConnectionWidget extends StatelessWidget {
  const _NoConnectionWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off,
                color: Colors.grey,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please check your internet connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Trigger retry by rebuilding the widget
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const _RetryScreen(),
                    ),
                  );
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RetryScreen extends StatelessWidget {
  const _RetryScreen();

  @override
  Widget build(BuildContext context) {
    return const ConnectionStatus(
      child: Scaffold(
        body: Center(
          child: Text('Connected!'),
        ),
      ),
    );
  }
}

class ConnectionBanner extends StatelessWidget {
  final bool isConnected;
  final VoidCallback? onRetry;
  
  const ConnectionBanner({
    super.key,
    required this.isConnected,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isConnected) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.red,
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'No internet connection',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          if (onRetry != null)
            GestureDetector(
              onTap: onRetry,
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.underline),
              ),
            ),
        ],
      ),
    );
  }
}
