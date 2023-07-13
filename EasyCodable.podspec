Pod::Spec.new do |s|
  s.name             = 'EasyCodable'
  s.version          = '0.1.0'
  s.summary          = 'A short description of EasyCodable.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/arcangelw/EasyCodable'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'arcangel-w' => 'wuzhezmc@gmail.com' }
  s.source           = { :git => 'https://github.com/arcangelw/EasyCodable.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.13'
  s.tvos.deployment_target = '11.0'
  s.watchos.deployment_target = '7.0'
  s.swift_version = ['5']
  s.source_files = 'Sources/**/*.swift'
  s.frameworks  = 'Foundation'
end
