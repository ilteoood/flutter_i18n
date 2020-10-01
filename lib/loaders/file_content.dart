/// Abstract class used to load different kind of file
abstract class IFileContent {
  Future<String> loadString(final String fileName, final String extension);
}
