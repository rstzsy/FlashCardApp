import '../../../models/chatModel.dart';
import '../services/roadmap_agent_service.dart';

class RoadMapExecutor {
  final RoadMapService service;

  RoadMapExecutor(this.service);

  Future<ChatMessage> generate({
    required String userId,
    required String message,
  }) async {
    try {
      final result = await service.generateRoadmap(userId: userId);

      print(result);

      if (result["success"] != true) {
        return ChatMessage(
          isBot: true,
          message: result["message"] ?? "Failed to generate roadmap",
        );
      }

      final excelUrl = result["excelUrl"]?.toString();
      print("Excel URL: $excelUrl");

      return ChatMessage(
        isBot: true,
        message: "Your roadmap is ready!",
        fileUrl: excelUrl,
      );
    } catch (e) {
      return ChatMessage(
        isBot: true,
        message: "Failed to generate roadmap: ${e.toString()}",
      );
    }
  }
}
