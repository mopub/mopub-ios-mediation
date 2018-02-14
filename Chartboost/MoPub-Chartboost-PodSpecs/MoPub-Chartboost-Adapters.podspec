#
# Be sure to run `pod lib lint MoPub-Chartboost-Adapters.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
s.name             = 'MoPub-Chartboost-Adapters'
s.version          = '7.0.4.1'
s.summary          = 'Chartboost Adapters for mediating through MoPub.'
s.description      = <<-DESC
Supported ad formats: Interstitial, Rewarded Video.\n
To download and integrate the Chartboost SDK, please check this tutorial: https://answers.chartboost.com/en-us/child_article/ios \n\n
For inquiries and support, please reach out to https://answers.chartboost.com/en-us/zingtree. \n
DESC
s.homepage         = 'https://github.com/mopub/mopub-ios-mediation'
s.license          = { :type => 'New BSD', :file => 'LICENSE' }
s.author           = { 'PoojaChirp' => 'pshashidhar@twitter.com' }
s.source           = { :git => 'https://github.com/mopub/mopub-ios-mediation.git', :tag => 'master' }
s.ios.deployment_target = '8.0'
s.source_files = 'Chartboost/*.{h,m}'
s.dependency 'mopub-ios-sdk', '~> 4.0'
s.dependency 'ChartboostSDK', '~> 7.0'
end
