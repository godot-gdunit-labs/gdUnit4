---
layout: default
title: Setup/Installation
nav_order: 1
---

## GdUnit4 C# Test Setup

### How GdUnit4 Integrates C# Test Support

GdUnit4 integrates C# testing capabilities through the [GdUnit4Net](https://github.com/godot-gdunit-labs/gdUnit4Net){:target="_blank"} project.
This integration works by loading the necessary dependencies and utilizing the GdUnit4Net test engine to discover and execute C# tests directly
within the Godot editor environment.

The complete list of features and capabilities provided by the C# testing integration can be found on the
[GdUnit4Net GitHub page](https://github.com/godot-gdunit-labs/gdUnit4Net){:target="_blank"}.

💡 **Recommended Approach:** For optimal C# testing experience, use dedicated IDEs like **JetBrains Rider**, **Visual Studio**,
or **Visual Studio Code** instead of the Godot editor.

⚠️ **Debugging Limitation:** Debugging C# tests inside the Godot editor is **not supported**. Use external IDEs for debugging capabilities.

### Framework Support

GdUnit4 v7 requires at least Godot 4.7. The supported .NET frameworks and C# language versions are defined by GdUnit4Net,
check the [GdUnit4Net README](https://github.com/godot-gdunit-labs/gdUnit4Net#readme){:target="_blank"} for the current list.

Before diving into gdUnit4 C# testing API, make sure your project is configured appropriately.<br>
Follow the steps outlined in the
[Official Godot documentary](https://docs.godotengine.org/en/stable/tutorials/scripting/c_sharp/c_sharp_basics.html#setting-up-c-for-godot){:target="_blank"}

1. Setup your Project

   Open your project file (\*.csproj) and add the GdUnit4Net package dependencies.
   GdUnit4Net is released independently of GdUnit4, use the latest versions listed on nuget.org:

   |Package|Latest version|
   |---|---|
   |[gdUnit4.api](https://www.nuget.org/packages/gdUnit4.api/#versions-body-tab){:target="_blank"}|![gdUnit4.api](https://img.shields.io/nuget/vpre/gdUnit4.api)|
   |[gdUnit4.test.adapter](https://www.nuget.org/packages/gdUnit4.test.adapter/#versions-body-tab){:target="_blank"}|![gdUnit4.test.adapter](https://img.shields.io/nuget/vpre/gdUnit4.test.adapter)|
   |[gdUnit4.analyzers](https://www.nuget.org/packages/gdUnit4.analyzers/#versions-body-tab){:target="_blank"}|![gdUnit4.analyzers](https://img.shields.io/nuget/vpre/gdUnit4.analyzers)|
   |[Microsoft.NET.Test.Sdk](https://www.nuget.org/packages/Microsoft.NET.Test.Sdk/#versions-body-tab){:target="_blank"}|![Microsoft.NET.Test.Sdk](https://img.shields.io/nuget/v/Microsoft.NET.Test.Sdk)|

2. Ensure a .NET SDK supported by GdUnit4Net is installed.

   ```bash
   dotnet --list-sdks
   ```

   If no supported SDK is installed, you can [download it here](https://dotnet.microsoft.com/en-us/download/dotnet){:target="_blank"}<br>
   If you encounter issues with older SDKs, consider uninstalling them.<br>
   Here is a complete example of what your project should look like. Use the `Godot.NET.Sdk` version of your Godot editor,
   a target framework supported by GdUnit4Net, and replace `x.y.z` with the latest package versions from the table above.

   ```cs
    <Project Sdk="Godot.NET.Sdk/4.7.0">
      <PropertyGroup>
        <TargetFramework>net8.0</TargetFramework>
        <!--Force nullable warnings, you can disable if you want-->
        <Nullable>enable</Nullable>
        <CopyLocalLockFileAssemblies>true</CopyLocalLockFileAssemblies>
        <!--Disable warning of invalid/incompatible GodotSharp version-->
        <NoWarn>NU1605</NoWarn>
      </PropertyGroup>

      <!-- gdUnit4 package dependencies -->
      <ItemGroup>
        <PackageReference Include="Microsoft.NET.Test.Sdk" Version="x.y.z"/>
        <PackageReference Include="gdUnit4.api" Version="x.y.z"/>
        <PackageReference Include="gdUnit4.test.adapter" Version="x.y.z"/>
        <PackageReference Include="gdUnit4.analyzers" Version="x.y.z">
          <PrivateAssets>none</PrivateAssets>
          <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
        </PackageReference>
      </ItemGroup>
    </Project>
   ```

## The GdUnit4 Godot Editor C# Support

GdUnit4 supports with [GdUnit4Net](https://github.com/godot-gdunit-labs/gdUnit4Net/blob/master/Api/README.md){:target="_blank"}
to write and run tests inside the Godot editor.
For support **Visual Studio**, **Visual Studio Code** and **JetBrains Rider** [check out here]({{site.baseurl}}/csharp_project_setup/vstest-adapter/){:target="_blank"}.

## Test your C# build settings in the Godot Editor

Open the **MSBuild** inspector at the bottom of the Godot editor and press **Rebuild Solution**.
![cs-build-test]({{site.baseurl}}/assets/images/install/cs-build-test.png)
The output should indicate that the project is built successfully.

### Running C# Tests inside the Godot Editor

How to [run test]({{site.baseurl}}/first_steps/how-to-run-tests/)

## Using External C# Editor

Open your Godot editor settings, and navigate to **dotnet** and select your preferred C# tool.
![cs-setup]({{site.baseurl}}/assets/images/install/cs-setup.png)
