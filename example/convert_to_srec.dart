// Copyright (C) 2022 by domohuhn
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:srec/srec.dart';
import 'dart:io';
import 'dart:typed_data';

/// This file shows how to create a program that reads a file
/// from the file system and converts it to a Motorola S-record file.
/// The output file will be called &lt;path&gt;.srec.

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print(
        "Motorola S-record file converter. This program will read a file and convert it to a Motorola S-record file.\n    Usage: convert_to_srec <path to file>\n\nThe output file will have the same name as the input, but with an additional .srec appended to its path.");
    exit(0);
  }
  Uint8List file = Uint8List(0);
  String path = arguments[0];
  try {
    file = File(path).readAsBytesSync();
  } catch (e) {
    print("Failed to open file '$path':\n$e");
    exit(1);
  }
  try {
    var srec = SRecordFile.fromData(file);
    var out = File("$path.srec");
    if (out.existsSync()) {
      print("ERROR: '$path.srec' already exists!");
      exit(1);
    }
    out.writeAsStringSync(srec.toFileContents());
    print('Created "$path.srec"');
  } catch (e) {
    print("ERROR: '$path' could not be converted!\n$e");
    exit(1);
  }
}
