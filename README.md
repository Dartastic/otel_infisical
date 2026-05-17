# otel_infisical

Dartastic OpenTelemetry bridge for Infisical (open-source secrets manager).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_infisical/otel_infisical.dart';

await tracedInfisical<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return InfisicalCallResult(value: r, result: InfisicalResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutInfisicalInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
