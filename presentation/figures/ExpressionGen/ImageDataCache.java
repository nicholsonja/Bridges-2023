class ImageDataCache implements java.io.Serializable {
  private static final long serialVersionUID = 2L;
	
  public String exampleName;
  public int[] data;
  public float minVal;
  public float range;
  public int imageWidth;
  public int imageHeight;
  public ImageDataCache(String exampleName, int[] data, float minVal, float range,
                        int imageWidth, int imageHeight) {
    this.exampleName = exampleName;
    this.data = data;
    this.minVal = minVal;
    this.range = range;
    this.imageWidth = imageWidth;
    this.imageHeight =imageHeight;
  }
}
