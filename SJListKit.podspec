Pod::Spec.new do |s|
  s.name             = 'SJListKit'
  s.version          = '1.1.0'
  s.summary          = 'Handy wrapper for IGListKit'

  s.description      = <<-DESC
SJListKit is a small wapper for Instagram's library IGListKit created by SuperJob.
Main features are:
  1) Easy work with autolayout cells in sections
  2) Support for different supplementary views in one list section
  3) Autolayout for supplementary views
  4) Handy wrappers for reload, insert, delete and update of cells
                       DESC

  s.homepage         = 'https://github.com/superjobru/SJListKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alexander Danilyak' => 'a.danilyak@superjob.ru' }
  s.source           = { :git => 'https://github.com/superjobru/SJListKit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/adanilyak'

  s.ios.deployment_target = '8.0'
  s.source_files = 'SJListKit/Classes/**/*'

  s.dependency 'IGListKit', '~> 3.0'
  s.dependency 'RxSwift',   '~> 4.0'
  s.dependency 'RxCocoa',   '~> 4.0'
  s.dependency 'SnapKit',   '~> 4.0'

end
