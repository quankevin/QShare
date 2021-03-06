Pod::Spec.new do |s|
  s.name         = "QShare"
  s.version      = "v1.0.2"
  s.summary      = "Gather Some Auth Share Pay."
  s.homepage     = "https://github.com/quankevin/QShare"
  s.license      = "MIT"
  s.author             = { "quankevin" => "quankevin@163.com" }
  s.social_media_url   = "http://weibo.com/quankevin"
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/quankevin/QShare.git", :tag => "v#{s.version}" }
  s.frameworks   = "SystemConfiguration","UIKit","CoreTelephony"
  s.libraries    = "stdc++", "sqlite3","z"
  s.requires_arc = true
  s.public_header_files = "QShare/ShareHeader.h"

  s.subspec 'Core' do |core|
    core.source_files = "QShare/*.{h,m}","QShare/QUtil/*.{h,m}"
  end

  s.subspec 'WeChat' do |wechat|
    wechat.dependency 'QShare/Core'
    wechat.source_files = "QShare/Wechat/SDK/*.{h,m}","QShare/Wechat/*.{h,m}"
    wechat.vendored_libraries = "QShare/Wechat/SDK/*.a"
  end

  s.subspec 'Weibo' do |weibo|
    weibo.dependency "WeiboSDK",'QShare/Core'
    weibo.source_files = "QShare/Weibo/*.{h,m}"
  end  

  s.subspec 'Tencent' do |qq|
    qq.dependency 'QShare/Core'
    qq.source_files = "QShare/Tencent/*.{h,m}"
    qq.vendored_frameworks = "QShare/Tencent/SDK/TencentOpenAPI.framework"
  end

  s.subspec 'Ali' do |ali|
    ali.dependency 'QShare/Core'
    ali.source_files = "QShare/Ali/*.{h,m}"
    ali.resources = "QShare/Ali/SDK/*.bundle"
    ali.vendored_frameworks = "QShare/Ali/SDK/AlipaySDK.framework"
  end


end
