//
//  IMatrixWebViewController.m
//  IOSMatrix
//
//  Created by zhoupan on 2017/7/24.
//  Copyright © 2017年 zhoupan. All rights reserved.
//

#import "IMatrixWebViewController.h"
@import WebKit;

@interface IMatrixWebViewController ()<WKUIDelegate,WKNavigationDelegate>
@property (nonatomic,strong)WKWebView *webView;
@property (nonatomic,strong)NSURLRequest *loadRequest;
@end

@implementation IMatrixWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.webView];
    
    [self addScript];
    [self addAlertScript];
    
    [self.webView loadRequest:_loadRequest];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self operationJS:@"document.title"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (WKWebView *)webView{
    if(!_webView){
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        //save
        //js
        WKUserContentController *userContent = [[WKUserContentController alloc] init];
        config.userContentController = userContent;
    
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
        
        _webView.allowsBackForwardNavigationGestures = YES;
        _webView.allowsLinkPreview = YES;
        _webView.customUserAgent = @"WebViewDemo/1.0.0";//UA
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        
    }
    return _webView;
}
- (void)addScript{
    WKUserScript *newCookieScript = [[WKUserScript alloc] initWithSource:@"document.cookie = 'DarkAngelCookie=DarkAngel;'" injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [self.webView.configuration.userContentController addUserScript:newCookieScript];
}
- (void)addAlertScript{
    WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:@"alert(document.cookie);" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    
    [self.webView.configuration.userContentController addUserScript:cookieScript];
}
- (void)setUrlString:(NSString *)urlString{
    if(urlString){
        _urlString = urlString;
        NSURL *url = [[NSURL alloc] initWithString:_urlString];
        self.loadRequest = [[NSURLRequest alloc] initWithURL:url];
    }
}
- (void)loadLocalScript{
    static NSString *jsSource;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jsSource = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"native_functions" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    });
    //添加自定义的脚本
    WKUserScript *js = [[WKUserScript alloc] initWithSource:jsSource injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    [self.webView.configuration.userContentController addUserScript:js];
 
}
//OC->JS
- (void)operationJS:(NSString *)js{
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable pkId, NSError * _Nullable error) {
        NSLog(@"调用evaluateJavaScript异步获取title：%@", pkId);
    }];
}
//JS->OC
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    //可以通过navigationAction.navigationType获取跳转类型，如新链接、后退等
    NSURL *URL = navigationAction.request.URL;
    //判断URL是否符合自定义的URL Scheme
    if ([URL.scheme isEqualToString:@"darkangel"]) {
        //根据不同的业务，来执行对应的操作，且获取参数
        if ([URL.host isEqualToString:@"smsLogin"]) {
            NSString *param = URL.query;
            NSLog(@"短信验证码登录, 参数为%@", param);
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
}
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"===");
}
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    self.title = webView.title;
}
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"===");
}


@end
