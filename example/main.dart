import 'package:token_bucket_algorithm/token_bucket_algorithm.dart';

void main() {
  final bucket = TokenBucket(
    size: 15,
    refillInterval: const Duration(seconds: 1),
    refillAmount: 10,
    storage: MemoryTokenBucketStorage(),
  );

  if(bucket.consume()) {
    // Consumed 1 token successfully
  }

  if(bucket.consume(2)) {
    // Consumed 2 tokens successfully
  }
}
