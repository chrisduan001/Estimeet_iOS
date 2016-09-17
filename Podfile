# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'Estimeet' do
pod 'Alamofire'
pod 'AlamofireObjectMapper', '~> 2.1'
pod 'ObjectMapper', '~> 1.1'
pod 'Kingfisher', '~> 2.0'
pod 'PonyDebugger', :git => 'https://github.com/square/PonyDebugger.git'
pod 'Fabric'
pod 'Digits'
pod 'TwitterCore'
pod 'Crashlytics'
pod 'FBSDKCoreKit'
pod 'FBSDKLoginKit'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end
end


