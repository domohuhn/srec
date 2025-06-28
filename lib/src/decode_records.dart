// Copyright (C) 2022 by domohuhn
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:intel_hex/intel_hex.dart';
import 'package:srec/srec.dart';
import 'dart:typed_data';
import 'dart:convert';

/// The type of the parsed record
enum SRecordType {
  /// A header for a block of data elements
  header,

  /// A data payload
  data,

  /// A record with the count of data blocks
  count,

  /// A start address/termination record
  startAddress
}

class SRecord {
  SRecordType recordType = SRecordType.data;
  String _header = "";
  int _address = 0;
  int _payloadOffset = 3;

  /// The address of the record. May also be the start address for "Start Address (Termination)" records.
  /// Not valid if the recordType is SRecordType.count.
  int get address {
    if (recordType == SRecordType.count) {
      throw ParsingError(
          "A SRecordType.count has no address! use count instead!");
    }
    return _address;
  }

  /// The count of records in the file. Only valid if the recordType is SRecordType.count.
  int get count {
    if (recordType != SRecordType.count) {
      throw ParsingError(
          "Only SRecordType.count has a count! Type is: $recordType");
    }
    return _address;
  }

  /// The text of the header. Only valid if the recordType is SRecordType.header.
  String get text {
    if (recordType != SRecordType.header) {
      throw ParsingError(
          "Only SRecordType.header has a text! Type is: $recordType");
    }
    return _header;
  }

  /// The payload of a data record. Only valid if the recordType is SRecordType.data.
  Uint8List get payload {
    if (recordType != SRecordType.data) {
      throw ParsingError(
          "Only SRecordType.data has a payload! Type is: $recordType");
    }
    return Uint8List.sublistView(_data, _payloadOffset, _data.length - 1);
  }

  /// Constructs the s-record by parsing a string given via [line].
  /// The start code can be configured with [startCode].
  ///
  /// In case the line cannot be parsed, exceptions will be thrown. For better error reporting,
  /// you can provide the current line number with [lineNumber].
  SRecord.fromLine(String line, {String startCode = "S", int lineNumber = 1}) {
    if (!line.startsWith(startCode)) {
      throw ParsingError.onLine(
          lineNumber, "A record must start with $startCode! Got: '$line'");
    }
    if (line.length < startCode.length + 7) {
      throw RangeError.range(
          line.length,
          startCode.length + 7,
          null,
          "line length",
          "SRecords have a minimum length! Line $lineNumber is out of range!");
    }
    final recordString = line.substring(startCode.length, startCode.length + 1);
    final byteLen = int.parse(
        line.substring(startCode.length + 1, startCode.length + 3),
        radix: 16);
    final requiredLength = startCode.length + 3 + 2 * byteLen;
    if (line.length < requiredLength) {
      throw RangeError.range(line.length, requiredLength, null, "line length",
          "The SRecord in line $lineNumber claims to have $byteLen bytes, requiring at least $requiredLength characters!");
    }
    _parseHexValues(line, startCode.length + 1, requiredLength);
    if (!validateChecksum(_data, 255)) {
      throw ParsingError.onLine(lineNumber,
          "Checksum does not match! Expected: ${computeChecksum(_data.sublist(0, _data.length - 1), false)} Got: ${_data.last}");
    }

    switch (recordString) {
      case "0":
        recordType = SRecordType.header;
        _address = _parse2ByteAddress();
        _decodeString();
        break;
      case "1":
        recordType = SRecordType.data;
        _address = _parse2ByteAddress();
        _payloadOffset = 3;
        break;
      case "2":
        recordType = SRecordType.data;
        _address = _parse3ByteAddress();
        _payloadOffset = 4;
        break;
      case "3":
        recordType = SRecordType.data;
        _address = _parse4ByteAddress();
        _payloadOffset = 5;
        break;
      case "5":
        recordType = SRecordType.count;
        _address = _parse2ByteAddress();
        break;
      case "6":
        recordType = SRecordType.count;
        _address = _parse3ByteAddress();
        break;
      case "7":
        recordType = SRecordType.startAddress;
        _address = _parse4ByteAddress();
        break;
      case "8":
        recordType = SRecordType.startAddress;
        _address = _parse3ByteAddress();
        break;
      case "9":
        recordType = SRecordType.startAddress;
        _address = _parse2ByteAddress();
        break;
      default:
        throw ParsingError.onLine(lineNumber,
            "Only record types 0,1,2,3,5,6,7,8,9 are valid! Got: '$recordString'");
    }
  }

  Uint8List _data = Uint8List(0);

  void _parseHexValues(String line, int start, int end) {
    List<int> parsed = [];
    for (var i = start; (i + 1) < end; i = (i + 2)) {
      parsed.add(int.parse(line.substring(i, i + 2), radix: 16));
    }
    _data = Uint8List.fromList(parsed);
  }

  int _parse2ByteAddress() {
    return _data.buffer.asByteData(1, 2).getUint16(0, Endian.big);
  }

  int _parse3ByteAddress() {
    return _data[1] << 16 | _data[2] << 8 | _data[3];
  }

  int _parse4ByteAddress() {
    return _data.buffer.asByteData(1, 4).getUint32(0, Endian.big);
  }

  void _decodeString() {
    _header = utf8.decode(Uint8List.sublistView(_data, 3, _data.length - 1),
        allowMalformed: true);
  }
}
