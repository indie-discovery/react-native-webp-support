require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name                = 'WebP'
  s.version             = package['version']
  s.summary             = 'Adds WebP'
  s.license             = package['license']
  s.homepage            = 'https://github.com/SmoshySmosh/react-native-webp-support'
  s.authors             = 'Techtonic'
  s.source              = { :git => 'https://github.com/SmoshySmosh/react-native-webp-support.git', :tag => s.version}
  s.source_files        = 'ios/**/*.{h,m}'
  s.vendored_frameworks = 'ios/WebP.framework', 'ios/WebPDemux.framework'
  s.resources           = 'ios/WebP.framework/WebP', 'ios/WebPDemux.framework/WebPDemux'
  s.requires_arc        = true
  s.platforms           = { :ios => "8.0", :tvos => "9.2" }
  s.dependency            'React'  
end