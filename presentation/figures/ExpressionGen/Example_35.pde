class Example_35 extends Example {
  Example_35(int imageSize) {
    super(35,      // example number 
          false,   // animated\
          2000,   // render Number Of Segments
          50000,     // num steps 
          null,  // no constant extent
          imageSize,  // width
          imageSize   // height
          );
    
    painter = new GradientPointPainter(
          new RGBColor(255, 255, 255), 
          new RGBColor[] {
            new RGBColor(243, 18, 0),
            new RGBColor(0, 131, 149),
            new RGBColor(243, 18, 0),
          }, 
          new java.awt.Point[] {
            new java.awt.Point(imageSize/2, 0),
            new java.awt.Point(imageSize/2, imageSize/2),
            new java.awt.Point(imageSize/2, imageSize-1),
          },
          4);
    
    shapes.add(new Circle(new Point2D.Float(0, 0),  100));
    shapes.add(new Polygon(new Point2D.Float(0, 0), 50, 4)); 
    shapes.add(new Polygon(new Point2D.Float(200, 200), 10, 3)); 
  }
  
  ThetaResult process(float theta) {
    Shape s1 = shapes.get(0)
                     .rotate(new Point2D.Float(100, 0), -5 * theta)
                     ;
    Shape s2 = shapes.get(1)
                     .rotate(new Point2D.Float(-100, 0), 7 * theta)
                     ;
    Shape s3 = shapes.get(2)
                     .rotate(new Point2D.Float(300, 200), 2 * theta)
                     ;
    
    Shape result = s1.add(s2).divide(s3);
    return new ThetaResult(result, 
                           new Shape[]{ s1, s2, s3});
  }
}
