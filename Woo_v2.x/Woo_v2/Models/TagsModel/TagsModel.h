//
//  TagsModel.h
//  Woo_v2
//
//  Created by Umesh Mishraji on 30/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TagsModel : NSObject

@property (nonatomic, strong) NSMutableArray *allTags;
@property (nonatomic, strong) NSMutableArray *popularTags;
@property (nonatomic, strong) NSMutableArray *selectedTags;
//@property (nonatomic, assign) NSInteger maxTagsAllowedCount;
//@property (nonatomic, assign) NSInteger minTagsAllowedCount;
//@property (nonatomic, assign) NSTimeInterval lastUpdateTime;


+ (TagsModel *)sharedInstance;
-(void) appTerminationHandler;
-(void) updateSelectedTags:(NSMutableArray *)newSelectedTags;

-(void)updateTagsData:(NSDictionary *)tagsDetail;
- (void)resetModel;
-(void)addTemporaryTagsDetails;
-(void)addAllTags;
-(void)getNewTagsIfAny:(void(^)(NSArray *newTagsArray))block;

@end
