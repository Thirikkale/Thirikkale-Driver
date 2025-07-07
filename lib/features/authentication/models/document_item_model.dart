class DocumentItem {
  final String title;
  final String subtitle;
  bool isCompleted;

  DocumentItem({
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
  });
}