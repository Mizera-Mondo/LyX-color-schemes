
function Select-File {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Title,
        [Parameter(Mandatory=$true)]
        [string]$Filter
    )

    # load System.Windows.Forms program assembly
    Add-Type -AssemblyName System.Windows.Forms

    # create OpenFileDialog object
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog

    # set properties of OpenFileDialog object
    $openFileDialog.Title = $Title
    $openFileDialog.Filter = $Filter

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
    $fileContent = Get-Content $filePath

    # get the path of LyX folder
    $lyxPath = Get-LyX-Preference-Path
    Write-Output $lyxPath
    # check if lyxPath is not null
    if ($null -ne $lyxPath) {
        # set the color scheme
        if (Test-Theme $filePath) {
            #Set-Color-Scheme $fileContent $lyxPath
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
    #TODO: Replace color codes
    param(
        [Parameter(Mandatory=$true)]
        [string]$fileContent,
        [Parameter(Mandatory=$true)]
        [string]$targetFilePath
    )

    # check if targetFilePath exists
    if (Test-Path $targetFilePath) {
        # load the fileContent into the targetFilePath
        $fileContent | Out-File $targetFilePath
    }
    # if targetFilePath does not exist
    else {
        # show error message
        Write-Host "File '$targetFilePath' does not exist." -ForegroundColor Red
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
    # check if the 1st line is a single # character
    # if the 2nd line starts with # COLOR SECTION
    # if the 3rd line is a single # character
    # if all conditions are met, return true
    if ($fileContent[0] -eq "#" -and $fileContent[1].StartsWith("# COLOR SECTION") -and $fileContent[2] -eq "#") {
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
    $filePath = Select-File -Title "Select a LyX color scheme file" -Filter "LyX Color Scheme (*.lyxtheme)|*.lyxtheme"
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