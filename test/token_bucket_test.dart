import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:token_bucket_algorithm/token_bucket_algorithm.dart';

import 'mocks.dart';

void main() {
  test('Bucket is respects initialAmount', () {
    final bucket1 = TokenBucket(
        size: 15, refillInterval: const Duration(seconds: 1), refillAmount: 10);
    expect(bucket1.availableTokens, 0);

    final bucket2 = TokenBucket(
        size: 15,
        refillInterval: const Duration(seconds: 1),
        refillAmount: 10,
        initialAmount: 3);
    expect(bucket2.availableTokens, 3);
  });

  test('Bucket stores token initially', () {
    fakeAsync((async) {
      final storage = MockTokenBucketStorage();
      when(() => storage.get()).thenReturn(null);
      TokenBucket(
        size: 15,
        refillInterval: const Duration(seconds: 1),
        refillAmount: 10,
        initialAmount: 3,
        storage: storage,
      );
      verify(() => storage.set(
          TokenBucketState(tokens: 3, lastRefillTime: clock.now()))).called(1);
    });
  });

  test('Async bucket stores token initially', () {
    fakeAsync((async) {
      final storage = MockTokenBucketStorage();
      when(() => storage.get()).thenReturn(null);
      AsyncTokenBucket(
        size: 15,
        refillInterval: const Duration(seconds: 1),
        refillAmount: 10,
        initialAmount: 3,
        storage: storage,
      );
      async.flushMicrotasks();
      verify(() => storage.set(
          TokenBucketState(tokens: 3, lastRefillTime: clock.now()))).called(1);
    });
  });

  test('Bucket respects storage value', () {
    final storage = MockTokenBucketStorage();
    final tokenBucketState =
        TokenBucketState(tokens: 3, lastRefillTime: clock.now());
    when(() => storage.get()).thenReturn(tokenBucketState);
    final bucket = TokenBucket(
      size: 15,
      refillInterval: const Duration(seconds: 1),
      refillAmount: 10,
      storage: storage,
    );
    expect(bucket.availableTokens, tokenBucketState.tokens);
  });

  test('Async bucket respects storage value', () {
    final storage = MockTokenBucketStorage();
    final tokenBucketState =
        TokenBucketState(tokens: 3, lastRefillTime: clock.now());
    when(() => storage.get()).thenReturn(tokenBucketState);
    final bucket = AsyncTokenBucket(
      size: 15,
      refillInterval: const Duration(seconds: 1),
      refillAmount: 10,
      storage: storage,
    );
    expect(bucket.availableTokens, completion(tokenBucketState.tokens));
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
}
