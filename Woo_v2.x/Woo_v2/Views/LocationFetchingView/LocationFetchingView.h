//
//  LocationFetchingView.h
//  Woo_v2
//
//  Created by Akhil Singh on 2/26/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LocationFetchingGetBlock)(BOOL needToChange);

@interface LocationFetchingView : UIView

+(LocationFetchingView* _Nonnull) createFromNIBWithOwner:(id _Nonnull)owner
                                                AndFrame:(CGRect)frame;

- (void)performTaskBasedOnActionPerformed:(LocationFetchingGetBlock _Nonnull)block;

- (void)SetLocationName:(NSString* _Nonnull)nameOfLocation;

@end
