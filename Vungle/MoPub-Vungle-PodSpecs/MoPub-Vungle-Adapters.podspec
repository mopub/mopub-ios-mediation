#
# Be sure to run 'pod lib lint MoPub-Vungle-Adapters.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
s.name             = 'MoPub-Vungle-Adapters'
s.version          = '6.3.2.2'
s.summary          = 'Vungle Adapters for mediating through MoPub.'
s.description      = <<-DESC
Supported ad formats: Interstitial, Rewarded Video.\n
To download and integrate the Vungle SDK, please check this tutorial: https://dashboard.vungle.com/sdk.\n\n
For inquiries and support, please utilize the support page: https://support.vungle.com/hc/en-us/requests/new.\n
DESC
s.homepage         = 'https://github.com/mopub/mopub-ios-mediation'
s.license          = { :type => 'New BSD', :file => 'LICENSE' }
s.author           = { 'MoPub' => 'support@mopub.com' }
s.source           = { :git => 'https://github.com/mopub/mopub-ios-mediation.git', :tag => "vungle-#{s.version}" }
s.ios.deployment_target = '8.0'
s.static_framework = true
s.subspec 'MoPub' do |ms|
  ms.dependency 'mopub-ios-sdk', '~> 5.5'
end
s.subspec 'Network' do |ns|
  ns.source_files ='Vungle/*.{h,m}'
  ns.dependency 'VungleSDK-iOS', '6.3.2'
  ns.dependency 'mopub-ios-sdk', '~> 5.5'
end
end
