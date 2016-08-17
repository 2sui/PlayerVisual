Pod::Spec.new do |spec|
  spec.name = "PlayerVisual"
  spec.version = "1.0.0"
  spec.summary = "PlayerVisual."
  spec.homepage = "https://gitlab.com/QPHi/PlayerVisual.git"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "2sui" => 'shuaiqi2sui@gmail.com' }
  spec.social_media_url = "https://gitlab.com/QPHi/"

  spec.platform = :ios, "9.0"
  spec.requires_arc = true
  spec.source = { git: "https://gitlab.com/QPHi/PlayerVisual.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "PlayerVisual/**/*.{h,swift}"

  spec.dependency "SnapKit"
end
