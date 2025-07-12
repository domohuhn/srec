// Copyright (C) 2022 by domohuhn
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:srec/src/encode_records.dart';
import 'package:test/test.dart';
import 'dart:typed_data';

void main() {
  group('Encode records', () {
    test("Header record", () {
      StringBuffer rv = StringBuffer();
      createHeaderRecord(rv, "HDR", address: 0x1234, startCode: 'Y');
      expect(rv.toString(), "Y0061234484452D5\n");
    });

    test("Data 16 record", () {
      var list = <int>[0x0A, 0x0A, 0x0D, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      StringBuffer rv = StringBuffer();
      createData16Record(rv, 0x7AF0, list, 'Y');
      expect(rv.toString(), "Y1137AF00A0A0D0000000000000000000000000061\n");
    });

    test("Data 24 record", () {
      var list = <int>[0x0A, 0x0D, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      StringBuffer rv = StringBuffer();
      createData24Record(rv, 0x7AF00A, list, 'S');
      expect(rv.toString(), "S2137AF00A0A0D0000000000000000000000000061\n");
    });

    test("Data 32 record", () {
      var list = <int>[0x0D, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      StringBuffer rv = StringBuffer();
      createData32Record(rv, 0x7AF00A0A, list);
      expect(rv.toString(), "S3137AF00A0A0D0000000000000000000000000061\n");
    });

    test("Count 16 record", () {
      StringBuffer rv = StringBuffer();
      createCount16Record(rv, 0x3);
      expect(rv.toString(), "S5030003F9\n");
    });
    test("Count 24 record", () {
      StringBuffer rv = StringBuffer();
      createCount24Record(rv, 0x3);
      expect(rv.toString(), "S604000003F8\n");
    });

    test("Start address 16 record", () {
      StringBuffer rv = StringBuffer();
      createStartAddress16Record(rv, 0x3);
      expect(rv.toString(), "S9030003F9\n");
    });

    test("Start address 24 record", () {
      StringBuffer rv = StringBuffer();
      createStartAddress24Record(rv, 0x3);
      expect(rv.toString(), "S804000003F8\n");
    });

    test("Start address 32 record", () {
      StringBuffer rv = StringBuffer();
      createStartAddress32Record(rv, 0x3);
      expect(rv.toString(), "S70500000003F7\n");
    });
  });

  group('Encode errors', () {
    StringBuffer rv = StringBuffer();
    final throwRangeError = throwsA(TypeMatcher<RangeError>());
    test("ASCII encoding", () {
      expect(() => convertToASCII(rv, Uint8List(2), "S0"), throwRangeError);
      expect(() => convertToASCII(rv, Uint8List(257), "S0"), throwRangeError);
    });
    test("Header encoding", () {
      expect(() => createHeaderRecord(rv, "HDR", address: -1), throwRangeError);
      expect(() => createHeaderRecord(rv, "HDR", address: 0x10000),
          throwRangeError);
    });
    var list = <int>[0x0A, 0x0A, 0x0D, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    test("Data 16 encoding", () {
      expect(() => createData16Record(rv, -1, list), throwRangeError);
      expect(() => createData16Record(rv, 0x10000, list), throwRangeError);
    });
    test("Data 24 encoding", () {
      expect(() => createData24Record(rv, -1, list), throwRangeError);
      expect(() => createData24Record(rv, 0x1000000, list), throwRangeError);
    });
    test("Data 32 encoding", () {
      expect(() => createData32Record(rv, -1, list), throwRangeError);
      expect(() => createData32Record(rv, 0x100000000, list), throwRangeError);
    });

    test("Count 16 encoding", () {
      expect(() => createCount16Record(rv, -1), throwRangeError);
      expect(() => createCount16Record(rv, 0x10000), throwRangeError);
    });
    test("Count 24 encoding", () {
      expect(() => createCount24Record(rv, -1), throwRangeError);
      expect(() => createCount24Record(rv, 0x1000000), throwRangeError);
    });

    test("start address 16 encoding", () {
      expect(() => createStartAddress16Record(rv, -1), throwRangeError);
      expect(() => createStartAddress16Record(rv, 0x10000), throwRangeError);
    });
    test("start address 24 encoding", () {
      expect(() => createStartAddress24Record(rv, -1), throwRangeError);
      expect(() => createStartAddress24Record(rv, 0x1000000), throwRangeError);
    });
    test("start address 32 encoding", () {
      expect(() => createStartAddress32Record(rv, -1), throwRangeError);
      expect(
          () => createStartAddress32Record(rv, 0x100000000), throwRangeError);
    });
  });
}
