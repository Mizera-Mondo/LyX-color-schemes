
function Select-File {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Title,
        [Parameter(Mandatory=$true)]
        [string]$Filter,
        [Parameter(Mandatory=$false)]
        [string]$InitialDirectory = [Environment]::GetFolderPath("Desktop")

    )

    # load System.Windows.Forms program assembly
    Add-Type -AssemblyName System.Windows.Forms

    # create OpenFileDialog object
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog

    # set properties of OpenFileDialog object
    $openFileDialog.Title = $Title
    $openFileDialog.Filter = $Filter
    $openFileDialog.InitialDirectory = $InitialDirectory
    # show the dialog
    $result = $openFileDialog.ShowDialog()

    # check if user click OK
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return $openFileDialog.FileName

    }
    else {
        return $null
    }

}
#function that takes filePath as argument.
#the function get content from filePath and call Get-LyX-Path function to get the path of LyX folder
#then call Set-Color-Scheme function with the content and the path of LyX folder as parameters
#existence check of filePath is done so no need to check again
function Get-And-Apply-Color-Scheme {
    param(
        [Parameter(Mandatory=$true)]
        [string]$filePath
    )

    # get content from filePath
    $fileContent = Get-Content $filePath -Raw

    # get the path of LyX folder
    $lyxPath = Get-LyX-Preference-Path
    Write-Host ("Found LyX Preference file: " + $lyxPath) -Foregroundcolor Green
    # check if lyxPath is not null
    if ($null -ne $lyxPath) {
        # set the color scheme
        if (Test-Theme $filePath) {
            $nameOfTheme = $filePath.Substring($filePath.LastIndexOf("\") + 1);
            Write-Host "Successfully loaded color scheme file: $nameOfTheme" -ForegroundColor Green
            Set-Color-Scheme $fileContent $lyxPath
        }
        else {
            Write-Host "File '$filePath' is not a valid LyX color scheme file." -ForegroundColor Red
        }
    }
    # if lyxPath is null
    else {
        # show error message
        Write-Host "LyX folder not found." -ForegroundColor Red
    }
}

# function that checks if there's a folder start with LyX in roaming folder under appdata
# return the path of the folder if found, otherwise return null
function Get-LyX-Preference-Path {
    # get the path of roaming folder under appdata
    $appDataPath = [Environment]::GetFolderPath("ApplicationData")

    # get all folders under appdata
    $folders = Get-ChildItem $appDataPath

    # loop through all folders
    foreach ($folder in $folders) {
        # check if folder name starts with LyX
        if ($folder.Name.StartsWith("LyX")) {
            # check if there's a file named preference in the folder
            if (Test-Path ($folder.FullName + "\preferences")) {
                # return the path of the folder with preference file
                return ($folder.FullName + "\preferences")
            }
            
        }
    }

    # if no folder found, return null
    return $null
}

# function that takes 2 parameters, fileContent and targetFilePath
# load the fileContent into the targetFilePath
function Set-Color-Scheme {
    param(
        [Parameter(Mandatory=$true)]
        [string]$fileContent,
        [Parameter(Mandatory=$true)]
        [string]$targetFilePath
    )

    # check if targetFilePath exists
    if (Test-Path $targetFilePath) {
        $targetFileContent = Get-Content $targetFilePath -Raw -Encoding utf8
        $startIndex = $targetFileContent.IndexOf("# COLOR SECTION")
        $endIndex = $targetFileContent.IndexOf("# PRINTER SECTION")
        # $debugContent = $targetFileContent.Substring($startIndex, $endIndex - $startIndex - 1)
        if ($startIndex -lt 0 -or $endIndex -lt 0) {
            Write-Host "Cannot find color scheme code section. The LyX preference may be broken." -ForegroundColor Red
            return $null
        }
        else {
            $targetFileContent = $targetFileContent.Remove($startIndex, $endIndex - $startIndex - 1)
            $targetFileContent = $targetFileContent.Insert($startIndex, $fileContent)
            $targetFileContent | Out-File $targetFilePath -Encoding utf8
            Write-Host "Color scheme applied." -ForegroundColor Green
            Write-Host "Please restart LyX to see the changes." -ForegroundColor Green
        }

    }
    # if targetFilePath does not exist
    else {
        # show error message
        Write-Host "File '$targetFilePath' does not exist." -ForegroundColor Red
        return $null
    }
}

function Test-Theme {
    # take a file path as argument
    param(
        [Parameter(Mandatory=$true)]
        [string]$filePath
    )
    # load content
    $fileContent = Get-Content $filePath
    # if the 1st line starts with # COLOR SECTION
    if ($fileContent[0].StartsWith("# COLOR SECTION")) {
        return $true
    }
    else {
        return $false
    }
}



$filePaths = $args
# check if count of filepaths > 0
if ($filePaths.Count -gt 0) {
    # load only the first file
    $filePath = $filePaths[0]

    # check if file exists
    if (Test-Path $filePath) {
        # apply the color scheme
        Get-And-Apply-Color-Scheme $filePath
    }
    # if file does not exist
    else {
        # show error message
        Write-Host "File '$filePath' does not exist." -ForegroundColor Red
    }
}

# if count of filepaths <= 0, prompt user to select a file
else {
    # prompt user to select a file
    $currentPath = Get-Location
    $filePath = Select-File "Select a LyX color scheme file" "Color Scheme (*.lyxtheme)|*.lyxtheme" $currentPath
    # check if $filePath is not null
    if ($null -ne $filePath) {
        # check if file exists
        if (Test-Path $filePath) {
            Get-And-Apply-Color-Scheme $filePath
        }
        # if file does not exist
        else {
            # show error message
            Write-Host "File '$filePath' does not exist." -ForegroundColor Red
        }
    }
    # if $filePath is null
    else {
        # show error message
        Write-Host "No file selected." -ForegroundColor Red
    }

}

# Press anykey to exit
Write-Host "Press any key to continue..."
[void][System.Console]::ReadKey($true)