// Copyright (C) 2022 by domohuhn
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:srec/srec.dart';
import 'dart:io';

/// This file shows how to create a program that reads a Motorola S-record file
/// from the file system and checks if there are any errors in the file.

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print(
        "Motorola S-record linter. This program will read a Motorola s-record file and check for any errors.\n    Usage: srec_lint <path to srec file>\n");
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
    var hex = SRecordFile.fromString(file);
    print("Valid:\n$hex");
  } catch (e) {
    print("'${arguments[0]}' is not a valid Motorola S-record file:\n$e");
    exit(1);
  }
}
