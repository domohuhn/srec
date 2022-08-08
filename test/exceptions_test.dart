// Copyright (C) 2022 by domohuhn
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:srec/src/expections.dart';
import 'package:test/test.dart';

void main() {
  group('Exceptions', () {
    test("on line", () {
      var ex = ParsingError.onLine(25, 'some reason');
      expect(ex.toString(), 'Parsing error on line 25 : \'some reason\'');
    });
  });
}
