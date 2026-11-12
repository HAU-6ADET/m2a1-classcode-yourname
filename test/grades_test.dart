import 'dart:convert';
import 'dart:io';

import 'package:m2a1/grades.dart';
import 'package:test/test.dart';

void main() {
  group('computeAverage', () {
    test('averages three scores', () => expect(computeAverage([80, 90, 100]), closeTo(90, 0.001)));
    test('keeps decimals', () => expect(computeAverage([75, 76]), closeTo(75.5, 0.001)));
    test('returns 0 for no scores', () => expect(computeAverage([]), equals(0)));
  });

  group('remarkFor', () {
    test('90 is Excellent', () => expect(remarkFor(90), equals('Excellent')));
    test('89.99 is Passed', () => expect(remarkFor(89.99), equals('Passed')));
    test('75 is Passed', () => expect(remarkFor(75), equals('Passed')));
    test('74.99 needs improvement', () => expect(remarkFor(74.99), equals('Needs improvement')));
  });

  group("Student details in your private activity copy", () {
    late Map<String, dynamic> info;
    setUpAll(() {
      info = jsonDecode(File("student.json").readAsStringSync()) as Map<String, dynamic>;
    });
    for (final field in ["fullName", "studentNumber", "studentEmail", "classCode", "githubAccount", "room", "pcNumber"]) {
      test("$field is filled in", () {
        final value = info[field];
        expect(value, isA<String>(), reason: "Set $field in student.json.");
        expect((value as String).trim(), isNotEmpty, reason: "Set $field in your private copy of student.json.");
      });
    }
    test("classCode identifies one of the new ADET classes", () {
      expect(info["classCode"], isIn(["2223", "2293", "2182", "2294"]), reason: "Use the class code shown in your own Canvas course.");
    });
  });
}
