
  Pod::Spec.new do |s|
    s.name = 'KomedCapacitorPluginSecureStorage'
    s.version = '0.0.1'
    s.summary = 'This plugin is for secure storage capacitor.'
    s.license = 'MIT'
    s.homepage = 'https://github.com/komed-health/capacitor-plugin-secure-storage'
    s.author = 'KomedHealth'
    s.source = { :git => 'https://github.com/komed-health/capacitor-plugin-secure-storage', :tag => s.version.to_s }
    s.source_files = 'ios/Plugin/**/*.{swift,h,m,c,cc,mm,cpp}'
    s.ios.deployment_target  = '11.0'
    s.dependency 'Capacitor'
  end