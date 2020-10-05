import 'package:flutter/material.dart';
import 'package:simple_logger/simple_logger.dart';

/// Logger
final SimpleLogger logger = SimpleLogger()
  ..mode = LoggerMode.print
  ..setLevel(Level.FINEST, includeCallerInfo: true);

///
enum Side { top, left, front, right, back, bottom }

class RubikSideImage {
  bool status;
  String code;
  List rgb;

  RubikSideImage.fromJSON(Map<String, dynamic> json)
      : status = json["status"],
        code = json["color_name"],
        rgb = json["color_rgb"];
}

class Kociemba {
  bool status;
  List rotations;

  Kociemba.fromJSON(Map<String, dynamic> json)
      : status = json["status"],
        rotations = json["rotations"];
}

extension RubikColor on String {
  Color get color {
    switch (this.toLowerCase()) {
      case "y": case "top": return Colors.yellow;
      case "b": case "left": return Colors.blue;
      case "r": case "front": return Colors.red;
      case "g": case "right":return Colors.green;
      case "o": case "back":return Colors.orange;
      case "w": case "bottom":return Colors.white;
      default:
        return Colors.transparent;
    }
  }

  List get rubikColors {
    if (this.length != 9) {
      logger.info('wrong color pattern');
      return [];
    }
    return this.split('').map((e) => e.color).toList();
  }

  Widget get colorContainer {
    var colors = rubikColors;
    return GridView(
      padding: EdgeInsets.all(10),
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      children: List.generate(colors.length, (index) {
          return Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: colors[index],
              ),
              width: 40,
              height: 40,
            ),
          );
        },
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 1,
      ),
    );
  }
}
