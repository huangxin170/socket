//
//  ViewController.m
//  socket
//
//  Created by huangxin on 2020/11/3.
//

#import "ViewController.h"
#import <GCDAsyncSocket.h>

@interface ViewController ()<GCDAsyncSocketDelegate>

@property (nonatomic , strong) GCDAsyncSocket * socket;

@property (nonatomic , strong) UITextField * textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton * clientButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 100, 100, 100)];
    clientButton.backgroundColor = [UIColor redColor];
    [clientButton setTitle:@"连接服务器" forState:UIControlStateNormal];
    [clientButton addTarget:self action:@selector(ONActionClient) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clientButton];
    
    UIButton * sendButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 300, 100, 100)];
    sendButton.backgroundColor = [UIColor redColor];
    [sendButton setTitle:@"发送数据" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(ONActionSend) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendButton];
    
    self.textField = [[UITextField alloc]initWithFrame:CGRectMake(0, 500, 400, 50)];
    self.textField.placeholder = @"请输入内容";
    self.textField.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.textField];
    
    
    [self creatRequset];
    
    
}
//请求网络数据
-(void)creatRequset{
    NSString * urlstring = @"http://127.0.0.1/data";
    NSURL * url = [NSURL URLWithString:urlstring];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"请求失败:%@",error.domain);
        }else{
            NSError * dicerror = nil;
            NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&dicerror];
            if (dicerror) {
                NSLog(@"解析数据失败:%@",dicerror.domain);
            }else{
                NSLog(@"解析数据成功:%@",dic);
            }
        }
    }];
    [task resume];
    
}
//发送数据
-(void)ONActionSend{
    NSLog(@"发送数据:%@",self.textField.text);
    
    [self.socket setUserData:self.textField.text];
    
    [self.socket writeData:[self.textField.text dataUsingEncoding:NSUTF8StringEncoding] withTimeout:10 tag:100];
    
}
-(void)ONActionClient{
    NSLog(@"连接服务器");
    
    NSString * host = @"10.10.12.137";
    int port = 8080;
    
    self.socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSError * error = nil;
    
    [self.socket connectToHost:host onPort:port error:&error];
    [self.socket acceptOnPort:port error:&error];
    if (error) {
        NSLog(@"服务器连接失败:%@",error.domain);
    }else{
        NSLog(@"服务器连接成功");
    }
    [self.socket readDataWithTimeout:-1 tag:0];
}
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"连接成功:%@",sock);
}
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    if (err) {
        NSLog(@"连接失败:%@",err.domain);
    }else{
        NSLog(@"正常断开连接");
    }
}
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"发送数据");
    [sock readDataWithTimeout:-1 tag:tag];
}
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString * receiverStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"读取数据的内容:%@",receiverStr);
    [sock readDataWithTimeout:-1 tag:tag];
}


@end
