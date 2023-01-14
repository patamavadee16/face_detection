// @dart=2.9
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:io';
import 'dart:ui' as ui;
// main method that runs the our main app
void main() => runApp(
	MaterialApp(
		debugShowCheckedModeBanner: false,
		theme: ThemeData(primarySwatch: Colors.teal),
		home: MyApp(),
	),
	);

class MyApp extends StatefulWidget {
@override
_MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
File _imageFile;
List<Face> _faces;
bool isLoading = false;
ui.Image _image;
final picker = ImagePicker();

@override
Widget build(BuildContext context) {
	// scaffold with appbar
	return Scaffold(
	appBar: AppBar(
		automaticallyImplyLeading: true,
		// title of the appbar
		title: Text('Face Detection'),
	),
	// floating button for picking image
	floatingActionButton: FloatingActionButton(
		onPressed: _getImage,
		tooltip: 'camera',
		child: Icon(Icons.add_a_photo),
	),
	// if file is null print no image
	// selected others wise show image
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : (_imageFile == null)
            ? Center(child: Text('no image selected'))
            : Center(
            child: FittedBox(
              child: SizedBox(
                width: _image.width.toDouble(),
                height: _image.height.toDouble(),
                child: CustomPaint(
                  painter: FacePainter(_image, _faces),
                ),
              ),
            )
        )
    );
}
	
// function for pick the image
// and detect faces in the image
_getImage() async {
	final imageFile = await picker.getImage(source: ImageSource.gallery);
	setState(() {
	isLoading = true;
	});

	final image = FirebaseVisionImage.fromFile(File(imageFile.path));
  final faceDetector = FirebaseVision.instance.faceDetector();
  List<Face> faces = await faceDetector.processImage(image);

 if (mounted) {
      setState(() {
        _imageFile = File(imageFile.path);
        _faces = faces;
        _loadImage(File(imageFile.path));
      });
    }
  }

_loadImage(File file) async {
	final data = await file.readAsBytes();
	await decodeImageFromList(data).then((value) => setState(() {
		_image = value;
		isLoading = false;
		}));
}
}

// paint the face
class FacePainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;
  final List<Rect> rects = [];

  FacePainter(this.image, this.faces) {
    for (var i = 0; i < faces.length; i++) {
      rects.add(faces[i].boundingBox);
    }
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = Colors.yellow;

    canvas.drawImage(image, Offset.zero, Paint());
    for (var i = 0; i < faces.length; i++) {
      canvas.drawRect(rects[i], paint);
    }
  }

  @override
  bool shouldRepaint(FacePainter old) {
    return image != old.image || faces != old.faces;
  }
}

