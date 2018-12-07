
Pod::Spec.new do |s|
  s.name             = 'JustTweak'
  s.version          = '3.1.0'
  s.summary          = 'A framework for feature flagging, locally and remotely configure and A/B test iOS apps.'
  s.description      = <<-DESC
JustTweak is a framework for feature flagging, locally and remotely configure and A/B test iOS apps.
                       DESC

  s.homepage         = 'https://github.com/justeat/JustTweak'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.authors          = { 'Just Eat iOS team' => 'justeat.ios.team@gmail.com', 'Gianluca Tranchedone' => 'gianluca.tranchedone@just-eat.com' }
  s.source           = { :git => 'https://github.com/justeat/JustTweak.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.default_subspecs = 'Core', 'UI'
  s.ios.resource_bundle = { 'JustTweak' => 'JustTweak/Assets/**/*' }

  s.subspec 'Core' do |ss|
    ss.source_files = 'JustTweak/Classes/Core/*.swift'
  end

  s.subspec 'UI' do |ss|
    ss.dependency 'JustTweak/Core'
    ss.source_files = 'JustTweak/Classes/UI/*.swift'
  end
end

