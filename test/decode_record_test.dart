// Copyright (C) 2022 by domohuhn
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:srec/src/decode_records.dart';
import 'package:srec/srec.dart';
import 'package:test/test.dart';

void main() {
  final throwParsingError = throwsA(TypeMatcher<ParsingError>());

  group('Decode records', () {
    test("Header record", () {
      final rv = SRecord.fromLine("Y0061234484452D5\n", startCode: "Y");
      expect(rv.address, 0x1234);
      expect(rv.text, "HDR");
      expect(() => rv.count, throwParsingError);
      expect(() => rv.payload, throwParsingError);
    });

    test("Data 16 S1 record", () {
      final rv = SRecord.fromLine(
          "Y1137AF00A0A0D0000000000000000000000000061\n",
          startCode: "Y");
      expect(rv.address, 0x7AF0);
      expect(() => rv.text, throwParsingError);
      expect(() => rv.count, throwParsingError);
      expect(rv.payload,
          <int>[0x0A, 0x0A, 0x0D, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    });

    test("Data 24 S2 record", () {
      final rv =
          SRecord.fromLine("S2137AF00A0A0D0000000000000000000000000061\n");
      expect(rv.address, 0x7AF00A);
      expect(() => rv.text, throwParsingError);
      expect(() => rv.count, throwParsingError);
      expect(
          rv.payload, <int>[0x0A, 0x0D, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    });

    test("Data 32 S3 record", () {
      final rv =
          SRecord.fromLine("S3137AF00A0A0D0000000000000000000000000061\n");
      expect(rv.address, 0x7AF00A0A);
      expect(() => rv.text, throwParsingError);
      expect(() => rv.count, throwParsingError);
      expect(rv.payload, <int>[0x0D, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    });

    test("Count S5 record", () {
      final rv = SRecord.fromLine("S5030003F9\n");
      expect(() => rv.address, throwParsingError);
      expect(() => rv.text, throwParsingError);
      expect(rv.count, 0x03);
      expect(() => rv.payload, throwParsingError);
    });

    test("Count S6 record", () {
      final rv = SRecord.fromLine("S604000003F8\n");
      expect(() => rv.address, throwParsingError);
      expect(() => rv.text, throwParsingError);
      expect(rv.count, 0x03);
      expect(() => rv.payload, throwParsingError);
    });

    test("Count S9 record", () {
      final rv = SRecord.fromLine("S9030003F9\n");
      expect(rv.address, 0x0003);
      expect(() => rv.text, throwParsingError);
      expect(() => rv.count, throwParsingError);
      expect(() => rv.payload, throwParsingError);
    });

    test("Count S8 record", () {
      final rv = SRecord.fromLine("S804000003F8\n");
      expect(rv.address, 0x0003);
      expect(() => rv.text, throwParsingError);
      expect(() => rv.count, throwParsingError);
      expect(() => rv.payload, throwParsingError);
    });

    test("Count S7 record", () {
      final rv = SRecord.fromLine("S70500000003F7\n");
      expect(rv.address, 0x0003);
      expect(() => rv.text, throwParsingError);
      expect(() => rv.count, throwParsingError);
      expect(() => rv.payload, throwParsingError);
    });
  });

  group('Decode records with Errors', () {
    test("checksum", () {
      expect(() => SRecord.fromLine("S0061334484452D5\n"), throwParsingError);
    });

    test("length", () {
      expect(() => SRecord.fromLine("S0061334484452\n"),
          throwsA(TypeMatcher<RangeError>()));
    });

    test("min length", () {
      expect(
          () => SRecord.fromLine("S0\n"), throwsA(TypeMatcher<RangeError>()));
    });

    test("record type", () {
      expect(() => SRecord.fromLine("S4061334484452D4\n"), throwParsingError);
    });

    test("wrong start code", () {
      expect(() => SRecord.fromLine("A0061334484452D5\n"), throwParsingError);
    });

    test("wrong Character", () {
      expect(() => SRecord.fromLine("S006133G484452D5\n"), throwParsingError);
    });

    test("empty code units", () {
      List<int> input = [];
      expect(() => SRecord.fromCodeUnits(input, 0), throwParsingError);
    });

    test("wrong start code", () {
      List<int> input = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      expect(() => SRecord.fromCodeUnits(input, 0), throwParsingError);
    });

    test("wrong length", () {
      List<int> input = [
        0x53,
        0x31,
        0x39,
        0x39,
        0x39,
        0x39,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0
      ];
      expect(() => SRecord.fromCodeUnits(input, 0), throwParsingError);
    });
  });
}
