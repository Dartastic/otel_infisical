// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_infisical_suppression.dart';

class InfisicalResult {
  const InfisicalResult({
    this.organization,
    this.project,
    this.environment,
    this.path,
    this.secretName,
    this.secretsCount,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? organization;
  final String? project;
  final String? environment;
  final String? path;
  final String? secretName;
  final int? secretsCount;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class InfisicalCallResult<T> {
  const InfisicalCallResult({required this.value, this.result});
  final T value;
  final InfisicalResult? result;
}

Future<T> tracedInfisical<T>({
  required String operation,
  required Future<InfisicalCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (infisicalInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_infisical');
  final span = t.startSpan('infisical $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'infisical');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.organization != null) {
        span.setStringAttribute('infisical.organization', res.organization!);
      }
      if (res.project != null) {
        span.setStringAttribute('infisical.project', res.project!);
      }
      if (res.environment != null) {
        span.setStringAttribute('infisical.environment', res.environment!);
      }
      if (res.path != null) {
        span.setStringAttribute('infisical.path', res.path!);
      }
      if (res.secretName != null) {
        span.setStringAttribute('infisical.secret.name', res.secretName!);
      }
      if (res.secretsCount != null) {
        span.setIntAttribute('infisical.secrets.count', res.secretsCount!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('infisical.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'infisical.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
