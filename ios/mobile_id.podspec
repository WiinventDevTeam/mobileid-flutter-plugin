#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
#
Pod::Spec.new do |s|
  s.name             = "mobile_id"
  s.version          = "1.1.0"
  s.summary          = "MobileID Flutter Plugin"
  s.description      = "MobileID Flutter Plugin"
  s.homepage         = "https://mobileid.vn"
  s.license          = { :type => "Commercial" }
  s.author           = { "Wiinvent" => "info@wiinvent.tv" }
  s.source           = { :path => "." }
  s.source_files     = "Classes/**/*"
  s.dependency "Flutter"
  s.vendored_frameworks = "MobileIdSdk.xcframework"
  s.platform = :ios, "13.0"
  s.swift_version = "5.0"

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { "DEFINES_MODULE" => "YES", "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "i386" }
end
