---
layout: default
title: Installation
nav_order: 1
---

# Installation

GdUnit4 is a Godot plugin that needs to be installed before it can be used.
To install GdUnit4, you can either use the AssetLib within the Godot application or manually download the latest build from the GdUnit4 GitHub
repository and install it yourself.

## Installing GdUnit4 from the AssetLib

To install GdUnit4 from the AssetLib, please follow these steps:

1. Open the AssetLib from the top menu bar in the Godot application.
2. In the search bar, enter "GdUnit4".
3. Select the GdUnit4 plugin from the search results.
   ![activate-gdunit-step0]({{site.baseurl}}/assets/images/install/activate-gdunit-step0.png)
4. Click on the "Download" button to download and install the plugin.
   ![activate-gdunit-step0]({{site.baseurl}}/assets/images/install/activate-gdunit-step01.png)
5. Accept the files and press install.
   ![activate-gdunit-step0]({{site.baseurl}}/assets/images/install/activate-gdunit-step02.png)
6. Activate the plugin [follow this steps]({{site.baseurl}}/first_steps/install/#activating-the-plugin)

{% include advice.html
content="It is recommended to restart the Godot Editor after the plugin installation.<br>
Godot has an issue with the project cache when installing plugins,
for more details <a href=\"../../faq/solutions/#scriptresource-errors-after-the-plugin-is-installed\">see here</a>"
%}

## Install the Latest Build from GitHub

Please note that if you install this version, you will be working with a version that has not been officially released yet.
The master branch contains the latest development state, and this version may contain bug fixes that have not yet been officially released.
To install the latest build from GitHub, follow these steps:

{% include advice.html
content="Note that installing GdUnit4 from GitHub requires some technical knowledge and is recommended for advanced users.
If you encounter any issues during the installation process, please refer to the GdUnit4 documentation or open an issue on the GitHub repository."
%}

To install the latest build from GitHub, follow these steps:

1. Download the latest build [from GitHub here](https://github.com/MikeSchulze/gdUnit4/archive/refs/heads/master.zip).
2. Disable the current GdUnit4 plugin if you have it installed.
3. Delete the `addons/gdunit4` folder.
4. Extract the downloaded package to the `addons` folder.

## Activating the Plugin

To activate the GdUnit4 plugin, follow these steps:

1. Open your project settings by navigating to Project -> Project Settings.
![activate-gdunit-step1]({{site.baseurl}}/assets/images/install/activate-gdunit-step1.png)
2. Click on the Plugins tab and find GdUnit4 in the list of plugins and click the checkbox to activate it.
![activate-gdunit-step2]({{site.baseurl}}/assets/images/install/activate-gdunit-step2.png)
3. Once activated, the GdUnit4 inspector will be displayed in the top left corner of the Godot Editor.

Make sure to save your project settings after activating the plugin.
{% include advice.html
content="It is recommended to restart the Godot Editor after the plugin installation.<br>
Godot has an issue with the project cache when installing plugins,
for more details <a href=\"../../faq/solutions/#scriptresource-errors-after-the-plugin-is-installed\">see here</a>"
%}

## GdUnit4 Inspector

After successfully installing and activating the GdUnit4 plugin, you will find the GdUnit4 inspector in the upper left corner of the Godot editor.

* For detailed information about the inspector, please refer to the [GdUnit Inspector]({{site.baseurl}}/first_steps/inspector/)
![activate-gdunit-step3]({{site.baseurl}}/assets/images/install/activate-gdunit-step3.png)
