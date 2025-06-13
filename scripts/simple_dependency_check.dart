import 'dart:io';

void main() async {
  print('🔍 의존성 체크 시작...\n');

  final libDir = Directory('lib');
  final files = <String>[];
  final imports = <String, List<String>>{};

  // 모든 dart 파일 수집
  await for (FileSystemEntity entity
      in libDir.list(recursive: true)) {
    if (entity is File &&
        entity.path.endsWith('.dart')) {
      final relativePath = entity.path
          .split('lib/')
          .last;
      files.add(relativePath);

      final content = await entity.readAsString();
      final fileImports = <String>[];

      // 간단한 import 추출
      final lines = content.split('\n');
      for (String line in lines) {
        if (line.startsWith('import \'') &&
            line.contains('../')) {
          final importPath = line.split('\'')[1];
          fileImports.add(importPath);
        }
      }

      imports[relativePath] = fileImports;
    }
  }

  print('📊 발견된 파일: ${files.length}개');
  print('📄 상대 경로 import가 있는 파일:');

  int importCount = 0;
  for (String file in imports.keys) {
    if (imports[file]!.isNotEmpty) {
      print(
        '  $file: ${imports[file]!.length}개 import',
      );
      importCount += imports[file]!.length;
    }
  }

  print('\n📈 총 상대경로 import: ${importCount}개');
  print('✅ 분석 완료!\n');

  if (importCount > 0) {
    print(
      '💡 추천: index.dart 파일들을 만들어 import 경로를 단순화할 수 있습니다.',
    );
  }
}
