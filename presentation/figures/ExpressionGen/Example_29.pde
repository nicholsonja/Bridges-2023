class Example_29 extends Example {
  Example_29(int imageSize) {
    super(29,      // example number 
          false,   // animated
          2000,   // render Number Of Segments
          75000,     // num steps
          new ExtentFloat(75, 75, -75, -75), // constant extent
          imageSize,  // width
          imageSize   // height
          );
    
    painter = new LinearPainter(
          new RGBColor(255, 255, 255), 
          new RGBColor[] {
            new RGBColor(255, 255, 255),
            new RGBColor(65, 42, 179),
            new RGBColor(255, 211, 32),
            new RGBColor(65, 42, 179)
          }, 
          4);
    
    shapes.add(new Circle(new Point2D.Float(0, 0),  100));
    shapes.add(new Circle(new Point2D.Float(300, 0), 50)); 
  }
  
  ThetaResult process(float theta) {
    Shape s1 = shapes.get(0)
                     .rotate(new Point2D.Float(0, 0), 7 * theta)
                     ;
    Shape s2 = shapes.get(1)
                     //.rotate(shapes.get(1).getCenter(), 5 * theta)
                     .rotate(new Point2D.Float(0, 0), -3 * theta)
                     ;
    
    Shape result = s1.divide(s2).multiply(s1);
    return new ThetaResult(result, 
                           new Shape[]{ s1, s2});
  }
}
