// Copyright (C) 2025 by domohuhn
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:intel_hex/intel_hex.dart';
import 'package:srec/srec.dart';
import 'package:test/test.dart';

void main() {
  group('Performance', () {
    final srec = SRecordFile(address: 0x0, length: 0x00);
    var data = <int>[];
    for (int i = 0; i < 0x100000; ++i) {
      data.add(0xFF & i);
    }
    srec.addAll(0x00, data);

    test('serialize 1mb', () {
      expect(srec.segments.length, 1);
      expect(srec.maxAddress, 0x100000);

      final stopwatch = Stopwatch();
      stopwatch.start();
      final output = srec.toFileContents();
      stopwatch.stop();
      expect(output.length, 2523160);
      expect(stopwatch.elapsed < Duration(seconds: 1), true);
    });

    test('parse 1mb', () {
      final input = srec.toFileContents();

      final stopwatch = Stopwatch();
      stopwatch.start();
      final hex2 = SRecordFile.fromString(input);
      stopwatch.stop();
      expect(hex2.segments.length, 1);
      expect(hex2.maxAddress, 0x100000);
      print(stopwatch.elapsed);
      expect(stopwatch.elapsed < Duration(seconds: 1), true);

      final parsedSegment = hex2.segments.first;
      for (int i = 0; i < 0x100000; ++i) {
        expect(parsedSegment.byte(i), (0xFF & i));
      }
    });

    test('parse 1mb lower', () {
      final input = srec.toFileContents().toLowerCase();

      final stopwatch = Stopwatch();
      stopwatch.start();
      final hex2 = SRecordFile.fromString(input, startToken: "s");
      stopwatch.stop();
      expect(hex2.segments.length, 1);
      expect(hex2.maxAddress, 0x100000);
      print(stopwatch.elapsed);
      expect(stopwatch.elapsed < Duration(seconds: 1), true);

      final parsedSegment = hex2.segments.first;
      for (int i = 0; i < 0x100000; ++i) {
        expect(parsedSegment.byte(i), (0xFF & i));
      }
    });
  });
}
