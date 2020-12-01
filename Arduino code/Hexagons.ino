#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <FastLED.h>

// LED stuff
#define NUM_LEDS 270
#define DATA_PIN 5
CRGB leds[NUM_LEDS];
//enum Triangles {
//  One = 0,
//  Two = 15,
//  Three = 30,
//  Four = 45,
//  Five = 60,
//  Six = 75,
//  Seven = 90,
//  Eight = 105,
//  Nine = 120,
//  Ten = 135,
//  Eleven = 150,
//  Twelve = 165,
//  Thirteen = 180,
//  Fourteen = 195,
//  Fifteen = 210,
//  Sixteen = 225,
//  Seventeen = 240,
//  Eighteen = 255
//}

// UUID for device
#define SERVICE_UUID "96f5d9aa-b11f-40ac-a3d9-59f85535c316"
#define CHARACTERISTIC_UUID "93190059-2838-4f05-ae60-1fcc5e1fbc13"

// Color stuff
String colorString = "";
bool rainbowStatus = false;
bool _BLEClientConnected = false;
bool fireStatus = false;
bool bouncingBallStatus = false;
bool pacificaStatus = false;
bool rainbowFade = false;

int brightness = 64;
int thishue = 0;


void fill_rainbow_custom(struct CRGB * pFirstLED, int numToFill, uint8_t initialhue, uint8_t deltahue)
{
  CHSV hsv;
  hsv.hue = initialhue;
  hsv.val = brightness;
  hsv.sat = 255;
  for (int i = 0; i< numToFill; i++) {
    pFirstLED[i] = hsv;
    hsv.hue += deltahue;
  }
}

// Callbacks for Server
class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    _BLEClientConnected = true;
  };

  void onDisconnect(BLEServer* pServer) {
    _BLEClientConnected = false;
  }
};

class MyCharacteristicCallbacks: public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    std::string value = pCharacteristic->getValue();

    String valueString = "";
    if (value.length() > 0) {
      Serial.println("********");
      Serial.print("New Value: ");
      for (int i=0; i<value.length(); i++) {
        Serial.print(value[i]);
        valueString += value[i];
      }
//      Serial.print("     " + value.length());
//      Serial.println();
//      Serial.println("0x" + valueString.substring(10,16));
      Serial.println();
      Serial.println("********");
    }

//    if(valueString == "ON") {
//      Serial.println("Turning ON LED");
//      fill_solid(leds, NUM_LEDS, CRGB::Red);
//      FastLED.show();
//    }

    if(valueString == "OFF") {
      Serial.println("Turning OFF LED");
      FastLED.clear(true);
      fill_solid(leds, NUM_LEDS, 0);
      
    }
    
    if(valueString.startsWith("Color")){
      FastLED.clear(true);
      String colorString = "0x" + valueString.substring(10,16);
      long color = strtol(colorString.c_str(), NULL, 0);
      colorString = color;
      fill_solid(leds, NUM_LEDS, color);
      FastLED.show();
    }

    if(valueString.startsWith("AColor")){
      FastLED.clear(true);
      String colorString1 = "0x" + valueString.substring(11,17);
      String colorString2 = "0x" + valueString.substring(28,34);
//      Serial.println(colorString1);
//      Serial.println(colorString2);
      long color1 = strtol(colorString1.c_str(), NULL, 0);
      long color2 = strtol(colorString2.c_str(), NULL, 0);
      for (int i =0; i<60; ++i) {
        leds[i] = color1;
      }
      for (int i =60; i<75; ++i) {
        leds[i] = color2;
      }
      for (int i =75; i<135; ++i) {
        leds[i] = color1;
      }
      for (int i =135; i<180; ++i) {
        leds[i] = color2;
      }
      for (int i =180; i<225; ++i) {
        leds[i] = color1;
      }
      for (int i =225; i<270; ++i) {
        leds[i] = color2;
      }
//      fill_solid(leds, NUM_LEDS, color);
      FastLED.show();
    }

    if (valueString.startsWith("RainbowFade")) {
      FastLED.clear(true);
      rainbowFade = true;
    }
    else {
      rainbowFade = false;
    }
     if(valueString.startsWith("Rainbow")){
      FastLED.clear(true);
      fill_rainbow_custom(leds, NUM_LEDS, 0, 5);
      FastLED.show();
//        rainbowStatus = true;
    }
    else {
        rainbowStatus = false;
    }
     if(valueString.startsWith("Restart")){
       FastLED.clear(true);
       ESP.restart();
    }
    if(valueString.startsWith("Brightness")){
       int brightnessValue = valueString.substring(11).toInt();
       brightness = brightnessValue;
       FastLED.setBrightness(brightness);
       FastLED.show();
    }
    if (valueString.startsWith("Fire")){
      FastLED.clear(true);
      fireStatus = true;
    }
    else {
      fireStatus = false;
    }
    if (valueString.startsWith("BouncingBalls")){
      FastLED.clear(true);
      bouncingBallStatus = true;
    }
    else {
      bouncingBallStatus = false;
    }
    if (valueString.startsWith("Pacifica")){
      FastLED.clear(true);
      pacificaStatus = true;
    }
    else {
      pacificaStatus = false;
    }
    if (valueString.startsWith("RainbowAnimation")){
      FastLED.clear(true);
      rainbowStatus = true;
    }
    else {
      rainbowStatus = false;
    }
  }
};

void setup() {
  Serial.begin(115200);
  Serial.println("Starting BLE work");

  FastLED.addLeds<WS2812B, DATA_PIN, GRB>(leds, NUM_LEDS).setCorrection(TypicalLEDStrip);
  FastLED.setMaxPowerInVoltsAndMilliamps(5, 15000);
  FastLED.setBrightness(brightness);

  BLEDevice::init("LED Strip");
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService *pService = pServer->createService(SERVICE_UUID);

  BLECharacteristic *pCharacteristic = pService->createCharacteristic(
                                         CHARACTERISTIC_UUID,
                                         BLECharacteristic::PROPERTY_READ |
                                         BLECharacteristic::PROPERTY_WRITE
                                       );
 
  pCharacteristic->setCallbacks(new MyCharacteristicCallbacks());

  pCharacteristic->setValue("Hello World");
  
  pService->start();

  BLEAdvertising *pAdvertising = pServer->getAdvertising();
  pAdvertising->start();
  delay(1000);

}

void loop() {
  if (_BLEClientConnected) {
    if (rainbowStatus) {
//      rainbow_beat(30);
//      rainbowCycle(10);
      EVERY_N_MILLISECONDS(150) {
        rainbow_beat();
      }
    }
    else if (fireStatus) {
      Fire(55,120,15);
    }
    else if (bouncingBallStatus) {
      byte colors[6][3] = { {0xff, 0, 0},
                            {0, 0xff, 0},
                            {0, 0, 0xff},
                            {0xff, 0xff, 0},
                            {0xff, 0, 0xff},
                            {0, 0xff, 0xff} };
      BouncingBalls(6, colors);
    }
    else if (pacificaStatus) {
      EVERY_N_MILLISECONDS(20) {
        pacifica_loop();
        FastLED.show();
      }
    }
    else if (rainbowFade) {
      EVERY_N_MILLISECONDS(150) {
        rainbow_fade_loop();
      }
    }
  }

}

void rainbow_beat() {
  uint8_t beatA = beatsin8(17,0,255);
  uint8_t beatB = beatsin8(13,0,255);
  fill_rainbow_custom(leds, NUM_LEDS, (beatA+beatB)/2, 8);
  FastLED.show();
}

void rainbow_fade_loop() {
  fill_solid(leds, NUM_LEDS, CHSV(thishue, brightness, 255));
  thishue += 5;
  if (thishue > 255) {
    thishue = 0;
  }
  FastLED.show();
}
void Fire(int Cooling, int Sparking, int SpeedDelay) {
  static byte heat[NUM_LEDS];
  int cooldown;
 
  // Step 1.  Cool down every cell a little
  for( int i = 0; i < NUM_LEDS; i++) {
    cooldown = random(0, ((Cooling * 10) / NUM_LEDS) + 2);
   
    if(cooldown>heat[i]) {
      heat[i]=0;
    } else {
      heat[i]=heat[i]-cooldown;
    }
  }
 
  // Step 2.  Heat from each cell drifts 'up' and diffuses a little
  for( int k= NUM_LEDS - 1; k >= 2; k--) {
    heat[k] = (heat[k - 1] + heat[k - 2] + heat[k - 2]) / 3;
  }
   
  // Step 3.  Randomly ignite new 'sparks' near the bottom
  if( random(255) < Sparking ) {
    int y = random(7);
    heat[y] = heat[y] + random(160,255);
    //heat[y] = random(160,255);
  }

  // Step 4.  Convert heat to LED colors
  for( int j = 0; j < NUM_LEDS; j++) {
    setPixelHeatColor(j, heat[j] );
  }

  FastLED.show();
  delay(SpeedDelay);
}

void setPixelHeatColor (int Pixel, byte temperature) {
  // Scale 'heat' down from 0-255 to 0-191
  byte t192 = round((temperature/255.0)*191);
 
  // calculate ramp up from
  byte heatramp = t192 & 0x3F; // 0..63
  heatramp <<= 2; // scale up to 0..252
 
  // figure out which third of the spectrum we're in:
  if( t192 > 0x80) {                     // hottest
    setPixel(Pixel, 255, 255, heatramp);
  } else if( t192 > 0x40 ) {             // middle
    setPixel(Pixel, 255, heatramp, 0);
  } else {                               // coolest
    setPixel(Pixel, heatramp, 0, 0);
  }
}

void setPixel(int Pixel, byte red, byte green, byte blue) {
   leds[Pixel].r = red;
   leds[Pixel].g = green;
   leds[Pixel].b = blue;
}
void setAll(byte red, byte green, byte blue) {
  for(int i = 0; i < NUM_LEDS; i++ ) {
    setPixel(i, red, green, blue);
  }
}
void BouncingBalls(int BallCount, byte colors[][3]) {
  float Gravity = -9.81;
  int StartHeight = 1;
 
  float Height[BallCount];
  float ImpactVelocityStart = sqrt( -2 * Gravity * StartHeight );
  float ImpactVelocity[BallCount];
  float TimeSinceLastBounce[BallCount];
  int   Position[BallCount];
  long  ClockTimeSinceLastBounce[BallCount];
  float Dampening[BallCount];
 
  for (int i = 0 ; i < BallCount ; i++) {  
    ClockTimeSinceLastBounce[i] = millis();
    Height[i] = StartHeight;
    Position[i] = 0;
    ImpactVelocity[i] = ImpactVelocityStart;
    TimeSinceLastBounce[i] = 0;
    Dampening[i] = 0.90 - float(i)/pow(BallCount,2);
  }

  while (bouncingBallStatus) {
    for (int i = 0 ; i < BallCount ; i++) {
      TimeSinceLastBounce[i] =  millis() - ClockTimeSinceLastBounce[i];
      Height[i] = 0.5 * Gravity * pow( TimeSinceLastBounce[i]/1000 , 2.0 ) + ImpactVelocity[i] * TimeSinceLastBounce[i]/1000;
 
      if ( Height[i] < 0 ) {                      
        Height[i] = 0;
        ImpactVelocity[i] = Dampening[i] * ImpactVelocity[i];
        ClockTimeSinceLastBounce[i] = millis();
 
        if ( ImpactVelocity[i] < 0.01 ) {
          ImpactVelocity[i] = ImpactVelocityStart;
        }
      }
      Position[i] = round( Height[i] * (NUM_LEDS - 1) / StartHeight);
    }
 
    for (int i = 0 ; i < BallCount ; i++) {
      setPixel(Position[i],colors[i][0],colors[i][1],colors[i][2]);
    }
   
    FastLED.show();
    delay(20);
    FastLED.clear(true);
  }
}

CRGBPalette16 pacifica_palette_1 = 
    { 0x000507, 0x000409, 0x00030B, 0x00030D, 0x000210, 0x000212, 0x000114, 0x000117, 
      0x000019, 0x00001C, 0x000026, 0x000031, 0x00003B, 0x000046, 0x14554B, 0x28AA50 };
CRGBPalette16 pacifica_palette_2 = 
    { 0x000507, 0x000409, 0x00030B, 0x00030D, 0x000210, 0x000212, 0x000114, 0x000117, 
      0x000019, 0x00001C, 0x000026, 0x000031, 0x00003B, 0x000046, 0x0C5F52, 0x19BE5F };
CRGBPalette16 pacifica_palette_3 = 
    { 0x000208, 0x00030E, 0x000514, 0x00061A, 0x000820, 0x000927, 0x000B2D, 0x000C33, 
      0x000E39, 0x001040, 0x001450, 0x001860, 0x001C70, 0x002080, 0x1040BF, 0x2060FF };

void pacifica_loop(){
  // Increment the four "color index start" counters, one for each wave layer.
  // Each is incremented at a different speed, and the speeds vary over time.
  static uint16_t sCIStart1, sCIStart2, sCIStart3, sCIStart4;
  static uint32_t sLastms = 0;
  uint32_t ms = GET_MILLIS();
  uint32_t deltams = ms - sLastms;
  sLastms = ms;
  uint16_t speedfactor1 = beatsin16(3, 179, 269);
  uint16_t speedfactor2 = beatsin16(4, 179, 269);
  uint32_t deltams1 = (deltams * speedfactor1) / 256;
  uint32_t deltams2 = (deltams * speedfactor2) / 256;
  uint32_t deltams21 = (deltams1 + deltams2) / 2;
  sCIStart1 += (deltams1 * beatsin88(1011,10,13));
  sCIStart2 -= (deltams21 * beatsin88(777,8,11));
  sCIStart3 -= (deltams1 * beatsin88(501,5,7));
  sCIStart4 -= (deltams2 * beatsin88(257,4,6));

  // Clear out the LED array to a dim background blue-green
  fill_solid( leds, NUM_LEDS, CRGB( 2, 6, 10));

  // Render each of four layers, with different scales and speeds, that vary over time
  pacifica_one_layer( pacifica_palette_1, sCIStart1, beatsin16( 3, 11 * 256, 14 * 256), beatsin8( 10, 70, 130), 0-beat16( 301) );
  pacifica_one_layer( pacifica_palette_2, sCIStart2, beatsin16( 4,  6 * 256,  9 * 256), beatsin8( 17, 40,  80), beat16( 401) );
  pacifica_one_layer( pacifica_palette_3, sCIStart3, 6 * 256, beatsin8( 9, 10,38), 0-beat16(503));
  pacifica_one_layer( pacifica_palette_3, sCIStart4, 5 * 256, beatsin8( 8, 10,28), beat16(601));

  // Add brighter 'whitecaps' where the waves lines up more
  pacifica_add_whitecaps();

  // Deepen the blues and greens a bit
  pacifica_deepen_colors();
}

// Add one layer of waves into the led array
void pacifica_one_layer( CRGBPalette16& p, uint16_t cistart, uint16_t wavescale, uint8_t bri, uint16_t ioff){
  uint16_t ci = cistart;
  uint16_t waveangle = ioff;
  uint16_t wavescale_half = (wavescale / 2) + 20;
  for( uint16_t i = 0; i < NUM_LEDS; i++) {
    waveangle += 250;
    uint16_t s16 = sin16( waveangle ) + 32768;
    uint16_t cs = scale16( s16 , wavescale_half ) + wavescale_half;
    ci += cs;
    uint16_t sindex16 = sin16( ci) + 32768;
    uint8_t sindex8 = scale16( sindex16, 240);
    CRGB c = ColorFromPalette( p, sindex8, bri, LINEARBLEND);
    leds[i] += c;
  }
}

// Add extra 'white' to areas where the four layers of light have lined up brightly
void pacifica_add_whitecaps(){
  uint8_t basethreshold = beatsin8( 9, 55, 65);
  uint8_t wave = beat8( 7 );
  
  for( uint16_t i = 0; i < NUM_LEDS; i++) {
    uint8_t threshold = scale8( sin8( wave), 20) + basethreshold;
    wave += 7;
    uint8_t l = leds[i].getAverageLight();
    if( l > threshold) {
      uint8_t overage = l - threshold;
      uint8_t overage2 = qadd8( overage, overage);
      leds[i] += CRGB( overage, overage2, qadd8( overage2, overage2));
    }
  }
}

// Deepen the blues and greens
void pacifica_deepen_colors(){
  for( uint16_t i = 0; i < NUM_LEDS; i++) {
    leds[i].blue = scale8( leds[i].blue,  145); 
    leds[i].green= scale8( leds[i].green, 200); 
    leds[i] |= CRGB( 2, 5, 7);
  }
}
void rainbowCycle(int SpeedDelay) {
  byte *c;
  uint16_t i, j=0;
  while (rainbowStatus) {
    for(i=0; i< NUM_LEDS; i++) {
      c=Wheel(((i * 256 / NUM_LEDS) + j) & 255);
      setPixel(i, *c, *(c+1), *(c+2));
    }
    FastLED.show();
    delay(SpeedDelay);
    j++;
  }
}

byte * Wheel(byte WheelPos) {
  static byte c[3];
 
  if(WheelPos < 85) {
   c[0]=WheelPos * 3;
   c[1]=255 - WheelPos * 3;
   c[2]=0;
  } else if(WheelPos < 170) {
   WheelPos -= 85;
   c[0]=255 - WheelPos * 3;
   c[1]=0;
   c[2]=WheelPos * 3;
  } else {
   WheelPos -= 170;
   c[0]=0;
   c[1]=WheelPos * 3;
   c[2]=255 - WheelPos * 3;
  }

  return c;
}
