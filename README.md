# Motorola S-Record library

[![Dart](https://github.com/domohuhn/srec/actions/workflows/dart.yml/badge.svg)](https://github.com/domohuhn/srec/actions/workflows/dart.yml)
[![codecov](https://codecov.io/gh/domohuhn/srec/branch/main/graph/badge.svg?token=G0I86WZYF8)](https://codecov.io/gh/domohuhn/srec)

A dart library that reads and writes [Motorola S-Record files](https://en.wikipedia.org/wiki/SREC_(file_format)) (common file extensions: .s19, .s28, .s37, .srec). Motorola S-Record is a file format that is used to store binary data as ASCII text. It is often used to program microcontrollers. The file is comprised of record blocks. Each record block is represented as a line in the text file. A record starts with a "S" character and ends at the end of the line. The last byte of a record block is the checksum of all other bytes in this block.

A record has six fields:

 - Start code. Usually "S".
 - Record type
 - Byte count
 - Address
 - Data. May be empty.
 - Checksum

## Features

The library can both read and write files in the Motorola S-record format. The checksum will be validated when reading a file. If the format cannot be parsed, then an exception is thrown with the line where the error occurred. Therefore, this library can also be used as linter for s-record files.

The following record types can be parsed:

| Record type     | Id   | Description |
| ---------   | -------------------------------  | ----------- |
| Header | S0 | A meta data field with a description of the following records. |
| Data  | S1, S2, S3 | A normal data field. |
| Count | S5, S6 | The count of previous S1, S2 and S3 records. |
| Start Address (termination) | S7, S8, S9 | A data field that holds the initial instruction pointer and terminates the record block. |

Each record can contain a payload of 0-255 bytes.

## Getting started

To use the package, simply add it to your pubspec.yaml:
```yaml
dependencies:
  srec: ^1.1.0
```

And you are good to go!

## Usage

Here is a simple example showing how to read a file:

```dart
import 'package:srec/srec.dart';

// example reading a file ...
final file = File(path).readAsStringSync();
var srec = SRecordFile.fromString(file);
```

Converting binary data to an Intel HEX string can be done with the following code:
```dart
import 'package:srec/srec.dart';

Uint8List data = /* get binary data */;
var srec = SRecordFile.fromData(data);
var hexString = srec.toFileContents();
```

See also the examples in the [examples directory](https://github.com/domohuhn/srec/tree/main/example).
There is also an up to date documentation on [pub.dev](https://pub.dev/documentation/srec/latest/) that explains the API of the library.

## Additional information

In case of bug reports or feature requests, please use the [issue tracker](https://github.com/domohuhn/srec/issues) on github.

## Dependencies

The library uses the Memory Segments from the [intel_hex](https://pub.dev/packages/intel_hex) package.
