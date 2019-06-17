#
# Be sure to run `pod lib lint MoPub-Facebook-Adapters.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
s.name             = 'MoPub-FacebookAudienceNetwork-Adapters'
s.version          = '5.4.0.0'
s.summary          = 'Facebook Adapters for mediating through MoPub.'
s.description      = <<-DESC
Supported ad formats: Banners, Interstitial, Rewarded Video and Native.\n
To download and integrate the Facebook SDK, please check https://developers.facebook.com/docs/audience-network/ios/#sdk. \n\n
For inquiries and support, please visit https://developers.facebook.com/products/audience-network/faq/. \n
DESC
s.homepage         = 'https://github.com/mopub/mopub-ios-mediation'
s.license          = { :type => 'New BSD', :file => 'LICENSE' }
s.author           = { 'MoPub' => 'support@mopub.com' }
s.source           = { :git => 'https://github.com/mopub/mopub-ios-mediation.git', :tag => "facebook-#{s.version}" }
s.ios.deployment_target = '9.0'
s.static_framework = true
s.subspec 'MoPub' do |ms|
  ms.dependency 'mopub-ios-sdk/Core', '~> 5.5'
end
s.subspec 'Network' do |ns|
  ns.source_files = 'FacebookAudienceNetwork/*.{h,m}'
  ns.dependency 'mopub-ios-sdk/Core', '~> 5.5'
  ns.dependency 'FBAudienceNetwork', '5.4.0'
end
end
