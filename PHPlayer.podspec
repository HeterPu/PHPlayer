Pod::Spec.new do |s|
  s.name         = "PHPlayer"
  s.version      = "1.3"
  s.ios.deployment_target = '8.0'
  s.summary      = "BaseOn IJKFRAMEWORK , encapsule three player MPPlayer AVPlayer FFPlayer， supply three level playerview for use and custom."
  s.homepage     = "https://github.com/HeterPu/PHPlayer"
  s.license      = "MIT"
  s.author             = { "HuterPu" => "wycgpeterhu@sina.com" }
  s.social_media_url   = "http://weibo.com/u/2342495990"
  s.source       = { :git => "https://github.com/HeterPu/PHPlayer.git", :tag => s.version }
  s.source_files  = "PHPlayer_DEMO/PHPlayerDemo/PHPlayer/**/*.{h,m,c}"
  s.requires_arc = true

  s.resources = "PHPlayer_DEMO/PHPlayerDemo/PHPlayer/**/*.{xib}"
  s.frameworks = 'Foundation', 'UIKit'
  s.dependency  'ijkplayer'
end
