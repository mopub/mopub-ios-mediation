#
# Be sure to run 'pod lib lint MoPub-Aol-Adapters.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
s.name             = 'MoPub-OnebyAOL-Adapters'
s.version          = '6.8.1.1'
s.summary          = 'Aol Adapters for mediating through MoPub.'
s.description      = <<-DESC
Supported ad formats: Banner, Interstitial, Rewarded Video, Native.\n
To download and integrate the AOL SDK, please check this tutorial: http://docs.onemobilesdk.aol.com/android-ad-sdk/ (Android) and http://docs.onemobilesdk.aol.com/ios-ad-sdk/ (iOS).\n\n
For inquiries and support, please utilize the support portal: https://tools.mmedia.com/user/supportDevPortal.\n
DESC
s.homepage         = 'https://github.com/mopub/mopub-ios-mediation';
s.license          = { :type => 'New BSD', :file => 'LICENSE' }
s.author           = { 'MoPub' => 'support@mopub.com' }
s.source           = { :git => 'https://github.com/mopub/mopub-ios-mediation.git', :tag => 'aol-6.8.1.1' }
s.ios.deployment_target = '8.0'
s.static_framework = true
s.source_files = 'OnebyAOL/*.{h,m}'
s.exclude_files = 'MPStaticNativeAdImpressionTimer.{h,m}'
s.subspec 'MoPub' do |ms|
  ms.dependency 'mopub-ios-sdk', '~> 5.5'
end
s.subspec 'Network' do |ns|
end
end
