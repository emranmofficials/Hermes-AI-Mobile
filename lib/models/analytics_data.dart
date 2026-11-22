class AnalyticsData {
  int totalPromptTokens;
  int totalCompletionTokens;
  double totalCostUsd;
  int requestsCount;
  int toolCallsCount;
  Map<String, int> modelUsage; // model -> token count

  AnalyticsData({
    this.totalPromptTokens = 12480,
    this.totalCompletionTokens = 8640,
    this.totalCostUsd = 0.042,
    this.requestsCount = 28,
    this.toolCallsCount = 14,
    Map<String, int>? modelUsage,
  }) : modelUsage = modelUsage ??
            {
              'gemini-3.8-flash': 14200,
              'hermes-3-llama-3.1-8b': 4800,
              'gemini-3.1-pro-preview': 2120,
            };

  int get totalTokens => totalPromptTokens + totalCompletionTokens;

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      totalPromptTokens: json['totalPromptTokens'] ?? 12480,
      totalCompletionTokens: json['totalCompletionTokens'] ?? 8640,
      totalCostUsd: (json['totalCostUsd'] as num?)?.toDouble() ?? 0.042,
      requestsCount: json['requestsCount'] ?? 28,
      toolCallsCount: json['toolCallsCount'] ?? 14,
      modelUsage: (json['modelUsage'] as Map?)?.map((k, v) => MapEntry(k.toString(), (v as num).toInt())) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPromptTokens': totalPromptTokens,
      'totalCompletionTokens': totalCompletionTokens,
      'totalCostUsd': totalCostUsd,
      'requestsCount': requestsCount,
      'toolCallsCount': toolCallsCount,
      'modelUsage': modelUsage,
    };
  }
}
