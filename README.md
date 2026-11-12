# M2A1: Student Grades

**Kind:** demo, built live in the lab. Follow along, type the code yourself, and push before you leave. Searching, AI and helping each other are all allowed.

In this demo you build a console program that reads one student's name and scores, works out the average, and prints a remark. It is syllabus Lab 1.

## Before you start

Follow the [setup guide](SETUP.md) to create and clone your private repository, exactly as in M1A0. The repository is named `m2a1-CLASSCODE-USERNAME`.

## What you build with the instructor

1. A short calculator warm-up in `bin/warmup.dart` that reads two numbers and prints their sum, difference, product and quotient.
2. The grades program in `bin/grades.dart`:
   - It asks for the student's name and three scores out of 100.
   - A function `double computeAverage(List<double> scores)` in `lib/grades.dart` returns the average.
   - A function `String remarkFor(double average)` returns `"Excellent"` from 90, `"Passed"` from 75, and `"Needs improvement"` below 75.
   - `main()` prints the name, the average to two decimals, and the remark.

The demo shows how `stdin`, `double.tryParse`, `??` and functions fit together. See `content/m2-dart-basics/LAB.md` for the syntax.

## How it is graded

5 test points. The tests call `computeAverage` and `remarkFor` with several inputs. If you followed along and your program runs, you earn full marks.

Every activity also checks `student.json`: fill in your full name, student number, school email, class code, GitHub username, `room` and `pcNumber`, all as text.

## Check and save your work

```sh
dart analyze
dart test
```

The tests in your repository are a guide. The instructor grades from the course's own copy of the tests, so do not edit the tests to make them pass.

```sh
git status
git add bin/ lib/ student.json SOURCES-AND-ASSISTANCE.md
git commit -m "Complete M2A1"
```

In VS Code, open **Source Control** and choose **Push**, then check that the commit appears on GitHub.

## Submit the exact commit link in Canvas

Open your repository's commit history on GitHub, open the commit with your finished work, copy its full URL (it contains **/commit/**), and submit it in the Canvas assignment for M2A1 using the Website URL option. Submit the commit page, not the repository home page or a screenshot.
