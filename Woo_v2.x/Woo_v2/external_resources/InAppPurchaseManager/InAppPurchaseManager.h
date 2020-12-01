//
//  InAppPurchaseManager.h
//  Woo_v2
//
//  Created by Vaibhav Gautam on 05/01/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "WooPlusModel.h"

typedef NS_ENUM(NSInteger, InAppPRoductType){
    InAppPRoductTypeBoost = 1,
    InAppPRoductTypeCrush = 2,
    InAppPRoductTypeWooPlus = 3,
    InAppPRoductTypeWooGlobal = 4,
    InAppPRoductTypeFreeTrail = 5
};

typedef void(^ProductsCallback)(BOOL success, BOOL canMakePurchase, NSArray *productsArray);
typedef void(^PaymentCallback)(BOOL success,id error,BOOL canMakePayment, id serverResponse);
typedef void(^PaymentCallbackRenew)(BOOL success, BOOL canMakePayment, id serverResponse);
typedef void(^receiptRefreshedCallback)(SKPaymentTransaction *transactionObj) ;


@interface InAppPurchaseManager : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver , SKRequestDelegate>{
    
    SKProductsRequest *productsRequest;
    
    ProductsCallback _productCallbackObj;
    PaymentCallback _paymentCallbackObj;
    PaymentCallbackRenew _paymentCallbackObjReNew;
    
    BOOL productsFetched;
    BOOL purchasesAllowed;
    NSArray *products;
    
    InAppPRoductType productTypeToBePurchased;
    NSString *planIDToBePurchased;
    
    SKProduct *skProductObj;
    
    NSString *productCount;
    NSInteger paidAmount;
    
    BOOL IsProcessingAnyInAppPurchase;
    
    SKPaymentTransaction *currentTransaction;
    
}


/**
 *  Shared instance of InAppManager
 *
 *  @return This method will return the singleton object of InAppManager
 */
+ (id)sharedIAPManager;


/**
 *  This method will return if InAppManager is processing any in app
 *
 *  @return true/false status if the in app manager is busy
 */
-(BOOL)isProcessingInApp;

-(void)setInAppProcessingInApp:(BOOL)isInAppProcessing;

/**
 *  This method will return all the IAP products from apple's server matching product identifiers
 *
 *  @param productIdSet NSSet containing all the identifiers of the required products
 *  @param callback     Callback block returning success status, can user make purchase and array of products
 */
-(void)getAllProductsFromAppleWithProductIdentifiers:(NSSet *)productIdSet withProductCount:(NSString *)count withCallback:(ProductsCallback )callback;


/**
 *  This method will be used to purchase product, process it and inform server about the purchase
 *
 *  @param productToBePurchased Object of SKProduct which has to be purchased
 *  @param productType          type of product, for now only BOOST and CRUSH
 *  @param planID               planID which we got from our own server
 *  @param callback             This will return three values success status, can user make payments and response from server
 */
-(void)purchaseProductWithProduct:(SKProduct *)productToBePurchased withProductType:(InAppPRoductType )productType withPlanID:(NSString *)planID andResult:(PaymentCallback )callback;

/**
 *  This method will check if there is any pending in-app purchase from client, if there is then it will process it
 */
-(void)completeInAppForFailedTransaction;


-(void)informServerAboutPurchaseForRenewWithCallback:(PaymentCallbackRenew )callback;

+ (void)resetSharedInstance;

- (void)refreshReceipt;

@end
