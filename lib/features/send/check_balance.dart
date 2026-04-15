import 'dart:io';

// ignore_for_file: avoid_print

void main(List<String> args) {
  if (args.length < 3) {
    print('Usage: dart check_balance.dart <filename> <start_line> <end_line>');
    return;
  }

  String filename = args[0];
  int startLine = int.parse(args[1]);
  int endLine = int.parse(args[2]);

  checkBalance(filename, startLine, endLine);
}

void checkBalance(String filename, int startLine, int endLine) {
  File file = File(filename);
  if (!file.existsSync()) {
    print('File not found: $filename');
    return;
  }

  List<String> lines = file.readAsLinesSync();
  
  // startLine is 1-indexed
  int startIdx = startLine - 1;
  int endIdx = endLine;
  
  if (startIdx < 0) startIdx = 0;
  if (endIdx > lines.length) endIdx = lines.length;

  if (startIdx >= endIdx) {
    print('Parentheses: 0');
    print('Braces: 0');
    print('Square brackets: 0');
    return;
  }

  String code = lines.sublist(startIdx, endIdx).join('\n');
  
  int pCount = 0;
  int bCount = 0;
  int sCount = 0;

  for (int i = 0; i < code.length; i++) {
    String char = code[i];
    if (char == '(') {
      pCount += 1;
    } else if (char == ')') {
      pCount -= 1;
    } else if (char == '{') {
      bCount += 1;
    } else if (char == '}') {
      bCount -= 1;
    } else if (char == '[') {
      sCount += 1;
    } else if (char == ']') {
      sCount -= 1;
    }
  }

  print('Parentheses: $pCount');
  print('Braces: $bCount');
  print('Square brackets: $sCount');
}
