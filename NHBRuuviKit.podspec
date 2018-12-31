Pod::Spec.new do |spec|
  spec.name             = 'NHBRuuviKit'
  spec.version          = '1.0.0'
  spec.summary          = 'ruuvi tag BLE scanning and parsing for iOS'
  spec.description      = <<-DESC
NHBRuuviKit is an iOS framework with functionality to scan for and parse BLE advertisements from ruuvi tags. It currently supports ruuvi formats 2, 3, 4 and 5. It has good test coverage and withstand a few hours of fuzzing. It comes with a basic sample app demonstrating its usage.

NHBRuuviKit requires iOS 9 or later and Xcode 9 or later. It's written in Objective-C and uses ARC. It has no dependencies beyond standard iOS frameworks.
                       DESC

  spec.homepage         = 'http://dev.fluthaus.de/NHBRuuviKit'
  spec.license          = { :type => 'BSD 3-Clause', :file => 'LICENSE' }
  spec.author           = { 'NoHalfBits' => 'cocoapods@fluthaus.com' }
  spec.source           = { :git => 'https://github.com/fluthaus/NHBRuuviKit.git', :tag => spec.version.to_s }

  spec.platform = :ios, '9.0'
  
  spec.requires_arc = true

  spec.source_files = 'NHBRuuviKit/NHBRuuviKit/**/*.{h,m}'
  spec.public_header_files = 'NHBRuuviKit/NHBRuuviKit/*.h'
  
  spec.frameworks = 'Foundation', 'CoreBluetooth'
  
  spec.test_spec 'NHBRuuviKitTests' do |test_spec|
    test_spec.source_files = 'NHBRuuviKit/NHBRuuviKitTests/*'
  end 

end
