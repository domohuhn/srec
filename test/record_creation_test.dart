// Copyright (C) 2022 by domohuhn
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:srec/src/encode_records.dart';
import 'package:test/test.dart';
import 'dart:typed_data';

void main() {
  group('Encode records', () {
    test("Header record", () {
      final rv = createHeaderRecord("HDR", address: 0x1234, startCode: 'Y');
      expect(rv, "Y0061234484452D5\n");
    });

    test("Data 16 record", () {
      var list = <int>[0x0A, 0x0A, 0x0D, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      final rv = createData16Record(0x7AF0, list, 'Y');
      expect(rv, "Y1137AF00A0A0D0000000000000000000000000061\n");
    });

    test("Data 24 record", () {
      var list = <int>[0x0A, 0x0D, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      final rv = createData24Record(0x7AF00A, list, 'S');
      expect(rv, "S2137AF00A0A0D0000000000000000000000000061\n");
    });

    test("Data 32 record", () {
      var list = <int>[0x0D, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      final rv = createData32Record(0x7AF00A0A, list);
      expect(rv, "S3137AF00A0A0D0000000000000000000000000061\n");
    });

    test("Count 16 record", () {
      final rv = createCount16Record(0x3);
      expect(rv, "S5030003F9\n");
    });
    test("Count 24 record", () {
      final rv = createCount24Record(0x3);
      expect(rv, "S604000003F8\n");
    });

    test("Start address 16 record", () {
      final rv = createStartAddress16Record(0x3);
      expect(rv, "S9030003F9\n");
    });

    test("Start address 24 record", () {
      final rv = createStartAddress24Record(0x3);
      expect(rv, "S804000003F8\n");
    });

    test("Start address 32 record", () {
      final rv = createStartAddress32Record(0x3);
      expect(rv, "S70500000003F7\n");
    });
  });

  group('Encode errors', () {
    final throwRangeError = throwsA(TypeMatcher<RangeError>());
    test("ASCII encoding", () {
      expect(() => convertToASCII(Uint8List(2), "S0"), throwRangeError);
      expect(() => convertToASCII(Uint8List(257), "S0"), throwRangeError);
    });
    test("Header encoding", () {
      expect(() => createHeaderRecord("HDR", address: -1), throwRangeError);
      expect(
          () => createHeaderRecord("HDR", address: 0x10000), throwRangeError);
    });
    var list = <int>[0x0A, 0x0A, 0x0D, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    test("Data 16 encoding", () {
      expect(() => createData16Record(-1, list), throwRangeError);
      expect(() => createData16Record(0x10000, list), throwRangeError);
    });
    test("Data 24 encoding", () {
      expect(() => createData24Record(-1, list), throwRangeError);
      expect(() => createData24Record(0x1000000, list), throwRangeError);
    });
    test("Data 32 encoding", () {
      expect(() => createData32Record(-1, list), throwRangeError);
      expect(() => createData32Record(0x100000000, list), throwRangeError);
    });

    test("Count 16 encoding", () {
      expect(() => createCount16Record(-1), throwRangeError);
      expect(() => createCount16Record(0x10000), throwRangeError);
    });
    test("Count 24 encoding", () {
      expect(() => createCount24Record(-1), throwRangeError);
      expect(() => createCount24Record(0x1000000), throwRangeError);
    });

    test("start address 16 encoding", () {
      expect(() => createStartAddress16Record(-1), throwRangeError);
      expect(() => createStartAddress16Record(0x10000), throwRangeError);
    });
    test("start address 24 encoding", () {
      expect(() => createStartAddress24Record(-1), throwRangeError);
      expect(() => createStartAddress24Record(0x1000000), throwRangeError);
    });
    test("start address 32 encoding", () {
      expect(() => createStartAddress32Record(-1), throwRangeError);
      expect(() => createStartAddress32Record(0x100000000), throwRangeError);
    });
  });
}
