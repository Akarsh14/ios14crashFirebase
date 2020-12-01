//
//  PermissionView.m
//  Woo
//
//  Created by Umesh Mishra on 11/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#import "PermissionView.h"
#import "PermissionTableViewCell.h"

@implementation PermissionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *viewArray = [[NSBundle mainBundle] loadNibNamed:@"PermissionView" owner:self options:nil];
        UIView *viewObj = [viewArray objectAtIndex:0];
        viewObj.frame = frame;
        [self addSubview:viewObj];
        [self initialiseView];
    }
    return self;
}

-(void)fadeInView{
    [APP_Utilities fadeInView:self];
}

-(void)initialiseView{
//    _headerLabel.backgroundColor = kHeaderBackgroundColor;
//    _headerLabel.font = [UIFont fontWithName:kProximaNovaFontSemiBold size:20];
//    _headerLabel.textColor = kHeaderTextColor;
//    _permissionContainerView.layer.cornerRadius = 5;
    [APP_Utilities makeTopCornersOfViewRounded:_headerLabel];
    
    [self addTapGesture];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self getHeightForText:indexPath.row];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"PermissionCell";
    PermissionTableViewCell *permissionTableViewCellObj;
    permissionTableViewCellObj = (PermissionTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!permissionTableViewCellObj) {
        permissionTableViewCellObj = [[[NSBundle mainBundle] loadNibNamed:@"PermissionTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    
//    [permissionTableViewCellObj setHeightOfLabel:[self getHeightForText:indexPath.row]];
    [permissionTableViewCellObj setMessageText:[self getMessageTextForRow:indexPath.row]];
    
    
    return permissionTableViewCellObj;
}

-(NSMutableAttributedString *)getMessageTextForRow:(NSInteger)row{
    
//    UIColor *themeTextColor = _getThemeColorValue;
    //get above color and set color below
    
    NSMutableAttributedString *msgString;
    msgString = [[NSMutableAttributedString alloc] initWithString:[self getTextForIndex:row]];
    switch (row) {
        case 0:
//            [msgString addAttribute:NSForegroundColorAttributeName value:kHeaderBackgroundColor range:NSMakeRange(8, 5)];
            break;
        case 1:
//            [msgString addAttribute:NSForegroundColorAttributeName value:kHeaderBackgroundColor range:NSMakeRange(17, 5)];
            break;
        case 2:
//            [msgString addAttribute:NSForegroundColorAttributeName value:kHeaderBackgroundColor range:NSMakeRange(5, 6)];
            break;
        default:
            break;
    }
    
    UIFont *font = [UIFont fontWithName:kProximaNovaFontSemiBold size:14.0f];
    [msgString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, msgString.length)];
    
    
    return msgString;
}

// Method to get height for the text for permission text for a row.
-(float)getHeightForText:(NSInteger)row{
    UIFont *font = [UIFont fontWithName:kProximaNovaFontSemiBold size:14.0f];
    NSString *text = [self getTextForIndex:row];
    return [APP_Utilities getHeightForText:text forFont:font widthOfLabel:214]+15;
}


// Method to get permission text for a row.
-(NSString *)getTextForIndex:(NSInteger)row{
    NSString *msgString;
    switch (row) {
        case 0:
            msgString = NSLocalizedString(@"We will never post anything on Facebook",nil);
            break;
        case 1:
//            msgString = NSLocalizedString(@"Other users will never know if you’ve liked them, unless they like you too",nil);
            msgString = NSLocalizedString(@"Users can’t contact you unless you’ve been matched with them",nil);
            break;
        case 2:
            msgString = NSLocalizedString(@"Users can’t contact you unless you’ve been matched with them",nil);
            break;
        default:
            break;
    }
    return msgString;
}

/*
 Method to add tap gesture to view. Tapping on view will remove the view.
 */
-(void)addTapGesture{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapGesture.numberOfTapsRequired = 1;
//    [self addGestureRecognizer:tapGesture];
//    [_permissionContainerView removeGestureRecognizer:tapGesture];
}
-(void)handleSingleTap:(UIGestureRecognizer *)tap{
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [APP_Utilities fadeOutAndRemoveView:self];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)closeButtonClicked:(id)sender {
    [APP_Utilities fadeOutAndRemoveView:self];
}
@end
