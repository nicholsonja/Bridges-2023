class ShapeImageApplet extends PApplet {
  private int windowWidth;
  private int windowHeight;
  
  private Renderer renderer;
  public boolean doRender;
  private String exampleName;
  
  private boolean animate;
    
  public ShapeImageApplet(String exampleName,
                          int windowWidth, int windowHeight, 
                          int imageWidth, int imageHeight,
                          int renderSegements,
                          Painter painter,
                          boolean limitRepeatPixels,
                          ExtentFloat coordExtent ) {
    super();
    this.exampleName = exampleName;
    
    this.windowHeight = windowHeight;
    this.windowWidth = windowWidth;
    
    this.renderer = new ShapeImage(imageWidth, imageHeight, renderSegements, limitRepeatPixels, painter, coordExtent);
    this.doRender = false;
    this.animate = false;
    
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }
  
  
    
  public ShapeImageApplet(String exampleName,
                          int windowWidth, int windowHeight, 
                          int imageWidth, int imageHeight,
                          int renderSegements,
                          ExtentFloat coordExtent ) {
    super();
    this.exampleName = exampleName;
    
    this.windowHeight = windowHeight;
    this.windowWidth = windowWidth;
    
    this.renderer = new ShapeAnimation(imageWidth, imageHeight, renderSegements, coordExtent, exampleName);
    this.doRender = false;
    this.animate = true;
    
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }
  
  void settings() {
    size(windowWidth, windowHeight);
  }
  
  void setup() {
    if (animate) {
      frameRate(10);
    }
  }
  
  void draw() { 
    translate(0, height);
    scale(1, -1);
    if (doRender) {
      renderer.render(exampleName);
      doRender = false;
    }
    PImage tmp = renderer.getImage();
    if (tmp != null) {
      image(renderer.getImage(), 0, 0, width, height);
    }
      
  }
  
  public void addShape(Shape shape) {
    renderer.addShape(shape);
  }
  
  public void render() {
    doRender = true;
  }
}

abstract class Renderer {
  protected float theta_step; 
  private int imageWidth;
  private int imageHeight;
  private int renderSegements;
  private ArrayList<Shape> shapes; 
  private PImage image;
  
  private ExtentFloat coordExtent;
  private boolean constantExtent;
  
  public Renderer(int imageWidth, int imageHeight, int renderSegements, ExtentFloat coordExtent) {
    this.imageWidth = imageWidth;
    this.imageHeight = imageHeight;
    this.renderSegements = renderSegements;
    this.theta_step = 2 * PI/renderSegements; 

    image = createImage(imageWidth, imageHeight, RGB);
    
    this.shapes = new ArrayList<Shape>();
    
    if (coordExtent == null) {
      this.coordExtent = new ExtentFloat();
      this.constantExtent = false;
    } else {
      this.coordExtent = coordExtent;
      this.constantExtent = true;
    }
  }
  
  public abstract void render(String exampleName);
  
  public PImage getImage() {
    return image;
  }
  
  public void setImage(PImage image) {
    this.image = image;
  }
  
  public void addShape(Shape shape) {
    if (! isConstantExtent()) {
      float theta = 0;
      while (theta < 2 * PI) {
        Point2D.Float p = shape.getPoint(theta);
        getCoordExtent().check(p.x, p.y);
        theta += theta_step;
      }
    }
    
    shapes.add(shape);
  }
  
  public int getImageWidth() {
    return imageWidth;
  }
  
  public int getImageHeight() {
    return imageHeight;
  }
  
  public ExtentFloat getCoordExtent() {
    return coordExtent;
  }
  
  public boolean isConstantExtent() {
    return constantExtent;
  }
  
  public ArrayList<Shape> getShapes() {
    return shapes;
  }
}

class ShapeAnimation extends Renderer {
  private boolean renderDone;
  private int currentImage;
  private String exampleName;
  
  public ShapeAnimation(int imageWidth, int imageHeight, 
                        int renderSegements, ExtentFloat coordExtent,
                        String exampleName) {
    super(imageWidth, imageHeight, renderSegements, coordExtent);
    renderDone = false;
    currentImage = 0;
    this.exampleName = exampleName;
  }
  
  public PImage getImage() {
    if (renderDone) {
      setImage(loadImage(getImageFilename(currentImage)));
      currentImage = (currentImage + 1) % getShapes().size();
    }
    return super.getImage();
  }
  
  public void render(String exampleName) {
    File dir = new File(sketchPath(exampleName));
    println(dir);
    if (dir.exists()) {
      for (File file: dir.listFiles()) {
        file.delete();
      }
      dir.delete();
    }
    String folder = exampleName;
    
    float rangeX = getCoordExtent().getRangeX();
    float rangeY = getCoordExtent().getRangeY();
    float range = max(rangeX, rangeY);
    
    int numShapes = getShapes().size();
    
    PGraphics pg = createGraphics(getImageWidth(), getImageHeight());
    
    for (int i = 0; i < getShapes().size(); i++) {
      Shape shape = getShapes().get(i);
       
      pg.beginDraw();
      
      pg.strokeWeight(1.0);
      pg.stroke(0, 0, 255);
      pg.background(255, 255, 255);
       
      for (LineSegment ls : shape.getLineSegments(10000)) {
        float startX = fit(ls.start.x, getCoordExtent().getMidX(), range, getImageWidth());
        float startY = fit(ls.start.y, getCoordExtent().getMidY(), range,  getImageHeight());
        
        float endX = fit(ls.end.x, getCoordExtent().getMidX(), range, getImageWidth());
        float endY = fit(ls.end.y, getCoordExtent().getMidY(), range, getImageHeight());
        
        pg.line(startX, startY, endX, endY);
      }
    

      pg.endDraw();
      setImage(pg.get());
      getImage().save(getImageFilename(i));
    }
    renderDone = true;
  }
  
  private String getImageFilename(int imageNum) {
    return String.format("%s/%05d.png", exampleName, imageNum);
  }
  
  private float fit(float a, float mid, float range, float windowSize) {
   return round((a - mid) / range * (windowSize-1) + windowSize/2.0);
  }
}

class ShapeImage extends Renderer {
  private IntList counts;
  private boolean limitRepeatPixels;
  
  private Painter painter;
  
  public ShapeImage(int imageWidth, int imageHeight, int renderSegements,
                    boolean limitRepeatPixels,
                    Painter painter, ExtentFloat coordExtent) {
    super(imageWidth, imageHeight, renderSegements, coordExtent);
    
    counts = new IntList(imageWidth * imageHeight);
    for (int i = 0; i < imageWidth * imageHeight; i++ ) {
      counts.append(0);
    }
    
    this.limitRepeatPixels = limitRepeatPixels;
    
    this.painter = painter;
  }
  
  public void render(String exampleName) {
    try {
      // println("HERE");
      
      int numShapes = getShapes().size();
      
      int imageX, imageY;
      
      float rangeX = getCoordExtent().getRangeX();
      float rangeY = getCoordExtent().getRangeY();
      float range = max(rangeX, rangeY);
      
      float midX = getCoordExtent().getMidX();
      float midY = getCoordExtent().getMidY();
      
      println("Start numShapes=" + numShapes);
      
      int prevImageX = -1;
      int prevImageY = -1;
      
      int percentDone = 0;
      int prevPercentDone = -1;
      for (int s = 0; s < numShapes; s++) {
        Shape shape = getShapes().get(s);
        float theta = 0;
        while (theta < 2 * PI) {
          Point2D.Float p = shape.getPoint(theta);
          //println("p=" + p);
          //println("extent=" + coordExtent);
          imageX = round((p.x - midX) / range * (getImageWidth()-1) + (getImageWidth()-1)/2.0);
          imageY = round((p.y - midY) / range * (getImageHeight()-1) + (getImageHeight()-1)/2.0);
          
          if (!limitRepeatPixels || 
              (prevImageX != imageX || prevImageY != imageY)) {
            int idx = imageY * getImageWidth() + imageX;
            if (idx >= 0 && idx < counts.size()) {
              int val = counts.get(idx) + 1;
              counts.set(idx, val);
            }
          }
          
          prevImageX = imageX;
          prevImageY = imageY;
          
          theta += theta_step;
          
          percentDone = 100 * s/numShapes;
          if (prevPercentDone != percentDone) {
            println("Render progress: " + percentDone + "%");
            prevPercentDone = percentDone;
          }
        }
      }
      
      buildImage(exampleName);
      
      println("Done");
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  
  private void buildImage(String exampleName) {
    
    java.util.TreeMap<Integer, Integer> test = new java.util.TreeMap<Integer, Integer>();
    
    int[] data = counts.toArray();
    float maxVal = max(data);
    float minVal = min(data);
    
    for (int x : data) {
      if (test.containsKey(x)) {
        test.put(x, test.get(x) + 1);
      } else {
        test.put(x, 1);
      }
    }
    
    float range = maxVal - minVal;
    if (range == 0) range = 1;
    
    println("    buildImage: maxVal=" + maxVal
            + " minVal=" + minVal
            + " range=" + range);
            
    cacheImageData(exampleName, data, minVal, range, getImageWidth(), getImageHeight());
    paintImage( exampleName, data, minVal, range);
  }
  
  
  public void paintImage(String exampleName, int[] data, float minVal, float range) {
    
    PImage newImage = createImage(getImageWidth(), getImageHeight(), RGB);
    
    newImage.loadPixels();
    painter.paint(newImage, data, getImageWidth(), getImageHeight(), minVal, range);
    
    newImage.save(exampleName + ".png");
    setImage(newImage);
  }
  
  public void cacheImageData(String exampleName, int[] data, float minVal, float range, 
                             int imageWidth, int imageHeight) {
    try {
      ImageDataCache cacheData = new ImageDataCache(exampleName, data, minVal, range,
                                                    imageWidth, imageHeight);
      
      OutputStream os = createOutput(getCacheFilename(exampleName));
      
      java.io.ObjectOutputStream oos = new java.io.ObjectOutputStream(os);
      oos.writeObject(cacheData);
      oos.flush();
      oos.close();
    } catch (IOException e) {
        println("ERROR: Can't cache image data");
        e.printStackTrace();
    }
  }
}

String getCacheFilename(String exampleName) {
  return "data_" + exampleName + ".cache";
}

PImage paintCacheData(String exampleName, Painter painter) {
  try {
    InputStream is = createInput(getCacheFilename(exampleName));
    
    java.io.ObjectInputStream ois = new java.io.ObjectInputStream(is);
    ImageDataCache cacheData = (ImageDataCache) ois.readObject();
    ois.close();
    
    PImage newImage = createImage(cacheData.imageWidth, cacheData.imageHeight, RGB);
    
    newImage.loadPixels();
    painter.paint(newImage, cacheData.data, cacheData.imageWidth,
                  cacheData.imageHeight, cacheData.minVal, cacheData.range);
    
    
    newImage.save(exampleName + ".png");
    
    return newImage;
  } catch (Exception e) {
    println("WARNING: Can't read cache image data");
    return null;
  }
}


class ColorMap {
   ArrayList<RGBColor> colorList;
   
   ColorMap(RGBColor[] colors, int stepsBetweenColors) {
     if (colors.length < 2) {
       throw new RuntimeException("Need 2 or more colors for color map");
     }
     colorList = new ArrayList<RGBColor>();
     for (int i = 0; i < colors.length-1; i++) {
       RGBColor color1 = colors[i];
       RGBColor color2 = colors[i+1];
       
       float N = stepsBetweenColors;
       for (int step = 0; step < stepsBetweenColors; step++) {
          int r = round(lerp(color1.red, color2.red, step/N));
          int g = round(lerp(color1.green, color2.green, step/N));
          int b = round(lerp(color1.blue, color2.blue, step/N));
          
          colorList.add(new RGBColor(r, g, b));
       }
     }
     colorList.add(colors[colors.length-1]);
   }
   
   int getSize() {
     return colorList.size();
   }
   
   int getColor(int i) {
     return colorList.get(i).getColor();
   }
   
   RGBColor getRGBColor(int i) {
     return colorList.get(i);
   }
}
