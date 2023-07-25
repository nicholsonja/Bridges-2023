class Example_37 extends Example {
  Point2D.Float origin = new Point2D.Float(0, 0);
  
  Example_37(int imageSize) {
    super(37,      // example number 
          false,  // animated\
          200000,   // render Number Of Segments
          50000,     // num steps 
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
          4);
    
    shapes.add(new Epitrochoid(new Point2D.Float(0, 0), 100, 30, 40));
    shapes.add(new Epitrochoid(new Point2D.Float(0, 0), 200, 45, 40));
  }
  
  ThetaResult process(float theta) {
    Shape s0 = shapes.get(0)
                     .rotate(shapes.get(0).getCenter(), 1 * theta)
                     ;
    Shape s1 = shapes.get(1)
                     .rotate(shapes.get(1).getCenter(), 0 * theta)
                     ;
    
    Shape result =s0.add(s1);
    return new ThetaResult(result, 
                           new Shape[]{ s0, s1});
  }
}
