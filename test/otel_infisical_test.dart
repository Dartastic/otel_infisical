// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

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
