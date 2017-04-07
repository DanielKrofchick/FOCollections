Pod::Spec.new do |s|

  s.name         = "FOCollections"
  s.version      = "0.2.0"
  s.summary      = "UITableView and UICollectionView controller and data-source classes that make it easy to work with large code bases."
  s.homepage     = "https://github.com/DanielKrofchick/FOCollections.git"
  s.license      = { :type => 'MIT', :text => <<-LICENSE
      LICENSE
    }
  s.author       = { "Daniel Krofchick" => "krofchick@gmail.com" }
  s.ios.deployment_target = '8.0'
  s.source       = {
      :git => "https://github.com/DanielKrofchick/FOCollections.git",
      :tag => "0.2.1"
  }
  s.source_files = 'FOCollections/**/*.{d,h,m,swift}'

end
