
  Pod::Spec.new do |s|
    s.name = 'CapacitorPluginSecureStorage'
    s.version = '0.0.1'
    s.summary = 'This plugin is for secure storage capacitor.'
    s.license = 'MIT'
    s.homepage = 'https://github.com/dwlrathod/capacitor-plugin-secure-storage.git'
    s.author = 'KomedHealth'
    s.source = { :git => 'https://github.com/dwlrathod/capacitor-plugin-secure-storage.git', :tag => s.version.to_s }
    s.source_files = 'ios/Plugin/**/*.{swift,h,m,c,cc,mm,cpp}'
    s.ios.deployment_target  = '11.0'
    s.dependency 'Capacitor'
  end