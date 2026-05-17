// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'dart:async';

const _key = #dartastic_otel_libs_awsLambda_suppress;

bool awsLambdaInstrumentationSuppressed() => Zone.current[_key] == true;

T runWithoutAwsLambdaInstrumentation<T>(T Function() body) =>
    runZoned(body, zoneValues: {_key: true});

Future<T> runWithoutAwsLambdaInstrumentationAsync<T>(
  Future<T> Function() body,
) => runZoned(body, zoneValues: {_key: true});
