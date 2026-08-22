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
import '../widgets/messageNotification.dart';
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

  // handle logic out chatbot
  bool _isChatbotVisible = true;

  bool get isChatbotVisible => _isChatbotVisible;

  void setChatbotVisible(bool visible) {
    _isChatbotVisible = visible;

    // when user return to chat, clear background task flag
    if (visible && _hasBackgroundTask) {
      _hasBackgroundTask = false;
      _backgroundTaskMessage = null;
    }
  }

  // add background task
  bool _hasBackgroundTask = false;
  String? _backgroundTaskMessage;

  bool get hasBackgroundTask => _hasBackgroundTask;
  String? get backgroundTaskMessage => _backgroundTaskMessage;

  // create helper instead of notifylistener
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _isChatbotVisible = false;
    super.dispose();
  }

  void _safeNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

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

  Future<void> initialize() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (historyController.currentConversationId != null) {
      return;
    }

    const text =
        "Hi there! I'm your Mofu Assistant!\nWhat would you like to do today?";

    final botMessage = ChatMessage(
      isBot: true,
      message: text,
      options: ["Create flashcards", "Suggest vocabulary", "Study plan"],
    );

    messages.add(botMessage);

    // Conversation start with greeting of bot
    await historyController.startConversation(
      userId: user.uid,
      firstMessage: botMessage,
    );

    _safeNotify();
  }

  Future<void> _showFirstMenu() async {
    const text =
        "Hi there! I'm your Mofu Assistant!\nWhat would you like to do today?";

    final botMessage = ChatMessage(
      isBot: true,
      message: text,
      options: ["Create flashcards", "Suggest vocabulary", "Study plan"],
    );

    messages.add(botMessage);

    await historyController.addMessage(botMessage);

    _safeNotify();
  }

  // handle background task
  Future<void> _handleBackgroundCompletion(String message) async {
    _hasBackgroundTask = true;
    _backgroundTaskMessage = message;

    if (!_isChatbotVisible) {
      AppNotification.show(message);
    }

    _safeNotify(); // UI update
  }

  Future<void> _completeAgentTask({
    required List<ChatMessage> resultMessages,
    required String backgroundNotification,
  }) async {
    for (final msg in resultMessages) {
      await historyController.addMessage(msg);
    }
    messages.addAll(resultMessages);

    const menuText =
        "Task complete successfully! What would you like to do next?";
    final menuMessage = ChatMessage(
      isBot: true,
      message: menuText,
      options: ["Create flashcards", "Suggest vocabulary", "Study plan"],
    );

    messages.add(menuMessage);
    await historyController.addBotMessage(menuText);

    if (_isChatbotVisible) {
      _safeNotify();
    } else {
      await _handleBackgroundCompletion(backgroundNotification);
    }
  }

  Future<void> restoreConversation(String conversationId) async {
    final msgs = await historyController.loadConversation(conversationId);

    messages.clear();
    messages.addAll(msgs);

    historyController.currentConversationId = conversationId;

    _safeNotify();
  }

  void selectAgent(String option) async {
    if (isProcessing) return;

    // chat title get by first option selected by user
    await historyController.updateConversationTitle(option);

    switch (option) {
      case "Create flashcards":
        currentAgent = ChatAgentType.flashcard;
        await flashcardAgent.start(messages, saveChatMessage);
        break;

      case "Suggest vocabulary":
        currentAgent = ChatAgentType.vocabulary;
        suggestionAgent.start(messages);
        await historyController.addBotMessage(
          "How many minutes do you usually study in one session?",
        );
        notifyListeners();
        break;

      case "Study plan":
        currentAgent = ChatAgentType.studyPlan;
        _handleRoadmapByAgent();
        _safeNotify();
        break;
    }

    _safeNotify();
  }

  Future<void> sendMessage(String text) async {
    // history
    if (text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (isProcessing) return;

    // add message
    messages.add(ChatMessage(message: text, isBot: false));

    _safeNotify();

    // save history
    if (historyController.currentConversationId == null) {
      await historyController.startConversation(
        userId: user.uid,
        firstMessage: ChatMessage(message: text, isBot: false),
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
        _safeNotify();
        return;
      }

      _safeNotify();

      if (flashcardAgent.isCompleted) {
        isProcessing = true;
        isLoading = true;
        _safeNotify();

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

            await _completeAgentTask(
              resultMessages: responses,
              backgroundNotification:
                  "Your flashcards are ready! Open the chatbot to view the result.",
            );
          }
        } catch (e) {
          final botMessage = "Flashcard failed: $e";
          messages.add(ChatMessage(isBot: true, message: botMessage));
          await historyController.addBotMessage(botMessage);
          _safeNotify();
        }

        isProcessing = false;
        isLoading = false;
        _safeNotify();
      }

      return;
    }
    // ------ suggestion agent -----
    if (currentAgent == ChatAgentType.vocabulary &&
        suggestionAgent.isCollecting) {
      final error = suggestionAgent.processMessage(text, messages);

      if (error != null) {
        onValidationError?.call(error.title, error.message);
        _safeNotify();
        return;
      }

      // User answer session duration
      // Agent will ask for topN if step is topN
      if (suggestionAgent.step == SuggestionStep.topN) {
        await historyController.addBotMessage(
          "How many vocabulary suggestions do you want?",
        );
      }

      _safeNotify();

      if (suggestionAgent.isCompleted) {
        isProcessing = true;
        isLoading = true;
        _safeNotify();

        try {
          final user = FirebaseAuth.instance.currentUser;

          if (user == null) {
            const botMessage = "Please login first.";
            messages.add(ChatMessage(isBot: true, message: botMessage));
            await historyController.addBotMessage(botMessage);
            _safeNotify();
          } else {
            final result = await suggestionExecutor.generate(
              userId: user.uid,
              sessionDuration: suggestionAgent.sessionDuration!,
              topN: suggestionAgent.topN!,
            );

            suggestionAgent.reset();

            await _completeAgentTask(
              resultMessages: [result],
              backgroundNotification:
                  "Your vocabulary suggestions are ready! Open the chatbot to view the result.",
            );
          }
        } catch (e) {
          final botMessage = "Suggestion failed: $e";
          messages.add(ChatMessage(isBot: true, message: botMessage));
          await historyController.addBotMessage(botMessage);
          _safeNotify();
        }

        isProcessing = false;
        isLoading = false;
        _safeNotify();
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

    _safeNotify();
  }

  Future<void> _handleRoadmapByAgent() async {
    if (isProcessing) return;

    isProcessing = true;
    isLoading = true;
    _safeNotify();

    try {
      final user = FirebaseAuth.instance.currentUser;

      final result = await studyPlanExecutor.generate(
        userId: user!.uid,
        message: "create roadmap",
      );

      await _completeAgentTask(
        resultMessages: [result],
        backgroundNotification:
            "Your study plan is ready! Open the chatbot to view the result.",
      );
    } catch (e) {
      final botMessage = "Road map failed: $e";
      messages.add(ChatMessage(isBot: true, message: botMessage));
      await historyController.addBotMessage(botMessage);
      _safeNotify();
    }

    isProcessing = false;
    isLoading = false;
    _safeNotify();
  }

  // helper
  Future<void> saveChatMessage(ChatMessage message) async {
    await historyController.addMessage(message);
  }
}
