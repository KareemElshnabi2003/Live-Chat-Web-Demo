import 'dart:io';

void main() {
  void revertFile(String filepath) {
    var file = File(filepath);
    if (!file.existsSync()) return;
    var content = file.readAsStringSync();
    
    // Remove the custom kIsWeb ternary operator
    var regex = RegExp(r'\(\s*kIsWeb\s*\?\s*[0-9.]+\s*\:\s*([0-9]+(?:\.[0-9]+)?)\s*\)\.(w|h)');
    content = content.replaceAllMapped(regex, (match) {
      return match.group(1)! + '.' + match.group(2)!;
    });
    
    file.writeAsStringSync(content);
    print('Reverted $filepath');
  }

  void processDirectory(Directory dir) {
    for (var entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        var content = entity.readAsStringSync();
        var originalContent = content;

        // Replace import
        content = content.replaceAll(
          "import 'package:screen_go/extensions/responsive_nums.dart';",
          "import 'package:live_chat/Core/utils/responsive_nums.dart';"
        );

        if (content != originalContent) {
          entity.writeAsStringSync(content);
          print('Updated import in ${entity.path}');
        }
      }
    }
  }

  revertFile(r'c:\Users\Afraad.User01.WATANYAROADS\Desktop\Live-Chat-web\Live-Chat-web\lib\View\Screens\start page\page_start.dart');
  revertFile(r'c:\Users\Afraad.User01.WATANYAROADS\Desktop\Live-Chat-web\Live-Chat-web\lib\View\Widget\PublicWidget\chat_card_widget.dart');
  
  processDirectory(Directory(r'c:\Users\Afraad.User01.WATANYAROADS\Desktop\Live-Chat-web\Live-Chat-web\lib'));
}
