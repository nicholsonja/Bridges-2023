
import java.awt.geom.Point2D;


class Circle extends Shape {
  public float radius;
  
  public Circle(Point2D.Float center, float radius) {
    super(center);
    this.radius = radius;
  }
  
  public Point2D.Float getPoint(float theta) {
    return new Point2D.Float(
      cos(theta) * radius + center.x,
      sin(theta) * radius + center.y
    );
  }
}

class Polygon extends Shape {
  public int sides;
  public float radius;
  public FloatList cornerAngles;
  
  public Polygon(Point2D.Float center, float radius, int sides) {
    super(center);
    if (sides < 3) {
      throw new RuntimeException("sides < 3");
    }
    
    cornerAngles = new FloatList();
    for (int side = 0; side <= sides; side++) {
      float theta = 2 * PI/sides * side;
      cornerAngles.append(theta);
    }
    
    this.sides = sides;
    this.radius = radius;
  }
  
  public Point2D.Float getPoint(float theta) {
    theta = theta % (2 * PI);
    
    float startTheta = cornerAngles.get(0);
    float endTheta = cornerAngles.get(1);
    int side = 1;
    while (theta > endTheta) {
      startTheta = cornerAngles.get(side-1);
      endTheta = cornerAngles.get(side);
      side++;
    }
    
    Point2D.Float startPoint = new Point2D.Float(
      cos(startTheta) * radius + center.x,
      sin(startTheta) * radius + center.y
    );
    
    Point2D.Float endPoint = new Point2D.Float(
      cos(endTheta) * radius + center.x,
      sin(endTheta) * radius + center.y
    );
   
    float amt = (theta - startTheta)/(endTheta - startTheta);
    return new Point2D.Float(
      lerp(startPoint.x, endPoint.x, amt),
      lerp(startPoint.y, endPoint.y, amt)
    );
  }
  
}

class Lemniscate extends Shape {
  public float alpha;
  
  public Lemniscate(Point2D.Float center, float alpha) {
    super(center);
    this.alpha = alpha;
  }
  
  public Point2D.Float getPoint(float theta) {
    return new Point2D.Float(
      (alpha * cos(theta))/(1 + pow(sin(theta), 2)) + center.x,
      (alpha * sin(theta) * cos(theta))/(1 + pow(sin(theta), 2)) + center.y
    );
  }
}


class Epitrochoid extends Shape {
  public float R;
  public float r;
  public float d;
  public float thetaMultiplier;
  
  public Epitrochoid(Point2D.Float center, int R, int r, float d) {
    super(center);
    this.R = R;
    this.r = r;
    this.d = d;
    
    float gcd = gcd(R, r);
    thetaMultiplier = r /gcd;
    println("thetaMultiplier=" + thetaMultiplier);
  }
  
  public Point2D.Float getPoint(float theta) {
    theta = theta * thetaMultiplier;
    return new Point2D.Float(
      (R+r) * cos(theta) - d * cos((R+r)/r * theta) + center.x,
      (R+r) * sin(theta) - d * sin((R+r)/r * theta) + center.y
    );
  }
}

class Hypotrochoid extends Shape {
  public float R;
  public float r;
  public float d;
  public float thetaMultiplier;
  
  public Hypotrochoid(Point2D.Float center, int R, int r, float d) {
    super(center);
    this.R = R;
    this.r = r;
    this.d = d;
    
    float gcd = gcd(R, r);
    thetaMultiplier = r/ gcd;
  }
  
  public Point2D.Float getPoint(float theta) {
    theta = theta * thetaMultiplier;
    return new Point2D.Float(
      (R-r) * cos(theta) + d * cos((R-r)/r * theta) + center.x,
      (R-r) * sin(theta) - d * sin((R-r)/r * theta) + center.y
    );
  }
}

class RoseCurve extends Shape {
  public int n;
  public int d;
  public float k;
  public float alpha;
  public int thetaMultiplier;
  
  public RoseCurve(Point2D.Float center, float alpha, int k) {
    super(center);
    this.n = k;
    this.d = 1;
    this.k = k;
    this.alpha = alpha;
    
    thetaMultiplier = 1;
  }
  
  // https://en.wikipedia.org/wiki/Rose_(mathematics)
  public RoseCurve(Point2D.Float center, float alpha, int n, int d) {
    super(center);
    int denom = gcd(n, d);
    n = n/denom;
    d = d/denom;
    
    this.n = n;
    this.d = d;
    this.k = (float) n/d;
    this.alpha = alpha;
    
    if (n % 2 == 1 && d % 2 == 1) {
      thetaMultiplier = d;
    } else if ((n % 2 == 0 && d % 2 == 1) || (n % 2 == 1 && d % 2 == 0)) {
      println("here");
      thetaMultiplier = 2 * d;
    } else {
      thetaMultiplier = 1;
    }
  }
  
  public Point2D.Float getPoint(float theta) {
    theta *= thetaMultiplier;
    return new Point2D.Float(
      alpha * cos(k * theta) * cos(theta) + center.x,
      alpha * cos(k * theta) * sin(theta) + center.y
    );
  }
}

class Line extends Shape {
  public float width;
  
  public Line(Point2D.Float center, float width) {
    super(center);
    this.width = width;
  }
  
  public Point2D.Float getPoint(float theta) {
    return new Point2D.Float(
      sin(theta) * width + center.x,
      center.y
    );
  }
}
