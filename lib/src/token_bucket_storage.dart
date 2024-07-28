import 'dart:async';

import 'package:token_bucket_algorithm/token_bucket_algorithm.dart';

/// The base class for storing a [TokenBucketState].
abstract class AsyncTokenBucketStorage {
  const AsyncTokenBucketStorage();

  /// Gets the current [TokenBucketState] stored by this storage.
  ///
  /// Returns [null] if no state is available.
  FutureOr<TokenBucketState?> get();

  /// Overwrites the currently stored [TokenBucketState] of this storage.
  FutureOr<void> set(TokenBucketState state);
}

/// The base class for storing a [TokenBucketState] synchronously.
abstract class TokenBucketStorage extends AsyncTokenBucketStorage {
  const TokenBucketStorage();

  @override
  TokenBucketState? get();

  @override
  void set(TokenBucketState state);
}

/// This [TokenBucketStorage] stores a [TokenBucketState] as local variable in memory.
class MemoryTokenBucketStorage extends TokenBucketStorage {
  MemoryTokenBucketStorage();

  TokenBucketState? _state;

  @override
  TokenBucketState? get() => _state;

  @override
  void set(TokenBucketState state) => _state = state;
}

/// This [TokenBucketStorage] stores a [TokenBucketState] as static variable in memory.
class StaticMemoryTokenBucketStorage extends TokenBucketStorage {
  static final Map<String, TokenBucketState> _states = {};

  final String key;

  StaticMemoryTokenBucketStorage({required this.key});

  @override
  TokenBucketState? get() => _states[key];

  @override
  void set(TokenBucketState state) => _states[key] = state;
}
