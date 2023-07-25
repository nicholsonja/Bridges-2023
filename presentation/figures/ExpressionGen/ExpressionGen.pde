String imageFile;
Example example;

int imageSize = 1000;
float step;
boolean keepOpen;
boolean doExample39 = false;

ShapeImageApplet shapeImageApplet;

void setup() {
  if (args != null) {
    keepOpen=false;
    imageFile = args[0];
    if (imageFile.equals("example_27")) {
      example = new Example_27(imageSize);
    } else if (imageFile.equals("example_29")) {
      example = new Example_29(imageSize);
    } else if (imageFile.equals("example_31")) {
      example = new Example_31(imageSize);
    } else if (imageFile.equals("example_33")) {
      example = new Example_33(imageSize); 
    } else if (imageFile.equals("example_35")) {
      example = new Example_35(imageSize);
    } else if (imageFile.equals("example_37")) {
      example = new Example_37(imageSize);
    } else if (imageFile.equals("example_39")) {
      doExample39 = true;
    } else {
      throw new UnsupportedOperationException("No example code for \"" + imageFile + "\"");
    }
  } else {
    keepOpen=true;
    println("WARNING: missing example argument");
    imageFile = "example_27";
    example = new Example_27(imageSize);
  }
  
  if (!doExample39) {
    step = 2*PI/example.getNumSteps();
    
    shapeImageApplet = new ShapeImageApplet(example.getName(),
                                              500, 500, example.getImageWidth(), example.getImageHeight(), 
                                              example.getRenderNumberOfSegments(),
                                              example.getPainter(), true,
                                              example.getConstantExtant());
  }
}


void draw() {
  if (doExample39) {
     makeExample39();
  } else {
     makeImage();
  }
   
  if (keepOpen) {
    noLoop();
  } else {
    delay(3000);
    exit();
  }
  
}

void makeImage() {
  int pctDone = -1;
  float currentTheta = 0;
  
  while (currentTheta < 2 * PI) {
    int percent = (int)(currentTheta/(2 * PI) * 100);
    if (percent != pctDone) {
      println("Prerender: " + percent + "% done");
      pctDone = percent;
    }
   
    ThetaResult thetaResult = example.process(currentTheta);
    shapeImageApplet.addShape(thetaResult.result); 
    currentTheta += step;
  }
  
  print("--- Done with prerender --- ");
  shapeImageApplet.render();
  while (shapeImageApplet.doRender) {
    delay(1000);
  }
}

void makeExample39() {
  File outputFolder = new File(new File(sketchPath(), ".."), "39_tmp");
  if (!outputFolder.exists()) {
    outputFolder.mkdir();
  }
  
  for (int i = 2; i <= 4096; i *= 2) {
    example = new Example_39(imageSize, i);
 
    step = 2*PI/example.getNumSteps();
      
    shapeImageApplet = new ShapeImageApplet(example.getName(),
                                                500, 500, example.getImageWidth(), example.getImageHeight(), 
                                                example.getRenderNumberOfSegments(),
                                                example.getPainter(), true,
                                                example.getConstantExtant());
    makeImage();
    
    try {
      File imageFile = new File(sketchPath(), "example_39.png");
      File dest = new File(outputFolder, String.format("example_39_%05d.png", i));
      java.nio.file.Files.copy(imageFile.toPath(), dest.toPath());
    } catch (IOException e) {
      println("Error");
      println(e);
      return;
    }
    
  }
}
