import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:token_bucket_algorithm/token_bucket_algorithm.dart';

void _testStorage(TokenBucketStorage storage) {
  final value = TokenBucketState(tokens: 4, lastRefillTime: DateTime(2003));
  expect(storage.get(), null, reason: 'get() does not return null initially');
  storage.set(value);
  expect(storage.get(), value, reason: 'get() does not return the set value');
  expect(storage.get(), value, reason: 'get() seems to change the value');
}

void main() {
  test('MemoryTokenBucketStorage', () {
    _testStorage(MemoryTokenBucketStorage());
  });

  test('StaticMemoryTokenBucketStorage', () {
    _testStorage(StaticMemoryTokenBucketStorage(key: 'test'));
  });
}
