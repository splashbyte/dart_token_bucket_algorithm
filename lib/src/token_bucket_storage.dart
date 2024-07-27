import 'dart:async';

import 'package:clock/clock.dart';
import 'package:token_bucket_algorithm/token_bucket_algorithm.dart';

abstract class TokenBucketStorage extends AsyncTokenBucketStorage {
  const TokenBucketStorage();

  @override
  TokenBucketState get();

  @override
  void set(TokenBucketState state);
}

class MemoryTokenBucketStorage extends TokenBucketStorage {
  MemoryTokenBucketStorage();

  TokenBucketState _state =
      TokenBucketState(tokens: 0, lastRefillTime: clock.now());

  @override
  TokenBucketState get() => _state;

  @override
  void set(TokenBucketState state) => _state = state;
}

abstract class AsyncTokenBucketStorage {
  const AsyncTokenBucketStorage();

  FutureOr<TokenBucketState> get();

  FutureOr<void> set(TokenBucketState state);
}
