Pod::Spec.new do |s|
  s.name = "MaVec"
  s.version = "0.2.0"
  s.summary = "Classes representing Matrices/Vectors and operations performed on them via Accelerate wrappers and novel methods."
  s.homepage = "http://github.com/sixstringtheory/MaVec"
  s.license = "MIT"
  s.authors = { "Andrew McKnight" => "amcknight2718@gmail.com" }
  s.source = { :git => "https://github.com/sixstringtheory/MaVec.git", :tag => "0.2.0" }
  s.source_files = 'MaVec/**/*.{h,m}'
  s.requires_arc = true
end
