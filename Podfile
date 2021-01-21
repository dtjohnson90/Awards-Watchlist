target 'Oscars' do
	platform :ios, '10.0'
	use_frameworks!
	pod 'NVActivityIndicatorView'
	pod 'GoogleSignIn'
	pod 'SwiftyStoreKit'
	pod 'TextFieldEffects' 
	pod 'youtube-ios-player-helper'
	pod "HorizontalStickyHeaderLayout"
end

target 'Awards Watchlist TV' do
	platform :tvos, '12.0'
	use_frameworks!
	pod 'Firebase/Auth'          # Limited watchOS support
	pod 'Firebase/Firestore'     # No watchOS support yet
	pod 'Firebase/Functions'     # No watchOS support yet
	pod 'Firebase/Messaging'
	pod 'Firebase/Storage'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end


