import 'dart:async';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:token_bucket_algorithm/src/token_bucket_storage.dart';

part 'token_bucket_state.dart';

abstract class _BaseTokenBucket<S extends AsyncTokenBucketStorage> {
  /// The maximum token amount of this bucket.
  final int size;

  /// The interval for refilling the bucket.
  final Duration refillInterval;

  /// The amount of tokens that is refilled every [refillInterval].
  final int refillAmount;

  /// The storage for the internal [TokenBucketState].
  final S storage;

  _BaseTokenBucket({
    required this.size,
    required this.refillInterval,
    required this.refillAmount,
    required this.storage,
  })  : assert(size > 0),
        assert(refillAmount > 0),
        assert(refillInterval > Duration.zero);

  /// Returns the currently available tokens of this bucket.
  FutureOr<int> get availableTokens;

  /// Consumes [cost] tokens and returns whether the consuming was successful.
  FutureOr<bool> consume([int cost = 1]);

  TokenBucketState _refillBucket(TokenBucketState state) {
    final now = clock.now();

    // relevant if e.g. user updates time in settings
    if (state.lastRefillTime.isAfter(now)) {
      return state.copyWith(lastRefillTime: now);
    }

    final refillTimes = (now.difference(state.lastRefillTime)).inMicroseconds ~/
        refillInterval.inMicroseconds;

    final newTokenCount = min(size, state.tokens + refillTimes * refillAmount);

    return state.copyWith(
      tokens: newTokenCount,
      lastRefillTime: state.lastRefillTime.add(refillInterval * refillTimes),
    );
  }
}

/// An async token bucket which can have an async [storage].
class AsyncTokenBucket extends _BaseTokenBucket<AsyncTokenBucketStorage> {
  Future<void> _future = Future.value();

  AsyncTokenBucket({
    required super.size,
    required super.refillInterval,
    required super.refillAmount,
    AsyncTokenBucketStorage? storage,
  }) : super(storage: storage ?? MemoryTokenBucketStorage());

  @override
  FutureOr<int> get availableTokens async {
    await _queueFuture(() async {
      await storage.set(_refillBucket(await storage.get()));
      return false;
    });
    return Future.value(storage.get()).then((state) => state.tokens);
  }

  @override
  FutureOr<bool> consume([int cost = 1]) async {
    if (cost < 1 || cost > size) {
      throw ArgumentError('cost must be <=$size and >=1');
    }
    return _queueFuture(() async {
      final state = _refillBucket(await storage.get());
      final (result, newState) = state.consume(cost);
      await storage.set(newState);
      return result;
    });
  }

  Future<T> _queueFuture<T>(Future<T> Function() computation) {
    final newFuture = _future.then((_) => computation());
    _future = newFuture.whenComplete(() {
      if (_future == newFuture) _future = Future.value();
    });
    return newFuture;
  }
}

/// A standard token bucket.
///
/// If you want to store the [TokenBucketState] in an [AsyncTokenBucketStorage],
/// you have to use [AsyncTokenBucket] instead.
class TokenBucket extends _BaseTokenBucket<TokenBucketStorage> {
  TokenBucket({
    required super.size,
    required super.refillInterval,
    required super.refillAmount,
    TokenBucketStorage? storage,
  }) : super(storage: storage ?? MemoryTokenBucketStorage());

  @override
  int get availableTokens {
    storage.set(_refillBucket(storage.get()));
    return storage.get().tokens;
  }

  @override
  bool consume([int cost = 1]) {
    if (cost < 1 || cost > size) {
      throw ArgumentError('cost must be <=$size and >=1');
    }
    final state = _refillBucket(storage.get());
    final (result, newState) = state.consume(cost);
    storage.set(newState);
    return result;
  }
}
