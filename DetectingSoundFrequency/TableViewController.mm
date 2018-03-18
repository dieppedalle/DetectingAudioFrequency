//
//  TableViewController.m
//  DetectingSoundFrequency
//
//  Created by Gauthier Dieppedalle on 3/17/18.
//  Copyright © 2018 Mac. All rights reserved.
//

#import "TableViewController.h"

#import "mo_audio.h" //stuff that helps set up low-level audio
#import "FFTHelper.h"


#define SAMPLE_RATE 44100  //22050 //44100
#define FRAMESIZE  512
#define NUMCHANNELS 2

#define kOutputBus 0
#define kInputBus 1



/// Nyquist Maximum Frequency
const Float32 NyquistMaxFreq = SAMPLE_RATE/2.0;

/// caculates HZ value for specified index from a FFT bins vector
Float32 frequencyHerzValue(long frequencyIndex, long fftVectorSize, Float32 nyquistFrequency ) {
    return ((Float32)frequencyIndex/(Float32)fftVectorSize) * nyquistFrequency;
}



// The Main FFT Helper
FFTHelperRef *fftConverter = NULL;



//Accumulator Buffer=====================

const UInt32 accumulatorDataLenght = 131072;  //16384; //32768; 65536; 131072;
UInt32 accumulatorFillIndex = 0;
Float32 *dataAccumulator = nil;
static void initializeAccumulator() {
    dataAccumulator = (Float32*) malloc(sizeof(Float32)*accumulatorDataLenght);
    accumulatorFillIndex = 0;
}
static void destroyAccumulator() {
    if (dataAccumulator!=NULL) {
        free(dataAccumulator);
        dataAccumulator = NULL;
    }
    accumulatorFillIndex = 0;
}

static BOOL accumulateFrames(Float32 *frames, UInt32 lenght) { //returned YES if full, NO otherwise.
    //    float zero = 0.0;
    //    vDSP_vsmul(frames, 1, &zero, frames, 1, lenght);
    
    if (accumulatorFillIndex>=accumulatorDataLenght) { return YES; } else {
        memmove(dataAccumulator+accumulatorFillIndex, frames, sizeof(Float32)*lenght);
        accumulatorFillIndex = accumulatorFillIndex+lenght;
        if (accumulatorFillIndex>=accumulatorDataLenght) { return YES; }
    }
    return NO;
}

static void emptyAccumulator() {
    accumulatorFillIndex = 0;
    memset(dataAccumulator, 0, sizeof(Float32)*accumulatorDataLenght);
}
//=======================================


//==========================Window Buffer
const UInt32 windowLength = accumulatorDataLenght;
Float32 *windowBuffer= NULL;
//=======================================



/// max value from vector with value index (using Accelerate Framework)
static Float32 vectorMaxValueACC32_index(Float32 *vector, unsigned long size, long step, unsigned long *outIndex) {
    Float32 maxVal;
    vDSP_maxvi(vector, step, &maxVal, outIndex, size);
    return maxVal;
}




///returns HZ of the strongest frequency.
static Float32 strongestFrequencyHZ(Float32 *buffer, FFTHelperRef *fftHelper, UInt32 frameSize, Float32 *freqValue) {
    
    
    //the actual FFT happens here
    //****************************************************************************
    Float32 *fftData = computeFFT(fftHelper, buffer, frameSize);
    //****************************************************************************
    
    
    fftData[0] = 0.0;
    unsigned long length = frameSize/2.0;
    Float32 max = 0;
    unsigned long maxIndex = 0;
    max = vectorMaxValueACC32_index(fftData, length, 1, &maxIndex);
    if (freqValue!=NULL) { *freqValue = max; }
    Float32 HZ = frequencyHerzValue(maxIndex, length, NyquistMaxFreq);
    return HZ;
}



__weak UILabel *labelToUpdate = nil;
__weak UILabel *lettersToUpdate = nil;
__weak UILabel *adToUpdate = nil;

NSString* currentLetters = @"";
NSString* currentAdStr = @"";

NSString* convertFrequencyToLetter(Float32 frequency){
    if (abs(frequency - 18000) < 30){
        return @"A";
    }
    if (abs(frequency - 18075) < 30){
        return @"B";
    }
    if (abs(frequency - 18150) < 30){
        return @"C";
    }
    if (abs(frequency - 18225) < 30){
        return @"D";
    }
    if (abs(frequency - 18300) < 30){
        return @"E";
    }
    if (abs(frequency - 18375) < 30){
        return @"F";
    }
    if (abs(frequency - 18450) < 30){
        return @"G";
    }
    if (abs(frequency - 18525) < 30){
        return @"H";
    }
    if (abs(frequency - 18600) < 30){
        return @"I";
    }
    if (abs(frequency - 18675) < 30){
        return @"J";
    }
    if (abs(frequency - 18750) < 30){
        return @"K";
    }
    if (abs(frequency - 18825) < 30){
        return @"L";
    }
    if (abs(frequency - 18900) < 30){
        return @"M";
    }
    if (abs(frequency - 18975) < 30){
        return @"N";
    }
    if (abs(frequency - 19050) < 30){
        return @"O";
    }
    if (abs(frequency - 19125) < 30){
        return @"P";
    }
    if (abs(frequency - 19200) < 30){
        return @"Q";
    }
    if (abs(frequency - 19275) < 30){
        return @"R";
    }
    if (abs(frequency - 19350) < 30){
        return @"S";
    }
    if (abs(frequency - 19425) < 30){
        return @"T";
    }
    if (abs(frequency - 19500) < 30){
        return @"U";
    }
    if (abs(frequency - 19575) < 30){
        return @"V";
    }
    if (abs(frequency - 19650) < 30){
        return @"W";
    }
    if (abs(frequency - 19725) < 30){
        return @"X";
    }
    if (abs(frequency - 19800) < 30){
        return @"Y";
    }
    if (abs(frequency - 19875) < 30){
        return @"Z";
    }
    if (abs(frequency - 19950) < 30){
        return @"a";
    }
    return @"";
}

NSString* convertToAd(){
    if ([currentLetters isEqualToString:@"AG"]){
        return @"Use coupon code SUMMERSALE to get a free 🕶 when you buy any pair!";
    } else if ([currentLetters isEqualToString:@"AD"]){
        return @"It's time to upgrade your iPhone 📱!";
    } else if ([currentLetters isEqualToString:@"AJ"]){
        return @"Come check out our new summer brand of clothes 👕!";
    } else if ([currentLetters isEqualToString:@"AP"]){
        return @"Your friend John has played this arcade game last week 🕹!";
    } else if ([currentLetters isEqualToString:@"AK"]){
        return @"Get a free month of delivery if you buy the a box of 6 🍪!";
    } else if ([currentLetters isEqualToString:@"AU"]){
        return @"You could win a trip to France if you buy this 🌯!";
    } else if ([currentLetters isEqualToString:@"AA"]){
        return @"Thank you for shopping at Safeway! 👋";
    }
    return @"Use coupon code BIGMAC2018 for 20% off your next 🍔!";
}


#pragma mark MAIN CALLBACK
void AudioCallback( Float32 * buffer, UInt32 frameSize, void * userData )
{
    
    
    //take only data from 1 channel
    Float32 zero = 0.0;
    vDSP_vsadd(buffer, 2, &zero, buffer, 1, frameSize*NUMCHANNELS);
    
    
    
    if (accumulateFrames(buffer, frameSize)==YES) { //if full
        
        //windowing the time domain data before FFT (using Blackman Window)
        if (windowBuffer==NULL) { windowBuffer = (Float32*) malloc(sizeof(Float32)*windowLength); }
        vDSP_blkman_window(windowBuffer, windowLength, 0);
        vDSP_vmul(dataAccumulator, 1, windowBuffer, 1, dataAccumulator, 1, accumulatorDataLenght);
        //=========================================
        
        
        Float32 maxHZValue = 0;
        Float32 maxHZ = strongestFrequencyHZ(dataAccumulator, fftConverter, accumulatorDataLenght, &maxHZValue);
        
        NSLog(@" max HZ = %0.3f ", maxHZ);
        dispatch_async(dispatch_get_main_queue(), ^{ //update UI only on main thread
            NSString *currentLetter = convertFrequencyToLetter(maxHZ);
            NSString *toDisplayLetters;
            
            if (currentLetter.length == 0){
                toDisplayLetters = @"--";
                currentLetters = @"";
            } else{
                currentLetters = [currentLetters stringByAppendingString:currentLetter];
                int lengthDisplay = currentLetters.length;
                if (lengthDisplay > 2){
                    currentLetters = [currentLetters substringFromIndex:1];
                }
                
                toDisplayLetters = currentLetters;
                
                if (toDisplayLetters.length >= 2){
                    adToUpdate.text = convertToAd();
                }
            }
            
            
            lettersToUpdate.text = toDisplayLetters;
            labelToUpdate.text = [NSString stringWithFormat:@"%0.3f Hz",maxHZ];
        });
        
        emptyAccumulator(); //empty the accumulator when finished
    }
    memset(buffer, 0, sizeof(Float32)*frameSize*NUMCHANNELS);
}



@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    lettersToUpdate = lettersLabel;
    labelToUpdate = HZValueLabel;
    adToUpdate = adLabel;
    frequencyCard.backgroundColor=[UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:0.5];
    [frequencyCard.layer setCornerRadius:5.0f];
    [frequencyCard.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [frequencyCard.layer setBorderWidth:0.2f];
    [frequencyCard.layer setShadowColor:[UIColor colorWithRed:225.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0].CGColor];
    [frequencyCard.layer setShadowOpacity:1.0];
    [frequencyCard.layer setShadowRadius:5.0];
    [frequencyCard.layer setShadowOffset:CGSizeMake(5.0f, 5.0f)];
    
    
    categoryCard.backgroundColor=[UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:0.5];
    [categoryCard.layer setCornerRadius:5.0f];
    [categoryCard.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [categoryCard.layer setBorderWidth:0.2f];
    [categoryCard.layer setShadowColor:[UIColor colorWithRed:225.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0].CGColor];
    [categoryCard.layer setShadowOpacity:1.0];
    [categoryCard.layer setShadowRadius:5.0];
    [categoryCard.layer setShadowOffset:CGSizeMake(5.0f, 5.0f)];
    
    adCard.backgroundColor=[UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:0.5];
    [adCard.layer setCornerRadius:5.0f];
    [adCard.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [adCard.layer setBorderWidth:0.2f];
    [adCard.layer setShadowColor:[UIColor colorWithRed:225.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0].CGColor];
    [adCard.layer setShadowOpacity:1.0];
    [adCard.layer setShadowRadius:5.0];
    [adCard.layer setShadowOffset:CGSizeMake(5.0f, 5.0f)];
    
    
    //initialize stuff
    fftConverter = FFTHelperCreate(accumulatorDataLenght);
    initializeAccumulator();
    [self initMomuAudio];
    
}

-(void) viewWillAppear:(BOOL)animated {
    
    [self.navigationController.navigationBar setValue:@(YES) forKeyPath:@"hidesShadow"];
}

-(void) initMomuAudio {
    bool result = false;
    result = MoAudio::init( SAMPLE_RATE, FRAMESIZE, NUMCHANNELS, false);
    if (!result) { NSLog(@" MoAudio init ERROR"); }
    result = MoAudio::start( AudioCallback, NULL );
    if (!result) { NSLog(@" MoAudio start ERROR"); }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc {
    destroyAccumulator();
    FFTHelperRelease(fftConverter);
}


#pragma mark - Table view data source




@end
