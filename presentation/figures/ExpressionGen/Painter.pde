import java.util.*;

abstract class Painter {
  RGBColor backgroundColor;
  float colorScale;
  RGBColor[] colors;
  
  Painter(RGBColor backgroundColor, RGBColor[] colors, float colorScale) {
    this.backgroundColor = backgroundColor;
    this.colorScale = colorScale;
    this.colors = colors;
  }
  abstract void paint(PImage image, int[] data, int width, int height, float minVal, float range);
}

class LinearPainter extends Painter {
  ColorMap colorMap;
  
  LinearPainter(RGBColor backgroundColor, RGBColor[] colors, float colorScale) {
    this(backgroundColor, colors, colorScale, 255);
  }
  
  LinearPainter(RGBColor backgroundColor, RGBColor[] colors, float colorScale,
                int colorMapSteps) {
    super(backgroundColor, colors, colorScale);
    colorMap = new ColorMap(colors, colorMapSteps);
  }
  
  void paint(PImage image, int[] data, int width, int height, float minVal, float range) {
    for (int i = 0; i < width*height; i++) {
      if (data[i] == 0) {
        image.pixels[i] = backgroundColor.getColor();
      } else {
        float alpha = min((data[i] - minVal)/range * colorScale, 1.0);
        int colorIndex = round(alpha * (colorMap.getSize()-1));
        image.pixels[i] =  colorMap.getColor(colorIndex);
      }
    }
  }
}

class RadialPainter extends Painter {
  ColorMap colorMap;
  RGBColor maxColor;
  
  RadialPainter(RGBColor backgroundColor, RGBColor[] colors, float colorScale) {
    this(backgroundColor,colors,  null, colorScale, 255);
  }
  
  RadialPainter(RGBColor backgroundColor, RGBColor[] colors, RGBColor maxColor, float colorScale) {
    this(backgroundColor,colors, maxColor, colorScale, 255);
  }
  
  RadialPainter(RGBColor backgroundColor, RGBColor[] colors, 
                RGBColor maxColor, float colorScale,
                int colorMapSteps) {
    super(backgroundColor, colors, colorScale);
    colorMap = new ColorMap(colors, colorMapSteps);
    this.maxColor = maxColor;
  }
  
  void paint(PImage image, int[] data, int width, int height, float minVal, float range) {
    int cx = width/2;
    int cy = height/2;
    int maxDist = max(cx,  cy);
    
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        int i = y * width + x;
        
        if (data[i] == 0) {
          image.pixels[i] = backgroundColor.getColor();
        } else {
          float dist = sqrt(pow(x-cx, 2) + pow(y-cy, 2));
          dist = dist/maxDist;
          if (dist > 1) dist = 1;
          
          int colorIndex = round(dist * (colorMap.getSize()-1));
          RGBColor rgbColor = colorMap.getRGBColor(colorIndex);

          float alpha = min((data[i] - minVal)/range * colorScale, 1.0);
          int r, g, b;
          if (maxColor == null) {
            r = round(lerp(backgroundColor.red, rgbColor.red, alpha));
            g = round(lerp(backgroundColor.green, rgbColor.green, alpha));
            b = round(lerp(backgroundColor.blue, rgbColor.blue, alpha));
          } else {
            r = round(lerp(rgbColor.red, maxColor.red, alpha));
            g = round(lerp(rgbColor.green, maxColor.green, alpha));
            b = round(lerp(rgbColor.blue, maxColor.blue, alpha));
          }
          image.pixels[i] =  color(r, g, b);
        }
      }
    }
  }
}


class GradientPointPainter extends Painter {
  java.awt.Point[] colorCenters;
  
  
  GradientPointPainter(RGBColor backgroundColor, 
                RGBColor[] colors, 
                java.awt.Point[] colorCenters,
                float colorScale) {
    super(backgroundColor, colors, colorScale);
    
    if (colors.length != colorCenters.length) {
      throw new RuntimeException("colors and colorCenters are different lengths");
    }
    this.colorCenters = colorCenters;
  }
  
  RGBColor[] buildColorMap(int width, int height) {
    RGBColor[] map = new RGBColor[width*height];
    
    HashMap<java.awt.Point, Float> weights = new HashMap<>();
    
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        int loc = y * width + x;
        
        float red = 0;
        float green = 0;
        float blue = 0;
        
        boolean exactMatch = false;
        for (int i = 0; i < colorCenters.length; i++) {
          java.awt.Point c = colorCenters[i];
          if (c.x == x && c.y == y) {
           RGBColor colr = colors[i];
           red = colr.red;
           green = colr.green;
           blue = colr.blue;
           exactMatch = true;
          }
        }
        
        if (!exactMatch) {
        
          weights.clear();
          float weightSum = 0;
          for (int i = 0; i < colorCenters.length; i++) {
            java.awt.Point c = colorCenters[i];
            float dist = sqrt(pow(c.x - x, 2) + pow(c.y - y, 2));
            float weight = 1/(dist * dist);
            weightSum += weight;
            weights.put(c, weight);
          }
          
          for (int i = 0; i < colorCenters.length; i++) {
             java.awt.Point colorCenter = colorCenters[i];
             float weight = weights.get(colorCenter);
             float scaled = weight/weightSum;
             RGBColor colr = colors[i];
             red += scaled * colr.red;
             green += scaled * colr.green;
             blue += scaled * colr.blue;
          }
        }
        
        map[loc] = new RGBColor(int(red), int(green), int(blue));
      }
    }
    return map;
  }
  
  void paint(PImage image, int[] data, int width, int height, float minVal, float range) {
    RGBColor[] colorMap = buildColorMap(width, height);
    
    int cx = width/2;
    int cy = height/2;
    
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        int i = y * width + x;
        
        if (data[i] == 0) {
          image.pixels[i] = backgroundColor.getColor();
        } else {
          
          float alpha = min((data[i] - minVal)/range * colorScale, 1.0);
          RGBColor rgbColor = colorMap[i];

          int r = round(lerp(backgroundColor.red, rgbColor.red, alpha));
          int g = round(lerp(backgroundColor.green, rgbColor.green, alpha));
          int b = round(lerp(backgroundColor.blue, rgbColor.blue, alpha));
         
          image.pixels[i] =  color(r, g, b);
        }
      }
    }
  }
}


class WeightedPainter extends Painter {
  List<ColorWeight> colorWeights;
  
  WeightedPainter(RGBColor backgroundColor, RGBColor[] colors, 
                float[] weights, float colorScale) {
    super(backgroundColor, colors, colorScale);
    
    if (colors.length != weights.length) {
      throw new RuntimeException("colors and weights are different lengths");
    }
    
    float totalWeight = 0;
    for (float f : weights) {
      totalWeight += f;
    }
    
    colorWeights = new ArrayList<>();
    for (int i = 0; i < colors.length; i++) {
      colorWeights.add(new ColorWeight(colors[i], weights[i], weights[i]/totalWeight));
    }
  }
  
  void paint(PImage image, int[] data, int width, int height, float minVal, float range) {
    
    for (int i = 0; i < width*height; i++) {
      if (data[i] == 0) {
        image.pixels[i] = backgroundColor.getColor();
      } else {
        float alpha = min((data[i] - minVal)/range * colorScale, 1.0);
        
        float weight = 1;
        int colorIndex = -1;
        for (int c = colorWeights.size()-1; c >= 0; c--) {
          weight = weight - colorWeights.get(c).normWeight;
          if (weight <= alpha) {
            colorIndex = c;
            break;
          }
        }
        
        image.pixels[i] =  colorWeights.get(colorIndex).rgbColor.getColor();
      }
    }
  }

  class ColorWeight {
    RGBColor rgbColor;
    float rawWeight;
    float normWeight;
    ColorWeight(RGBColor rgbColor, float rawWeight, float normWeight) {
      this.rgbColor = rgbColor;
      this.rawWeight = rawWeight;
      this.normWeight = normWeight;
    }
  }
}

class DotPainter extends Painter {
  Random rand;
  
  DotPainter(RGBColor backgroundColor, RGBColor[] colors, float colorScale) {
    this(backgroundColor, colors, colorScale, 255);
  }
  
  DotPainter(RGBColor backgroundColor, RGBColor[] colors, float colorScale,
                int colorMapSteps) {
    super(backgroundColor, colors, colorScale);
    rand = new Random();
  }
  
  void paint(PImage image, int[] data, int width, int height, float minVal, float range) {
    for (int i = 0; i < width*height; i++) {
      if (data[i] == 0) {
        image.pixels[i] = backgroundColor.getColor();
      } else {
        float alpha = min((data[i] - minVal)/range * colorScale, 1.0);
        if (rand.nextFloat() < alpha) {
          image.pixels[i] =  colors[0].getColor();
        } else {
          image.pixels[i] =  colors[1].getColor();
        }
      }
    }
  }
}
