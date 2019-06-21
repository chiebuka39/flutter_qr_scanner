class CreationParams {
  CreationParams({this.width, this.height});

  static CreationParams fromWidget(double width, double height) {
    return CreationParams(
      width: width,
      height: height,
    );
  }

  final double width;
  final double height;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'width': width,
      'height': height,
    };
  }
}