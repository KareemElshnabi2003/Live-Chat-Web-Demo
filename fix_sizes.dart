import 'dart:io';

void main() {
  void fixFile(String filepath) {
    var file = File(filepath);
    if (!file.existsSync()) {
      print('File not found: $filepath');
      return;
    }
    var content = file.readAsStringSync();
    
    var wRegex = RegExp(r'\b([0-9]+(?:\.[0-9]+)?)\.w');
    var hRegex = RegExp(r'\b([0-9]+(?:\.[0-9]+)?)\.h');
    
    content = content.replaceAllMapped(wRegex, (match) {
      var valStr = match.group(1)!;
      var val = double.parse(valStr);
      var webVal = (val * 0.35).toStringAsFixed(2);
      return '(kIsWeb ? $webVal : $valStr).w';
    });
    
    content = content.replaceAllMapped(hRegex, (match) {
      var valStr = match.group(1)!;
      var val = double.parse(valStr);
      var webVal = (val * 0.35).toStringAsFixed(2);
      return '(kIsWeb ? $webVal : $valStr).h';
    });
    
    if (content.contains('kIsWeb') && !content.contains('package:flutter/foundation.dart')) {
      content = "import 'package:flutter/foundation.dart';\n" + content;
    }
    
    file.writeAsStringSync(content);
    print('Fixed $filepath');
  }

  fixFile(r'c:\Users\Afraad.User01.WATANYAROADS\Desktop\Live-Chat-web\Live-Chat-web\lib\View\Screens\start page\page_start.dart');
  fixFile(r'c:\Users\Afraad.User01.WATANYAROADS\Desktop\Live-Chat-web\Live-Chat-web\lib\View\Widget\PublicWidget\chat_card_widget.dart');
}
