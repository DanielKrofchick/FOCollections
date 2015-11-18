Pod::Spec.new do |s|

  s.name         = "FOCollections"
  s.version      = "0.1"
  s.summary      = "UITableView and UICollectionView controller and data-source classes that make it easy to work with large code bases."
  s.homepage     = "https://github.com/DanielKrofchick/FOCollections.git"
  s.license      = "MIT"
  s.author       = { "Daniel Krofchick" => "krofchick@gmail.com" }
  s.platform     = :ios
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/DanielKrofchick/FOCollections.git", :tag => "0.1" }
  s.source_files = "FOCollections/**/*.swift"

end
