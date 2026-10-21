// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_aws_lambda/otel_aws_lambda.dart';

/// Traces Aws Lambda calls with OpenTelemetry.
///
/// `otel_aws_lambda` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Aws Lambda call in
/// [tracedAwsLambda]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'aws-lambda-example');

  // Traces a Aws Lambda call.
  final awsLambdaId = await tracedAwsLambda<String>(
    operation: 'create',
    invoke: () async {
      // Make the Aws Lambda call here, then report what it returned.
      const id = 'aws_lambda_8f3a2c';
      return const AwsLambdaCallResult(
          value: id,
          result: AwsLambdaResult(
              functionName: 'example',
              functionArn: 'example',
              version: '1',
              aliasName: 'example',
              invocationType: 'standard',
              executedVersion: '1',
              requestId: 'request_8f3a2c',
              durationMs: 0.5,
              billedDurationMs: 0.5,
              memoryLimitMb: 25,
              memoryUsedMb: 1,
              coldStart: true,
              region: 'us-east-1',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedAwsLambda create returned $awsLambdaId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAwsLambdaInstrumentationAsync.
  await runWithoutAwsLambdaInstrumentationAsync(
    () => tracedAwsLambda<String>(
      operation: 'create',
      invoke: () async {
        const id = 'aws_lambda_8f3a2c';
        return const AwsLambdaCallResult(
            value: id,
            result: AwsLambdaResult(
                functionName: 'example',
                functionArn: 'example',
                version: '1',
                aliasName: 'example',
                invocationType: 'standard',
                executedVersion: '1',
                requestId: 'request_8f3a2c',
                durationMs: 0.5,
                billedDurationMs: 0.5,
                memoryLimitMb: 25,
                memoryUsedMb: 1,
                coldStart: true,
                region: 'us-east-1',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
