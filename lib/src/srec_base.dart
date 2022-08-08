// Copyright (C) 2022 by domohuhn
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:intel_hex/intel_hex.dart';
import 'package:srec/src/decode_records.dart';
import 'package:srec/src/encode_records.dart';
import 'package:srec/srec.dart';
import 'dart:math';

/// This class holds all the methods to read and write S-Record files.
class SRecordFile extends MemorySegmentContainer {
  /// Creates a file with a single segment if [address] is >= 0 and [length] is >= 0.
  /// Otherwise the file is empty.
  SRecordFile({int? address, int? length})
      : super(address: address, length: length);

  /// Creates a file with a single segment containing all bytes from [data].
  /// The start [address] is 0 unless another value is provided.
  ///
  /// The contents of [data] will be truncated to (0, 255).
  SRecordFile.fromData(Iterable<int> data, {int address = 0})
      : super.fromData(data, address: address);

  /// The start code for a record. The standard value is "S".
  String startCode = "S";

  /// The start address where the code is executed (if supported by the CPU).
  /// This value may be null if it is not contained in the file.
  int? startAddress;

  /// The text of the header in the file.
  String? header;

  /// Controls the number of bytes in a data record.
  ///
  /// Must in the inclusive range of 1 and 250.
  int get lineLength => _lineLength;

  set lineLength(int v) {
    _validateLineLength(v);
    _lineLength = v;
  }

  int _lineLength = 32;

  /// Parses the Motorola S-records in the [data] string and adds it to the
  /// segments in this object. All lines not starting with "S" are ignored.
  /// After the start token, only valid characters for hexadecimal numbers (0-9a-fA-F)
  /// are allowed up until the end of the line.
  ///
  /// May throw an error during parsing. Potential error cases are: a checksum that is not correct,
  /// a record with an unknown record type, a record where the given length is wrong, a record that
  /// can not be converted to integers or if records 3 or 5 occur multiple times.
  ///
  /// If a nonstandard start code should be used instead of "S", then you must provide it
  /// via the optional argument [startToken]. If the argument is provided, then [startCode] property will be set to its value.
  ///
  /// The constructor will also verify that every address in the data string is unique. You can prevent this
  /// check by setting [allowDuplicateAddresses] to true.
  SRecordFile.fromString(String data,
      {String? startToken,
      bool allowDuplicateAddresses = false,
      bool ignoreCount = false})
      : super() {
    if (startToken != null) {
      startCode = startToken;
    }
    final re = RegExp(r'[\r\n]+');
    final lines = data.split(re);
    int lineNo = 0;
    int recordCount = 0;

    for (final line in lines) {
      lineNo++;
      if (!line.startsWith(startCode)) {
        continue;
      }
      var record =
          SRecord.fromLine(line, startCode: startCode, lineNumber: lineNo);
      switch (record.recordType) {
        case SRecordType.header:
          header = record.text;
          break;
        case SRecordType.data:
          _addDataRecord(record, lineNo, allowDuplicateAddresses);
          recordCount++;
          break;
        case SRecordType.count:
          if (record.count != recordCount && !ignoreCount) {
            throw ParsingError.onLine(lineNo,
                "Actual record count of $recordCount records does not match the declared count ${record.count}");
          }
          break;
        case SRecordType.startAddress:
          if (startAddress != null) {
            throw ParsingError.onLine(lineNo,
                "Start address record (S7,S8,S9) occurs more than once!");
          }
          startAddress = record.address;
          break;
      }
    }
    if (recordCount == 0) {
      throw ParsingError("The file contains no valid records!");
    }
  }

  /// Converts this instance of SRecordFile to an Motorola S-record file record block.
  ///
  /// If a nonstandard start code should be used instead of "S", then you must provide it
  /// via the optional argument [startToken]. If the argument is provided, then startCode property will be set to its value.
  ///
  /// The method will also verify that every address in the segments is unique.
  /// You can prevent this check by setting [allowDuplicateAddresses] to true.
  String toFileContents(
      {String? startToken, bool allowDuplicateAddresses = false}) {
    if (startToken != null) {
      startCode = startToken;
    }
    sortSegments();
    if (!allowDuplicateAddresses && !validateSegmentsAreUnique()) {
      throw ParsingError("There are overlapping Segments in the file!");
    }
    _setFunctions();
    String rv = "";

    rv +=
        createHeaderRecord(header != null ? header! : "", startCode: startCode);

    for (final seg in segments) {
      for (int i = 0; i < seg.length; i = i + lineLength) {
        rv += _dataRecord!(seg.address + i,
            seg.slice(i, min(i + lineLength, seg.length)), startCode);
      }
    }

    rv += _endRecord!(startAddress != null ? startAddress! : 0, startCode);
    return rv;
  }

  void _addDataRecord(SRecord record, int line, bool allowDuplicateAddresses) {
    final address = record.address;
    final seg = MemorySegment.fromBytes(address: address, data: record.payload);
    if (!allowDuplicateAddresses && !segmentIsNew(seg)) {
      throw ParsingError.onLine(line,
          "The address range [${seg.address}, ${seg.endAddress}[ of the record is not unique!");
    }
    addSegment(seg);
  }

  Function(int, String)? _endRecord;
  Function(int, Iterable<int>, String)? _dataRecord;

  /// Sets the record functions to the correct functions.
  void _setFunctions() {
    final maxAddr = maxAddress;
    if (maxAddr <= 65536) {
      _dataRecord = createData16Record;
      _endRecord = createStartAddress16Record;
    } else if (maxAddr <= 1048576) {
      _dataRecord = createData24Record;
      _endRecord = createStartAddress24Record;
    } else {
      _dataRecord = createData32Record;
      _endRecord = createStartAddress32Record;
    }
  }

  /// Prints information about the file and its contents.
  @override
  String toString() {
    return '"SREC" : { ${super.toString()} }';
  }
}

/// Verifies that the line length is correct. Throws an exception otherwise.
void _validateLineLength(int len) {
  if (len > 250) {
    throw RangeError("data in lines cannot be longer than 250 bytes! Got $len");
  }
  if (len < 1) {
    throw RangeError("Lines cannot be shorter than 1 byte! Got $len");
  }
}
