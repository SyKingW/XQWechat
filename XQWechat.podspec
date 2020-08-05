Pod::Spec.new do |s|

s.name         = "XQWechat"      #SDK名称
s.version      = "0.1"#版本号
s.homepage     = "https://github.com/SyKingW/XQWechat"  #工程主页地址
s.summary      = "对微信的封装."  #项目的简单描述
s.license     = "MIT"  #协议类型
s.author       = { "王兴乾" => "1034439685@qq.com" } #作者及联系方式

s.ios.deployment_target = "10.0"#iPhone

s.source       = { :svn => "https://github.com/SyKingW/XQWechat.git", :tag => "#{s.version}"}   #工程地址及版本号

# 微信问题, 需要静态库
s.static_framework  =  true

s.source_files = 'SDK/**/*.{h,m}'

s.ios.dependency 'WechatOpenSDK'

#s.ios.dependency 'XQProjectTool'


end
