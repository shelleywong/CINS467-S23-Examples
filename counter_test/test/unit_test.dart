import 'package:flutter_test/flutter_test.dart';

import 'package:counter_test/main.dart';

void main() {
  test('Confirm Counter class increment', () async {
    final counter = Counter();
    expect(counter.value, 0);
    counter.increment();
    expect(counter.value, 1);
  });

  test('Confirm Counter value does not go below zero', () async {
    final counter = Counter();
    expect(counter.value, 0);
    counter.decrement();
    expect(counter.value, 0);
  });

  test('Confirm Counter value decrements positive values', () async {
    final counter = Counter();
    expect(counter.value, 0);
    counter.increment();
    counter.increment();
    expect(counter.value, 2);
    counter.decrement();
    expect(counter.value, 1);
  });
}