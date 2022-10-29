// Copyright (C) 2022 by domohuhn
//
// SPDX-License-Identifier: BSD-3-Clause

/// Thrown if an error during parsing occurs
class ParsingError implements Exception {
  /// Information about the parsing error can be given in [_msg].
  ParsingError(this._msg);

  /// Error when parsing a [line] with the given [reason].
  ParsingError.onLine(int line, String reason)
      : _msg = "Parsing error on line $line : '$reason'";

  final String _msg;
  @override
  String toString() {
    return _msg;
  }
}
