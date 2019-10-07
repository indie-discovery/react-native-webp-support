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
  s.source_files        = 'ios/*.{h,m}'
  s.requires_arc        = true
  s.platforms           = { :ios => "9.0" }
  s.dependency            'React'
  s.dependency            'SDWebImageWebPCoder'
end