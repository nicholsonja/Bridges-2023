abstract class FunctionShape extends Shape {
   protected Shape op1;
   protected Shape op2;
   
   public FunctionShape(Point2D.Float center, Shape op1) {
     this(center, op1, null);
   }
   
   public FunctionShape(Point2D.Float center, Shape op1, Shape op2) {
     super(center);
     this.op1 = op1;
     this.op2 = op2;
   }
}

public class OffsetStartShape extends FunctionShape {
  private float offsetStartTheta;
  public OffsetStartShape(Shape op1, float offsetStartTheta) {
    super(op1.getCenter(), op1);
    this.offsetStartTheta = offsetStartTheta;
  }
  
  public Point2D.Float getPoint(float theta) {
    Point2D.Float p = op1.getPoint(theta + offsetStartTheta);
    return p;
  }
}

public class AddShape extends FunctionShape {
  public AddShape(Shape op1, Shape op2) {
    super(new Point2D.Float(op1.center.x + op2.center.x, 
                            op1.center.y + op2.center.y),
          op1, op2);
  }
  
  public Point2D.Float getPoint(float theta) {
    Point2D.Float p1 = op1.getPoint(theta);
    Point2D.Float p2 = op2.getPoint(theta);
    return new Point2D.Float(p1.x + p2.x, p1.y + p2.y);
  }
}

public class SubtractShape extends FunctionShape {
  public SubtractShape(Shape op1, Shape op2) {
    super(new Point2D.Float(op1.center.x - op2.center.x, 
                            op1.center.y - op2.center.y),
          op1, op2);
  }
  
  public Point2D.Float getPoint(float theta) {
    Point2D.Float p1 = op1.getPoint(theta);
    Point2D.Float p2 = op2.getPoint(theta);
    return new Point2D.Float(p1.x - p2.x, p1.y - p2.y);
  }
}

public class MultiplyShape extends FunctionShape {
  public MultiplyShape(Shape op1, Shape op2) {
    super(new Point2D.Float(op1.center.x * op2.center.x, 
                            op1.center.y * op2.center.y),
          op1, op2);
  }
  
  public Point2D.Float getPoint(float theta) {
    Point2D.Float p1 = op1.getPoint(theta);
    Point2D.Float p2 = op2.getPoint(theta);
    return new Point2D.Float(p1.x * p2.x, p1.y * p2.y);
  }
}

public class DivideShape extends FunctionShape {
  public DivideShape(Shape op1, Shape op2) {
    super(new Point2D.Float(op1.center.x / op2.center.x, 
                            op1.center.y / op2.center.y),
          op1, op2);
  }
  
  public Point2D.Float getPoint(float theta) {
    Point2D.Float p1 = op1.getPoint(theta);
    Point2D.Float p2 = op2.getPoint(theta);
    return new Point2D.Float(p1.x / p2.x, p1.y / p2.y);
  }
}

public class SqrtShape extends FunctionShape {
  public SqrtShape(Shape op1) {
    super(new Point2D.Float((float) Math.sqrt(op1.center.x),
                            (float) Math.sqrt(op1.center.y)),
          op1);
  }
  
  public Point2D.Float getPoint(float theta) {
    Point2D.Float p = op1.getPoint(theta);
    return new Point2D.Float((float) Math.sqrt(p.x), (float) Math.sqrt(p.y));
  }
}

public class ScaleShape extends FunctionShape {
  private float xScale;
  private float yScale;
  
  public ScaleShape(Shape op1, float scale) {
    this(op1, scale, scale);
  }
  
  public ScaleShape(Shape op1, float xScale, float yScale) {
    super(new Point2D.Float(xScale * op1.center.x,
                            yScale * op1.center.y),
          op1);
    this.xScale = xScale;
    this.yScale = yScale;
  }
  
  public Point2D.Float getPoint(float theta) {
    Point2D.Float p = op1.getPoint(theta);
    return new Point2D.Float(p.x * xScale, p.y * yScale);
  }
}


public class TranslateShape extends FunctionShape {
  private Point2D.Float newCenter;
  private Point2D.Float oldCenter;
  
  public TranslateShape(Shape op1, Point2D.Float newCenter) {
    super(op1.center, op1);
    this.oldCenter = op1.center;
    this.newCenter = newCenter;
    center = newCenter;
  }
  
  public Point2D.Float getPoint(float theta) {
    Point2D.Float p = op1.getPoint(theta);
    return new Point2D.Float(
      p.x - oldCenter.x + newCenter.x,
      p.y - oldCenter.y + newCenter.y
    );
  }
}

public class RotateShape extends FunctionShape {
  private Point2D.Float rotationCenter;
  private float rotationTheta;
  
  public RotateShape(Shape op1, Point2D.Float rotationCenter, float rotationTheta) {
    super(rotatePoint(op1.center, rotationCenter, rotationTheta), op1);
    this.rotationCenter = rotationCenter;
    this.rotationTheta = rotationTheta;
  }
  
  public Point2D.Float getPoint(float theta) {
    Point2D.Float p = op1.getPoint(theta);
    return rotatePoint(p, rotationCenter, rotationTheta);
  }
}
  
// hack so that RotateShape constructor can rotate the center
static Point2D.Float rotatePoint(Point2D.Float point,  
                            Point2D.Float rotationCenter, 
                            float rotationTheta) {
                                
    Point2D.Float p = new Point2D.Float(point.x, point.y);
    
    float s = sin(rotationTheta);
    float c = cos(rotationTheta);
        
    p.x -= rotationCenter.x;
    p.y -= rotationCenter.y;
  
    float xnew = p.x * c - p.y * s;
    float ynew = p.x * s + p.y * c;

    p.x = xnew + rotationCenter.x;
    p.y = ynew + rotationCenter.y;
    
    return p;
  }
