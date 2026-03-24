import 'dart:math';
import '../models/question_model.dart';

class QuestionGeneratorService {
  final Random random = Random();

  // Math Questions
  Question generateMathQuestion() {
    int type = random.nextInt(3);
    
    if (type == 0) {
      // Addition
      int a = random.nextInt(50) + 1;
      int b = random.nextInt(50) + 1;
      int correct = a + b;
      
      return Question(
        question: "What is $a + $b?",
        options: _generateNumericOptions(correct),
        correctIndex: 0,
        category: "math",
      );
    } else if (type == 1) {
      // Multiplication
      int a = random.nextInt(12) + 1;
      int b = random.nextInt(12) + 1;
      int correct = a * b;
      
      return Question(
        question: "What is $a × $b?",
        options: _generateNumericOptions(correct),
        correctIndex: 0,
        category: "math",
      );
    } else {
      // Subtraction
      int a = random.nextInt(50) + 20;
      int b = random.nextInt(20) + 1;
      int correct = a - b;
      
      return Question(
        question: "What is $a - $b?",
        options: _generateNumericOptions(correct),
        correctIndex: 0,
        category: "math",
      );
    }
  }

  // Science Questions
  Question generateScienceQuestion() {
    List<Map<String, dynamic>> questions = [
      {
        'question': 'What is the chemical symbol for water?',
        'correct': 'H2O',
        'wrong': ['CO2', 'O2', 'NaCl']
      },
      {
        'question': 'What planet is known as the Red Planet?',
        'correct': 'Mars',
        'wrong': ['Venus', 'Jupiter', 'Saturn']
      },
      {
        'question': 'What is the speed of light?',
        'correct': '300,000 km/s',
        'wrong': ['150,000 km/s', '500,000 km/s', '100,000 km/s']
      },
      {
        'question': 'What is the largest organ in the human body?',
        'correct': 'Skin',
        'wrong': ['Heart', 'Liver', 'Brain']
      },
      {
        'question': 'How many bones are in the adult human body?',
        'correct': '206',
        'wrong': ['195', '220', '180']
      },
      {
        'question': 'What gas do plants absorb from the atmosphere?',
        'correct': 'Carbon Dioxide',
        'wrong': ['Oxygen', 'Nitrogen', 'Hydrogen']
      },
    ];

    return _createQuestionFromTemplate(questions, 'science');
  }

  // Geography Questions
  Question generateGeographyQuestion() {
    List<Map<String, dynamic>> questions = [
      {
        'question': 'What is the capital of France?',
        'correct': 'Paris',
        'wrong': ['London', 'Berlin', 'Madrid']
      },
      {
        'question': 'Which is the largest ocean on Earth?',
        'correct': 'Pacific Ocean',
        'wrong': ['Atlantic Ocean', 'Indian Ocean', 'Arctic Ocean']
      },
      {
        'question': 'What is the longest river in the world?',
        'correct': 'Nile River',
        'wrong': ['Amazon River', 'Yangtze River', 'Mississippi River']
      },
      {
        'question': 'Which country has the largest population?',
        'correct': 'India',
        'wrong': ['China', 'USA', 'Indonesia']
      },
      {
        'question': 'What is the smallest continent?',
        'correct': 'Australia',
        'wrong': ['Europe', 'Antarctica', 'South America']
      },
      {
        'question': 'Which desert is the largest in the world?',
        'correct': 'Sahara Desert',
        'wrong': ['Gobi Desert', 'Arabian Desert', 'Kalahari Desert']
      },
    ];

    return _createQuestionFromTemplate(questions, 'geography');
  }

  // History Questions
  Question generateHistoryQuestion() {
    List<Map<String, dynamic>> questions = [
      {
        'question': 'In which year did World War II end?',
        'correct': '1945',
        'wrong': ['1944', '1946', '1943']
      },
      {
        'question': 'Who was the first President of the United States?',
        'correct': 'George Washington',
        'wrong': ['Thomas Jefferson', 'Abraham Lincoln', 'John Adams']
      },
      {
        'question': 'Which ancient wonder is still standing today?',
        'correct': 'Great Pyramid of Giza',
        'wrong': ['Hanging Gardens', 'Colossus of Rhodes', 'Lighthouse of Alexandria']
      },
      {
        'question': 'Who painted the Mona Lisa?',
        'correct': 'Leonardo da Vinci',
        'wrong': ['Michelangelo', 'Raphael', 'Donatello']
      },
      {
        'question': 'What year did the Titanic sink?',
        'correct': '1912',
        'wrong': ['1910', '1915', '1920']
      },
    ];

    return _createQuestionFromTemplate(questions, 'history');
  }

  // Technology Questions
  Question generateTechnologyQuestion() {
    List<Map<String, dynamic>> questions = [
      {
        'question': 'Who is known as the father of computers?',
        'correct': 'Charles Babbage',
        'wrong': ['Alan Turing', 'Bill Gates', 'Steve Jobs']
      },
      {
        'question': 'What does CPU stand for?',
        'correct': 'Central Processing Unit',
        'wrong': ['Computer Personal Unit', 'Central Program Utility', 'Computer Processing Unit']
      },
      {
        'question': 'What year was the first iPhone released?',
        'correct': '2007',
        'wrong': ['2005', '2008', '2006']
      },
      {
        'question': 'What does HTML stand for?',
        'correct': 'HyperText Markup Language',
        'wrong': ['High Tech Modern Language', 'Home Tool Markup Language', 'Hyperlinks Text Markup Language']
      },
      {
        'question': 'Who founded Microsoft?',
        'correct': 'Bill Gates',
        'wrong': ['Steve Jobs', 'Mark Zuckerberg', 'Elon Musk']
      },
    ];

    return _createQuestionFromTemplate(questions, 'technology');
  }

  // Sports Questions
  Question generateSportsQuestion() {
    List<Map<String, dynamic>> questions = [
      {
        'question': 'How many players are on a soccer team?',
        'correct': '11',
        'wrong': ['10', '12', '9']
      },
      {
        'question': 'Which country won the FIFA World Cup 2018?',
        'correct': 'France',
        'wrong': ['Brazil', 'Germany', 'Argentina']
      },
      {
        'question': 'How many rings are on the Olympic flag?',
        'correct': '5',
        'wrong': ['4', '6', '7']
      },
      {
        'question': 'In which sport would you perform a slam dunk?',
        'correct': 'Basketball',
        'wrong': ['Volleyball', 'Tennis', 'Baseball']
      },
      {
        'question': 'What is the maximum score in a single frame of bowling?',
        'correct': '30',
        'wrong': ['20', '25', '10']
      },
    ];

    return _createQuestionFromTemplate(questions, 'sports');
  }

  // Animals Questions
  Question generateAnimalsQuestion() {
    List<Map<String, dynamic>> questions = [
      {
        'question': 'What is the fastest land animal?',
        'correct': 'Cheetah',
        'wrong': ['Lion', 'Leopard', 'Tiger']
      },
      {
        'question': 'Which animal is known as the "King of the Jungle"?',
        'correct': 'Lion',
        'wrong': ['Tiger', 'Elephant', 'Gorilla']
      },
      {
        'question': 'How many hearts does an octopus have?',
        'correct': '3',
        'wrong': ['2', '4', '1']
      },
      {
        'question': 'What is the largest mammal in the world?',
        'correct': 'Blue Whale',
        'wrong': ['Elephant', 'Giraffe', 'Polar Bear']
      },
      {
        'question': 'Which bird cannot fly?',
        'correct': 'Penguin',
        'wrong': ['Eagle', 'Sparrow', 'Parrot']
      },
    ];

    return _createQuestionFromTemplate(questions, 'animals');
  }

  // Helper method to create question from template
  Question _createQuestionFromTemplate(List<Map<String, dynamic>> questions, String category) {
    var q = questions[random.nextInt(questions.length)];
    List<String> options = [q['correct'], ...q['wrong']];
    options.shuffle();
    
    return Question(
      question: q['question'],
      options: options,
      correctIndex: options.indexOf(q['correct']),
      category: category,
    );
  }

  // Helper method to generate numeric options
  List<String> _generateNumericOptions(int correct) {
    Set<int> options = {correct};
    
    while (options.length < 4) {
      int offset = random.nextInt(20) - 10;
      if (offset != 0) {
        options.add(correct + offset);
      }
    }
    
    List<String> result = options.map((e) => e.toString()).toList();
    result.shuffle();
    
    return result;
  }

  // Generate mixed quiz
  List<Question> generateQuiz(int number) {
    List<Question> quiz = [];
    List<Function> generators = [
      generateMathQuestion,
      generateScienceQuestion,
      generateGeographyQuestion,
      generateHistoryQuestion,
      generateTechnologyQuestion,
      generateSportsQuestion,
      generateAnimalsQuestion,
    ];

    for (int i = 0; i < number; i++) {
      var generator = generators[random.nextInt(generators.length)];
      quiz.add(generator());
    }

    return quiz;
  }
}
