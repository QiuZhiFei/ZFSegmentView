platform :ios, '8.0'
inhibit_all_warnings!
use_frameworks!

target 'ZFSegmentView' do

pod 'ZFSegmentView',
  #    :git => 'https://zhifei_qiu@bitbucket.org/byguitarios/guitarstation.git', :commit => '175982260415d6612eaa27721ecef47166f6c8af'
      :path => 'ZFSegmentView.podspec'
end


post_install do |installer| installer.pods_project.targets.each do |target| target.build_configurations.each do |config| config.build_settings['SWIFT_VERSION'] = '3.0' end end end