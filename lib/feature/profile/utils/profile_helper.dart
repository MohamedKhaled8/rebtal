class ProfileHelper {
  static String getRoleText(String role) {
    switch (role.toLowerCase()) {
      case 'user':
        return 'مستخدم';
      case 'owner':
        return 'صاحب شاليه';
      case 'admin':
        return 'مدير';
      default:
        return 'مستخدم';
    }
  }

  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String calculateDays(DateTime createdAt) {
    final days = DateTime.now().difference(createdAt).inDays;
    return days.toString();
  }
}
