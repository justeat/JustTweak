
Pod::Spec.new do |s|
  s.name                    = 'JustTweak'
  s.version                 = '5.1.2'
  s.summary                 = 'A framework for feature flagging, locally and remotely configure and A/B test iOS apps.'
  s.description             = <<-DESC
JustTweak is a framework for feature flagging, locally and remotely configure and A/B test iOS apps.
                       DESC

  s.homepage                = 'https://github.com/justeat/JustTweak'
  s.license                 = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.authors                 = { 'Gianluca Tranchedone' => 'gianluca.tranchedone@just-eat.com',
                                'Alberto De Bortoli' => 'alberto.debortoli@just-eat.com',
                                'Dimitar Chakarov' => 'dimitar.chakarov@just-eat.com' }
  s.source                  = { :git => 'https://github.com/justeat/JustTweak.git', :tag => s.version.to_s }

  s.ios.deployment_target   = '11.0'
  s.swift_version           = '5.1'
  
  s.source_files            = 'JustTweak/Classes/**/*.swift'
  s.resource_bundle         = { 'JustTweak' => 'JustTweak/Assets/**/*' }
  
end

