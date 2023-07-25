abstract class Example {

  private String name;
  protected ArrayList<Shape> shapes;
  protected ArrayList<Shape> paths;
  protected Painter painter;
  
  private boolean animated;
  private int renderNumberOfSegments;
  private int numSteps;
  private ExtentFloat constantExtant;
  
  private int imageWidth;
  private int imageHeight;
  
  Example(int exampleNum, boolean animated, int renderNumberOfSegmentsm,
          int numSteps) {
    this(exampleNum, animated, renderNumberOfSegmentsm, numSteps, null, 2000, 2000);
  }
  
  
  Example(int exampleNum, boolean animated, int renderNumberOfSegments,
          int numSteps, ExtentFloat constantExtent) {
    this(exampleNum, animated,  
         renderNumberOfSegments, numSteps, constantExtent, 2000, 2000);
  }
          
  Example(int exampleNum, boolean animated, int renderNumberOfSegments,
          int numSteps, 
          ExtentFloat constantExtant, int imageWidth, int imageHeight) {
    this.name = String.format("example_%02d", exampleNum);
    this.shapes = new ArrayList<>();
    this.paths = new ArrayList<>();
    this.animated = animated;
    this.renderNumberOfSegments = renderNumberOfSegments;
    this.numSteps = numSteps;
    this.constantExtant = constantExtant;
    this.imageWidth = imageWidth;
    this.imageHeight = imageHeight;
  }
  
  String getName() {
    return name;
  }
  
  boolean isAnimated() {
    return animated;
  }
  
  int getRenderNumberOfSegments() {
    return renderNumberOfSegments;
  }
  
  int getNumSteps() {
    return numSteps;
  }
  
  Painter getPainter() {
    return painter;
  }
  
  ExtentFloat getConstantExtant() {
    return constantExtant;
  }
  
  int getImageWidth() {
    return imageWidth;
  }
  
  int getImageHeight() {
    return imageHeight;
  }
  
  abstract ThetaResult process(float theta);
}

class ThetaResult {
  Shape result;
  Shape[] operands;
  ThetaResult(Shape result, Shape[] operands) {
    this.result = result;
    this.operands = operands;
  }
}
