import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_app/features/chatbot/controllers/roadmap_agent_executor.dart';
import 'package:flashcard_app/features/chatbot/controllers/suggestion_agent_controller.dart';
import 'package:flashcard_app/features/chatbot/controllers/suggestion_agent_executor.dart';
import 'package:flashcard_app/features/chatbot/services/suggestion_agent_service.dart';
import 'package:flutter/material.dart';

import '../../../models/chatModel.dart';
import '../services/chatbot_service.dart';
import '../services/flashcard_agent_service.dart';
import '../services/roadmap_agent_service.dart';
import 'flashcard_agent_controller.dart';
import 'flashcard_agent_executor.dart';
import 'roadmap_agent_controller.dart';

class ChatbotController extends ChangeNotifier {
  final ChatbotService _chatbotService = ChatbotService();

  final List<ChatMessage> messages = [];

  final FlashcardAgent flashcardAgent = FlashcardAgent();

  final FlashcardExecutor flashcardExecutor = FlashcardExecutor(
    FlashcardAgentService(),
  );

  final SuggestionAgentExecutor suggestionExecutor = SuggestionAgentExecutor(
    SuggestionAgentService(),
  );

  final SuggestionAgent suggestionAgent = SuggestionAgent();

  final RoadMapExecutor studyPlanExecutor = RoadMapExecutor(RoadMapService());

  ChatAgentType currentAgent = ChatAgentType.flashcard;

  bool isLoading = false;
  bool isProcessing = false;
  bool _isGreeting(String text) {
    final msg = text.trim().toLowerCase();

    return [
      "hi",
      "hello",
      "hey",
      "good morning",
      "good afternoon",
      "good evening",
    ].contains(msg);
  }

  ChatbotController() {
    messages.add(
      ChatMessage(
        isBot: true,
        message:
            "Hi there! I'm your Mofu Assistant!\nWhat would you like to do today?",
        options: ["Create flashcards", "Suggest vocabulary", "Study plan"],
      ),
    );
  }

  void _showFirstMenu() {
    messages.add(
      ChatMessage(
        isBot: true,
        message:
            "Hi there! I'm your Mofu Assistant!\nWhat would you like to do today?",
        options: ["Create flashcards", "Suggest vocabulary", "Study plan"],
      ),
    );

    notifyListeners();
  }

  void _showMainMenu() {
    messages.add(
      ChatMessage(
        isBot: true,
        message: "Task complete successfully! What would you like to do next?",
        options: ["Create flashcards", "Suggest vocabulary", "Study plan"],
      ),
    );

    currentAgent = ChatAgentType.flashcard;
  }

  void selectAgent(String option) {
    if (isProcessing) return;

    switch (option) {
      case "Create flashcards":
        currentAgent = ChatAgentType.flashcard;
        flashcardAgent.start(messages);
        break;

      case "Suggest vocabulary":
        currentAgent = ChatAgentType.vocabulary;
        suggestionAgent.start(messages);
        notifyListeners();
        break;

      case "Study plan":
        currentAgent = ChatAgentType.studyPlan;
        _handleRoadmapByAgent();
        break;
    }

    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    if (isProcessing) return; // avoid agents running at the same time

    messages.add(ChatMessage(message: text, isBot: false));
    notifyListeners();

    // ------ flashcard agent -----
    if (currentAgent == ChatAgentType.flashcard &&
        flashcardAgent.isCollecting) {
      flashcardAgent.processMessage(text, messages);
      notifyListeners();

      if (flashcardAgent.isCompleted) {
        isProcessing = true;
        isLoading = true;
        notifyListeners();

        try {
          final user = FirebaseAuth.instance.currentUser;

          if (user != null) {
            final responses = await flashcardExecutor.generate(
              userId: user.uid,
              topic: flashcardAgent.topic!,
              totalCards: flashcardAgent.totalCards!,
              language: flashcardAgent.language,
              difficulty: flashcardAgent.difficulty!,
            );

            messages.addAll(responses);
          }

          flashcardAgent.reset();

          _showMainMenu();
        } catch (e) {
          messages.add(
            ChatMessage(isBot: true, message: "Flashcard failed: $e"),
          );
        }

        isProcessing = false;
        isLoading = false;
        notifyListeners();
      }

      return;
    }
    // ------ suggestion agent -----
    if (currentAgent == ChatAgentType.vocabulary &&
        suggestionAgent.isCollecting) {
      suggestionAgent.processMessage(text, messages);
      notifyListeners();

      if (suggestionAgent.isCompleted) {
        isProcessing = true;
        isLoading = true;
        notifyListeners();

        try {
          final user = FirebaseAuth.instance.currentUser;

          if (user == null) {
            messages.add(
              ChatMessage(isBot: true, message: "Please login first."),
            );
          } else {
            final result = await suggestionExecutor.generate(
              userId: user.uid,
              sessionDuration: suggestionAgent.sessionDuration!,
              topN: suggestionAgent.topN!,
            );

            messages.add(result);
          }

          flashcardAgent.reset();

          _showMainMenu();
        } catch (e) {
          messages.add(
            ChatMessage(isBot: true, message: "Suggestion failed: $e"),
          );
        }

        isProcessing = false;
        isLoading = false;
        notifyListeners();
      }

      return;
    }

    // ------ greeting ------
    if (_isGreeting(text)) {
      _showFirstMenu();
      return;
    }

    // ------ unsupported ------
    messages.add(
      ChatMessage(
        isBot: true,
        message:
            "I'm so sorry\nI currently support only:",
        options: ["Create flashcards", "Suggest vocabulary", "Study plan"],
      ),
    );

    notifyListeners();
  }

  Future<void> _handleRoadmapByAgent() async {
    if (isProcessing) return;

    isProcessing = true;
    isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;

      final result = await studyPlanExecutor.generate(
        userId: user!.uid,
        message: "create roadmap",
      );

      print("FILE URL: ${result.fileUrl}");

      messages.add(result);
      _showMainMenu();
    } catch (e) {
      messages.add(
        ChatMessage(isBot: true, message: "Roadmap failed: ${e.toString()}"),
      );
    }

    isProcessing = false;
    isLoading = false;
    notifyListeners();
  }
}
