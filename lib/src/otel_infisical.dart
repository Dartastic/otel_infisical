// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_infisical_suppression.dart';

class InfisicalResult {
  /// Creates a result.
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

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class InfisicalCallResult<T> {
  /// Creates a call result.
  const InfisicalCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final InfisicalResult? result;
}

Future<T> tracedInfisical<T>({
  required String operation,
  required Future<InfisicalCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (infisicalInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_infisical');
  final span = t.startSpan('infisical $operation', kind: SpanKind.client);
  try {
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('rpc.system', 'infisical')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.organization != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('infisical.organization', res.organization!)
        ]));
      }
      if (res.project != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('infisical.project', res.project!)]));
      }
      if (res.environment != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('infisical.environment', res.environment!)
        ]));
      }
      if (res.path != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('infisical.path', res.path!)]));
      }
      if (res.secretName != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('infisical.secret.name', res.secretName!)
        ]));
      }
      if (res.secretsCount != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('infisical.secrets.count', res.secretsCount!)
        ]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('infisical.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'infisical.error',
          )
        ]));
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
