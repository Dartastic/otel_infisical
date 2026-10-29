// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_infisical/otel_infisical.dart';

/// Traces Infisical calls with OpenTelemetry.
///
/// `otel_infisical` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Infisical call in
/// [tracedInfisical]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'infisical-example');

  // Traces a Infisical call.
  final infisicalId = await tracedInfisical<String>(
    operation: 'create',
    invoke: () async {
      // Make the Infisical call here, then report what it returned.
      const id = 'infisical_8f3a2c';
      return const InfisicalCallResult(
          value: id,
          result: InfisicalResult(
              organization: 'example',
              project: 'example',
              environment: 'example',
              path: '/v1/orders',
              secretName: 'example',
              secretsCount: 3,
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedInfisical create returned $infisicalId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutInfisicalInstrumentationAsync.
  await runWithoutInfisicalInstrumentationAsync(
    () => tracedInfisical<String>(
      operation: 'create',
      invoke: () async {
        const id = 'infisical_8f3a2c';
        return const InfisicalCallResult(
            value: id,
            result: InfisicalResult(
                organization: 'example',
                project: 'example',
                environment: 'example',
                path: '/v1/orders',
                secretName: 'example',
                secretsCount: 3,
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
