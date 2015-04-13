import fontastic.*; Fontastic f; import gab.opencv.*; OpenCV opencv;
import themidibus.*; MidiBus myBus; int[] slider = {10 ,40 ,20 ,0 ,20 ,20 ,20 ,20}; int[] knob = {0 ,0 ,0 ,0 ,0 ,0 ,0 ,0}; int[] button = {0 ,0 ,0 ,0 ,0 ,0 ,0 ,0};
char[] letters = {'a','z','e','r','t','y','u','i','o','p','q','s','d','f','g','h','j','k','l','m','w','x','c','v','b','n','A','Z','E','R','T','Y','U','I','O','P','Q','S','D','F'};//,'G','H','J','K','L','M','W','X','C','V','B','N','1','2','3','4','5','6','7','8','9','0','\\',';',':','!','?','.','/','§','%','ù','µ','*','£','$','¨','^','°','+','&','é','\"','\'','(','-','è','_','ç','à',')','=','²','ë'};
String previewTxt = "gatô";
PFont iniFont; PImage src ; ArrayList<Contour> contours; 
boolean printing=false, analysing=false, editTxt=false, invert=false;
int W = 400;

void setup() {
  size(W, W);   myBus = new MidiBus(this, 0,1);

  iniFont = createFont("Fedra-Serif-A-Pro-Book.ttf",W*3/4);  // INPUT FONT
  textAlign(CENTER, CENTER);
  f = new Fontastic(this, "test B");                        // OUTPUT FONT
  f.setAuthor("FontBuilder_Grey-Scott-model");  
  f.setFontFamilyName("GreyScott");
  f.setVersion("0.1");  
  for (char c : letters) { f.addGlyph(c); }
}

void draw() {
  int fontSize = constrain( W*3/4-slider[2], 1, 900);   
  int printSize = 512/fontSize *2 ;

  for (char c : letters) { //---------------------DRAW-LETTER------
    textFont(iniFont, fontSize); background(0); fill(255); 

    if (printing) { textAlign(LEFT); text(c+"", W/4, W*3/4 ); }
    else { text( previewTxt, 0,0,W,W);} 
    noFill();
    if (invert) filter(INVERT); 
    //--------------------------------------------ALGORITHME------
     //sand();    // algorithme du tas de sable ou Abelian sandpile model
    turing();     // algoritme de réaction / diffusion
   
    //--------------------------------------------VECTORIZE---------
    if(printing || analysing) { 
      save("data/tempScreen.tiff");      src = loadImage("data/tempScreen.tiff");
      opencv = new OpenCV(this, src );   opencv.setROI(10,10, width-20, height-20); 
      if (slider[3] > 0) opencv.blur( slider[3] );  slider[3] = constrain(slider[3], 0, 40);  // blur
      opencv.threshold(slider[1]);  slider[1] = constrain(slider[1], 0, 255);                 // threshold
      contours = opencv.findContours();  println(c+" : " + contours.size() + " contours");

      for (Contour contour : contours) {
          PVector[] points = new PVector[0]; stroke(255,0,0);

beginShape();  // getConvexHull() 
        knob[0]=constrain(knob[0], 0, 50);
        contour.setPolygonApproximationFactor(knob[0]);
          for (PVector coords : contour.getPolygonApproximation().getPoints()) {
            if (contour.getPoints().get(0).x != 1.0 && contour.getPoints().get(0).x != 1.0 ) { // delete error contour
              if(printing) points = (PVector[]) append(points, new PVector(( coords.x-W/4+10)*printSize, W-(coords.y-W/4+10)*printSize));
              vertex(coords.x+10, coords.y+10);  
            }
          }
endShape();
          if(printing){ f.getGlyph(c).addContour(points); f.getGlyph(c).setAdvanceWidth( (int)textWidth(c)*printSize ); }
        }
    }
    if(!printing) break;
  }
  if(printing){ f.buildFont(); f.cleanup(); printing=false; noLoop();}
}

///////////////////////////////////////////////////////////////////////////////////// CONTROLS
void keyPressed() {
  if (key == ' ') {       printing  = true; frame.setTitle("#### building TTF ####" ); }
  if (key == 'w')         analysing = !analysing ;
  if (key == 'x')         invert = !invert ;
  if (keyCode == CONTROL) editTxt   = !editTxt ;

  if (key == 't') knob[0]++; 
  if (key == 'g') knob[0]--; 

  char[] keys1 = {'a','z','e','r','u','i','o','p'} ;      // assign keyboard to slider[]
  char[] keys2 = {'q','s','d','f','j','k','l','m'} ;
  int i=0;  for(char k : keys1){  if (key == k) slider[i]++; constrain(slider[i], -20, 256);  i++; }
  i=0;      for(char k : keys2){  if (key == k) slider[i]--; constrain(slider[i], -20, 256);  i++; }

  if(editTxt){    // edit text preview
    if (keyCode == BACKSPACE ) {
      if (previewTxt.length() > 0) {
        previewTxt = previewTxt.substring(0, previewTxt.length()-1);
      }
    } else if (keyCode != SHIFT && keyCode != CONTROL && keyCode != ALT) {
      previewTxt = previewTxt + key;
    }
    frame.setTitle("#### Text edit mode ####" );
  }else{ frame.setTitle(slider[4]+"|"+slider[5]+"|"+slider[6]+"|"+slider[7]+" fps : "+int(frameRate)); }
}
void controllerChange(int channel, int number, int value) {
  if(number<=7)  slider[number] = (int)map(value,0,127,0,255);
  if(number>=16 && number<=23) { knob[number-16] = (int)map(value,0,127,0,255); analysing=true;}
  if(number>=32 && number<=39) button[number-32] = -1 ;  if(number>=48 && number<=55) button[number-48] = 0 ;   if(number>=64 && number<=71) button[number-64] = 1 ; 
}


///////////////////////////////////////////////////////////////////////////////////// SAND

int[] pxl; int off, poff;
void sand(){

  loadPixels();                   
    pxl = new int[width*height];
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
          pxl[i*height+j] = int(map(brightness(pixels[i*height+j]),0,255,slider[6],0) ) ;
      }
    } updatePixels();


  for (int iterations=0 ; iterations < slider[0]*2 ; iterations++){ 
    loadPixels();
      for (int i = 1; i < width-2; i++) {
        for (int j = 1; j < height-2; j++) {
          off = i*height+j;

          if ( pxl[off] > 4){
            pxl[off] -= 4;
            pxl [off +1]++;
            pxl [off -1]++;
            pxl [off +height]++;
            pxl [off -height]++;
          } 

          poff = pxl[off]*slider[7]*5 ;
          pixels[off] =  poff << 8 | poff << 16 | poff << 32 ;      //  pixels[off] = color(0,0,pxl[off]) ; 
            /*if (pxl[off]==0) pixels[off] = color(0) ;
            if (pxl[off]==1) pixels[off] = color(0) ;
            if (pxl[off]==2) pixels[off] = color(0,0,255) ;
            if (pxl[off]==3) pixels[off] = color(0,0,255) ;
            if (pxl[off]==4) pixels[off] = color(255) ;
            if (pxl[off] >4) pixels[off] = color(255) ;*/
        }  
      }
    updatePixels();
  }
}

//////////////////////////////////////////////// reaction - diffusion /////////////// TURING

int init = 1, N = W;
int left, right, up, down;  double uvv, u, v;
double diffU, diffV, F, K; int[][] offset = new int[N][2];
double[][] U = new double[N][N];  double[][] V = new double[N][N];
double[][] dU = new double[N][N]; double[][] dV = new double[N][N];

void turing() {
  generateInitialState();

  for (int i = 1; i < N-1; i++) {  //Set up offsets
    offset[i][0] = i-1;
    offset[i][1] = i+1;
  }
  offset[0][0] = N-1;   offset[0][1] = 1;  
  offset[N-1][0] = N-2; offset[N-1][1] = 0;

  diffU = map(slider[4],0,127,0,0.1); diffV = map(slider[5],0,127,0,0.1); F = map(slider[6],0,127,0,0.1); K = map(slider[7],0,127,0,0.1);
  diffU = 0.16; diffV = 0.08; 

  for (int n = 0; n<slider[0]*4+1; n++){
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
         
        u = U[i][j];  
        v = V[i][j]; 
        left  = offset[i][0];
        right = offset[i][1];
        up    = offset[j][0];
        down  = offset[j][1];
         
        uvv = u*v*v;    
        double lapU = (U[left][j] + U[right][j] + U[i][up] + U[i][down] - 4*u);
        double lapV = (V[left][j] + V[right][j] + V[i][up] + V[i][down] - 4*v);
         
        dU[i][j] = diffU*lapU  - uvv + F*(1 - u);
        dV[i][j] = diffV*lapV + uvv - (K+F)*v;
      }
    }
              
    for (int i= 0; i < N; i++) {
      for (int j = 0; j < N; j++){
          U[i][j] += dU[i][j];
          V[i][j] += dV[i][j];
      }
    }
  }

  loadPixels();
    for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
        pixels[i*N+j] = color( (float)(U[i][j]*255) ) ;
      }
    }
  updatePixels();
}
 
void generateInitialState() {
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      U[i][j] = 1.0;
      V[i][j] = 0.0;
    }
  }
  loadPixels();
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {    
      switch (init) {
        case 0:    
          U[i][j] = 0.5*(1 + random(-1, 1));
          V[i][j] = 0.25*( 1 + random(-1, 1));
        break;
        case 1:
          U[i][j] = map(brightness(pixels[i*N+j]),0,255,1,0.5);
          V[i][j] = map(brightness(pixels[i*N+j]),0,255,0,0.25);
        break;
      }
    }
  }  
  updatePixels();
}
 

/* KEYBOARD DOCUMENTATION

sliders :    
  + - 
  A Q  TIME  - temps d'action de l'algorithme
  Z S  SEUIL - valeur de gris, seuil de la vectorisation
  E D  SIZE  - taille de la pixellisation des lettres
  R F  BLUR  - lisse la vectorisation
  T G  RESOL - réduit les point de vecteurs
 
  U J  PARAM 4 |
  I K  PARAM 3 | Paramètres
  O L  PARAM 2 | de l'algorithme
  P M  PARAM 1 |

active/desactive :
  W   - la prévisualisation de la vectorisation
  X   - l'inversion des valeurs de gris des pixels
  C
  V
  B
  N
 CTRL - l'édition du text de prévisualisation au clavier

SPACE - exporte la fonte TTF

*/