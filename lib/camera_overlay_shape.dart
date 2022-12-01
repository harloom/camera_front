import 'package:flutter/material.dart';

class CameraOverLayShape extends StatelessWidget {
  const CameraOverLayShape(
      {Key? key, required this.type, this.customShapePainter}):
        super(key: key);

  final CustomPainter? customShapePainter;
  final CameraTypeShape type;

  @override
  Widget build(BuildContext context) {
    /// start setup
    var media = MediaQuery.of(context);
    var size = media.size;

    // width
    double width = size.shortestSide * .9;

    // height
    double height =size.height ;

    ///end size setup

    if (type == CameraTypeShape.face) {
      return _faceMask(width, height);
    } else if(type == CameraTypeShape.cardID){
      return _idCardMask(width);
    }else if(type == CameraTypeShape.oval){
      return _ovalMask();
    }
    else {
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcOut),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: width,
                  height: width / 1.4,
                  child: CustomPaint(painter: customShapePainter),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _idCardMask(double width) {
    double ratio = 1.59;
    double height = width  / ratio;
    double cornerRadius =  0.064;
    double radius =  height * cornerRadius;

    return Stack(
      children: [
        Align(
            alignment: Alignment.center,
            child: Container(
              width: width,
              height: width / ratio,
              decoration: ShapeDecoration(
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius),
                      side: const BorderSide(width: 1, color: Colors.white))),
            )),
        ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcOut),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: width,
                    height: width / ratio,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(radius)),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _ovalMask() {
    return IgnorePointer(
      child: ClipPath(
        clipper: InvertedCircleClipper(),
        child: Container(
          color: const Color.fromRGBO(0, 0, 0, 0.5),
        ),
      ),
    );
  }

  Widget _faceMask(double width, double height) {
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcOut),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: width,
                    height: height / 1.4,
                    child: CustomPaint(painter: FaceOverlay()),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum CameraTypeShape {
  /// type
  oval,
  cardID,
  face,
  // circle,
  custom,
}

class InvertedCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width * 0.40))
      ..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


class FaceOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {

    Path path_0 = Path();
    path_0.moveTo(size.width*0.7829783,size.height*0.7153192);
    path_0.cubicTo(size.width*0.6518608,size.height*0.6675542,size.width*0.6099450,size.height*0.6272342,size.width*0.6099450,size.height*0.5409042);
    path_0.cubicTo(size.width*0.6099450,size.height*0.4890958,size.width*0.6529075,size.height*0.4555192,size.width*0.6675517,size.height*0.4111175);
    path_0.cubicTo(size.width*0.6821975,size.height*0.3667150,size.width*0.6906692,size.height*0.3141450,size.width*0.6977108,size.height*0.2759042);
    path_0.cubicTo(size.width*0.7047533,size.height*0.2376633,size.width*0.7075517,size.height*0.2228725,size.width*0.7113808,size.height*0.1821275);
    path_0.cubicTo(size.width*0.7160633,size.height*0.1312767,size.width*0.6820217,0,size.width*0.5000000,0);
    path_0.cubicTo(size.width*0.3180325,0,size.width*0.2838825,size.height*0.1312767,size.width*0.2886700,size.height*0.1821275);
    path_0.cubicTo(size.width*0.2925000,size.height*0.2228725,size.width*0.2953133,size.height*0.2376650,size.width*0.3023400,size.height*0.2759042);
    path_0.cubicTo(size.width*0.3093675,size.height*0.3141442,size.width*0.3177567,size.height*0.3667117,size.width*0.3323925,size.height*0.4111175);
    path_0.cubicTo(size.width*0.3470275,size.height*0.4555225,size.width*0.3900508,size.height*0.4890958,size.width*0.3900508,size.height*0.5409042);
    path_0.cubicTo(size.width*0.3900508,size.height*0.6272342,size.width*0.3481358,size.height*0.6675533,size.width*0.2170192,size.height*0.7153192);
    path_0.cubicTo(size.width*0.08542583,size.height*0.7631917,0,size.height*0.8103992,0,size.height*0.8437500);
    path_0.lineTo(0,size.height);
    path_0.lineTo(size.width,size.height);
    path_0.lineTo(size.width,size.height*0.8437500);
    path_0.cubicTo(size.width,size.height*0.8104525,size.width*0.9145217,size.height*0.7632450,size.width*0.7829783,size.height*0.7153192);
    path_0.close();

    Paint paint_0_fill = Paint()..style=PaintingStyle.fill;
    paint_0_fill.color = Colors.black.withOpacity(1.0);
    canvas.drawPath(path_0,paint_0_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
