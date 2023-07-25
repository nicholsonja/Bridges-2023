
class Example_31 extends Example {
  Example_31(int imageSize) {
    super(31,      // example number 
          false,   // animated
          2000,   // render Number Of Segments
          50000,     // num steps
          null,  // no constant extent
          imageSize,  // width
          imageSize   // height
          );
    
    painter = new GradientPointPainter(
          new RGBColor(255, 255, 255), 
          new RGBColor[] {
            new RGBColor(206, 171, 0),
            new RGBColor(43, 12, 142),
          }, 
          new java.awt.Point[] {
            new java.awt.Point(imageSize/5, imageSize/2),
            new java.awt.Point(3 * imageSize/5, imageSize/2),
            
          },
          6);
    
    shapes.add(new Hypotrochoid(new Point2D.Float(30, 30), 100, 95, 90));
    shapes.add(new Hypotrochoid(new Point2D.Float(300, 300), 100, 50, 200)); 
  }
  
  ThetaResult process(float theta) {
    Shape s1 = shapes.get(0)
                     //.offsetStart(-3 * theta)
                     .rotate(shapes.get(0).getCenter(), 1 * theta)
                     ;
    Shape s2 = shapes.get(1)
                     .offsetStart(2 * theta)
                     //.rotate(shapes.get(1).getCenter(), -1 * theta)
                     //.rotate(new Point2D.Float(0, 0), -1 * theta)
                     ;
    
    Shape result = s1.multiply(s2);
    return new ThetaResult(result, 
                           new Shape[]{ s1, s2});
  }
}
