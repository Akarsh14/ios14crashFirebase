//
//  USingleton.h
//  Woo
//
//  Created by Umesh Mishra on 13/02/14.
//  Copyright (c) 2014 Vaibhav Gautam. All rights reserved.
//

#ifndef Woo_USingleton_h
#define Woo_USingleton_h

#define SINGLETON_FOR_CLASS(classname)\
+ (id) shared##classname {\
static dispatch_once_t pred = 0;\
__strong static id _sharedObject = nil;\
dispatch_once(&pred, ^{\
_sharedObject = [[self alloc] init];\
});\
return _sharedObject;\
}



#endif