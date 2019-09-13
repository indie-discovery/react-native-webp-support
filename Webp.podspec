require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name             = 'Webp'
  s.version          = package['version']
  s.summary          = 'adds Webp'
  s.license          = package['license']
  s.homepage         = 'https://github.com/TGPSKI/react-native-webp-support'
  s.authors          = 'Techtonic'
  s.source           = { :git => 'https://github.com/TGPSKI/react-native-webp-support.git', :tag => s.version}
  s.source_files     = 'ios/**/*.{h,m}'
  s.requires_arc     = true
  s.platforms        = { :ios => "8.0", :tvos => "9.2" }
  s.dependency         'React'  
end
