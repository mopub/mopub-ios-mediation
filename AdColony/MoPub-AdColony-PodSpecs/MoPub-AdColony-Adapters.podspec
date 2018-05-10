#
# Be sure to run `pod lib lint MoPub-AdColony-Adapters.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
  s.name             = 'MoPub-AdColony-Adapters'
  s.version          = '3.3.0.3'
  s.summary          = 'AdColony Adapters for mediating through MoPub.'
  s.description      = <<-DESC
Supported ad formats: Interstitial, Rewarded Video.\n
To download and integrate the AdColony SDK, please check this tutorial: https://github.com/AdColony/AdColony-iOS-SDK-3/wiki. \n\n
For inquiries and support, please email support@adcolony.com. \n
                       DESC
  s.homepage         = 'https://github.com/mopub/mopub-ios-mediation'
  s.license          = { :type => 'New BSD', :file => 'LICENSE' }
  s.author           = { 'MoPub' => 'support@mopub.com' }
  s.source           = { :git => 'https://github.com/mopub/mopub-ios-mediation.git', :commit => 'master' }
  s.ios.deployment_target = '8.0'
  s.static_framework = true
  s.source_files = 'AdColony/*.{h,m}'
  s.dependency 'mopub-ios-sdk', '~> 4.0'
  s.dependency 'AdColony', '3.3.0'
end
