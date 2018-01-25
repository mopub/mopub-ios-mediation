#
# Be sure to run `pod lib lint MoPub-Unity-Adapters.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
s.name             = 'MoPub-Unity-Adapters'
s.version          = '2.1.2.0'
s.summary          = 'Unity Adapters for mediating through MoPub.'
s.description      = <<-DESC
Supported ad formats: Interstitial, Rewarded Video.\n
To download and integrate the Unity Ads SDK, please check this tutorial: https://github.com/Unity-Technologies/unity-ads-iOS/releases.\n\n
For inquiries and support, please email unityads-support@unity3d.com.\n
DESC
s.homepage         = 'https://github.com/mopub/mopub-ios-mediation'
s.license          = { :type => 'New BSD', :file => 'LICENSE' }
s.author           = { 'PoojaChirp' => 'pshashidhar@twitter.com' }
s.source           = { :git => 'https://github.com/mopub/mopub-ios-mediation.git', :tag => 'master' }
s.ios.deployment_target = '8.0'
s.source_files = 'Unity/*.{h,m}'
s.dependency 'mopub-ios-sdk', '~> 4.19.0'
s.dependency 'UnityAds', '~> 2.0'
end

