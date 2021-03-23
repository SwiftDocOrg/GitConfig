# GitConfig

A Swift library for parsing [Git configuration files](https://git-scm.com/docs/git-config).

## Requirements

- Swift 5.3+

## Usage

```swift
let example = #"""
# This is an example .git/config file
[core]
    repositoryformatversion = 0
    filemode = true
    bare = false

    # equivalent to "blank-at-eol,blank-at-eof"
    whitespace = trailing-space

# [unused]
#   should-be-parsed = false

[remote "origin"]
    url = git@github.com:SwiftDocOrg/GitConfig.git
    fetch = +refs/heads/*:refs/remotes/origin/*
    gh-resolved = base
"""#

let configuration = try Configuration(example)
configuration.sections.count // 2

// Sections are stored in declaration order
// and can be retrieved by array index or by name
configuration["core"] == configuration.sections[0] // true

configuration["core"]?["repositoryformatversion"] // 0
configuration["core"]?["filemode"] // true
configuration["core"]?["bare"] // "trailing-space"
configuration["core"]?["whitespace"] // false
configuration["core"]?["undefined"] // nil

let remote = configuration["remote \"origin\""]
remote["url"] // "git@github.com:SwiftDocOrg/GitConfig.git"
remote["fetch"] // "+refs/heads/*:refs/remotes/origin/*"
remote["gh-resolved"] // "base"
```

## Installation

### Swift Package Manager

Add the GitConfig package to your target dependencies in `Package.swift`:

```swift
import PackageDescription

let package = Package(
  name: "YourProject",
  dependencies: [
    .package(
        url: "https://github.com/SwiftDocOrg/GitConfig",
        from: "0.0.1"
    ),
  ]
)
```

Add `GitConfig` as a dependency to your target(s):

```swift
targets: [
.target(
    name: "YourTarget",
    dependencies: ["GitConfig"]),
```

## License

MIT

## Contact

Mattt ([@mattt](https://twitter.com/mattt))
