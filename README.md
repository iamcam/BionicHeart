BionicHeart
===========

Mocking a heart rate monitor for iOS8's Health Kit. Why? 

1) The Simulator can't connect to physical monitors

2) You might not have a real Bluetooth monitor anyway.

##Getting Started

It's probably best to boot it up in your AppDelegate (though there's nothing preventing you from putting it elsewhere)

```
#import "CPBionicHeart.h"
- (BOOL)application:(UIApplication *)application 
  didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  ...
  CPBionicHeart *bh = [[CPBionicHeart alloc] init];
  [bh start];
  ...
}
```


BionicHeart will start the heart rate at 85.0 (beats/minute) and increment/decrement randomly from zero to two BPM each second, up to the min/max values defined in the header.

To keep things easy, it keeps reference to its own HKHealthStore and also handles asking permissions for you. It will also call an optional delegate methods when permissions change and when the HKSample is saved with success/error.

If you fail to grant permissions, the heart will be stopped <*sad trombone*> and you must manually re-grant permissions in the Health App. This is where it's handy to pay attention via the -permissionsUpdated delegate method.

If you wish to stop recording, cake:
  
  ```
  [bh stop];
  ```
