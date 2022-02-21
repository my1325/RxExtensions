Pod::Spec.new do |s|

  s.name         = "RxExtensions"
  s.version      = "0.0.1"
  s.summary      = "Some RxSwift tools For iOS"
  s.homepage     = "https://github.com/my1325/RxExtensions"
  s.license      = "MIT"
  s.platform     = :ios, "10.0"
  s.authors      = { "my1325" => "1173962595@qq.com" }
  s.source       = { :git => "https://github.com/my1325/RxExtensions.git", :tag => "#{s.version}" }
  s.default_subspecs = 'UIKit'
  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'

  s.subspec 'UIKit' do |ss|
    ss.source_files = "Sources/UIKit/*.swift"
  end
  
  s.subspec 'MJRefresh' do |ss|
    ss.source_files = 'Sources/MJRefresh/*.swift'
    ss.dependency 'MJRefresh'
  end
  
  s.subspec 'EmptyDataSet' do |ss|
    ss.source_files = 'Sources/EmptyDataSet/*.swift'
    ss.dependency 'EmptyDataSet-Swift'
  end
  
  s.subspec 'JXSegmentedView' do |ss|
    ss.source_files = 'Sources/JxSegmentedView/*.swift'
    ss.dependency 'JXSegmentedView'
    ss.dependency 'JXPagingView/Paging'
  end

  s.subspec 'Alamofire' do |ss|
    ss.source_files = 'Sources/Alamofire/*.swift'
    ss.dependency 'Alamofire'
  end

  s.subspec 'ASAuthorizationAppleIDProvider' do |ss|
    ss.platform = :ios, "13.0"
    ss.source_files = 'Sources/ASAuthorizationAppleIDProvider/*.swift'
  end 
end
