# otel_aws_lambda

Dartastic OpenTelemetry bridge for AWS Lambda (serverless functions).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_aws_lambda/otel_aws_lambda.dart';

await tracedAwsLambda<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return AwsLambdaCallResult(value: r, result: AwsLambdaResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutAwsLambdaInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
