class ExtentFloat {
  public float maxX;
  public float maxY;
  
  public float minX;
  public float minY;
  
  public ExtentFloat() {
    maxX = maxY = Float.MIN_VALUE;
    minX = minY = Float.MAX_VALUE;
  }
  
  public ExtentFloat(ExtentFloat o) {
    maxX = o.maxX;
    minX = o.minX;
    maxY = o.maxY;
    minY = o.minY;
  }
  
  public ExtentFloat(float maxX, float maxY, float minX, float minY) {
    this.maxX = maxX;
    this.minX = minX;
    this.maxY = maxY;
    this.minY = minY;
  }
  
  public void check(float x, float y) {
    maxX = max(x, maxX);
    minX = min(x, minX);
    
    maxY = max(y, maxY);
    minY = min(y, minY);
  }
  
  public float getRangeX() {
    return maxX - minX;
  }
  
  public float getRangeY() {
    return maxY - minY;
  }
  
  public float getMidX() {
    return (maxX + minX)/2;
  }
  
  public float getMidY() {
    return (maxY + minY)/2;
  }
  
  public int hashCode() {
      int hash = 41; // + 1
      hash = 31 * hash + Float.hashCode(maxX);
      hash = 31 * hash + Float.hashCode(minX);
      hash = 31 * hash + Float.hashCode(maxY);
      hash = 31 * hash + Float.hashCode(minY);
      return hash;
  }
  
  public boolean equals(Object o) {
    if (o == null || !(o instanceof ExtentFloat)) return false;
    
    ExtentFloat ef = (ExtentFloat) o;
    return maxX == ef.maxX &&
           minX == ef.minX &&
           maxY == ef.maxY &&
           minY == ef.minY;
  }
  
  public String toString() {
    return "Extent(maxX=" + maxX + ", maxY=" + maxY
           + ", minX=" + minX + ", minY=" + minY
           + ")";
  }
}
