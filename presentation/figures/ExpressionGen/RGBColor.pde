class RGBColor {
  int red;
  int green;
  int blue;
  
  RGBColor(int r, int g, int b) {
    this.red=r;
    this.green = g;
    this.blue = b;
  }
  
  int getColor() {
    return color(red, green, blue);
  }
  
  public String toString() {
    return "RGB(" + red + "," + green + "," + blue + ")";
  }
}
