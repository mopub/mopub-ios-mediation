#
# Be sure to run 'pod lib lint MoPub-Vungle-Adapters.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
s.name             = 'MoPub-Vungle-Adapters'
s.version          = '5.3.2.0'
s.summary          = 'Vungle Adapters for mediating through MoPub.'
s.description      = <<-DESC
Supported ad formats: Interstitial, Rewarded Video.\n
To download and integrate the Vungle SDK, please check this tutorial: https://dashboard.vungle.com/sdk.\n\n
For inquiries and support, please utilize the support page: https://support.vungle.com/hc/en-us/requests/new.\n
DESC
s.homepage         = 'https://github.com/mopub/mopub-ios-mediation'
s.license          = { :type => 'New BSD', :file => 'LICENSE' }
s.author           = { 'PoojaChirp' => 'pshashidhar@twitter.com' }
s.source           = { :git => 'https://github.com/mopub/mopub-ios-mediation.git', :tag => 'master' }
#s.source = { :path => '**/*.{h,m}' }
s.ios.deployment_target = '8.0'
s.source_files ='Vungle/*.{h,m}'
s.dependency 'mopub-ios-sdk', '~> 4.19.0'
s.dependency 'VungleSDK-iOS', '~> 5.0'
end
