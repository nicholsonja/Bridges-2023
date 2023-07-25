import java.awt.geom.Point2D;

abstract class Shape {
  protected Point2D.Float center;
  private color strokeColor;
  
  public Shape(Point2D.Float center) {
    this(center, color(0,0,0));
  }
  
  public Shape(Point2D.Float center, color strokeColor) {
    this.center = center;
    this.strokeColor = strokeColor;
  }
  
  public abstract Point2D.Float getPoint(float theta);
  
  public int gcd(int a, int b) {
    while (b != 0) {
        int t = a;
        a = b;
        b = t % b;
    }
    return a;
  }
  
  public Shape setStrokeColor(color strokeColor) {
    this.strokeColor = strokeColor;
    return this;
  }
  
  public color getStrokeColor() {
    return strokeColor;
  }
  
  public Point2D.Float getCenter() {
    return center;
  }
  
  public void draw() {
    draw(720, false);
  }
  
  public void draw(boolean showStart) {
    draw(720, showStart);
  }
  
  public void draw(int segments, boolean showStart) {
    draw(segments, showStart, .05);
  }
  
  public void draw(int segments, boolean showStart, 
                   float strokeWeight) {
    strokeWeight(strokeWeight);
    stroke(strokeColor);
    
    ArrayList<LineSegment> lineSegments = getLineSegments(segments);
    for (LineSegment ls : lineSegments) {
      if (abs(ls.start.x) <= width * 3 &&
          abs(ls.start.y) <= height * 3) {
        line(ls.start.x, ls.start.y, ls.end.x, ls.end.y);
      }
    }
    
    if (showStart) {
      Point2D.Float start = lineSegments.get(0).start;
      noStroke();
      fill(255, 0, 0);
      circle(start.x, start.y, 5);
    }
  }
  
  public ArrayList<LineSegment> getLineSegments(int segments) {
      ArrayList<LineSegment> lineSegments = new ArrayList<LineSegment>();
          float theta = 0;
    float thetaStep = 2 * PI / segments;
    Point2D.Float start = null;
    Point2D.Float end;
    
    for(int segment = 0; segment < segments + 1; segment++) {
      if (start == null) {
        start = getPoint(theta);
      } else {
        end = getPoint(theta);
        lineSegments.add(new LineSegment(start, end));
        start = end;
      }
      
      theta += thetaStep;
    }
    
    return lineSegments;
  }
  
  public Shape add(Shape b) {
    Shape s = new AddShape(this, b);
    return s;
  }
  
  public Shape subtract(Shape b) {
    Shape s = new SubtractShape(this, b);
    return s;
  }
  
  public Shape multiply(Shape b) {
    Shape s = new MultiplyShape(this, b);
    return s;
  }
  
  public Shape divide(Shape b) {
    Shape s = new DivideShape(this, b);
    return s;
  }
  
  public Shape rotate(Point2D.Float center, float rotationTheta) {
    Shape s = new RotateShape(this, center, rotationTheta);
    return s;
  }
  
  public Shape scale(float scale) {
    Shape s = new ScaleShape(this, scale);
    return s;
  }
  
  public Shape scale(float xScale, float yScale) {
    Shape s = new ScaleShape(this, xScale, yScale);
    return s;
  }
  
  public Shape translate(Point2D.Float center) {
    Shape s = new TranslateShape(this, center);
    return s;
  }
  
  
  public Shape sqrt() {
    Shape s = new SqrtShape(this);
    return s;
  }
  
  
  public Shape offsetStart(float offsetStartTheta) {
    Shape s = new OffsetStartShape(this, offsetStartTheta);
    return s;
  }

}
