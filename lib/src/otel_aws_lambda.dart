// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_aws_lambda_suppression.dart';

class AwsLambdaResult {
  /// Creates a result.
  const AwsLambdaResult({
    this.functionName,
    this.functionArn,
    this.version,
    this.aliasName,
    this.invocationType,
    this.executedVersion,
    this.requestId,
    this.durationMs,
    this.billedDurationMs,
    this.memoryLimitMb,
    this.memoryUsedMb,
    this.coldStart,
    this.region,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? functionName;
  final String? functionArn;
  final String? version;
  final String? aliasName;
  final String? invocationType;
  final String? executedVersion;
  final String? requestId;
  final double? durationMs;
  final double? billedDurationMs;
  final int? memoryLimitMb;
  final int? memoryUsedMb;
  final bool? coldStart;
  final String? region;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class AwsLambdaCallResult<T> {
  /// Creates a call result.
  const AwsLambdaCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final AwsLambdaResult? result;
}

Future<T> tracedAwsLambda<T>({
  required String operation,
  required Future<AwsLambdaCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (awsLambdaInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_aws_lambda');
  final span = t.startSpan('lambda $operation', kind: SpanKind.client);
  try {
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('faas.invoked_provider', 'aws')]));
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.system', 'aws-api')]));
    span.addAttributes(
        OTelAPI.attributes([OTelAPI.attributeString('rpc.service', 'Lambda')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.functionName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('faas.invoked_name', res.functionName!)]));
      }
      if (res.functionArn != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('aws.lambda.function_arn', res.functionArn!)
        ]));
      }
      if (res.version != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('faas.invoked_version', res.version!)]));
      }
      if (res.aliasName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('aws.lambda.alias', res.aliasName!)]));
      }
      if (res.invocationType != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            'aws.lambda.invocation_type',
            res.invocationType!,
          )
        ]));
      }
      if (res.executedVersion != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            'aws.lambda.executed_version',
            res.executedVersion!,
          )
        ]));
      }
      if (res.requestId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('aws.request_id', res.requestId!)]));
      }
      if (res.durationMs != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeDouble('faas.duration', res.durationMs!)]));
      }
      if (res.billedDurationMs != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeDouble(
            'aws.lambda.billed_duration',
            res.billedDurationMs!,
          )
        ]));
      }
      if (res.memoryLimitMb != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('faas.max_memory', res.memoryLimitMb!)]));
      }
      if (res.memoryUsedMb != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('aws.lambda.memory_used', res.memoryUsedMb!)
        ]));
      }
      if (res.coldStart != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeBool('faas.coldstart', res.coldStart!)]));
      }
      if (res.region != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('cloud.region', res.region!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('lambda.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'lambda.error',
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
