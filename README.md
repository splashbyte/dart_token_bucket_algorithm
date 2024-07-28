# token_bucket_algorithm

[![pub.dev](https://img.shields.io/pub/v/token_bucket_algorithm.svg?style=flat?logo=dart)](https://pub.dev/packages/token_bucket_algorithm)
[![github](https://img.shields.io/static/v1?label=platform&message=flutter&color=1ebbfd)](https://github.com/splashbyte/dart_token_bucket_algorithm)
[![likes](https://img.shields.io/pub/likes/token_bucket_algorithm)](https://pub.dev/packages/token_bucket_algorithm/score)
[![popularity](https://img.shields.io/pub/popularity/token_bucket_algorithm)](https://pub.dev/packages/token_bucket_algorithm/score)
[![pub points](https://img.shields.io/pub/points/token_bucket_algorithm)](https://pub.dev/packages/token_bucket_algorithm/score)
[![license](https://img.shields.io/github/license/splashbyte/dart_token_bucket_algorithm.svg)](https://github.com/SplashByte/dart_token_bucket_algorithm/blob/main/LICENSE)
[![codecov](https://codecov.io/gh/splashbyte/dart_token_bucket_algorithm/branch/main/graph/badge.svg?token=NY1D6W88H2)](https://codecov.io/gh/splashbyte/dart_token_bucket_algorithm)

This Dart package provides rate limiting by using an implementation of the token bucket algorithm.

## Simple usage

```dart
final bucket = TokenBucket(
  size: 15,
  refillInterval: const Duration(seconds: 1),
  refillAmount: 10,
  storage: MemoryTokenBucketStorage(), // optionally change the way the state of the bucket is stored
);

if(bucket.consume()) {
  // Consumed 1 token successfully
}

if(bucket.consume(2)) {
  // Consumed 2 tokens successfully
}
```

If you want to store the tokens asynchronously in a custom storage, you can also use the `AsyncTokenBucket`.

```dart
final bucket = AsyncTokenBucket(
  size: 15,
  refillInterval: const Duration(seconds: 1),
  refillAmount: 10,
  storage: MyCustomAsyncTokenBucketStorage(),
);

if(await bucket.consume()) {
  // Consumed 1 token successfully
}
```
