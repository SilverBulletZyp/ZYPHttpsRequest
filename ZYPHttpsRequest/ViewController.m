//
//  ViewController.m
//  ZYPHttpsRequest
//
//  Created by zhaoyunpeng on 16/10/25.
//  Copyright © 2016年 zhaoyunpeng. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // 1.证书
    NSString * cerPath = [[NSBundle mainBundle] pathForResource:@"XXX" ofType:@"cer"];
    NSData * certData = [NSData dataWithContentsOfFile:cerPath];
    NSSet * certDataSet = [[NSSet alloc] initWithObjects:certData, nil];
    
    // 2.安全策略
    AFSecurityPolicy * securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = NO;
    securityPolicy.pinnedCertificates = certDataSet;
    
    // 3.请求
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy = securityPolicy;
    
    NSString * url = @"https://...";
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
    
    
}


@end
