Pod::Spec.new do |s|
  s.name             = 'Stay Liquid'
  s.version          = '0.1.0'
  s.summary          = 'Native Liquid Glass for Ionic & Capacitor Applications'
  s.license          = { :type => 'MIT' }
  s.homepage         = 'https://github.com/alistairheath/stay-liquid'
  s.author           = { 'Hapcha' => 'team@hapcha.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'ios/Plugin/**/*.{swift,m,h}'
  s.ios.deployment_target = '13.0'
  s.swift_version    = '5.9'
  s.dependency       'Capacitor', '>= 6.0.0'
end