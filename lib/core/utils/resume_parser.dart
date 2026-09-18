/// Rule-based, deterministic Resume Skill Detector
/// Normalizes text and matches against a comprehensive technical and engineering dictionary.
class ResumeParser {
  ResumeParser._();

  /// Canonical skills mapped to common industry aliases, frameworks, and acronyms
  static const Map<String, List<String>> _skillAliases = {
    // Core Programming Languages
    'C': ['c language', 'c programming', 'ansi c', 'c/c++', 'c & c++', 'c and c++'],
    'C++': ['c++', 'cpp', 'c plus plus'],
    'C#': ['c#', '.net', 'dotnet', 'asp.net', 'csharp', 'c sharp'],
    'Java': ['java', 'core java', 'advanced java', 'j2ee', 'jvm'],
    'Python': ['python', 'python3', 'python 3', 'py'],
    'JavaScript': ['javascript', 'js', 'es6', 'ecmascript'],
    'TypeScript': ['typescript', 'ts'],
    'Dart': ['dart', 'dartlang', 'dart sdk'],
    'Kotlin': ['kotlin', 'kotlin coroutines'],
    'Swift': ['swift', 'swiftui', 'cocoapods', 'xcode'],
    'Golang': ['golang', 'go language', 'go lang', 'go developer'],
    'Rust': ['rust', 'rustlang'],
    'PHP': ['php', 'laravel', 'symfony'],
    'Ruby': ['ruby', 'ruby on rails', 'rails'],

    // Mobile App Development
    'Flutter': ['flutter', 'flutter sdk', 'flutter framework', 'flutter/dart', 'flutter developer'],
    'React Native': ['react native', 'react-native', 'expo'],
    'Android': ['android', 'android sdk', 'gradle', 'android development', 'jetpack compose'],
    'iOS': ['ios', 'ios development', 'uikit', 'apple developer'],
    'State Management': ['state management', 'bloc', 'flutter_bloc', 'riverpod', 'provider', 'getx', 'mobx', 'zustand'],

    // Frontend Web Development
    'React': ['react', 'react.js', 'reactjs', 'react-js'],
    'Next.js': ['next.js', 'nextjs', 'next js'],
    'HTML': ['html', 'html5'],
    'CSS': ['css', 'css3', 'sass', 'scss'],
    'Tailwind CSS': ['tailwind', 'tailwindcss', 'tailwind css'],
    'Bootstrap': ['bootstrap', 'bootstrap 5', 'bootstrap 4'],
    'Vue.js': ['vue', 'vue.js', 'vuejs', 'nuxt', 'nuxtjs'],
    'Angular': ['angular', 'angularjs', 'angular 2+'],
    'Redux': ['redux', 'redux toolkit', 'rtk query'],
    'WebSockets': ['websocket', 'websockets', 'socket.io'],

    // Backend Web Development
    'Node.js': ['node.js', 'nodejs', 'node js', 'node'],
    'Express.js': ['express', 'express.js', 'expressjs'],
    'Spring Boot': ['spring boot', 'springboot', 'spring framework', 'spring mvc', 'spring'],
    'Django': ['django', 'django rest framework', 'drf'],
    'FastAPI': ['fastapi', 'fast api'],
    'Flask': ['flask'],
    'REST API': ['rest api', 'rest apis', 'restful', 'restful api', 'restful apis', 'rest', 'api integration', 'web apis', 'http apis'],
    'GraphQL': ['graphql', 'apollo', 'relay'],
    'gRPC': ['grpc', 'protobuf', 'protocol buffers'],
    'Microservices': ['microservices', 'micro-services', 'distributed systems', 'event-driven architecture'],
    'Kafka': ['kafka', 'apache kafka', 'event streaming'],
    'RabbitMQ': ['rabbitmq', 'message queue', 'amqp'],

    // Databases & Caching
    'SQL': ['sql', 'rdbms', 'relational database', 'relational db', 'pl/sql'],
    'PostgreSQL': ['postgresql', 'postgres', 'psql'],
    'MySQL': ['mysql'],
    'SQLite': ['sqlite', 'sqflite', 'room db'],
    'MongoDB': ['mongodb', 'mongo', 'mongoose', 'nosql'],
    'Redis': ['redis', 'caching', 'in-memory database'],
    'Firebase': ['firebase', 'firestore', 'cloud firestore', 'firebase auth', 'firebase storage', 'realtime database', 'cloud messaging'],
    'Supabase': ['supabase', 'supabase auth'],
    'Elasticsearch': ['elasticsearch', 'elk stack', 'opensearch'],

    // Cloud, DevOps & Systems
    'Docker': ['docker', 'containerization', 'containers', 'dockerfile', 'docker-compose'],
    'Kubernetes': ['kubernetes', 'k8s', 'helm', 'kubectl'],
    'AWS': ['aws', 'amazon web services', 'ec2', 's3', 'lambda', 'cloudfront', 'ecs', 'dynamodb', 'cloudwatch'],
    'Google Cloud': ['google cloud', 'gcp', 'google cloud platform', 'cloud run', 'cloud functions', 'bigquery', 'app engine'],
    'Azure': ['azure', 'microsoft azure', 'azure devops'],
    'CI/CD': ['ci/cd', 'ci-cd', 'cicd', 'github actions', 'gitlab ci', 'jenkins', 'circleci', 'continuous integration', 'continuous deployment'],
    'Git': ['git', 'version control'],
    'GitHub': ['github', 'gitlab', 'bitbucket'],
    'Linux': ['linux', 'bash', 'shell scripting', 'unix', 'ubuntu', 'centos', 'debian'],
    'Terraform': ['terraform', 'infrastructure as code', 'iac'],
    'Nginx': ['nginx', 'reverse proxy', 'web server', 'apache'],

    // CS Fundamentals
    'Data Structures & Algorithms': ['data structures and algorithms', 'data structures & algorithms', 'data structures', 'algorithms', 'dsa'],
    'Object-Oriented Programming': ['object-oriented programming', 'object oriented programming', 'oop', 'oops'],
    'DBMS': ['dbms', 'database management systems', 'database management system'],
    'Operating Systems': ['operating systems', 'operating system', 'os fundamentals'],
    'Computer Networks': ['computer networks', 'computer networking', 'tcp/ip'],
    'System Design': ['system design', 'high level design', 'low level design', 'hld', 'lld'],
    'Clean Architecture': ['clean architecture', 'solid principles', 'design patterns', 'mvvm', 'mvc', 'repository pattern', 'bloc pattern'],

    // AI, Data Science & Machine Learning
    'Machine Learning': ['machine learning', 'ml', 'deep learning', 'artificial intelligence', 'ai', 'neural networks'],
    'Deep Learning': ['deep learning', 'cnn', 'rnn', 'lstm', 'transformers'],
    'Generative AI': ['generative ai', 'genai', 'gen ai', 'llm', 'llms', 'large language models', 'langchain', 'rag', 'vector database', 'openai', 'gemini', 'prompt engineering'],
    'Data Science': ['data science', 'data analytics', 'data analysis'],
    'PyTorch': ['pytorch', 'torch'],
    'TensorFlow': ['tensorflow', 'keras'],
    'Scikit-Learn': ['scikit-learn', 'sklearn'],
    'Pandas': ['pandas', 'numpy', 'scipy'],
    'NLP': ['nlp', 'natural language processing', 'spacy', 'nltk', 'huggingface'],
    'Computer Vision': ['computer vision', 'opencv', 'object detection'],
    'Tableau': ['tableau'],
    'Power BI': ['power bi', 'powerbi'],

    // UI/UX & Design Tools
    'Figma': ['figma', 'figma design'],
    'UI/UX Design': ['ui/ux', 'ui design', 'ux design', 'wireframing', 'prototyping', 'user research', 'product design'],
    'Design Systems': ['design system', 'design systems', 'component library', 'material design'],

    // Testing, Tools & Methodologies
    'Unit Testing': ['unit testing', 'unit test', 'test driven development', 'tdd', 'integration testing', 'widget testing', 'jest', 'mockito', 'flutter test', 'pytest', 'junit'],
    'Postman': ['postman', 'swagger', 'api documentation', 'api testing'],
    'Jira': ['jira', 'confluence', 'trello', 'asana'],
    'Agile': ['agile', 'scrum', 'kanban', 'sprint'],
    'Problem Solving': ['problem solving', 'analytical skills', 'debugging', 'troubleshooting'],
    'Communication': ['communication skills', 'interpersonal skills', 'team communication'],
    'Leadership': ['leadership', 'team leadership', 'mentorship'],
  };

  /// Canonical list of all searchable skills
  static List<String> get skillDictionary => _skillAliases.keys.toList();

  /// Detects all matching skills from the resume text payload
  static List<String> detectSkills(String resumeContent) {
    if (resumeContent.trim().isEmpty) return [];

    final lower = resumeContent.toLowerCase();
    // Normalize punctuation while keeping #, +, ., /, and placing - at the end
    final normalized = ' ${lower.replaceAll(RegExp(r'[^a-z0-9+#./\s-]'), ' ')} ';
    final detected = <String>{};

    for (final entry in _skillAliases.entries) {
      final canonicalName = entry.key;
      final aliases = entry.value;

      for (final alias in aliases) {
        final a = alias.toLowerCase().trim();
        if (a.isEmpty) continue;

        // For short aliases (e.g. 'c#', 'c++', 'go', 'ts', 'js', 'sql', 'r', 'ml', 'ai')
        // use strict boundary matching to avoid substrings within regular English words
        final isShort = a.length <= 3;
        final escaped = RegExp.escape(a);

        // Put - at the end of character classes to avoid being parsed as a character range
        final pattern = isShort
            ? r'(?:^|[\s,./()\[\]|:;•\t\n\r-])' + escaped + r'(?:$|[\s,./()\[\]|:;•\t\n\r-])'
            : r'(?:^|[\s,./()\[\]|:;•\t\n\r-])' + escaped + r'(?:$|[\s,./()\[\]|:;•\t\n\r-s])';

        final regex = RegExp(pattern, caseSensitive: false);
        if (regex.hasMatch(normalized) || regex.hasMatch(lower)) {
          detected.add(canonicalName);
          break; // Stop after first matched alias for this canonical skill
        }
      }
    }

    // Special high-precision detection for single-letter language 'C'
    if (!detected.contains('C')) {
      final cPattern = RegExp(
        r'(?:languages?|skills?|technologies?)[\s\S]{0,100}?(?:^|[\s,;|/•])c(?:$|[\s,;|/•])',
        caseSensitive: false,
      );
      final cListPattern = RegExp(r'(?:^|[\s,;|/•])c\s*,\s*(?:c\+\+|cpp|java|python|c#)', caseSensitive: false);
      if (cPattern.hasMatch(lower) || cListPattern.hasMatch(lower)) {
        detected.add('C');
      }
    }

    return detected.toList()..sort();
  }

  /// Detects skills along with an estimated proficiency score (75-95%)
  static Map<String, int> detectSkillsWithProficiency(String resumeContent) {
    final skills = detectSkills(resumeContent);
    final lowerContent = resumeContent.toLowerCase();
    final result = <String, int>{};

    for (final skill in skills) {
      final aliases = _skillAliases[skill] ?? [skill.toLowerCase()];
      int occurrences = 0;
      for (final alias in aliases) {
        try {
          occurrences += RegExp(RegExp.escape(alias.toLowerCase()), caseSensitive: false)
              .allMatches(lowerContent)
              .length;
        } catch (_) {}
      }

      // Base proficiency calibrated on prominence in the CV
      int score = 75;
      if (occurrences >= 4) {
        score = 95;
      } else if (occurrences >= 2) {
        score = 88;
      } else {
        score = 80;
      }

      result[skill] = score;
    }

    return result;
  }
}
