Pod::Spec.new do |s|
  s.name                    = 'JustTweak'
  s.version                 = '10.1.0'
  s.summary                 = 'A framework for feature flagging, locally and remotely configure and A/B test iOS apps.'
  s.description             = <<-DESC
JustTweak is a framework for feature flagging, locally and remotely configure and A/B test iOS apps.
                       DESC

  s.homepage                = 'https://github.com/justeat/JustTweak'
  s.license                 = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author                  = 'Just Eat Takeaway iOS Team'
  s.source                  = { :git => 'https://github.com/justeat/JustTweak.git', :tag => s.version.to_s }

  s.ios.deployment_target   = '11.0'
  s.swift_version           = '5.1'

  s.source_files            = 'JustTweak/Classes/**/*.swift'
  s.resource_bundle         = { 'JustTweak' => 'JustTweak/Assets/en.lproj/*' }

  s.preserve_paths = [
    '_TweakAccessorGenerator',
  ]

  # Ensure the generator script are callable via
  # ${PODS_ROOT}/<name>
  s.prepare_command = <<-PREPARE_COMMAND_END
    cp -f ./JustTweak/Assets/TweakAccessorGenerator.bundle/TweakAccessorGenerator ./_TweakAccessorGenerator
  PREPARE_COMMAND_END

end
