class RoadMapController {
  static bool isRoadmapRequest(String text) {
    final t = text.toLowerCase();

    return t.contains("roadmap") ||
        t.contains("study plan") ||
        t.contains("learning plan") ||
        t.contains("give me roadmap") ||
        t.contains("create plan");
  }
}