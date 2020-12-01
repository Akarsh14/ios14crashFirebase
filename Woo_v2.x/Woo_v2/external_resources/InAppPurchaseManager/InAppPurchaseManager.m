//
//  InAppPurchaseManager.m
//  Woo_v2
//
//  Created by Vaibhav Gautam on 05/01/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import "InAppPurchaseManager.h"
#import "MDSnackbar.h"

@implementation InAppPurchaseManager

 #define SHARED_SECRET      @"aff420ccc9d7449ab90a8b291cadbde8"

static InAppPurchaseManager *sharedManagerObj = nil;

+ (id)sharedIAPManager {
    @synchronized(self){
        if (!sharedManagerObj) {
        sharedManagerObj = [[self alloc] init];
        }
    }
    
    return sharedManagerObj;

}


#pragma mark - SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {

    NSUInteger productCount = [response.products count];
    
    purchasesAllowed = [SKPaymentQueue canMakePayments];
    
    if (productCount > 0) {
        
        productsFetched = YES;
        products = response.products;
        
    }else{
        productsFetched = NO;
        products = nil;
    }
    
    [self returnProductsToCaller];
    
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    
    switch (productTypeToBePurchased) {
            
        case InAppPRoductTypeBoost:
            
            //Swrve Event
            
           // [APP_DELEGATE sendSwrveEventWithEvent:[NSString stringWithFormat:@"3-GetBoost.Boost_Payment_Method.PM_%@_Boost_AppStore_Failure",productCount] andScreen:@"Boost_Payment_Method"];
            
            //[APP_DELEGATE sendSwrveEventWithEvent:[NSString stringWithFormat:@"3-GetBoost.Boost_Payment_Method.PM_Boost_AppStore_Failure"] andScreen:@"Boost_Payment_Method"];

            
            break;
        case InAppPRoductTypeCrush:
            
            //Swrve Event
            
            //[APP_DELEGATE sendSwrveEventWithEvent:[NSString stringWithFormat:@"3-GetCrush.Crush_Payment_Method.PM_%@_Crush_AppStore_Failure",productCount] andScreen:@"Crush_Payment_Method"];
            
           // [APP_DELEGATE sendSwrveEventWithEvent:[NSString stringWithFormat:@"3-GetCrush.Crush_Payment_Method.PM_Crush_AppStore_Failure"] andScreen:@"Crush_Payment_Method"];

            
            
            break;
        case InAppPRoductTypeWooPlus:
            
            //Swrve Event
            
            //[APP_DELEGATE sendSwrveEventWithEvent:[NSString stringWithFormat:@"3-WooPlusPurchase.WP_Payment_Method.PM_%@_WP_AppStore_Failure",productCount] andScreen:@"WP_Payment_Method"];

            //[APP_DELEGATE sendSwrveEventWithEvent:[NSString stringWithFormat:@"3-WooPlusPurchase.WP_Payment_Method.PM_WP_AppStore_Failure"] andScreen:@"WP_Payment_Method"];

            
            
            break;
            
    }

    
    
    [request cancel];
    if (error) {
        productsFetched = NO;
        products = nil;
    }
    purchasesAllowed = [SKPaymentQueue canMakePayments];
    
    [self returnProductsToCaller];
    
    
    NSLog(@" ✅✅✅error >>> %@",error);
}


-(void)returnProductsToCaller{
    
    if (_productCallbackObj) {
        _productCallbackObj(productsFetched,purchasesAllowed,products);
    }
    
    
}

#pragma  - SKPaymentTransactionObserver methods

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{

    NSLog(@" ✅✅✅in queue");
    
   // [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPendingInAppPurchaseURL];

//    SKPaymentTransaction *transactionObj = [transactions lastObject];
    for (SKPaymentTransaction *transactionObj in transactions) {
    if (transactionObj) {
        
        NSLog(@"\n\n\n🕶🕶🕶🕶 transactionObj %@",transactionObj.transactionIdentifier);
        NSLog(@"\n\n\n➡️➡️transaction identifier %@⬅️⬅️",transactionObj.payment.productIdentifier);
        
        switch (transactionObj.transactionState) {
            case SKPaymentTransactionStatePurchasing: {
                NSLog(@" ✅✅✅Purchasing - Transaction is being added to the server queue.");
                break;
            }
                
            case SKPaymentTransactionStatePurchased: {
                
                if ([[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] && [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender]) {
                    [[AppsFlyerTracker sharedTracker] trackEvent:@"PURCHASE"
                                                      withValues:[[NSDictionary alloc] initWithObjectsAndKeys:
                                                                  [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],@"User_id",
                                                                  [[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender],@"Gender",
                                                                  nil]];
//  @{@"User_id":[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],@"Gender":[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserGender]
//                                                                   }];

                }
                

//                if (transactionObj && transactionObj.payment.productIdentifier != skProductObj.productIdentifier) {
//                    [[SKPaymentQueue defaultQueue] finishTransaction:transactionObj];
//                    break;
//                }
            
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transactionObj];
                NSLog(@" ✅✅✅Purchased - Transaction is in queue, user has been charged.  Client should complete the transaction. - %@",transactionObj.payment.productIdentifier);
                
                if (productTypeToBePurchased == 0 && transactionObj.payment.applicationUsername) {
                    if ([transactionObj.payment.applicationUsername rangeOfString:@"BOOST"].location != NSNotFound) {
                        productTypeToBePurchased = InAppPRoductTypeBoost;
                    }else if([transactionObj.payment.applicationUsername rangeOfString:@"CRUSH"].location != NSNotFound) {
                        productTypeToBePurchased = InAppPRoductTypeCrush;
                    }else if([transactionObj.payment.applicationUsername rangeOfString:@"WOOPLUS"].location != NSNotFound) {
                        productTypeToBePurchased = InAppPRoductTypeWooPlus;
                    }
                    else if([transactionObj.payment.applicationUsername rangeOfString:@"FreeTrial"].location != NSNotFound) {
                        productTypeToBePurchased = InAppPRoductTypeFreeTrail;
                    }
                }else if (productTypeToBePurchased == 0){
                    if ([planIDToBePurchased length] < 1) {
                        productTypeToBePurchased = InAppPRoductTypeWooPlus;
                    }else{
                        break;
                    }
                    
                }
                
                if ([planIDToBePurchased length] < 1 && [transactionObj.payment.applicationUsername length] > 0) {
                    
                    NSArray *productDetailsArray = [transactionObj.payment.applicationUsername componentsSeparatedByString:@"-"];
                    
                    if ([productDetailsArray count] > 0 && [[productDetailsArray objectAtIndex:1] length] > 0) {
                        planIDToBePurchased = [productDetailsArray objectAtIndex:1];
                    }
                    
                }
                
                switch (productTypeToBePurchased) {
                        
                case InAppPRoductTypeFreeTrail:
                        break;
                        
                    case InAppPRoductTypeBoost:
                        
                        //Swrve Event
                        
                        //[APP_DELEGATE sendSwrveEventWithEvent:[NSString stringWithFormat:@"3-GetBoost.Boost_Payment_Method.PM_%@_Boost_AppStore_Successful",productCount] andScreen:@"Boost_Payment_Method"];
                        
                        //[APP_DELEGATE sendSwrveEventWithEvent:[NSString stringWithFormat:@"3-GetBoost.Boost_Payment_Method.PM_Boost_AppStore_Successful"] andScreen:@"Boost_Payment_Method"];

                        break;
                    case InAppPRoductTypeCrush:
                        
                        //Swrve Event
                        
                        //[APP_DELEGATE sendSwrveEventWithEvent:[NSString stringWithFormat:@"3-GetCrush.Crush_Payment_Method.PM_%@_Crush_AppStore_Successful",productCount] andScreen:@"Crush_Payment_Method"];
                        
                       // [APP_DELEGATE sendSwrveEventWithEvent:[NSString stringWithFormat:@"3-GetCrush.Crush_Payment_Method.PM_Crush_AppStore_Successful"] andScreen:@"Crush_Payment_Method"];

                        break;
                    case InAppPRoductTypeWooPlus:
                        
                        //Swrve Event
                        
                        //[APP_DELEGATE sendSwrveEventWithEvent:[NSString stringWithFormat:@"3-WooPlusPurchase.WP_Payment_Method.PM_%@_WP_AppStore_Successful",productCount] andScreen:@"WP_Payment_Method"];
                        
                        //[APP_DELEGATE sendSwrveEventWithEvent:[NSString stringWithFormat:@"3-WooPlusPurchase.WP_Payment_Method.PM_WP_AppStore_Successful"] andScreen:@"WP_Payment_Method"];

                        break;
                        
                    case InAppPRoductTypeWooGlobal:
                        break;
                }
                
                
                [self onTransactionProcessed:transactionObj productBought:skProductObj];
//                NSLog(@"%@",skProductObj.price);

                [self informServerAboutPurchaseWithTransaction:transactionObj];
                
                
                break;
            }
            case SKPaymentTransactionStateFailed: {
                
                NSLog(@" ❌❌❌Failed - Transaction was cancelled or failed before being added to the server queue.%@",transactionObj.error);
                
                switch (transactionObj.error.code) {
                    case SKErrorUnknown:
                        NSLog(@" ❌❌❌ SKErrorUnknown");
                        break;
                    case SKErrorClientInvalid:
                        NSLog(@" ❌❌❌ SKErrorClientInvalid");
                        break;
                    case SKErrorPaymentCancelled:
                        NSLog(@" ❌❌❌ SKErrorPaymentCancelled");
                        
                        
                        switch (productTypeToBePurchased) {
                                
                            case InAppPRoductTypeBoost:
                                
                                //Swrve Event
                                
                       // [APP_DELEGATE sendSwrveEventWithEvent:[NSString stringWithFormat:@"3-GetBoost.Boost_Payment_Method.PM_%@_Boost_AppStore_UserCancel",productCount] andScreen:@"Boost_Payment_Method"];
                                 
                                //[APP_DELEGATE sendSwrveEventWithEvent:[NSString stringWithFormat:@"3-GetBoost.Boost_Payment_Method.PM_Boost_AppStore_UserCancel"] andScreen:@"Boost_Payment_Method"];

                                
                                break;
                            case InAppPRoductTypeCrush:
                                
                                //Swrve Event
                                
                                //[APP_DELEGATE sendSwrveEventWithEvent:[NSString stringWithFormat:@"3-GetCrush.Crush_Payment_Method.PM_%@_Crush_AppStore_UserCancel",productCount] andScreen:@"Crush_Payment_Method"];

                                //[APP_DELEGATE sendSwrveEventWithEvent:[NSString stringWithFormat:@"3-GetCrush.Crush_Payment_Method.PM_Crush_AppStore_UserCancel"] andScreen:@"Crush_Payment_Method"];
                                
                                break;
                            case InAppPRoductTypeWooPlus:
                                
                                //Swrve Event
                                
                                //[APP_DELEGATE sendSwrveEventWithEvent:[NSString stringWithFormat:@"3-WooPlusPurchase.WP_Payment_Method.PM_%@_WP_AppStore_UserCancel",productCount] andScreen:@"WP_Payment_Method"];

                                //[APP_DELEGATE sendSwrveEventWithEvent:[NSString stringWithFormat:@"3-WooPlusPurchase.WP_Payment_Method.PM_WP_AppStore_UserCancel"] andScreen:@"WP_Payment_Method"];
                                
                                break;
                                
                            case InAppPRoductTypeWooGlobal:
                                break;
                            case InAppPRoductTypeFreeTrail:
                                
                                break;
                        }
                        
                        break;
                    case SKErrorPaymentInvalid:
                        NSLog(@" ❌❌❌ SKErrorPaymentInvalid");
                        break;
                    case SKErrorPaymentNotAllowed:
                        NSLog(@" ❌❌❌ SKErrorPaymentNotAllowed");
                        break;
                    case SKErrorStoreProductNotAvailable:
                        NSLog(@" ❌❌❌ SKErrorStoreProductNotAvailable");
                        break;
                    case SKErrorCloudServicePermissionDenied:
                        NSLog(@" ❌❌❌ SKErrorCloudServicePermissionDenied");
                        break;
                    case SKErrorCloudServiceNetworkConnectionFailed:
                        NSLog(@" ❌❌❌ SKErrorCloudServiceNetworkConnectionFailed");
                        break;
                        
                    default:
                        break;
                }
                
                
                switch (productTypeToBePurchased) {
                        
                    case InAppPRoductTypeBoost:
                        [self informingServerAboutPaymentFailure:@"BOOST"];
                        break;
                    case InAppPRoductTypeCrush:
                        [self informingServerAboutPaymentFailure:@"CRUSH"];
                        break;
                    case InAppPRoductTypeWooPlus:
                        [self informingServerAboutPaymentFailure:@"WOOPLUS"];
                        break;
                    case InAppPRoductTypeWooGlobal:
                        [self informingServerAboutPaymentFailure:@"GLOBE"];
                        break;
                    case InAppPRoductTypeFreeTrail:
                        [self informingServerAboutPaymentFailure:@"FreeTrial"];
                        break;

                        
                }
                
                
                
                if (_paymentCallbackObj) {
                    _paymentCallbackObj(NO,transactionObj.error,[SKPaymentQueue canMakePayments],nil);
                }
                
                IsProcessingAnyInAppPurchase = NO;
                [[SKPaymentQueue defaultQueue] finishTransaction:transactionObj];
                break;
            }
            case SKPaymentTransactionStateRestored: {
                NSLog(@"this time transaction is restored");
                [[SKPaymentQueue defaultQueue] finishTransaction:transactionObj];
                break;
            }
            case SKPaymentTransactionStateDeferred: {
                NSLog(@" ✅✅✅Deffered(iOS8) - The transaction is in the queue, but its final status is pending external action.");
                break;
            }
        }
    }
        
    }
}

-(void)informingServerAboutPaymentFailure:(NSString*)eventType{
    
    [APP_DELEGATE logEventOnFacebook:@"ecommerce_failure"];
    [APP_DELEGATE sendFirebaseEvent:@"ecommerce_failure" andScreen:@""];
    
    if ([APP_Utilities reachable]) {

        AFNetworkReachabilityManager *reachability = [AFNetworkReachabilityManager sharedManager];
        
        if (!reachability.reachable)
            return;
        
        
        NSString *productEventAPI = [NSString stringWithFormat:@"%@%@%lld/%@",kBaseURLV1,kPurchaseEventAPI,[[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId] longLongValue],eventType];
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                planIDToBePurchased,  @"data",
                                nil];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        
        [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [manager setRequestSerializer:requestSerializer];
        
        [manager  POST:productEventAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        } caching:GET_DATA_FROM_URL_ONLY andNumberOfRetries:3];
        
    }
}


- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    
    //    for (SKPaymentTransaction *transactionObj in transactions){
    //        NSLog(@"removed transaction » %@",transactionObj);
    //        [[SKPaymentQueue defaultQueue] finishTransaction:transactionObj];
    //    }
    SKPaymentQueue* currentQueue = [SKPaymentQueue defaultQueue];
    // finish ALL transactions in queue
    if(currentQueue)
    {
//        for (SKPaymentTransaction *items in currentQueue.transactions){
//            if (items != nil){
//                [currentQueue finishTransaction:items];
//            }
//
//        }
        
        [currentQueue.transactions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             if(obj != nil && [currentQueue respondsToSelector:@selector(finishTransaction:)])
             {
                 [currentQueue finishTransaction:(SKPaymentTransaction *)obj];
             }
         }];
    }
}

#pragma mark - Adding this to Notify Swrve for succesful transaction
// https://docs.swrve.com/developer-documentation/integration/ios/
- (void) onTransactionProcessed:(SKPaymentTransaction*) transaction productBought:(SKProduct*) product {
//    // Tell Swrve what was purchased.
//    SwrveIAPRewards* rewards = [[SwrveIAPRewards alloc] init];
//    
//    // You can track the purchase of virtual items
//    [rewards addItem:[product productIdentifier] withQuantity:[productCount longLongValue]];
//    // Or virtual currency or both.
//    
    NSString *amount = [NSString stringWithFormat:@"%@",[product price]];
    paidAmount = [amount integerValue];
    NSLog(@"%ld",(long)paidAmount);
    
//    
//    [APP_DELEGATE sendSwrveEventWithEvent:[NSString stringWithFormat:@"3-WooPlusPurchase.WP_Payment_Item",productCount] andScreen:@"WP_Payment_Method"];
//
    
////    NSString *price = [NSString stringWithFormat:@"%@%@ %@", [product.priceLocale objectForKey:NSLocaleCurrencySymbol], product.price, [product.priceLocale objectForKey:NSLocaleCurrencyCode]];
//    
//    [rewards addCurrency:[product.priceLocale objectForKey:NSLocaleCurrencyCode] withAmount:[amount longLongValue]];
//    
//    // Send the IAP event to Swrve.
//    [[Swrve sharedInstance] iap:transaction product:product rewards:rewards];
}





- (NSString*)base64forData:(NSData*)theData {
    
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}



#pragma mark - Receipt Validation

- (void)refreshReceipt{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserDeniedRenew] && [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDeniedRenew] boolValue] == true) {
        return;
    }
    if (IsProcessingAnyInAppPurchase) {
        return;
    }
    IsProcessingAnyInAppPurchase = YES;
    
    //    _paymentCallbackObjReNew = callback;
    NSString *productType = @"WOOPLUS";
    NSString *receiptString = @"";
    
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    
    receiptString = [self base64forData:receiptData];
    
    NSInteger currentTimeStamp = [[NSDate date] timeIntervalSince1970];
    
    NSString *transactionId = [NSString stringWithFormat:@"%@-%ld",[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId], (long)currentTimeStamp];
    
    NSMutableString *paymentMadeURL = nil;
    
    paymentMadeURL = [NSMutableString stringWithFormat:@"%@%@?wooId=%@&productType=%@&transactionId=%@&purchaseChannel=I_STORE&source=%@",kBaseURLV9,kPurchaseProduct,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],productType,transactionId,APP_DELEGATE.ComingToPurchaseFromTypeOfView];
    
    
    NSDictionary    *param = [NSDictionary dictionaryWithObject:receiptString forKey:@"payload"];
    
    [[NSUserDefaults standardUserDefaults] setObject:paymentMadeURL forKey:kPendingInAppPurchaseURL];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (![APP_Utilities reachable]) {
        [APP_Utilities hideLoaderView];
        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"No internet connection! Please try again.", nil));
        return;
    }
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =paymentMadeURL;
    wooRequestObj.time =9000;
    wooRequestObj.requestParams =param;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =5;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = postInAppDataToServerForRenew;
    
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        if (requestType == postInAppDataToServerForRenew) {
            if (success) {
                if ([response objectForKey:@"wooPlusDto"] && [[response objectForKey:@"wooPlusDto"] objectForKey:@"expired"] && [[[response objectForKey:@"wooPlusDto"] objectForKey:@"expired"] boolValue] == true) {
                    
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDeniedRenew];
                    
                }else if([response objectForKey:@"wooPlusDto"] && [[response objectForKey:@"wooPlusDto"] objectForKey:@"expired"] && [[[response objectForKey:@"wooPlusDto"] objectForKey:@"expired"] boolValue] == false){
                    
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserDeniedRenew];
                    
                }
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPendingInAppPurchaseURL];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPendingReceiptData];
                [[NSUserDefaults standardUserDefaults] synchronize];
                //                if (_paymentCallbackObjReNew) {
                //                    _paymentCallbackObjReNew(YES,[SKPaymentQueue canMakePayments],response);
                //                }
                
                IsProcessingAnyInAppPurchase = NO;
            }
        }
    } shouldReachServerThroughQueue:FALSE];
    
    
}


- (NSDictionary *)getStoreReceipt:(BOOL)sandbox {
    
    NSArray *objects;
    NSArray *keys;
    NSDictionary *dictionary;
    
    BOOL gotreceipt = false;
    
    @try {
        
        NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[receiptUrl path]]) {
            
            NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
            
            NSString *receiptString = [self base64forData:receiptData];
            
            if (receiptString != nil) {
                
                objects = [[NSArray alloc] initWithObjects:receiptString,SHARED_SECRET, nil];
                keys = [[NSArray alloc] initWithObjects:@"receipt-data", @"password", nil];
                dictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
                
                NSData *postData1  = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
                NSString *postData =[[NSString alloc] initWithData:postData1 encoding:NSUTF8StringEncoding];
                NSString *urlSting = @"https://buy.itunes.apple.com/verifyReceipt";
                if (sandbox) urlSting = @"https://sandbox.itunes.apple.com/verifyReceipt";
                
                dictionary = [self getJsonDictionaryWithPostFromUrlString:urlSting andDataString:postData];
                
                if ([dictionary objectForKey:@"status"] != nil) {
                    
                    if ([[dictionary objectForKey:@"status"] intValue] == 0) {
                        
                        gotreceipt = true;
                        
                        NSDictionary     *dictReceipt = [dictionary objectForKey:@"receipt"];
                        
                    }else if([[dictionary objectForKey:@"status"] intValue] == 21007){
                        
                        // Sandbox Receipt
                        
                        gotreceipt = true;
                    }
                }
                
            }
            
        }
        
    } @catch (NSException * e) {
        gotreceipt = false;
    }
    
    if (!gotreceipt) {
        objects = [[NSArray alloc] initWithObjects:@"-1", nil];
        keys = [[NSArray alloc] initWithObjects:@"status", nil];
        dictionary = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    }
    
    return dictionary;
}


- (NSDictionary *) getJsonDictionaryWithPostFromUrlString:(NSString *)urlString andDataString:(NSString *)dataString {
    NSString *jsonString = [self getStringWithPostFromUrlString:urlString andDataString:dataString];
    NSLog(@" ✅✅✅%@", jsonString); // see what the response looks like
    return [self getDictionaryFromJsonString:jsonString];
}


- (NSDictionary *) getDictionaryFromJsonString:(NSString *)jsonstring {
    NSError *jsonError;
    NSDictionary *dictionary = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:[jsonstring dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonError];
    if (jsonError) {
        dictionary = [[NSDictionary alloc] init];
    }
    return dictionary;
}

- (NSString *) getStringWithPostFromUrlString:(NSString *)urlString andDataString:(NSString *)dataString {
    NSString *s = @"";
    @try {
        NSData *postdata = [dataString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postlength = [NSString stringWithFormat:@"%lu", (unsigned long)[postdata length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setTimeoutInterval:60];
        [request setHTTPMethod:@"POST"];
        [request setValue:postlength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postdata];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        if (data != nil) {
            s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    @catch (NSException *exception) {
        s = @"";
    }
    return s;
}


#pragma mark - Public methods

-(void)purchaseProductWithProduct:(SKProduct *)productToBePurchased withProductType:(InAppPRoductType )productType withPlanID:(NSString *)planID andResult:(PaymentCallback )callback{
    
    IsProcessingAnyInAppPurchase = YES;
    _paymentCallbackObj = callback;
    productTypeToBePurchased = productType;
    planIDToBePurchased = planID;
    skProductObj = productToBePurchased;
    
    if ([SKPaymentQueue canMakePayments]) {
        
        SKMutablePayment *paymentObj = [SKMutablePayment paymentWithProduct:productToBePurchased];
        
        switch (productTypeToBePurchased) {
                
            case InAppPRoductTypeBoost:
                paymentObj.applicationUsername = [NSString stringWithFormat:@"BOOST-%@",planIDToBePurchased];
                break;
            case InAppPRoductTypeCrush:
                paymentObj.applicationUsername = [NSString stringWithFormat:@"CRUSH-%@",planIDToBePurchased];
                break;
            case InAppPRoductTypeWooPlus:
                paymentObj.applicationUsername = [NSString stringWithFormat:@"WOOPLUS-%@",planIDToBePurchased];
                break;
            case InAppPRoductTypeFreeTrail:
                paymentObj.applicationUsername = [NSString stringWithFormat:@"FreeTrial-%@",planIDToBePurchased];
                break;
            case InAppPRoductTypeWooGlobal:
                paymentObj.applicationUsername = [NSString stringWithFormat:@"GLOBE-%@",planIDToBePurchased];
                break;
        }

        if (paymentObj) {
            [[SKPaymentQueue defaultQueue] addPayment:paymentObj];
        }else{
            _paymentCallbackObj(NO,nil, [SKPaymentQueue canMakePayments],nil);
        }
//        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
        
    }else{
        
        _paymentCallbackObj(NO,nil, [SKPaymentQueue canMakePayments],nil);
        
    }
}

-(void)getAllProductsFromAppleWithProductIdentifiers:(NSSet *)productIdSet withProductCount:(NSString *)count withCallback:(ProductsCallback )callback{
    
    productCount = count;
    
    if (![APP_Utilities isJailbroken]) {
        _productCallbackObj = callback;

        productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdSet];
        
        productsRequest.delegate = self;
        [productsRequest start];
    }else{
        UIAlertView *jailbrokenAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops!", nil) message:@"In-App purchases are not allowed on jailbroken device." delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        
        //[jailbrokenAlertView show];
    }
    
    
}


-(BOOL)isProcessingInApp{
    return IsProcessingAnyInAppPurchase;
}


-(void)setInAppProcessingInApp:(BOOL)isInAppProcessing{
    IsProcessingAnyInAppPurchase = isInAppProcessing;
}

#pragma mark - Informing server about in app purchase

-(void)completeInAppForFailedTransaction{
    
    
    if (![APP_Utilities reachable]) {
        [APP_Utilities hideLoaderView];
    //    SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"No internet connection! Please try again.", nil));
        return;
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kLastLocationLatitudeKey] || ![[NSUserDefaults standardUserDefaults] objectForKey:kLastLocationLongitudeKey]) {
        return;
    }

    if ([[NSUserDefaults standardUserDefaults] objectForKey:kPendingInAppPurchaseURL]) {
        
        NSDictionary *param = nil;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kPendingReceiptData])
            param  = [NSDictionary dictionaryWithObject:[[NSUserDefaults standardUserDefaults] objectForKey:kPendingReceiptData] forKey:@"payload"];

        
        IsProcessingAnyInAppPurchase = YES;
        WooRequest *wooRequestObj = [[WooRequest alloc]init];
        wooRequestObj.url =[[NSUserDefaults standardUserDefaults] objectForKey:kPendingInAppPurchaseURL];
        wooRequestObj.time =9000;
        wooRequestObj.requestParams =param;
        wooRequestObj.methodType =postRequest;
        wooRequestObj.numberOfRetries =5;
        wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
        wooRequestObj.requestType = postInAppDataToServer;
        
        
        [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
            
            NSLog(@" ✅✅✅response %@",response);
            if (requestType == postInAppDataToServer) {
                if (success) {
                    

                    if (_paymentCallbackObj)
                        _paymentCallbackObj(YES,nil,[SKPaymentQueue canMakePayments],response);
                    
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPendingInAppPurchaseURL];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    
                }
                IsProcessingAnyInAppPurchase = NO;

            }
        } shouldReachServerThroughQueue:FALSE];
    }
}




-(void)informServerAboutPurchaseWithTransaction:(SKPaymentTransaction *)transactionObj {
    
    
    if (([[APP_Utilities validString:[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId]] length] < 1) || ([planIDToBePurchased length] < 1)) {
        return;
    }

    NSString *productType = @"";
    NSString *receiptString = @"";
    
    switch (productTypeToBePurchased) {
            
        case InAppPRoductTypeBoost:
            productType = @"BOOST";
            break;
        case InAppPRoductTypeCrush:
            productType = @"CRUSH";
            break;
        case InAppPRoductTypeWooPlus:
            productType = @"WOOPLUS";
            break;
            
        case InAppPRoductTypeWooGlobal:
            productType = @"GLOBE";
            break;
            
        case InAppPRoductTypeFreeTrail:
             productType = @"WOOPLUS";
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[[NSBundle mainBundle] appStoreReceiptURL] path]]) {
        
        NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
        NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
        
        receiptString = [self base64forData:receiptData];
        [[NSUserDefaults standardUserDefaults] setObject:receiptString forKey:kPendingReceiptData];
        
    }else{
        
        currentTransaction = transactionObj;
        
        SKReceiptRefreshRequest *receiptRequest = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:nil];
        receiptRequest.delegate = self;
        [receiptRequest start];
        
        return;
    }
    
    if (productTypeToBePurchased == (InAppPRoductTypeWooPlus | InAppPRoductTypeFreeTrail) && [receiptString length] < 1) {
        return;
    }
    
    NSMutableString *paymentMadeURL = [[NSMutableString alloc]init];
    
    
    paymentMadeURL = [NSMutableString stringWithFormat:@"%@%@?wooId=%@&productType=%@&transactionId=%@&purchaseChannel=I_STORE&source=%@",kBaseURLV13,kPurchaseProduct,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],productType,transactionObj.transactionIdentifier,APP_DELEGATE.ComingToPurchaseFromTypeOfView];
    
    
    if ([planIDToBePurchased length] > 0) {
        
        paymentMadeURL = [NSMutableString stringWithFormat:@"%@&planId=%@",paymentMadeURL,planIDToBePurchased];
    }
    
      if(productTypeToBePurchased == InAppPRoductTypeFreeTrail){
          NSString *offerId = [NSString stringWithFormat:@"%ld", (long)[FreeTrailModel sharedInstance].offerId];
          paymentMadeURL = [NSMutableString stringWithFormat:@"%@&offerId=%@",paymentMadeURL,offerId];
      }
    
    NSDictionary *param = [NSDictionary dictionaryWithObject:receiptString forKey:@"payload"];
    
    [[NSUserDefaults standardUserDefaults] setObject:paymentMadeURL forKey:kPendingInAppPurchaseURL];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (![APP_Utilities reachable]) {
        [APP_Utilities hideLoaderView];
        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"No internet connection! Please try again.", nil));
        return;
    }
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =paymentMadeURL;
    wooRequestObj.time =9000;
    wooRequestObj.requestParams =param;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries = 5 ;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = postInAppDataToServer;
    
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        if (requestType == postInAppDataToServer) {
            if (success) {
                
                NSString *priceUnitForSelectedProduct = [[NSUserDefaults standardUserDefaults] objectForKey:@"priceUnitForSelectedProduct"];
                
                if([priceUnitForSelectedProduct isEqualToString:@"\u20B9"]){
                    if(self->paidAmount > 998){
                        [APP_DELEGATE sendFirebaseEvent:@"high_val" andScreen:@""];
                        [APP_DELEGATE logEventOnFacebook:@"high_val"];
                        
                        NSDictionary *purchaseEventForsendFirebase = @{
                            @"currency" : priceUnitForSelectedProduct,
                            @"channel" : @"ios",
                            @"amount" : [NSString stringWithFormat:@"%ld",(long)self->paidAmount]
                        };
                        
                        [APP_DELEGATE sendPurchasedFirebaseEvent:@"high_val_new" ForPurchaseData:purchaseEventForsendFirebase];
                        
                    }
                }
                if(self->paidAmount > 0){
                    if([priceUnitForSelectedProduct isEqualToString:@"\u20B9"]){
                        [APP_Utilities logPurchaseEventOnFacebook:@"" withParameters:nil withPurchaseAmount:self->paidAmount];
                    }
                }
                
                
                if ([productType isEqualToString:@"WOOPLUS"])
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserDeniedRenew];

                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPendingInAppPurchaseURL];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPendingReceiptData];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if (_paymentCallbackObj) {
                    _paymentCallbackObj(YES,nil,[SKPaymentQueue canMakePayments],response);
                }
                
                IsProcessingAnyInAppPurchase = NO;
            }
        }
    } shouldReachServerThroughQueue:FALSE];
    
    currentTransaction = nil;
}

-(void) requestDidFinish:(SKRequest *)request{
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[[NSBundle mainBundle] appStoreReceiptURL] path]] && currentTransaction) {
        NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
        NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
        NSString *receiptString = @"";
        receiptString = [self base64forData:receiptData];
        [[NSUserDefaults standardUserDefaults] setObject:receiptString forKey:kPendingReceiptData];
        [self informServerAboutPurchaseWithTransaction:currentTransaction];
    }
    
}



#pragma mark - Call Purchase API for renew

-(void)informServerAboutPurchaseForRenewWithCallback:(PaymentCallbackRenew )callback {
    
    
    IsProcessingAnyInAppPurchase = YES;
    
    _paymentCallbackObjReNew = callback;
    NSString *productType = @"WOOPLUS";
    NSString *receiptString = @"";
    
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    
    receiptString = [self base64forData:receiptData];

    NSInteger currentTimeStamp = [[NSDate date] timeIntervalSince1970];

    NSString *transactionId = [NSString stringWithFormat:@"%@-%ld",[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId], (long)currentTimeStamp];
    
    NSMutableString *paymentMadeURL = nil;
    
    paymentMadeURL = [NSMutableString stringWithFormat:@"%@%@?wooId=%@&productType=%@&transactionId=%@&purchaseChannel=I_STORE&source=%@",kBaseURLV9,kPurchaseProduct,[[NSUserDefaults standardUserDefaults] objectForKey:kWooUserId],productType,transactionId,APP_DELEGATE.ComingToPurchaseFromTypeOfView];
    
    
    NSDictionary *param = [NSDictionary dictionaryWithObject:receiptString forKey:@"payload"];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:paymentMadeURL forKey:kPendingInAppPurchaseURL];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (![APP_Utilities reachable]) {
        [APP_Utilities hideLoaderView];
        SHOW_TOAST_WITH_TEXT(NSLocalizedString(@"No internet connection! Please try again.", nil));
        return;
    }
    
    
    WooRequest *wooRequestObj = [[WooRequest alloc]init];
    wooRequestObj.url =paymentMadeURL;
    wooRequestObj.time =9000;
    wooRequestObj.requestParams =param;
    wooRequestObj.methodType =postRequest;
    wooRequestObj.numberOfRetries =5;
    wooRequestObj.cachePolicy=GET_DATA_FROM_URL_ONLY;
    wooRequestObj.requestType = postInAppDataToServerForRenew;
    
    
    [[APIQueue sharedAPIQueue] makeRequest:wooRequestObj withCallback:^(BOOL success, id response, NSError *error, int statusCode, kindOfRequest requestType) {
        if (requestType == postInAppDataToServerForRenew) {
            if (success) {
                
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserDeniedRenew];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPendingInAppPurchaseURL];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPendingReceiptData];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if (_paymentCallbackObjReNew) {
                    _paymentCallbackObjReNew(YES,[SKPaymentQueue canMakePayments],response);
                }
                
                IsProcessingAnyInAppPurchase = NO;
            }
        }
    } shouldReachServerThroughQueue:FALSE];
    
}


+ (void)resetSharedInstance {
    @synchronized(self){
        sharedManagerObj = nil;
    }
}


@end
