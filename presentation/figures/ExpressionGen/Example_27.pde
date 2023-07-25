class Example_27 extends Example {
  
  Example_27(int imageSize)  {
    super(27,    // example number 
          false, // animated
          5000,  // render Number Of Segments
          20000, // num steps
          null,  // no constant extent
          imageSize,  // width
          imageSize   // height
          );
    
    painter = new RadialPainter(
          new RGBColor(255, 255, 255), 
          new RGBColor[] {
            new RGBColor(255, 255, 255),
            new RGBColor(6, 45, 115),
            new RGBColor(0, 118, 70),
            new RGBColor(173, 112, 0),
            new RGBColor(173, 52, 0),
          }, 
         5);
    
    Point2D.Float origin = new Point2D.Float(0, 0);
    
    shapes.add(new Epitrochoid(new Point2D.Float(0, 0), 60, 40, 50));
    shapes.add(new Hypotrochoid(new Point2D.Float(0, 0), 60, 40, 100)); // path for circle
    //paths.add(new Polygon(new Point2D.Float(1000, 1000), 300, 4));
  }
  
  ThetaResult process(float theta) {
    //Shape path1 = paths.get(0);
    Shape s1 = shapes.get(0)
                     .rotate(shapes.get(0).getCenter(), 3 * theta)
                     //.translate(path1.getPoint(theta))
                     ;
                     
    //Shape path2 = paths.get(1);
    Shape s2 = shapes.get(1) 
                     //.offsetStart(PI/2)
                     .rotate(shapes.get(1).getCenter(), -2 * theta)
                     //.translate(path2.getPoint(theta))
                     //.offsetStart(-3 * theta)
                     ;

  
    Shape result =s1.add(s2); //.multiply(s3);
    return new ThetaResult(result, 
                           new Shape[]{ //path1, 
                                        //path2, 
                                        s1, s2
                                    });
  }
}
