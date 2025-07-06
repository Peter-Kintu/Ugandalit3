// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/category.dart';
import '../data/quiz_data.dart';


class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  final int totalQuestions = 10;
  Category? selectedCategory;
  List<Map<String, String>> questionAnswerPairs = [];
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedCategory?.name ?? 'Themes',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue,
                  Colors.blue.shade50,
                ],
              ),
            ),
            child: selectedCategory == null
                ? _buildCategoryGrid()
                : _buildQuizContent(),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -3.14 / 2, // Blast upwards
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.05,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: quizCategories.length,
      itemBuilder: (context, index) {
        return Card(
          child: InkWell(
            onTap: () {
              setState(() {
                selectedCategory = quizCategories[index];
                currentQuestionIndex = 0;
                score = 0;
                questionAnswerPairs.clear();
              });
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.blue.shade50,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    quizCategories[index].icon,
                    style: const TextStyle(fontSize: 50),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    quizCategories[index].name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuizContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Question ${currentQuestionIndex + 1} of $totalQuestions',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      selectedCategory!.questions[currentQuestionIndex].questionText,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ...selectedCategory!.questions[currentQuestionIndex].options.map(
                (option) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () => answerQuestion(
                        selectedCategory!.questions[currentQuestionIndex].options.indexOf(option)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.all(20),
                      textStyle: const TextStyle(fontSize: 18),
                      elevation: 4,
                      shadowColor: Colors.blue.withOpacity(0.2),
                    ),
                    child: Text(option),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
}

void answerQuestion(int selectedIndex) {
    String correctAnswer = selectedCategory!
        .questions[currentQuestionIndex]
        .options[selectedCategory!.questions[currentQuestionIndex]
            .correctAnswerIndex];
    String questionText = selectedCategory!
        .questions[currentQuestionIndex]
        .questionText;

    questionAnswerPairs.add({"question": questionText, "answer": correctAnswer});

    if (selectedIndex ==
        selectedCategory!.questions[currentQuestionIndex].correctAnswerIndex) {
      score++;
    }

    setState(() {
      if (currentQuestionIndex < 9) {
        currentQuestionIndex++;
      } else {
        if (score == totalQuestions) {
          _confettiController.play(); // Play confetti animation
        }
       showDialog(
  context: context,
  barrierDismissible: false, // Prevent dismissing by tapping outside
  builder: (context) => AlertDialog(
    title: score == totalQuestions
        ? const Text(
            'Wow! Congratulations!',
            style: TextStyle(color: Colors.green),
          )
        : const Text('Quiz Completed!'),
    content: SizedBox(
      height: 300,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your score: $score/10'),
            const SizedBox(height: 16),
            const Text(
              'Questions and Correct Answers:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (var pair in questionAnswerPairs)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Qtn: ${pair["question"]}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Ans: ${pair["answer"]}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          setState(() {
            selectedCategory = null;
            currentQuestionIndex = 0;
            score = 0;
            questionAnswerPairs.clear();
            _confettiController.stop();
          });
        },
        child: const Text('OK'),
      ),
    ],
  ),
);
}
  });
   }
    }