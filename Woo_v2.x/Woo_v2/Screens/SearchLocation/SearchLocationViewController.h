//
//  SearchLocationViewController.h
//  Woo_v2
//
//  Created by Deepak Gupta on 2/24/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LocationSelectionBlock) (NSString* crushPurchasedSuccessfully);

@interface SearchLocationViewController : UIViewController<UISearchBarDelegate , UITableViewDataSource , UITableViewDelegate , CLLocationManagerDelegate>{
    
    __weak IBOutlet UITableView *tblView;
    
    __weak IBOutlet UITableView *tblViewSearch;

    __weak IBOutlet UISearchBar *SearchBarObj;
    
    
    __weak IBOutlet UIButton     *btnCancel;
    
    NSMutableArray               *arrSearchData;
    
    NSArray                      *arrDefaultLocation;
    
    int                           selectedIndex;
    
    WooLoader                     *customLoader;

    
    CLLocation *locationObj;

}


@property(nonatomic, assign)BOOL comingFromSettings;
@property (assign)BOOL           isCancelButtonVisible;

@property( nonatomic, strong)CLLocationManager       *locationManager;



@property( nonatomic, strong)  LocationSelectionBlock doneBlock;

- (IBAction)okButtonClicked:(id)sender;

- (IBAction)cancelButtonClicked:(id)sender;

@end
