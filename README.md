# AggregateSource

聚合源基于"Kanna"以及"Alamofire"爬取腾讯、百度、天天查询以及其他网站数据，聚合成新的源。

## 要求
- macOS 10.15
- Xcode 11.0
- Swift 5.0

## 支持的平台
- macOS 10.15
- iOS 13.0
- tvOS 13.0
- watchOS 6.0

## 特点

- [x] 支持Combine

## SPM安装

[Swift 包管理器](https://swift.org/package-manager/) 是一个用于自动分发 Swift 代码的工具，并集成到 `swift` 编译器中。

设置好 Swift 包后，添加 AggregateSource 作为依赖项就像将其添加到 `Package.swift` 的 `dependencies` 值中一样简单。

```swift
dependencies: [
    .package(url: "https://github.com/xtzPioneer/AggregateSource.git", .upToNextMajor(from: "0.1.0")),
]
```

## 许可证

AggregateSource 是根据麻省理工学院许可证发布的。[见许可证](https://github.com/xtzPioneer/AggregateSource/blob/main/LICENSE)有关详细信息。