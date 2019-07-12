#
# Be sure to run `pod lib lint MoPub-IronSource-Adapters.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
s.name             = 'MoPub-IronSource-Adapters'
s.version          = '6.8.4.0.1'
s.summary          = 'IronSource Adapters for mediating through MoPub.'
s.description      = <<-DESC
Supported ad formats: Interstitial, Rewarded Video.\n
To download and integrate the IronSource SDK, please check this tutorial: https://developers.ironsrc.com/ironsource-mobile/ios/ios-sdk/ \n\n
For inquiries and support, please check https://developers.ironsrc.com/submit-a-request/\n
DESC
s.homepage         = 'https://github.com/mopub/mopub-ios-mediation'
s.license          = { :type => 'New BSD', :file => 'LICENSE' }
s.author           = { 'MoPub' => 'support@mopub.com' }
s.source           = { :git => 'https://github.com/mopub/mopub-ios-mediation.git', :tag => "ironsource-#{s.version}" }
s.ios.deployment_target = '8.0'
s.static_framework = true
s.subspec 'MoPub' do |ms|
  ms.dependency 'mopub-ios-sdk/Core', '~> 5.5'
end
s.subspec 'Network' do |ns|
  ns.source_files = 'IronSource/*.{h,m}'
  ns.dependency 'IronSourceSDK','6.8.4.0'
  ns.dependency 'mopub-ios-sdk/Core', '~> 5.5'
end
end

