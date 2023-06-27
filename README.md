# LyX-color-schemes
 Some editor color schemes for LyX, with scheme selector based on PowerShell.
 
 Note that some themes are NOT verbatim with the original palettes; some choices of the colors are modified for better look under LyX environment.
 
# How to Use

## Method 1: Use Color Scheme Selector
1. Clone the repository
2. Run Load-Color-Scheme.ps1 with PowerShell
3. Select and apply a .lyxtheme file

## Method 2: Manual Replacement
1. Choose a theme file (.lyxtheme) in this repo
2. Locate your LyX "perferences" file 
3. Paste **# COLOR SECTION** codes from the theme file to replace the original ones in your "preferences" file.

On locating the "preference" file and code details, follow instructions from LyX official [here](https://wiki.lyx.org/Tips/ColorSchemes). 

# TODO
~~A PowerShell-based theme selector for easy updating color schemes.~~ Finished 230627
# Reference
[ayu-colors](https://github.com/ayu-theme/ayu-colors)
