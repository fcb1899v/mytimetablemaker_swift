# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'mytimetablemaker' do

  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks! :linkage => :static

  # Pods for mytimetablemaker
  # Add the Firebase pod for Google Analytics
  
  pod 'Firebase/Analytics'

  # Add the pods for any other Firebase products you want to use in your app
  # For example, to use Firebase Authentication and Cloud Firestore
  pod 'Firebase'
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Google-Mobile-Ads-SDK'

  target 'mytimetablemakerTests' do
    inherit! :search_paths
    use_frameworks! :linkage => :static
  end

  target 'mytimetablemakerUITests' do
    use_frameworks! :linkage => :static
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
