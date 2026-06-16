import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:test/test.dart';

Future<String> _run(List<String> inputs) async {
  final process = await Process.start('dart', ['run', 'bin/voting.dart']);
  for (final line in inputs) {
    process.stdin.writeln(line);
  }
  await process.stdin.flush();
  await process.stdin.close();
  final out = await process.stdout.transform(utf8.decoder).join();
  await process.exitCode;
  return out;
}

/// The voting age is 18. Rather than hardcode the expected words for fixed
/// ages, the tests feed the boundary plus random ages on each side and check
/// the program's decision matches `age >= votingAge` (so it can't be faked).
const votingAge = 18;

bool _qualified(String out) {
  final low = out.toLowerCase();
  return low.contains('qualified') && !low.contains('not qualified');
}

void main() {
  test('student.json is filled in', () {
    final info = jsonDecode(File('student.json').readAsStringSync())
        as Map<String, dynamic>;
    for (final field in [
      'classCode',
      'fullName',
      'studentNumber',
      'studentEmail',
      'personalEmail',
      'githubAccount',
    ]) {
      expect(info[field], isNotEmpty, reason: 'Set "$field" in student.json');
    }
  });

  group('Voting eligibility', () {
    final rng = Random(2026);
    final olderAge = votingAge + 1 + rng.nextInt(60); // 19..78
    final youngerAge = rng.nextInt(votingAge); // 0..17

    test('exactly the voting age ($votingAge) is qualified', () async {
      expect(_qualified(await _run(['$votingAge'])), isTrue,
          reason: '$votingAge is exactly the voting age');
    });
    test('one year under the voting age (${votingAge - 1}) is not qualified',
        () async {
      expect(_qualified(await _run(['${votingAge - 1}'])), isFalse,
          reason: '${votingAge - 1} is below the voting age');
    });
    test('an older age ($olderAge) is qualified', () async {
      expect(_qualified(await _run(['$olderAge'])), isTrue,
          reason: '$olderAge is above the voting age');
    });
    test('a younger age ($youngerAge) is not qualified', () async {
      expect(_qualified(await _run(['$youngerAge'])), isFalse,
          reason: '$youngerAge is below the voting age');
    });
  }, timeout: const Timeout(Duration(seconds: 60)));
}
