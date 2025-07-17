# This file contains the fastlane.tools configuration
# Update this file, then run `fastlane update_fastfile`

default_platform(:ios)

platform :ios do
  desc "Run tests"
  lane :test do
    run_tests(
      scheme: "DataSenderApp",
      devices: ["iPhone 14"],
      clean: true,
      code_coverage: true
    )
  end

  desc "Build for release"
  lane :build do
    build_app(
      scheme: "DataSenderApp",
      configuration: "Release",
      clean: true,
      export_method: "app-store",
      output_directory: "./build"
    )
  end

  desc "Run SwiftLint"
  lane :lint do
    swiftlint(
      mode: :lint,
      config_file: ".swiftlint.yml",
      strict: true
    )
  end

  desc "Format code"
  lane :format do
    sh("swiftformat .")
  end

  desc "Generate documentation"
  lane :docs do
    jazzy(
      clean: true,
      author: "DataSenderApp Team",
      module: "DataSenderApp",
      swift_version: "5.8",
      theme: "apple"
    )
  end

  desc "Increment build number"
  lane :bump_build do
    increment_build_number
    commit_version_bump(
      message: "Bump build number to #{get_build_number}"
    )
  end

  desc "Create a new release"
  lane :release do |options|
    ensure_git_status_clean
    
    version = options[:version]
    increment_version_number(version_number: version) if version
    
    bump_build
    
    test
    build
    
    add_git_tag(
      tag: "v#{get_version_number}"
    )
    
    push_to_git_remote
  end

  desc "Setup development environment"
  lane :setup do
    sh("brew bundle")
    sh("mint bootstrap")
    sh("cp .env.example .env")
    sh("cp Backend/MCP/.mcp.json.example Backend/MCP/.mcp.json")
  end

  desc "Clean all derived data"
  lane :clean_all do
    clear_derived_data
    clean_build_artifacts
    sh("rm -rf ~/Library/Developer/Xcode/DerivedData/DataSenderApp-*")
  end
end