import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hirehub/core/utils/document_text_extractor.dart';
import 'package:hirehub/core/utils/resume_parser.dart';

void main() {
  group('ResumeParser Deterministic Engine', () {
    test('Extracts known skills from resume text string', () {
      const sampleResume = '''
        Rahul Sharma
        Senior Mobile Developer with 3+ years experience building cross-platform apps using Flutter and Dart.
        Integrated Firebase Authentication and Cloud Firestore. Proficient in Git, CI/CD, and REST API.
      ''';

      final skills = ResumeParser.detectSkills(sampleResume);

      expect(skills, contains('Flutter'));
      expect(skills, contains('Dart'));
      expect(skills, contains('Firebase'));
      expect(skills, contains('Git'));
      expect(skills, contains('CI/CD'));
      expect(skills, contains('REST API'));
      expect(skills, isNot(contains('Kotlin')));
    });

    test('Returns empty list on empty resume content', () {
      expect(ResumeParser.detectSkills('').isEmpty, isTrue);
      expect(ResumeParser.detectSkills('    ').isEmpty, isTrue);
    });

    test('Estimates proficiency scores based on skill prominence', () {
      const resume = '''
        Experienced Flutter developer. Built 10+ Flutter applications.
        Also familiar with Docker, Kubernetes, and Golang.
      ''';
      final proficiencies = ResumeParser.detectSkillsWithProficiency(resume);
      expect(proficiencies['Flutter'], greaterThanOrEqualTo(80));
      expect(proficiencies['Docker'], greaterThanOrEqualTo(70));
      expect(proficiencies['Kubernetes'], greaterThanOrEqualTo(70));
    });

    test('Detects acronyms and aliases (K8s, GCP, Postgres, TS)', () {
      const resume = 'Deployed microservices to K8s on GCP using Postgres and TS backend.';
      final skills = ResumeParser.detectSkills(resume);
      expect(skills, contains('Kubernetes'));
      expect(skills, contains('Google Cloud'));
      expect(skills, contains('PostgreSQL'));
      expect(skills, contains('TypeScript'));
    });

    test('Detects CS fundamentals and full-stack technical stack', () {
      const resume = '''
        B.Tech Computer Science & Engineering.
        Programming: C, C++, Java, Python, JavaScript.
        Web: React, Node.js, Express.js, MongoDB, Tailwind CSS, Bootstrap.
        CS Core: Data Structures & Algorithms (DSA), OOP, DBMS, Operating Systems.
        DevOps & Tools: Docker, AWS, Git, GitHub, Postman, Figma.
      ''';
      final skills = ResumeParser.detectSkills(resume);
      expect(skills, contains('C'));
      expect(skills, contains('C++'));
      expect(skills, contains('Java'));
      expect(skills, contains('Python'));
      expect(skills, contains('JavaScript'));
      expect(skills, contains('React'));
      expect(skills, contains('Node.js'));
      expect(skills, contains('Express.js'));
      expect(skills, contains('MongoDB'));
      expect(skills, contains('Tailwind CSS'));
      expect(skills, contains('Bootstrap'));
      expect(skills, contains('Data Structures & Algorithms'));
      expect(skills, contains('Object-Oriented Programming'));
      expect(skills, contains('DBMS'));
      expect(skills, contains('Operating Systems'));
      expect(skills, contains('Docker'));
      expect(skills, contains('AWS'));
      expect(skills, contains('Git'));
      expect(skills, contains('GitHub'));
      expect(skills, contains('Postman'));
      expect(skills, contains('Figma'));
    });

    test('DocumentTextExtractor extracts text from UTF8/ASCII bytes and matches skills', () {
      final bytes = Uint8List.fromList('Senior Flutter Engineer proficient with Python, GraphQL, and AWS.'.codeUnits);
      final extracted = DocumentTextExtractor.extractText(bytes, 'my_resume.txt');
      expect(extracted, contains('Flutter'));
      final skills = ResumeParser.detectSkills(extracted);
      expect(skills, contains('Flutter'));
      expect(skills, contains('Python'));
      expect(skills, contains('GraphQL'));
      expect(skills, contains('AWS'));
    });

    test('DocumentTextExtractor extracts text from PDF text operators', () {
      const fakePdf = '%PDF-1.4\n1 0 obj\n<< /Length 50 >>\nstream\nBT /F1 12 Tf (Lead Flutter and React Architect) Tj ET\nendstream\nendobj';
      final bytes = Uint8List.fromList(fakePdf.codeUnits);
      final extracted = DocumentTextExtractor.extractText(bytes, 'resume.pdf');
      expect(extracted, contains('Lead Flutter and React Architect'));
      final skills = ResumeParser.detectSkills(extracted);
      expect(skills, contains('Flutter'));
      expect(skills, contains('React'));
    });

    test('DocumentTextExtractor decodes PDF hex text operators and kerning arrays', () {
      // Hex literal for 'Flutter' = <466C7574746572>
      // TJ kerning array with word separation -120
      const fakeHexPdf = '''%PDF-1.4
1 0 obj
<< /Length 120 >>
stream
BT
<466C7574746572> Tj
[(Full) -120 (Stack) -120 (Engineer)] TJ
ET
endstream
endobj''';

      final bytes = Uint8List.fromList(fakeHexPdf.codeUnits);
      final extracted = DocumentTextExtractor.extractText(bytes, 'resume_hex.pdf');
      expect(extracted, contains('Flutter'));
      expect(extracted, contains('Full Stack Engineer'));
      final skills = ResumeParser.detectSkills(extracted);
      expect(skills, contains('Flutter'));
    });

    test('DocumentTextExtractor decompresses Flate streams with ZLib', () {
      final rawContent = 'BT /F1 14 Tf (Python Machine Learning Engineer with PyTorch and TensorFlow) Tj ET';
      final compressed = ZLibEncoder().encode(latin1.encode(rawContent));

      final fakeFlatePdf = '%PDF-1.4\n1 0 obj\n<< /Filter /FlateDecode /Length ${compressed.length} >>\nstream\n${latin1.decode(compressed)}\nendstream\nendobj';

      final bytes = Uint8List.fromList(latin1.encode(fakeFlatePdf));
      final extracted = DocumentTextExtractor.extractText(bytes, 'flate_resume.pdf');
      expect(extracted, contains('Python Machine Learning Engineer'));
      final skills = ResumeParser.detectSkills(extracted);
      expect(skills, contains('Python'));
      expect(skills, contains('Machine Learning'));
      expect(skills, contains('PyTorch'));
      expect(skills, contains('TensorFlow'));
    });

    test('DocumentTextExtractor translates custom font glyphs via ToUnicode CMap', () {
      // CMap translating custom glyphs <0001> -> 'F', <0002> -> 'l', <0003> -> 'u', <0004> -> 't'
      const fakeCMapPdf = '''%PDF-1.4
1 0 obj
<< /Length 200 >>
stream
/CIDInit /ProcSet findresource begin
begincmap
1 beginbfchar
<0001> <0046>
<0002> <006C>
<0003> <0075>
<0004> <0074>
endbfchar
endcmap
endstream
endobj
2 0 obj
<< /Length 60 >>
stream
BT
<000100020003000400040003> Tj
ET
endstream
endobj''';

      final bytes = Uint8List.fromList(fakeCMapPdf.codeUnits);
      final extracted = DocumentTextExtractor.extractText(bytes, 'cmap_resume.pdf');
      expect(extracted.length, greaterThanOrEqualTo(4));
      // First four letters translated to Flut
      expect(extracted, contains('Flut'));
    });
  });
}
