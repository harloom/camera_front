
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_front/camera_overlay_shape.dart';
import 'package:camera_front/preview_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image/image.dart' as img;

import 'package:path_provider/path_provider.dart';


class CustomCamera extends StatefulWidget {
  const CustomCamera({Key? key,required this.guideText}) : super(key: key);

  static Future<File?> take(BuildContext context, String guideText) async{
    File? file;
    final MaterialPageRoute route = MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) =>  CustomCamera(guideText: guideText),
    );
    var result =  await Navigator.push(context, route);
    if(result != null && result is File){
      file = result;
    }else{
      print("else check ${result}" );
    }
    print("result file  : $result");
    return file;

  }


  final String guideText;

  @override
  State<CustomCamera> createState() => _CustomCameraState();
}

class _CustomCameraState extends State<CustomCamera> with WidgetsBindingObserver {
  bool _isLoading = true;
  bool _isCapture = false;
  String? _isErrorMessage;
  CameraController? _cameraController;






  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    _initCamera();
    super.initState();
  }

  /// setup OrientationDevice only portrait
  _setupOrientationDevice() async{
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  /// canghe back default
  _disposeOrientationDevice(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose()  {
    _disposeOrientationDevice();
    _cameraController?.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  // #initialize camera
  _initCamera() async {

    try{
      // setup force orientation
      await _setupOrientationDevice();

      //check camera available
      final cameras = await availableCameras();
      print(cameras);
      if(cameras.isEmpty){
        setState(() {
          _isErrorMessage = "Cameras Hardware Not Found!";
          _isLoading = false;
        });

        return;
      }
      // get front camera
      final front = cameras.firstWhereOrNull((camera) => camera.lensDirection == CameraLensDirection.front);

      if(front == null){
        setState(() {
          _isErrorMessage = "Font Camera Not Found!";
          _isLoading = false;
        });
        return;
      }

      //setup resolution
      _cameraController = CameraController(front, ResolutionPreset.high,imageFormatGroup: ImageFormatGroup.yuv420);

      // initialize camera
      await _cameraController?.initialize();


      // is not web
      // if(!kIsWeb){
      //   await _cameraController?.lockCaptureOrientation(DeviceOrientation.portraitUp,DeviceOrientation.portraitDown);
      // }

      setState(() {
        _isLoading = false;
        _isCapture = false;
      });
    }catch(e){
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            setState(() {
              _isErrorMessage = "User denied camera access.";
              _isLoading = false;
            });
            break;
          default:
            print('Handle other errors.');
            print(e);
            setState(() {
              _isErrorMessage = "Exception : $e";
              _isLoading = false;
            });
            break;
        }
      }else{
        print("exception : ${e.toString()}");
      }
    }
  }
  // #end initialize camera

  Future<XFile?> _takePicture() async{
    if (_cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      print(" A capture is already pending, do nothing");
      return null;
    }
    try {
      print("camera controller check,,,");
      print(_cameraController);
      XFile file = await _cameraController!.takePicture();
      print(file.path);
      return file;
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
      return null;
    }
  }

  _onTakePicture() async{
    if (kDebugMode) {
      print("take Pitcure");
    }
    setState(() {
      _isCapture = true;
    });
    showInSnackBar("Take Again....");

    final imageTake = await _takePicture();
    setState(() {
      _isCapture = false;
    });

    if(imageTake == null){
      showInSnackBar("Pengambilan gambar gagal");
      print("Pengambilan gambar gagal");
      return;
    }
    if(!mounted){
      print("!mounted");
      return;
    }
    var file = await _saveFile(imageTake);
    final route = MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) =>  PreviewImage(file: file),
    );
   var fileResult = await  Navigator.push(context, route);
    Navigator.pop(context,fileResult);
  }

  Future<File>  _saveFile(XFile xFile) async{
    int currentUnix = DateTime.now().millisecondsSinceEpoch;
    final directory = await getApplicationDocumentsDirectory();

    // final fixingImage = await FlutterExifRotation.rotateImage(path: file.path);

    List<int> imageBytes = await xFile.readAsBytes();

    img.Image? originalImage = img.decodeImage(imageBytes);
    img.Image fixedImage = img.flipHorizontal(originalImage!);

    File file = File(xFile.path);
    File fixedFile = await file.writeAsBytes(
      img.encodeJpg(fixedImage),
      flush: true,
    );
    String fileFormat = fixedFile.path.split('.').last;

    var saveFile = await fixedFile.copy(
      '${directory.path}/$currentUnix.$fileFormat',
    );
    return saveFile;
  }


  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("state camera ,,,");
    print(state);
    final CameraController? cameraController = _cameraController;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }
  // #enddocregion AppLifecycle

  @override
  Widget build(BuildContext context) {
    if(!_isLoading && _isErrorMessage != null){
      return SafeArea(child: Material(
        child: Container(color: Colors.white,
        child:  Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("$_isErrorMessage"),
            IconButton(onPressed: ()=>Navigator.pop(context), icon: Icon(Icons.arrow_back))
          ],
        ),),),
      ));
    }

    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SafeArea(child: Material(
      child: AspectRatio(
        aspectRatio: 1/  _cameraController!.value.aspectRatio,
        child: Center(
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              CameraPreview(_cameraController!),
              const CameraOverLayShape(type: CameraTypeShape.oval),
              Positioned(
                  bottom: 0,
                  top: 30,
                  child:Text(widget.guideText,style:  const TextStyle(color: Colors.white,fontSize: 15.0),) ),
      

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: FloatingActionButton(
                    backgroundColor: Colors.red,
                    child:const  Icon( Icons.camera_alt),
                    onPressed : _isCapture ? null : _onTakePicture,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }


  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    final CameraController? oldController = _cameraController;
    if (oldController != null) {
      // `controller` needs to be set to null before getting disposed,
      // to avoid a race condition when we use the controller that is being
      // disposed. This happens when camera permission dialog shows up,
      // which triggers `didChangeAppLifecycleState`, which disposes and
      // re-creates the controller.
      _cameraController = null;
      await oldController.dispose();
    }

    final cameras = await availableCameras();
    // get front camera
    final front = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);

    //setup resolution
    _cameraController = CameraController(front, ResolutionPreset.high,imageFormatGroup: ImageFormatGroup.yuv420);

    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    _cameraController = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      // await Future.wait(<Future<Object?>>[
      //   // The exposure mode is currently not supported on the web.
      //   ...!kIsWeb
      //       ? <Future<Object?>>[
      //     cameraController.getMinExposureOffset().then(
      //             (double value) => _minAvailableExposureOffset = value),
      //     cameraController
      //         .getMaxExposureOffset()
      //         .then((double value) => _maxAvailableExposureOffset = value)
      //   ]
      //       : <Future<Object?>>[],
      //   cameraController
      //       .getMaxZoomLevel()
      //       .then((double value) => _maxAvailableZoom = value),
      //   cameraController
      //       .getMinZoomLevel()
      //       .then((double value) => _minAvailableZoom = value),
      // ]);
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
          break;
        case 'CameraAccessDeniedWithoutPrompt':
        // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
          break;
        case 'CameraAccessRestricted':
        // iOS only
          showInSnackBar('Camera access is restricted.');
          break;
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
          break;
        case 'AudioAccessDeniedWithoutPrompt':
        // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
          break;
        case 'AudioAccessRestricted':
        // iOS only
          showInSnackBar('Audio access is restricted.');
          break;
        default:
            print("show Camera Expection : ${e}");
          break;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
