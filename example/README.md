# Example files

The full source code for the examples can be found in [the examples directory in github](https://github.com/domohuhn/srec/tree/main/example).

## Motorola S-record file linter

The file "srec_lint.dart" contains all the code you need to validate that
a Motorola S-record contains no errors. The program reads a file, and parses all
records until the end of the file. If there is any type of error (checksum not valid, wrong record block, wrong characters...) an exception is thrown.

The example condensed into a few lines:
```dart
import 'package:srec/srec.dart';

try {
  var file = File(path).readAsStringSync();
  var srec = SRecordFile.fromString(file);
} catch (e) {
  // handle error
}
```

## Motorola S-record file converter

The file "convert_to_srec.dart" contains all the code you need to convert binary data to a Motorola S-record file.

The example condensed into a few lines:
```dart
import 'package:srec/srec.dart';

List<int> data = /* fill data */;
var srec = SRecordFile.fromData(data);
var hexString = srec.toFileContents();
```

## Try the executables

You can try the example executables with a few simple commands in the project root directory:
```bash
# Runs the linter on an invalid file - will display an error and return a nonzero value
dart ./example/srec_lint.dart ./example/srec_lint.dart
# Converts a file to Motorola s-record
dart ./example/convert_to_srec.dart ./example/convert_to_srec.dart
# Runs the linter on a valid file
dart ./example/srec_lint.dart ./example/convert_to_srec.dart.srec
```
