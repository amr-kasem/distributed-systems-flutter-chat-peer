import 'dart:async';
import 'dart:math';

/// Configuration for retry behavior
class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final bool addJitter;

  const RetryConfig({
    this.maxAttempts = 5,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.addJitter = true,
  });

  static const RetryConfig mqtt = RetryConfig(
    maxAttempts: 10,
    initialDelay: Duration(seconds: 1),
    maxDelay: Duration(seconds: 60),
  );

  static const RetryConfig webrtc = RetryConfig(
    maxAttempts: 3,
    initialDelay: Duration(milliseconds: 500),
    maxDelay: Duration(seconds: 10),
  );

  static const RetryConfig message = RetryConfig(
    maxAttempts: 3,
    initialDelay: Duration(seconds: 2),
    maxDelay: Duration(seconds: 15),
  );
}

/// Result of a retry operation
class RetryResult<T> {
  final T? value;
  final Object? error;
  final int attempts;
  final bool success;

  RetryResult.success(this.value, this.attempts) : error = null, success = true;

  RetryResult.failure(this.error, this.attempts)
    : value = null,
      success = false;
}

/// Helper class for implementing retry logic with exponential backoff
class RetryHelper {
  static final _random = Random();

  /// Execute an operation with retry logic
  static Future<RetryResult<T>> retry<T>(
    Future<T> Function() operation, {
    RetryConfig config = const RetryConfig(),
    bool Function(Object error)? retryIf,
    void Function(int attempt, Object error, Duration nextDelay)? onRetry,
  }) async {
    int attempt = 0;
    Duration currentDelay = config.initialDelay;

    while (attempt < config.maxAttempts) {
      attempt++;
      try {
        final result = await operation();
        return RetryResult.success(result, attempt);
      } catch (e) {
        // Check if we should retry this error
        if (retryIf != null && !retryIf(e)) {
          return RetryResult.failure(e, attempt);
        }

        // Check if we've exhausted retries
        if (attempt >= config.maxAttempts) {
          return RetryResult.failure(e, attempt);
        }

        // Calculate delay with optional jitter
        final delay = _calculateDelay(currentDelay, config);
        onRetry?.call(attempt, e, delay);

        // Wait before next attempt
        await Future.delayed(delay);

        // Update delay for next attempt
        currentDelay = Duration(
          milliseconds: (currentDelay.inMilliseconds * config.backoffMultiplier)
              .toInt(),
        );
        if (currentDelay > config.maxDelay) {
          currentDelay = config.maxDelay;
        }
      }
    }

    return RetryResult.failure(
      Exception('Retry exhausted without success'),
      attempt,
    );
  }

  /// Calculate delay with optional jitter to avoid thundering herd
  static Duration _calculateDelay(Duration baseDelay, RetryConfig config) {
    if (!config.addJitter) return baseDelay;

    // Add jitter of ±25%
    final jitterFactor = 0.75 + (_random.nextDouble() * 0.5);
    return Duration(
      milliseconds: (baseDelay.inMilliseconds * jitterFactor).toInt(),
    );
  }

  /// Execute with timeout
  static Future<T> withTimeout<T>(
    Future<T> Function() operation, {
    required Duration timeout,
    String? operationName,
  }) async {
    try {
      return await operation().timeout(timeout);
    } on TimeoutException {
      throw TimeoutException(
        '${operationName ?? 'Operation'} timed out after ${timeout.inSeconds}s',
        timeout,
      );
    }
  }
}

/// Mixin for classes that need reconnection logic
mixin ReconnectionMixin {
  int _reconnectAttempt = 0;
  bool _isReconnecting = false;
  Timer? _reconnectTimer;

  int get reconnectAttempt => _reconnectAttempt;
  bool get isReconnecting => _isReconnecting;

  /// Start reconnection with exponential backoff
  Future<bool> reconnectWithBackoff({
    required Future<bool> Function() connectFn,
    required RetryConfig config,
    void Function(int attempt, Duration delay)? onAttempt,
    void Function()? onSuccess,
    void Function(int totalAttempts)? onGiveUp,
  }) async {
    if (_isReconnecting) return false;
    _isReconnecting = true;
    _reconnectAttempt = 0;

    Duration delay = config.initialDelay;

    while (_reconnectAttempt < config.maxAttempts && _isReconnecting) {
      _reconnectAttempt++;
      onAttempt?.call(_reconnectAttempt, delay);

      try {
        final connected = await connectFn();
        if (connected) {
          _isReconnecting = false;
          _reconnectAttempt = 0;
          onSuccess?.call();
          return true;
        }
      } catch (_) {
        // Continue to retry
      }

      if (_reconnectAttempt >= config.maxAttempts) {
        _isReconnecting = false;
        onGiveUp?.call(_reconnectAttempt);
        return false;
      }

      // Wait before next attempt
      await Future.delayed(delay);

      // Calculate next delay with backoff
      delay = Duration(
        milliseconds: (delay.inMilliseconds * config.backoffMultiplier).toInt(),
      );
      if (delay > config.maxDelay) {
        delay = config.maxDelay;
      }
    }

    _isReconnecting = false;
    return false;
  }

  /// Cancel ongoing reconnection attempts
  void cancelReconnection() {
    _isReconnecting = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Reset reconnection state
  void resetReconnection() {
    _reconnectAttempt = 0;
    _isReconnecting = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }
}
