#
# Be sure to run `pod lib lint HMHClassKitHelper.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HMHClassKitHelper'
  s.version          = '0.9.0'
  s.summary          = 'A library for making ClassKit a little easier to work with.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
`HMHClassKitHelper` is designed to take most of the boilerplate code required for ClassKit out of your code. It can be used both in apps and in Context Provider Extensions.
                       DESC

  s.homepage         = 'https://github.com/theMikeSwan-HMH/HMHClassKitHelper'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'theMikeSwan-HMH' => 'michael.swan@hmhco.com' }
  s.source           = { :git => 'https://github.com/theMikeSwan-HMH/HMHClassKitHelper.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.4'
  s.swift_version = '5.0'

  s.source_files = 'HMHClassKitHelper/Classes/**/*'
  
  # s.resource_bundles = {
  #   'HMHClassKitHelper' => ['HMHClassKitHelper/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
