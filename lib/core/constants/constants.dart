class AppConstants {
  static const String firebaseDatabaseUrl =
      'https://todoapp-1363d-default-rtdb.firebaseio.com';

  static String tasksEndpoint(String userId) => '/tasks/$userId.json';

  static String getTasksUrl(String userId, String idToken) =>
      '$firebaseDatabaseUrl/tasks/$userId.json?auth=$idToken';

  static String addTaskUrl(String userId, String idToken) =>
      '$firebaseDatabaseUrl/tasks/$userId.json?auth=$idToken';

  static String updateTaskUrl(String userId, String taskId, String idToken) =>
      '$firebaseDatabaseUrl/tasks/$userId/$taskId.json?auth=$idToken';

  static String deleteTaskUrl(String userId, String taskId, String idToken) =>
      '$firebaseDatabaseUrl/tasks/$userId/$taskId.json?auth=$idToken';
}
