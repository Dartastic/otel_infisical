// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_infisical/otel_infisical.dart';
import 'package:test/test.dart';

void main() {
  group('otel_infisical', () {
    test('suppression toggles in zone', () async {
      expect(infisicalInstrumentationSuppressed(), isFalse);
      await runWithoutInfisicalInstrumentationAsync(() async {
        expect(infisicalInstrumentationSuppressed(), isTrue);
      });
      expect(infisicalInstrumentationSuppressed(), isFalse);
    });

    test('InfisicalResult fields default null', () {
      const r = InfisicalResult();
      expect(r.statusCode, isNull);
    });
  });
}
