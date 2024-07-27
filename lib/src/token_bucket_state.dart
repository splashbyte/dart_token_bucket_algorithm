part of 'token_bucket.dart';

class TokenBucketState {
  /// Currently available tokens.
  final int tokens;

  /// The last time the tokens were refilled.
  final DateTime lastRefillTime;

  const TokenBucketState({required this.tokens, required this.lastRefillTime});

  /// Copies this state with [tokens] or [lastRefillTime] updated.
  TokenBucketState copyWith({int? tokens, DateTime? lastRefillTime}) {
    return TokenBucketState(
      tokens: tokens ?? this.tokens,
      lastRefillTime: lastRefillTime ?? this.lastRefillTime,
    );
  }

  (bool, TokenBucketState) consume(int cost) =>
      tokens < cost ? (false, this) : (true, copyWith(tokens: tokens - cost));

  factory TokenBucketState.fromJson(Map<String, dynamic> json) =>
      TokenBucketState(
        tokens: json['tokens'] as int,
        lastRefillTime:
            DateTime.fromMicrosecondsSinceEpoch(json['lastRefillTime'] as int),
      );

  Map<String, dynamic> toJson() => {
        'tokens': tokens,
        'lastRefillTime': lastRefillTime.microsecondsSinceEpoch,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenBucketState &&
          runtimeType == other.runtimeType &&
          tokens == other.tokens &&
          lastRefillTime == other.lastRefillTime;

  @override
  int get hashCode => tokens.hashCode ^ lastRefillTime.hashCode;
}
