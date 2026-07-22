import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashcard_app/features/chatbot/controllers/chat_history_controller.dart';
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
  final ChatHistoryController historyController = ChatHistoryController();
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

  /// The chat screen (View) sets this to show a validation-error popup
  /// whenever the user's input doesn't match what an agent expects.
  void Function(String title, String message)? onValidationError;

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

  Future<void> _showFirstMenu() async {
    const text =
        "Hi there! I'm your Mofu Assistant!\nWhat would you like to do today?";

    messages.add(
      ChatMessage(
        isBot: true,
        message: text,
        options: ["Create flashcards", "Suggest vocabulary", "Study plan"],
      ),
    );

    await historyController.addBotMessage(text);

    notifyListeners();
  }

  Future<void> _showMainMenu() async {
    const text = "Task complete successfully! What would you like to do next?";

    messages.add(
      ChatMessage(
        isBot: true,
        message: text,
        options: ["Create flashcards", "Suggest vocabulary", "Study plan"],
      ),
    );

    await historyController.addBotMessage(text);

    notifyListeners();
  }

  Future<void> restoreConversation(String conversationId) async {
    final msgs = await historyController.loadConversation(conversationId);

    messages.clear();
    messages.addAll(msgs);

    historyController.currentConversationId = conversationId;

    notifyListeners();
  }

  void selectAgent(String option) async {
    if (isProcessing) return;

    switch (option) {
      case "Create flashcards":
        currentAgent = ChatAgentType.flashcard;

        await flashcardAgent.start(messages, saveChatMessage);

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
    // history

    if (text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (isProcessing) return;

    // add message
    messages.add(ChatMessage(message: text, isBot: false));

    notifyListeners();

    // save history

    if (historyController.currentConversationId == null) {
      await historyController.startConversation(
        userId: user.uid,
        firstMessage: text,
      );
    } else {
      await historyController.addUserMessage(text);
    }

    if (isProcessing) return; // avoid agents running at the same time

    // ------ flashcard agent -----
    if (currentAgent == ChatAgentType.flashcard &&
        flashcardAgent.isCollecting) {
      final error = await flashcardAgent.processMessage(
        text,
        messages,
        saveChatMessage,
      );

      if (error != null) {
        // Invalid input: notify the view to show a popup, keep the current
        // step so the bot doesn't advance to the next question.
        onValidationError?.call(error.title, error.message);
        notifyListeners();
        return;
      }

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

            for (final msg in responses) {
              await historyController.addMessage(msg);
            }
          }

          flashcardAgent.reset();

          _showMainMenu();
        } catch (e) {
          final botMessage = "Flashcard failed: $e";

          messages.add(ChatMessage(isBot: true, message: botMessage));

          await historyController.addBotMessage(botMessage);

          notifyListeners();
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
      final error = suggestionAgent.processMessage(text, messages);

      if (error != null) {
        // Invalid input: notify the view to show a popup, keep the current
        // step so the bot doesn't advance to the next question.
        onValidationError?.call(error.title, error.message);
        notifyListeners();
        return;
      }

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

            await historyController.addMessage(result);
          }

          flashcardAgent.reset();

          _showMainMenu();
        } catch (e) {
          final botMessage = "Suggestion failed: $e";

          messages.add(ChatMessage(isBot: true, message: botMessage));

          await historyController.addBotMessage(botMessage);

          notifyListeners();
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
    const botMessage = "I'm so sorry\nI currently support only:";

    messages.add(
      ChatMessage(
        isBot: true,
        message: botMessage,
        options: ["Create flashcards", "Suggest vocabulary", "Study plan"],
      ),
    );

    await historyController.addBotMessage(botMessage);

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

      await historyController.addMessage(result);

      _showMainMenu();
    } catch (e) {
      final botMessage = "Road map failed: $e";

      messages.add(ChatMessage(isBot: true, message: botMessage));

      await historyController.addBotMessage(botMessage);

      notifyListeners();
    }

    isProcessing = false;
    isLoading = false;
    notifyListeners();
  }

  // helper
  Future<void> saveChatMessage(ChatMessage message) async {
    await historyController.addMessage(message);
  }
}