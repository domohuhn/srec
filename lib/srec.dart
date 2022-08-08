// Copyright (C) 2022 by domohuhn
//
// SPDX-License-Identifier: BSD-3-Clause

/// This library provides the functionality to read and write Motorola S-record files.
///
/// S-record is a file format that stores binary data as ASCII text files.
/// The primary interface to use this library is the class [SRecordFile].
///
/// The hex file may contain multiple instances of Memory Segments that
/// describe the binary layout of the memory. The segments are managed via
/// the base class of the file: MemorySegmentContainer from the [intel_hex](https://pub.dev/packages/intel_hex) package.
library srec;

export 'src/srec_base.dart';
export 'src/expections.dart';
