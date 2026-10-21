// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_aws_lambda/otel_aws_lambda.dart';
import 'package:test/test.dart';

void main() {
  group('otel_aws_lambda', () {
    test('suppression toggles in zone', () async {
      expect(awsLambdaInstrumentationSuppressed(), isFalse);
      await runWithoutAwsLambdaInstrumentationAsync(() async {
        expect(awsLambdaInstrumentationSuppressed(), isTrue);
      });
      expect(awsLambdaInstrumentationSuppressed(), isFalse);
    });

    test('AwsLambdaResult fields default null', () {
      const r = AwsLambdaResult();
      expect(r.statusCode, isNull);
    });
  });
}
