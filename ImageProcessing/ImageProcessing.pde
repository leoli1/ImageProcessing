
class Kernel {
  float[][] weightMatrix;
  public Kernel(float[][] _weightMatrix) {
    this.weightMatrix = _weightMatrix;
    if (weightMatrix.length!=weightMatrix[0].length || weightMatrix.length%2==0) {
      println("Weight-matrix must be a square matrix");
      exit();
    }
    Normalize();
  }
 /* public Kernel(float[][] _weightMatrix, float factor) {
    this.weightMatrix = _weightMatrix;
    if (weightMatrix.length!=weightMatrix[0].length || weightMatrix.length%2==0) {
      println("Weight-matrix must be a square matrix");
      exit();
    }
    Mult(factor);
  }*/
  void Normalize(){
    float sum = 0;
    for (int i=0; i<weightMatrix.length; i++) {
      for (int j=0; j<weightMatrix[i].length; j++) {
       sum += weightMatrix[i][j];
      }
    }
    for (int i=0; i<weightMatrix.length; i++) {
      for (int j=0; j<weightMatrix[i].length; j++) {
        weightMatrix[i][j] = weightMatrix[i][j]/sum;
      }
    }
  }
  void Mult(float factor) {
    for (int i=0; i<weightMatrix.length; i++) {
      for (int j=0; j<weightMatrix[i].length; j++) {
        weightMatrix[i][j] = weightMatrix[i][j]*factor;
      }
    }
  }

  int getSize() {
    return weightMatrix.length;
  }

  float ConvolutionAtCenter(float[][] matrix, boolean reversed) {
    if (matrix.length!=weightMatrix.length || matrix[0].length!=weightMatrix[0].length) {
      println("Input-matrix must have the same size as the weight-matrix");
      exit();
      return -1;
    }
    float sum = 0;
    for (int i=0; i<matrix.length; i++) {
      for (int j=0; j<matrix[i].length; j++) {
        int i0 = reversed ? matrix.length-1-i : i;
        int j0 = reversed ? matrix[0].length-1-j : j;
        sum += matrix[i][j]*weightMatrix[i0][j0];
      }
    }
    return sum;
  }
  float ConvolutionAtCenter(float[][] matrix) {
    return ConvolutionAtCenter(matrix, false);
  }
}


PImage img;
PImage changedImage;
String imgName = "flower.png";
void setup() {
  img = loadImage(imgName);
  changedImage = img.copy();
  surface.setSize(img.width, img.height);
  PerformConvolution(new Kernel(new float[][]{
    {1, 2, 1}, 
    {2, 4, 2}, 
    {1, 2, 1}
    }));
}
color getColorAtPixel(int x, int y) {
  if (x>=0 && x<img.width && y>=0 && y<img.height)
    return img.get(x, y);
  return color(0);
}
void PerformConvolution(Kernel kernel) {
  int dx = kernel.getSize()/2;

  float[][] redValues = new float[kernel.getSize()][kernel.getSize()];
  float[][] greenValues = new float[kernel.getSize()][kernel.getSize()];
  float[][] blueValues = new float[kernel.getSize()][kernel.getSize()];
  for (int x = 0; x<img.width; x++) {
    for (int y = 0; y<img.height; y++) {
      for (int x0 = x-dx; x0<=x+dx; x0++) {
        for (int y0= y-dx; y0<=y+dx; y0++) {
          redValues[x0+dx-x][y0+dx-y] = red(getColorAtPixel(x0,y0));
          greenValues[x0+dx-x][y0+dx-y] = green(getColorAtPixel(x0,y0));
          blueValues[x0+dx-x][y0+dx-y] = blue(getColorAtPixel(x0,y0));
        }
      }
      float r = kernel.ConvolutionAtCenter(redValues);
      float g = kernel.ConvolutionAtCenter(greenValues);
      float b = kernel.ConvolutionAtCenter(blueValues);
      changedImage.set(x,y,color(r,g,b));
    }
  }
}
void draw() {
  background(0);
  image(changedImage, 0, 0);
}