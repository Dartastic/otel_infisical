// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

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
    span.addAttributes(
        OTel.attributes([OTel.attributeString('rpc.system', 'infisical')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.organization != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('infisical.organization', res.organization!)
        ]));
      }
      if (res.project != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('infisical.project', res.project!)]));
      }
      if (res.environment != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('infisical.environment', res.environment!)]));
      }
      if (res.path != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('infisical.path', res.path!)]));
      }
      if (res.secretName != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('infisical.secret.name', res.secretName!)]));
      }
      if (res.secretsCount != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('infisical.secrets.count', res.secretsCount!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('infisical.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            ErrorResource.errorType.key,
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
