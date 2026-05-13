import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final String? fallbackMessage;
  final bool enableLogging;
  
  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.fallbackMessage,
    this.enableLogging = true,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    _setupErrorHandling();
  }

  void _setupErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (widget.enableLogging) {
        developer.log(
          'Flutter Error: ${details.exception}',
          name: 'ErrorBoundary',
          error: details.exception,
          stackTrace: details.stack,
        );
      }
      
      if (mounted) {
        setState(() {
          _error = details.exception;
          _stackTrace = details.stack;
        });
      }
    };
  }

  void _resetError() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  void _logError(Object error, StackTrace? stackTrace) {
    if (widget.enableLogging) {
      developer.log(
        'Error Boundary Caught: $error',
        name: 'ErrorBoundary',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      _logError(_error!, _stackTrace);
      return widget.errorBuilder?.call(_error!, _stackTrace) ??
          _DefaultErrorWidget(
            error: _error!,
            stackTrace: _stackTrace,
            onRetry: _resetError,
            fallbackMessage: widget.fallbackMessage,
          );
    }

    try {
      return widget.child;
    } catch (error, stackTrace) {
      _logError(error, stackTrace);
      setState(() {
        _error = error;
        _stackTrace = stackTrace;
      });
      return widget.errorBuilder?.call(error, stackTrace) ??
          _DefaultErrorWidget(
            error: error,
            stackTrace: stackTrace,
            onRetry: _resetError,
            fallbackMessage: widget.fallbackMessage,
          );
    }
  }
}

class _DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback onRetry;
  final String? fallbackMessage;
  
  const _DefaultErrorWidget({
    required this.error,
    this.stackTrace,
    required this.onRetry,
    this.fallbackMessage,
  });

  @override
  Widget build(BuildContext context) {
    String errorMessage = fallbackMessage ?? 'An unexpected error occurred';
    String errorDetails = error.toString();
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red[600],
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Error Title
              Text(
                errorMessage,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Error Details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Error Details:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorDetails.length > 200 
                          ? '${errorDetails.substring(0, 200)}...'
                          : errorDetails,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Try Again'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Copy error to clipboard functionality could be added here
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[600],
                        side: BorderSide(color: Colors.red[600]!),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Copy Error'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Help Text
              Center(
                child: Text(
                  'If this problem persists, please contact support.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
