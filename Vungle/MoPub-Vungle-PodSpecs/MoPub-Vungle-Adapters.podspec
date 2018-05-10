#
# Be sure to run 'pod lib lint MoPub-Vungle-Adapters.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
s.name             = 'MoPub-Vungle-Adapters'
s.version          = '5.4.0.1'
s.summary          = 'Vungle Adapters for mediating through MoPub.'
s.description      = <<-DESC
Supported ad formats: Interstitial, Rewarded Video.\n
To download and integrate the Vungle SDK, please check this tutorial: https://dashboard.vungle.com/sdk.\n\n
For inquiries and support, please utilize the support page: https://support.vungle.com/hc/en-us/requests/new.\n
DESC
s.homepage         = 'https://github.com/mopub/mopub-ios-mediation'
s.license          = { :type => 'New BSD', :file => 'LICENSE' }
s.author           = { 'MoPub' => 'support@mopub.com' }
s.source           = { :git => 'https://github.com/mopub/mopub-ios-mediation.git', :commit => 'master' }
s.ios.deployment_target = '8.0'
s.static_framework = true
s.source_files ='Vungle/*.{h,m}'
s.dependency 'mopub-ios-sdk', '~> 4.0'
s.dependency 'VungleSDK-iOS', '5.4.0'
end
