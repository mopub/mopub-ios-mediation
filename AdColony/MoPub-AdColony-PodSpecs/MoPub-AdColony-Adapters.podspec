#
# Be sure to run `pod lib lint MoPub-AdColony-Adapters.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
  s.name             = 'MoPub-AdColony-Adapters'
  s.version          = '3.3.8.1.0'
  s.summary          = 'AdColony Adapters for mediating through MoPub.'
  s.description      = <<-DESC
Supported ad formats: Interstitial, Rewarded Video.\n
To download and integrate the AdColony SDK, please check this tutorial: https://github.com/AdColony/AdColony-iOS-SDK-3/wiki. \n\n
For inquiries and support, please email support@adcolony.com. \n
                       DESC
  s.homepage         = 'https://github.com/mopub/mopub-ios-mediation'
  s.license          = { :type => 'New BSD', :file => 'LICENSE' }
  s.author           = { 'MoPub' => 'support@mopub.com' }
  s.source           = { :git => 'https://github.com/mopub/mopub-ios-mediation.git', :tag => "adcolony-#{s.version}" }
  s.ios.deployment_target = '8.0'
  s.static_framework = true
  s.subspec 'MoPub' do |ms|
    ms.dependency 'mopub-ios-sdk/Core', '~> 5.6'
  end
  s.subspec 'Network' do |ns|
    ns.source_files = 'AdColony/*.{h,m}'
    ns.dependency 'AdColony', '3.3.8.1'
    ns.dependency 'mopub-ios-sdk/Core', '~> 5.6'
  end
end
