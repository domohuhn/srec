// Copyright (C) 2022 by domohuhn
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:intel_hex/intel_hex.dart';
import 'package:srec/srec.dart';
import 'package:test/test.dart';

void main() {
  group('From data', () {
    test('file from data', () {
      var data = <int>[];
      for (int i = 0; i < 0x130; ++i) {
        data.add(0xFF);
      }
      final srec = SRecordFile.fromData(data, address: 0x10);
      expect(srec.segments.length, 1);
      expect(srec.maxAddress, 0x140);
      for (int i = 0x10; i < 0x140; ++i) {
        expect(srec.segments.first.byte(i), 0xFF);
      }
    });
  });

  group('Parse file', () {
    test('Normal file', () {
      final exampleFile = """S00D000068656C6C6F20202020203E
S11F00007C0802A6900100049421FFF07C6C1B787C8C23783C6000003863000026
S11F001C4BFFFFE5398000007D83637880010014382100107C0803A64E800020E9
S111003848656C6C6F20776F726C642E0A0042
S5030003F9
S9030000FC""";
      var parsed = SRecordFile.fromString(exampleFile);
      expect(parsed.header, "hello     ");
      expect(parsed.startAddress, 0);
      expect(parsed.segments.length, 1);
      var first = parsed.segments.first;
      expect(first.address, 0);
      expect(first.endAddress, 70);
      expect(first.byte(0), 0x7C);
      expect(first.byte(0x1C), 0x4B);
      expect(first.byte(0x38), 0x48);
    });

    test('Start code Y', () {
      final exampleFile = """Y00D000068656C6C6F20202020203E
Y11F00007C0802A6900100049421FFF07C6C1B787C8C23783C6000003863000026
Y11F001C4BFFFFE5398000007D83637880010014382100107C0803A64E800020E9
Y111003848656C6C6F20776F726C642E0A0042
Y5030003F9
Y9030000FC""";
      final parsed = SRecordFile.fromString(exampleFile, startToken: 'Y');
      expect(parsed.header, "hello     ");
      expect(parsed.startAddress, 0);
      expect(parsed.segments.length, 1);
      var first = parsed.segments.first;
      expect(first.address, 0);
      expect(first.endAddress, 70);
      expect(first.byte(0), 0x7C);
      expect(first.byte(0x1C), 0x4B);
      expect(first.byte(0x38), 0x48);
    });

    test('Start code Y round trip', () {
      final exampleFile = """Y00D000068656C6C6F20202020203E
Y12300007C0802A6900100049421FFF07C6C1B787C8C23783C600000386300004BFFFFE5F4
Y1230020398000007D83637880010014382100107C0803A64E80002048656C6C6F20776F15
Y1090040726C642E0A003C
Y9030000FC\n""";
      var parsed = SRecordFile.fromString(exampleFile, startToken: 'Y');
      expect(parsed.header, "hello     ");
      expect(parsed.startAddress, 0);
      expect(parsed.segments.length, 1);
      var first = parsed.segments.first;
      expect(first.address, 0);
      expect(first.endAddress, 70);
      expect(first.byte(0), 0x7C);
      expect(first.byte(0x1C), 0x4B);
      expect(first.byte(0x38), 0x48);
      var output = parsed.toFileContents(startToken: 'Y');
      expect(output, exampleFile);
    });

    test('Duplicate S9 record (start address)', () {
      final exampleFile = """S00D000068656C6C6F20202020203E
S11F00007C0802A6900100049421FFF07C6C1B787C8C23783C6000003863000026
S11F001C4BFFFFE5398000007D83637880010014382100107C0803A64E800020E9
S111003848656C6C6F20776F726C642E0A0042
S5030003F9
S9030000FC
S9030000FC""";
      expect(() => SRecordFile.fromString(exampleFile),
          throwsA(TypeMatcher<ParsingError>()));
    });

    test('Duplicate S1 record (data)', () {
      final exampleFile = """S00D000068656C6C6F20202020203E
S11F00007C0802A6900100049421FFF07C6C1B787C8C23783C6000003863000026
S11F001C4BFFFFE5398000007D83637880010014382100107C0803A64E800020E9
S11F001C4BFFFFE5398000007D83637880010014382100107C0803A64E800020E9
S111003848656C6C6F20776F726C642E0A0042
S5030003F9
S9030000FC""";
      expect(() => SRecordFile.fromString(exampleFile),
          throwsA(TypeMatcher<ParsingError>()));
    });

    test('Wrong start code', () {
      final exampleFile = "";
      expect(() => SRecordFile.fromString(exampleFile, startToken: "bla"),
          throwsA(TypeMatcher<ParsingError>()));
    });

    test('Wrong count record', () {
      final exampleFile = """S00D000068656C6C6F20202020203E
S11F00007C0802A6900100049421FFF07C6C1B787C8C23783C6000003863000026
S11F001C4BFFFFE5398000007D83637880010014382100107C0803A64E800020E9
S111003848656C6C6F20776F726C642E0A0042
S5030005F7
S9030000FC""";
      expect(() => SRecordFile.fromString(exampleFile),
          throwsA(TypeMatcher<ParsingError>()));

      var parsed = SRecordFile.fromString(exampleFile, ignoreCount: true);
      expect(parsed.header, "hello     ");
      expect(parsed.startAddress, 0);
      expect(parsed.segments.length, 1);
      var first = parsed.segments.first;
      expect(first.address, 0);
      expect(first.endAddress, 70);
    });

    test('set line length', () {
      var file = SRecordFile(address: 0, length: 32);
      expect(() => file.lineLength = 0, throwsA(TypeMatcher<RangeError>()));
      expect(() => file.lineLength = 251, throwsA(TypeMatcher<RangeError>()));
      file.lineLength = 1;
      file.lineLength = 250;
    });
  });

  group("to string", () {
    test('to file 16 bit address', () {
      final srec = SRecordFile(address: 0x120, length: 0x20);
      expect(srec.segments.length, 1);
      expect(srec.maxAddress, 0x140);
      expect(srec.toFileContents(),
          "S0030000FC\nS12301200000000000000000000000000000000000000000000000000000000000000000BB\nS9030000FC\n");
      expect(srec.toString(),
          '"SREC" : { "segments": [ {"start": 288,"end": 320}] }');
    });

    test('to file 24 bit address', () {
      final srec = SRecordFile(address: 0x14000, length: 0x20);
      expect(srec.segments.length, 1);
      expect(srec.maxAddress, 0x14020);
      expect(srec.toFileContents(),
          "S0030000FC\nS22401400000000000000000000000000000000000000000000000000000000000000000009A\nS804000000FB\n");
      expect(srec.toString(),
          '"SREC" : { "segments": [ {"start": 81920,"end": 81952}] }');
    });

    test('to file 32 bit address', () {
      final srec = SRecordFile(address: 0x1400000, length: 0x20);
      expect(srec.segments.length, 1);
      expect(srec.maxAddress, 0x1400020);
      expect(srec.toFileContents(),
          "S0030000FC\nS32501400000000000000000000000000000000000000000000000000000000000000000000099\nS70500000000FA\n");
      expect(srec.toString(),
          '"SREC" : { "segments": [ {"start": 20971520,"end": 20971552}] }');
    });

    test('to file with duplicate segments', () {
      final srec = SRecordFile(address: 0x0, length: 0x20);
      srec.segments.add(MemorySegment(address: 0x10, length: 0x20));
      expect(srec.segments.length, 2);

      expect(() => srec.toFileContents(), throwsA(TypeMatcher<RangeError>()));

      expect(
          srec.toFileContents(allowDuplicateAddresses: true),
          'S0030000FC\n'
          'S12300000000000000000000000000000000000000000000000000000000000000000000DC\n'
          'S12300100000000000000000000000000000000000000000000000000000000000000000CC\n'
          'S9030000FC\n'
          '');
    });
  });
}
