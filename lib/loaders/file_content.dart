abstract class IFileContent {
  Future<String> loadString(final String fileName, final String extension);
}
