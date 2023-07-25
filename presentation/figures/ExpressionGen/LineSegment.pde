class LineSegment {
  public Point2D.Float start;
  public Point2D.Float end;
  
  public LineSegment(Point2D.Float start, Point2D.Float end) {
    this.start = start;
    this.end = end;
  }
  
  public String toString() {
    return "LineSegment(start=" + start + " end=" + end + ")";
  }
}
