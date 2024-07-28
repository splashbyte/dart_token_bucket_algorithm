import 'package:flutter_test/flutter_test.dart';
import 'package:token_bucket_algorithm/token_bucket_algorithm.dart';

void main() {
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
