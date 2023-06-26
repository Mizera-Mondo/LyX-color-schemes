
function Select-File {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Title,
        [Parameter(Mandatory=$true)]
        [string]$Filter
    )

    # 加载 System.Windows.Forms 程序集
    Add-Type -AssemblyName System.Windows.Forms

    # 创建 OpenFileDialog 对象
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog

    # 设置对话框属性
    $openFileDialog.Title = $Title
    $openFileDialog.Filter = $Filter

    # 显示选择文件对话框
    $result = $openFileDialog.ShowDialog()

    # 检查用户是否点击了 "确定" 按钮
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        # return the selected file
        return $openFileDialog.FileName

    }

}
#function that takes filePath as argument.
#the function get content from filePath and call Get-LyX-Path function to get the path of LyX folder
#then call Set-Color-Scheme function with the content and the path of LyX folder as parameters
#existence check of filePath is done so no need to check again
function Load-Color-Scheme {
    param(
        [Parameter(Mandatory=$true)]
        [string]$filePath
    )

    # get content from filePath
    $fileContent = Get-Content $filePath

    # get the path of LyX folder
    $lyxPath = Get-LyX-Path

    # check if lyxPath is not null
    if ($null -ne $lyxPath) {
        # set the color scheme
        Set-Color-Scheme $fileContent "$lyxPath\LyX2.3\Resources\ui\color-schemes\default.lyxrc"
    }
    # if lyxPath is null
    else {
        # show error message
        Write-Host "LyX folder not found." -ForegroundColor Red
    }
}

# function that checks if there's a folder start with LyX in roaming folder under appdata
# return the path of the folder if found, otherwise return null
function Get-LyX-Path {
    # get the path of roaming folder under appdata
    $appDataPath = [Environment]::GetFolderPath("ApplicationData")

    # get all folders under appdata
    $folders = Get-ChildItem $appDataPath

    # loop through all folders
    foreach ($folder in $folders) {
        # check if folder name starts with LyX
        if ($folder.Name.StartsWith("LyX")) {
            # return the path of the folder
            return $folder.FullName
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
        # load the fileContent into the targetFilePath
        $fileContent | Out-File $targetFilePath
    }
    # if targetFilePath does not exist
    else {
        # show error message
        Write-Host "File '$targetFilePath' does not exist." -ForegroundColor Red
    }
}




$filePaths = $args

# check if count of filepaths > 0
if ($filePaths.Count -gt 0) {
    # load only the first file
    $filePath = $filePaths[0]

    # check if file exists
    if (Test-Path $filePath) {
        # load the file
        . $filePath
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
    $filePath = Select-File -Title "Select a LyX color scheme file" -Filter "LyX Color Scheme Files (*.lyxtheme)|*.lyxtheme"

    # check if file exists
    if (Test-Path $filePath) {
        # load the file
        . $filePath
    }
    # if file does not exist
    else {
        # show error message
        Write-Host "File '$filePath' does not exist." -ForegroundColor Red
    }
}