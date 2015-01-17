//
//  ViewController.m
//  Home Gym
//
//  Created by Jason Scharff on 1/16/15.
//
//

#import "ViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import <Spotify/Spotify.h>
#import "AppDelegate.h"

@import CoreMotion;

@interface ViewController ()

@property (nonatomic, strong) CMPedometer *counter;
@property(nonatomic, strong) NSTimer *timer;


@property (nonatomic, readwrite) SPTAudioStreamingController *player;




@end

@implementation ViewController


static NSString * const kClientId = @"2c2e95538e2d46a19ba2cdd910883947";
static NSString * const kCallbackURL = @"jockulus://callback";
static NSString * const kTokenSwapServiceURL = @"http://localhost:1234/swap";

- (void)viewDidLoad {
     [super viewDidLoad];
    [self prepNavBar];
    
//    _timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(getNumberOfSteps) userInfo:nil repeats:YES];
    NSLog(@"HERE:");
     AppDelegate *delegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self playUsingSession:delegate.session];
    

    
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}





-(void)getNumberOfSteps
{
    NSDate *startDate = [[NSDate date] dateByAddingTimeInterval:-5];
    
    self.counter = [[CMPedometer alloc] init];
    
    [self.counter startPedometerUpdatesFromDate:startDate withHandler:^(CMPedometerData *pedometerData, NSError *error) {
        
    }];
    
    NSDate *endDate = [NSDate date];
    
    [_counter queryPedometerDataFromDate:startDate toDate:endDate withHandler:^(CMPedometerData *pedometerData, NSError *error)
     {
         if (error)
         {
             NSLog(@"%@", error);
         }
         else
         {
       
             NSNumber *stepCount = [[NSNumber alloc] initWithInt:(pedometerData.numberOfSteps.intValue * 20)];
             NSLog(@"%@", stepCount);
             [self sendToNetwork:stepCount];
             
         }
     }];
    
    
    
    
}



-(BOOL)sendToNetwork : (NSNumber*) steps
{
    __block BOOL toReturn;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"bpm": steps};
    [manager POST:@"http://pennapps.gomurmur.com/get_songs.php" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        toReturn = true;
//        NSLog(@"JSON: %@", responseObject);
        NSLog(@"Here");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        toReturn = false;
    }];

    return toReturn;
}



-(void)prepNavBar
{
    
    UIColor *color = [self colorWithHexString:@"ffffff"];
    self.navigationController.navigationBar.tintColor = color;
    
    
    
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    color,NSForegroundColorAttributeName,
                                    color,NSBackgroundColorAttributeName,[UIFont fontWithName:@"Avenir-Light" size:25.0f],NSFontAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    
    
    
    self.navigationController.navigationBar.barTintColor = [self colorWithHexString:@"c0392b"];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = @"Jockulus";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}




-(void)playUsingSession:(SPTSession *)session {
    
    NSLog(@"Here");
    
    
    // Create a new player if needed
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:kClientId];
    }
    
    [self.player loginWithSession:session callback:^(NSError *error) {
        
        if (error != nil) {
            NSLog(@"*** Enabling playback got error: %@", error);
            return;
        }
        
        
        [SPTTrack trackWithURI:[NSURL URLWithString:@"spotify:track:32OlwWuMpZ6b0aN2RZOeMS"] session:nil callback:^(NSError *error, id object) {
            if(error != nil)
            {
                NSLog(@"%@", error);
            }
            else
            {
                NSLog(@"lucky day");
                [self.player playTrackProvider:object callback:nil];
            }
            
            
        }];
        
        
    }];
    
    
    
}




@end
