#
# Be sure to run `pod lib lint MoPub-Flurry-Adapters.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
s.name             = 'MoPub-Flurry-Adapters'
s.version          = '8.4.0.0'
s.summary          = 'Flurry Adapters for mediating through MoPub.'
s.description      = <<-DESC
Supported ad formats:  Interstitial, Rewarded Video, Native.\n
To download and integrate the Flurry SDK, please check this tutorial: https://developer.yahoo.com/flurry/docs/integrateflurry/ios/).\n\n
For inquiries and support, please utilize the support center: https://developer.yahoo.com/flurry/docs/faq/faqpublisher/iOS/.
DESC
s.homepage         = 'https://github.com/mopub/mopub-ios-mediation'
s.license          = { :type => 'New BSD', :file => 'LICENSE' }
s.author           = { 'PoojaChirp' => 'pshashidhar@twitter.com' }
s.source           = { :git => 'https://github.com/mopub/mopub-ios-mediation.git', :commit => 'master' }
s.ios.deployment_target = '8.0'
s.static_framework = true
s.source_files = 'Flurry/*.{h,m}'
s.dependency 'mopub-ios-sdk', '~> 4.0'
s.dependency 'Flurry-iOS-SDK/FlurrySDK', '~> 8.0'
s.dependency 'Flurry-iOS-SDK/FlurryAds', '~> 8.4.0'
end
