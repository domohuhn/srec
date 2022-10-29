// Copyright (C) 2022 by domohuhn
//
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:typed_data';

import 'package:srec/srec.dart';
import 'dart:io';

/// This file shows how to create a program that reads a Motorola S-record file
/// from the file system and writes the contents as binary file.
void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print(
        "Motorola S-record file converter. This program will read a Motorola S-record file and convert it to a binary file.\n    Usage: convert_to_binary <path to srec file>\n");
    exit(0);
  }
  String file = "";
  try {
    file = File(arguments[0]).readAsStringSync();
  } catch (e) {
    print("Failed to open file '${arguments[0]}':\n$e");
    exit(1);
  }
  try {
    var srec = SRecordFile.fromString(file);
    final filesize = srec.maxAddress;
    final outfile = getOutputFileName(arguments[0]);
    print(
        "Converting input file to binary: output: '$outfile' -> $filesize bytes!\n");
    var data = Uint8List(filesize);
    for (final seg in srec.segments) {
      for (int i = seg.address; i < seg.endAddress; ++i) {
        data[i] = seg.byte(i);
      }
    }
    File(outfile).writeAsBytesSync(data);
  } catch (e) {
    print("'${arguments[0]}' is not a valid Motorola S-record file:\n$e");
    exit(1);
  }
}

String getOutputFileName(String nm) {
  int index = nm.lastIndexOf('.');
  if (index > 0) {
    return '${nm.substring(0, index)}.bin';
  }
  return '$nm.bin';
}
