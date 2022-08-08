// Copyright (C) 2022 by domohuhn
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:typed_data';
import 'package:intel_hex/intel_hex.dart';
import 'dart:convert';

/// Creates a header record from the given [address] and [header].
/// It contains an utf8 string describing the following record block.
///
/// The address must be able to fit in 2 bytes otherwise an exception is thrown.
/// Usually the address is 0.
/// The length of data must be less than 252 otherwise an exception is thrown.
///
/// Example: "S00F000068656C6C6F202020202000003C"
///
/// A different start token than "S" can be provided via [startCode].
String createHeaderRecord(String header,
    {int address = 0, String startCode = "S"}) {
  var list = utf8.encode(header);
  final length = 3 + list.length;
  var data = Uint8List(length);
  data[0] = length;
  if (address < 0 || address > 0xFFFF) {
    throw RangeError.range(address, 0, 0xFFFF, "address",
        "There are only 2 bytes for the address in a Header record!");
  }
  data.buffer.asByteData(1, 2).setUint16(0, address, Endian.big);
  data.setAll(3, list);
  return convertToASCII(data, "${startCode}0");
}

/// Creates a data record from the given 16 bit [address] and [data].
///
/// The address must be able to fit in 2 bytes otherwise an exception is thrown.
/// The length of data must be less than 252 otherwise an exception is thrown.
///
/// Example: "S1137AF00A0A0D0000000000000000000000000061"
///
/// A different start token than "S" can be provided via [startCode].
String createData16Record(int address, Iterable<int> data,
    [String startCode = "S"]) {
  final length = 3 + data.length;
  var buffer = Uint8List(length);
  buffer[0] = length;
  if (address < 0 || address > 0xFFFF) {
    throw RangeError.range(address, 0, 0xFFFF, "address",
        "There are only 2 bytes for the address in a S1 data record!");
  }
  buffer.buffer.asByteData(1, 2).setUint16(0, address, Endian.big);
  buffer.setAll(3, data);
  return convertToASCII(buffer, "${startCode}1");
}

/// Creates a data record from the given 24 bit [address] and [data].
///
/// The address must be able to fit in 3 bytes otherwise an exception is thrown.
/// The length of data must be less than 252 otherwise an exception is thrown.
///
/// Example: "S2137AF00A0A0D0000000000000000000000000061"
///
/// A different start token than "S" can be provided via [startCode].
String createData24Record(int address, Iterable<int> data,
    [String startCode = "S"]) {
  final length = 4 + data.length;
  var buffer = Uint8List(length);
  buffer[0] = length;
  if (address < 0 || address > 0xFFFFFF) {
    throw RangeError.range(address, 0, 0xFFFFFF, "address",
        "There are only 3 bytes for the address in a S2 data record!");
  }
  buffer[1] = (address >> 16) & 0xFF;
  buffer[2] = (address >> 8) & 0xFF;
  buffer[3] = (address >> 0) & 0xFF;
  buffer.setAll(4, data);
  return convertToASCII(buffer, "${startCode}2");
}

/// Creates a data record from the given 32 bit [address] and [data].
///
/// The address must be able to fit in 4 bytes otherwise an exception is thrown.
/// The length of data must be less than 252 otherwise an exception is thrown.
///
/// Example: "S3137AF00A0A0D0000000000000000000000000061"
///
/// A different start token than "S" can be provided via [startCode].
String createData32Record(int address, Iterable<int> data,
    [String startCode = "S"]) {
  final length = 5 + data.length;
  var buffer = Uint8List(length);
  buffer[0] = length;
  if (address < 0 || address > 0xFFFFFFFF) {
    throw RangeError.range(address, 0, 0xFFFFFFFF, "address",
        "There are only 4 bytes for the address in a S3 data record!");
  }
  buffer.buffer.asByteData(1, 4).setUint32(0, address, Endian.big);
  buffer.setAll(5, data);
  return convertToASCII(buffer, "${startCode}3");
}

/// Creates a data count record from the given 16 bit [count].
/// This optional record should follow a block of data records and contain the count of the previous records.
///
/// The count must be able to fit in 2 bytes otherwise an exception is thrown.
///
/// Example: "S5030003F9"
///
/// A different start token than "S" can be provided via [startCode].
String createCount16Record(int count, [String startCode = "S"]) {
  final length = 3;
  var buffer = Uint8List(length);
  buffer[0] = length;
  if (count < 0 || count > 0xFFFF) {
    throw RangeError.range(count, 0, 0xFFFF, "count",
        "There are only 2 bytes for the count in a S5 data record!");
  }
  buffer.buffer.asByteData(1, 2).setUint16(0, count, Endian.big);
  return convertToASCII(buffer, "${startCode}5");
}

/// Creates a data count record from the given 24 bit [count].
/// This optional record should follow a block of data records and contain the count of the previous records.
///
/// The count must be able to fit in 3 bytes otherwise an exception is thrown.
///
/// Example: "S604000300F8"
///
/// A different start token than "S" can be provided via [startCode].
String createCount24Record(int count, [String startCode = "S"]) {
  final length = 4;
  var buffer = Uint8List(length);
  buffer[0] = length;
  if (count < 0 || count > 0xFFFFFF) {
    throw RangeError.range(count, 0, 0xFFFFFF, "count",
        "There are only 3 bytes for the count in a S6 data record!");
  }
  buffer[1] = (count >> 16) & 0xFF;
  buffer[2] = (count >> 8) & 0xFF;
  buffer[3] = (count >> 0) & 0xFF;
  return convertToASCII(buffer, "${startCode}6");
}

/// Creates a Start Address (Termination) record for a block of Data16 records.
/// The 16 bit [startAddress] is the starting execution location for CPUs that support it, otherwise ignored.
///
/// The startAddress must be able to fit in 2 bytes otherwise an exception is thrown.
///
/// Example: "S9030003F9"
///
/// A different start token than "S" can be provided via [startCode].
String createStartAddress16Record(int startAddress, [String startCode = "S"]) {
  final length = 3;
  var buffer = Uint8List(length);
  buffer[0] = length;
  if (startAddress < 0 || startAddress > 0xFFFF) {
    throw RangeError.range(startAddress, 0, 0xFFFF, "startAddress",
        "There are only 2 bytes for the startAddress in a S9 data record!");
  }
  buffer.buffer.asByteData(1, 2).setUint16(0, startAddress, Endian.big);
  return convertToASCII(buffer, "${startCode}9");
}

/// Creates a Start Address (Termination) record for a block of Data24 records.
/// The 24 bit [startAddress] is the starting execution location for CPUs that support it, otherwise ignored.
///
/// The startAddress must be able to fit in 3 bytes otherwise an exception is thrown.
///
/// Example: "S804000003F8"
///
/// A different start token than "S" can be provided via [startCode].
String createStartAddress24Record(int startAddress, [String startCode = "S"]) {
  final length = 4;
  var buffer = Uint8List(length);
  buffer[0] = length;
  if (startAddress < 0 || startAddress > 0xFFFFFF) {
    throw RangeError.range(startAddress, 0, 0xFFFFFF, "startAddress",
        "There are only 3 bytes for the startAddress in a S8 data record!");
  }
  buffer[1] = (startAddress >> 16) & 0xFF;
  buffer[2] = (startAddress >> 8) & 0xFF;
  buffer[3] = (startAddress >> 0) & 0xFF;
  return convertToASCII(buffer, "${startCode}8");
}

/// Creates a Start Address (Termination) record for a block of Data32 records.
/// The 24 bit [startAddress] is the starting execution location for CPUs that support it, otherwise ignored.
///
/// The startAddress must be able to fit in 3 bytes otherwise an exception is thrown.
///
/// Example: "S70500000003F7"
///
/// A different start token than "S" can be provided via [startCode].
String createStartAddress32Record(int startAddress, [String startCode = "S"]) {
  final length = 5;
  var buffer = Uint8List(length);
  buffer[0] = length;
  if (startAddress < 0 || startAddress > 0xFFFFFFFF) {
    throw RangeError.range(startAddress, 0, 0xFFFFFFFF, "startAddress",
        "There are only 4 bytes for the startAddress in a S7 data record!");
  }
  buffer.buffer.asByteData(1, 4).setUint32(0, startAddress, Endian.big);
  return convertToASCII(buffer, "${startCode}7");
}

/// Converts the buffer [buf] to a hex string. The [startCode] is prepended.
String convertToASCII(Uint8List buf, String startCode) {
  if (buf.length < 3 || buf.length > 256) {
    throw RangeError.range(buf.length, 3, 256, "buffer length",
        "The size of $startCode records has hard limits!");
  }
  String rv = startCode;
  for (final value in buf) {
    rv += _toHex(value);
  }
  return "$rv${_toHex(computeChecksum(buf, false))}\n";
}

/// Converts num to 2 hex digits. The value is truncated to 0-255.
String _toHex(int num) {
  var tmp = num & 0xFF;
  return tmp.toRadixString(16).padLeft(2, '0').toUpperCase();
}
