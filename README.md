# ZYPHttpsRequest


* 使用`AFNetWorking`进行`HTTPS`请求


由于`iOS 9`新特性`App Transport Security`，我们只能暂时将请求地址设为全部允许


```xml
<key>NSAppTransportSecurity</key>
<dict>
	<key>NSExceptionDomains</key>
	<dict>
		<key>域名.com</key>
		<dict>
			<!--允许子域名:subdomains-->
			<key>NSIncludesSubdomains</key>
			<true/>
			<!--允许App进行不安全的HTTP请求-->
			<key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
			<true/>
			<!--在这里声明所支持的 TLS 最低版本-->
			<key>NSTemporaryExceptionMinimumTLSVersion</key>
			<string>TLSv1.1</string>
		</dict>
	</dict>
</dict>
```


苹果宣称2017年将全面停止使用不安全的http访问形式，因此以上添加白名单的方式也将弃用

不久的将来我们不得不升级TLS版本以支持https访问，有关于这部分知识这里不详述。下面简单介绍下如何使用`AFNetWorking`发`HTTPS`请求

---

一般来讲如果app用了`web service`，我们需要防止数据嗅探来保证数据安全，通常的做法是用ssl来连接以防止数据抓包和嗅探，同时我们还需要防止中间人攻击。攻击者通过伪造的ssl证书使app连接到了伪装的假冒的服务器上。如何解决呢？

首先web服务器必须提供一个ssl证书，需要一个`.crt`文件，然后设置app只能连接有效ssl证书的服务器。

在开始写代码前，先要把`.crt`文件转成`.cer`文件，然后导入项目。


## 导入.cer文件


* 方法一

使用openssl将`.crt`转换成`.cer`文件

```
openssl x509 -in XXX.crt -out XXX.cer -outform der
```


* 方法二

在mac系统上安装`.crt`文件，进入`钥匙串访问`，选中安装好的`.crt`文件，选择`文件`->`导出项目`，保存格式为`.cer`


之后将其导入Xcode开发的项目，同时，在`.plist`文件中进行如下设置


```xml
<key>NSAppTransportSecurity</key>
<dict>
	<key>NSAllowsArbitraryLoads</key>
	<true/>
</dict>
```


## AFN请求

代码部分会使用到`AFSecurityPolicy.h`这个类，可以看下官方描述：

> `AFSecurityPolicy` evaluates server trust against pinned X.509 certificates and public keys over secure connections.
> Adding pinned SSL certificates to your app helps prevent man-in-the-middle attacks and other vulnerabilities. Applications dealing with sensitive customer data or financial information are strongly encouraged to route all communication over an HTTPS connection with SSL pinning configured and enabled.

即得知其用于安全策略认证相关


* 1.证书路径

```objective-c
NSString * cerPath = [[NSBundle mainBundle] pathForResource:@"XXX" ofType:@"cer"];
NSData * certData = [NSData dataWithContentsOfFile:cerPath];
NSSet * certDataSet = [[NSSet alloc] initWithObjects:certData, nil];
```

* 2.安全策略

```objective-c
AFSecurityPolicy * securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
securityPolicy.allowInvalidCertificates = YES;
securityPolicy.validatesDomainName = NO;
securityPolicy.pinnedCertificates = certDataSet;
```

验证模式`AFSSLPinningMode`根据需要选择，若不验证证书，则填写`AFSSLPinningModeNone`，验证`.cer`则填写`AFSSLPinningModeCertificate`

```objective-c
AFSSLPinningModeNone,
AFSSLPinningModePublicKey,
AFSSLPinningModeCertificate,
```

`allowInvalidCertificates` 允许无效证书(自建证书)，默认为NO；若需要验证则修改为YES

`validatesDomainName` 是否需要验证域名，默认为YES；若为NO，则服务器使用其他可信任机构颁发的证书也可以建立连接，设置不验证主要用于：客户端请求的是子域名，而证书上的是另外一个域名，这种情况下，我们也可以通过注册通配符域名进行验证

`pinnedCertificates` 验证的证书内容


* 3.请求

请求部分较为简单，地址和参数视自己的情况而定


```objective-c
AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
manager.responseSerializer = [AFHTTPResponseSerializer serializer];
manager.securityPolicy = securityPolicy;

NSString * url = @"https://...";

[manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    NSLog(@"%@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
} failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    NSLog(@"%@",error);
}];
```


注：[Demo](https://github.com/SilverBulletZyp/ZYPHttpsRequest)给出了示例代码，具体的证书及地址请根据实际情况修改
