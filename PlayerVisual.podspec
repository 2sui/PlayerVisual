Pod::Spec.new do |s|
  s.name             = "PlayerVisual"
  s.version          = "1.0.0"
  s.summary          = "PlayerVisual"
  s.description      = <<-DESC
                       An optional longer description of BZLib

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/<GITHUB_USERNAME>/BZLib"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "brycezhang" => "brycezhang.cn@gmail.com" }
  s.source           = { :git => "https://github.com/<GITHUB_USERNAME>/BZLib.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.{h,m}'
  s.resource_bundles = {
    'BZLib' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'MobileCoreServices', 'CFNetwork', 'CoreGraphics'
  s.libraries  = 'z.1'
  s.dependency 'YSASIHTTPRequest', '~> 2.0.1'
end
