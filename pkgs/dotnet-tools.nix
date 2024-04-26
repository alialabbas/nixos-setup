{ buildDotnetGlobalTool
, dotnetCorePackages
}:

let
  inherit (dotnetCorePackages) sdk_8_0;
in
buildDotnetGlobalTool {
  pname = "csharprepl";
  nugetName = "CSharpRepl";
  version = "0.6.6";
  dotnet-sdk = sdk_8_0;
  dotnet-runtime = sdk_8_0;


  nugetSha256 = "sha256-VkZGnfD8p6oAJ7i9tlfwJfmKfZBHJU7Wdq+K4YjPoRs=";
}
