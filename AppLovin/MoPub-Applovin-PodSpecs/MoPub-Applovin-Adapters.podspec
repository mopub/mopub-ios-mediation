#
# Be sure to run `pod lib lint MoPub-Applovin-Adapters.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
  s.name             = 'MoPub-Applovin-Adapters'
  s.version          = '6.7.1.0'
  s.summary          = 'Applovin Adapters for mediating through MoPub.'
  s.description      = <<-DESC
Supported ad formats: Banners, Interstitial, Rewarded Video and Native.\n
To download and integrate the Applovin SDK, please check this page: https://www.applovin.com/integration#iosMoPubIntegration. \n\n
For inquiries and support, please visit https://www.applovin.com/support \n
                       DESC
  s.homepage         = 'https://github.com/mopub/mopub-ios-mediation'
  s.license          = { :type => 'New BSD', :file => 'LICENSE' }
  s.author           = { 'MoPub' => 'support@mopub.com' }
  s.source           = { :git => 'https://github.com/mopub/mopub-ios-mediation.git', :tag => "applovin-#{s.version}" }
  s.ios.deployment_target = '9.0'
  s.static_framework = true
  s.subspec 'MoPub' do |ms|
    ms.dependency 'mopub-ios-sdk/Core', '~> 5.5'
  end
  s.subspec 'Network' do |ns|
    ns.source_files = 'Applovin/*.{h,m}'
    ns.dependency 'AppLovinSDK', '6.7.1'
    ns.dependency 'mopub-ios-sdk/Core', '~> 5.5'
  end
end
