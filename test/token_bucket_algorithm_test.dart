import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:token_bucket_algorithm/token_bucket_algorithm.dart';

void main() {
  test('Bucket is initialized with 0 tokens', () {
    final bucket = TokenBucket(
        size: 15, refillInterval: const Duration(seconds: 1), refillAmount: 10);
    expect(bucket.availableTokens, 0);
  });

  test('Consuming invalid amounts', () {
    const size = 15;
    const refillAmount = 10;
    const refillInterval = Duration(seconds: 1);
    final bucket = TokenBucket(
        size: size, refillInterval: refillInterval, refillAmount: refillAmount);
    final asyncBucket = AsyncTokenBucket(
        size: size, refillInterval: refillInterval, refillAmount: refillAmount);

    expect(() => bucket.consume(0), throwsArgumentError);
    expect(() => bucket.consume(size + 1), throwsArgumentError);
    expect(() => asyncBucket.consume(0), throwsArgumentError);
    expect(() => asyncBucket.consume(size + 1), throwsArgumentError);
    bucket.consume(1);
    bucket.consume(size);
    expect(asyncBucket.consume(1), completes);
    expect(asyncBucket.consume(size), completes);
  });

  test('Bucket gets correctly refilled', () {
    fakeAsync((async) {
      const size = 15;
      const refillAmount = 10;
      const refillInterval = Duration(seconds: 1);
      final bucket = TokenBucket(
          size: size,
          refillInterval: refillInterval,
          refillAmount: refillAmount);
      expect(bucket.availableTokens, 0);
      async.elapse(refillInterval);
      expect(bucket.availableTokens, refillAmount);
      async.elapse(refillInterval);
      expect(bucket.availableTokens, size);
    });
  });

  test('Bucket gets correctly refilled with corrupted time', () {
    fakeAsync((async) {
      const size = 15;
      const refillAmount = 10;
      const refillInterval = Duration(seconds: 1);
      final bucket = TokenBucket(
          size: size,
          refillInterval: refillInterval,
          refillAmount: refillAmount);

      fakeAsync((async) {
        expect(bucket.availableTokens, 0);
        async.elapse(const Duration(seconds: 1));
        expect(bucket.availableTokens, refillAmount);
      }, initialTime: clock.now().subtract(const Duration(days: 1)));

      expect(bucket.availableTokens, size);
    });
  });

  test('Bucket gets correctly consumed', () {
    fakeAsync((async) {
      const size = 15;
      const refillAmount = 10;
      const refillInterval = Duration(seconds: 1);
      final bucket = TokenBucket(
          size: size,
          refillInterval: refillInterval,
          refillAmount: refillAmount);
      expect(bucket.availableTokens, 0);
      async.elapse(refillInterval);
      expect(bucket.consume(), true);
      expect(bucket.consume(2), true);
      expect(bucket.availableTokens, refillAmount - 3);
      expect(bucket.consume(refillAmount), false);
      expect(bucket.availableTokens, refillAmount - 3);
    });
  });

  test('Async bucket gets correctly consumed', () async {
    fakeAsync((async) {
      const size = 15;
      const refillAmount = 10;
      const refillInterval = Duration(seconds: 1);
      final bucket = AsyncTokenBucket(
          size: size,
          refillInterval: refillInterval,
          refillAmount: refillAmount);
      expectLater(bucket.availableTokens, completion(0));
      async.elapse(refillInterval);
      expectLater(bucket.consume(), completion(true));
      expectLater(bucket.consume(2), completion(true));
      expectLater(bucket.availableTokens, completion(refillAmount - 3));
      expectLater(bucket.consume(refillAmount), completion(false));
      expectLater(bucket.availableTokens, completion(refillAmount - 3));
      async.elapse(Duration.zero);
    });
  });

  test('fromJson and toJson', () async {
    const tokens = 3;
    final lastRefillTime = DateTime(2000);
    final state =
        TokenBucketState(tokens: tokens, lastRefillTime: lastRefillTime);

    expect(
      state.toJson(),
      allOf(
        containsPair('tokens', tokens),
        containsPair('lastRefillTime', lastRefillTime.microsecondsSinceEpoch),
        hasLength(2),
      ),
    );

    expect(
      TokenBucketState.fromJson({
        'tokens': tokens,
        'lastRefillTime': lastRefillTime.microsecondsSinceEpoch,
      }),
      state,
    );
  });

  test('hashCode and ==', () async {
    const tokens = 3;
    final lastRefillTime = DateTime(2000);
    final state1 =
        TokenBucketState(tokens: tokens, lastRefillTime: lastRefillTime);
    final state2 =
        TokenBucketState(tokens: tokens, lastRefillTime: lastRefillTime);

    expect(state1, state2);
    expect(state1.hashCode, state2.hashCode);
  });

  test('copyWith', () async {
    const tokens = 3;
    final lastRefillTime = DateTime(2000);
    final state =
        TokenBucketState(tokens: tokens, lastRefillTime: lastRefillTime);

    expect(state.copyWith(tokens: 4),
        TokenBucketState(tokens: 4, lastRefillTime: lastRefillTime));
    expect(state.copyWith(lastRefillTime: DateTime(2001)),
        TokenBucketState(tokens: tokens, lastRefillTime: DateTime(2001)));
  });
}
