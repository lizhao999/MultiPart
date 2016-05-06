//
//  ViewController.m
//  MultiPart
//
//  Created by 杜亚伟 on 16/3/17.
//  Copyright © 2016年 杜亚伟. All rights reserved.
//

#import "ViewController.h"

#define YYEncode(str) [str dataUsingEncoding:NSUTF8StringEncoding]

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)upload:(NSString *)name filename:(NSString *)filename mimeType:(NSString *)mimeType data:(NSData *)data parmas:(NSDictionary *)params
{
    // 文件上传
    NSURL *url = [NSURL URLWithString: @"http://tsp-test.changxing.sh.cn:9090/tsp2/carlife/cx/ws/fileupload"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    // 设置请求体
    NSMutableData *body = [NSMutableData data];
    NSMutableString* mutableStr=[[NSMutableString alloc] init];

    /***************文件参数***************/
    // 参数开始的标志
    [body appendData:YYEncode(@"--YY\r\n")];
    // name : 指定参数名(必须跟服务器端保持一致)
    // filename : 文件名
    NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, filename];
    [body appendData:YYEncode(disposition)];
    NSString *type = [NSString stringWithFormat:@"Content-Type: %@\r\n", mimeType];
    [body appendData:YYEncode(type)];
    
    [body appendData:YYEncode(@"\r\n")];
    [body appendData:data];
    [body appendData:YYEncode(@"\r\n")];
    
    /***************普通参数***************/
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        // 参数开始的标志
        [body appendData:YYEncode(@"--YY\r\n")];
        NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key];
        [body appendData:YYEncode(disposition)];
        
        [body appendData:YYEncode(@"\r\n")];
        [body appendData:YYEncode(obj)];
        [body appendData:YYEncode(@"\r\n")];
    }];
    
    /***************参数结束***************/
    // YY--\r\n
    [body appendData:YYEncode(@"--YY--\r\n")];
    request.HTTPBody = body;
    
    
    // 设置请求头
    [request setValue:@"B0002" forHTTPHeaderField:@"businessId"];
    
    // 请求体的长度
    [request setValue:[NSString stringWithFormat:@"%zd", body.length] forHTTPHeaderField:@"Content-Length"];
    // 声明这个POST请求是个文件上传
    [request setValue:@"multipart/form-data; boundary=YY" forHTTPHeaderField:@"Content-Type"];
    
    // 发送请求
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"%@", dict[@"head"][@"resMessage"]);
        } else {
            NSLog(@"上传失败");
        }
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Socket 实现断点上传
    
    //apache-tomcat-6.0.41/conf/web.xml 查找 文件的 mimeType
    //    UIImage *image = [UIImage imageNamed:@"test"];
    //    NSData *filedata = UIImagePNGRepresentation(image);
    //    [self upload:@"file" filename:@"test.png" mimeType:@"image/png" data:filedata parmas:@{@"username" : @"123"}];
    
    // 给本地文件发送一个请求
    NSURL *fileurl = [[NSBundle mainBundle] URLForResource:@"itcast.txt" withExtension:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:fileurl];
    NSURLResponse *repsonse = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&repsonse error:nil];
    // 得到mimeType
    NSLog(@"%@", repsonse.MIMEType);
    [self upload:@"file" filename:@"itcast.txt" mimeType:repsonse.MIMEType data:data parmas:@{@"body":@{@"type":@"6"},@"head":@""}];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
