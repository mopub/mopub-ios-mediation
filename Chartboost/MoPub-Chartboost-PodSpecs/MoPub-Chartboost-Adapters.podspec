#
# Be sure to run `pod lib lint MoPub-Chartboost-Adapters.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
s.name             = 'MoPub-Chartboost-Adapters'
s.version          = '7.5.0.0'
s.summary          = 'Chartboost Adapters for mediating through MoPub.'
s.description      = <<-DESC
Supported ad formats: Interstitial, Rewarded Video.\n
To download and integrate the Chartboost SDK, please check this tutorial: https://answers.chartboost.com/en-us/child_article/ios \n\n
For inquiries and support, please reach out to https://answers.chartboost.com/en-us/zingtree. \n
DESC
s.homepage         = 'https://github.com/mopub/mopub-ios-mediation'
s.license          = { :type => 'New BSD', :file => 'LICENSE' }
s.author           = { 'MoPub' => 'support@mopub.com' }
s.source           = { :git => 'https://github.com/mopub/mopub-ios-mediation.git', :tag => "chartboost-#{s.version}" }
s.ios.deployment_target = '8.0'
s.static_framework = true
s.subspec 'MoPub' do |ms|
  ms.dependency 'mopub-ios-sdk/Core', '~> 5.5'
end
s.subspec 'Network' do |ns|
  ns.source_files = 'Chartboost/*.{h,m}'
  ns.dependency 'ChartboostSDK', '7.5.0'
  ns.dependency 'mopub-ios-sdk/Core', '~> 5.5'
end
end
