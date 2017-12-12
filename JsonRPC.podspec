Pod::Spec.new do |s|
  s.name              = 'JsonRPC'
  s.version           = '0.1.0'
  s.license           = 'MIT'
  s.documentation_url = 'http://www.tinrobots.org/JsonRPC'  
  s.summary           = 'A JSON-RPC 2.0 library written in Swift.'
  s.homepage          = 'http://www.tinrobots.org/JsonRPC'
  s.authors           = { 'Alessandro Marzoli' => 'me@alessandromarzoli.com' }
  s.source            = { :git => 'https://github.com/tinrobots/JsonRPC.git', :tag => s.version }
  s.requires_arc      = true
  
  s.ios.deployment_target     = '10.0'
  s.osx.deployment_target     = '10.12'
  s.tvos.deployment_target    = '10.0'
  s.watchos.deployment_target = '3.0'

  s.source_files =  'Sources/*.swift', 
                    'Support/*.{h,m}'
  
end
