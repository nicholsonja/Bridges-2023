
class Example_33 extends Example {
  Point2D.Float origin = new Point2D.Float(0, 0);
  
  Example_33(int imageSize) {
    super(33,      // example number 
          false,  // animated
          200000,   // render Number Of Segments
          15000,   // num steps 
          null,  // no constant extent
          imageSize,  // width
          imageSize   // height
          );
    
    painter = new RadialPainter(
          new RGBColor(255, 255, 255), 
          new RGBColor[] {
            new RGBColor(128, 0, 0),
            new RGBColor(128, 0, 128),
            new RGBColor(0, 0, 128),
            new RGBColor(0, 128, 128),
            new RGBColor(0, 128, 0),
          }, 
          3);
    
    float radius = 1000;
    for(int n = 0; n < maxN; n++) {
      float theta = 2 * PI * n / maxN;
      
      Point2D.Float c= new Point2D.Float(radius + 50, 0);
      paths.add(new Line(c, radius).rotate(origin, theta));
      if (n % 2 == 0) {
         shapes.add(new RoseCurve(origin, 100, 2, 1)); //.rotate(origin, theta));
      } else {
        shapes.add(new RoseCurve(origin, 100, (n + 1) * 20, 1)); //.rotate(origin, theta));
      }
    }
  }
 
  int maxN = 4;
  
  ThetaResult process(float theta) {
    Shape[] tmpShape = new Shape[shapes.size()];
    Shape result = null;
    for(int n = 0; n < maxN; n++) {
      Shape p = paths.get(n);
      Shape s = shapes.get(n)
                      .rotate(origin, (n % 2 * 2 -1) * theta)
                      .translate(p.getPoint((n % 2 * 2 -1) * theta));
      
      tmpShape[n] = s;
      
      if (result == null) {
        result = s;
      } else {
        result = result.add(s);
      }
    }
    
    return new ThetaResult(result, 
                           tmpShape);
  }
}
