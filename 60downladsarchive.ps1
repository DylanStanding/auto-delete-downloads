# Find the username
$findUsername = $env:USERNAME

# Define the paths for the Downloads and Archive folders
$DownloadsPath = "C:\Users\$findUsername\Downloads"
$ArchiveFolderPath = "C:\Users\$findUsername\Archive"

# Get the current date in a folder-friendly format
$DateFolderName = (Get-Date).ToString('yyyy-MM-dd')
$ArchiveDatePath = Join-Path -Path $ArchiveFolderPath -ChildPath $DateFolderName

# Function to handle file operations
function PerformFileOperations {
    try {
        # Check if Downloads folder exists
        if (Test-Path -Path $DownloadsPath) {
            # Create the dated folder inside the Archive folder
            $null = New-Item -ItemType Directory -Path $ArchiveDatePath -Force

            # Copy the entire Downloads folder contents
            Copy-Item -Path "$DownloadsPath\*" -Destination $ArchiveDatePath -Recurse

            # Move contents of Downloads to Recycle Bin
            Get-ChildItem -Path $DownloadsPath | ForEach-Object {
                Add-Type -AssemblyName Microsoft.VisualBasic
                [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($_.FullName, 'OnlyErrorDialogs', 'SendToRecycleBin')
            }

            # Empty the Recycle Bin
            $shell = New-Object -ComObject Shell.Application
            $shell.Namespace(0xA).Items() | ForEach-Object { $_.InvokeVerb('Delete') }
        } else {
            Write-Host "Downloads folder does not exist at $DownloadsPath"
        }
    } catch {
        Write-Host "Error: $($_.Exception.Message)"
    }
}

# Function to create a gradient panel
function CreateGradientPanel($width, $height) {
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Size = New-Object System.Drawing.Size($width, $height)
    $panel.BackColor = [System.Drawing.Color]::Transparent

    $bitmap = New-Object System.Drawing.Bitmap($width, $height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)

    $rect = New-Object System.Drawing.Rectangle(0, 0, $width, $height)
    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, [System.Drawing.Color]::Purple, [System.Drawing.Color]::Blue, 0.0)
    
    $graphics.FillRectangle($brush, $rect)
    $panel.BackgroundImage = $bitmap

    return $panel
}

# Function to show high-level explanation
function ShowExplanation {
    $explanationForm = New-Object System.Windows.Forms.Form
    $explanationForm.Text = 'Code Explanation'
    $explanationForm.Size = New-Object System.Drawing.Size(400,300)
    $explanationForm.StartPosition = 'CenterScreen'
    $explanationForm.BackColor = 'Black'

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Multiline = $true
    $textBox.Dock = 'Fill'
    $textBox.Text = "This script automates the process of archiving and cleaning up the Downloads folder. It copies the current contents of the Downloads folder to a new folder named with today's date within an Archive directory. Then, it moves the original files in the Downloads folder to the Recycle Bin and empties the Recycle Bin to complete the cleanup."
    $textBox.BackColor = 'Black'
    $textBox.ForeColor = 'White'
    $textBox.TextAlign = 'Center'
    $textBox.ReadOnly = $true
    $textBox.ScrollBars = 'Vertical'
    $explanationForm.Controls.Add($textBox)

    $explanationForm.ShowDialog()
}

# Create a Windows Form to notify the user
try {
    Add-Type -AssemblyName System.Windows.Forms
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Script Notification'
    $form.Size = New-Object System.Drawing.Size(315,200)
    $form.StartPosition = 'CenterScreen'
    $form.BackColor = 'Black'

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Processing Downloads Folder..."
    $label.Location = New-Object System.Drawing.Point(10,10)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.TextAlign = 'MiddleCenter'
    $label.ForeColor = 'White'
    $label.BackColor = 'Black'
    $form.Controls.Add($label)

    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(10,40)
    $progressBar.Size = New-Object System.Drawing.Size(280,20)
    $progressBar.Style = 'Continuous'
    $form.Controls.Add($progressBar)

    # Create and add the gradient panel
    $gradientPanel = CreateGradientPanel $progressBar.Width $progressBar.Height
    $gradientPanel.Location = $progressBar.Location
    $gradientPanel.BackColor = [System.Drawing.Color]::Transparent
    $form.Controls.Add($gradientPanel)
    $form.Controls.SetChildIndex($gradientPanel, 0) # Ensure the panel is on top

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(100,110)
    $okButton.Size = New-Object System.Drawing.Size(100,30)
    $okButton.Text = 'OK'
    $okButton.BackColor = 'DimGray'
    $okButton.ForeColor = 'White'
    $okButton.Add_Click({
        ShowExplanation
        $form.Close()
    })
    $form.Controls.Add($okButton)

    $showLocationButton = New-Object System.Windows.Forms.Button
    $showLocationButton.Location = New-Object System.Drawing.Point(10,70)
    $showLocationButton.Size = New-Object System.Drawing.Size(280,30)
    $showLocationButton.Text = 'Show File Location'
    $showLocationButton.ForeColor = 'White'
    $showLocationButton.BackColor = 'DimGray'
    $showLocationButton.Add_Click({
        Start-Process "explorer.exe" $ArchiveDatePath
        ShowExplanation
    })
    $form.Controls.Add($showLocationButton)

    # Timer for updating the progress bar and moving the gradient panel
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 90 # Slightly faster movement
    $timer.Add_Tick({
        if ($progressBar.Value -lt $progressBar.Maximum) {
            $progressBar.Value += 1
            $gradientPanel.Width = ($progressBar.Value / $progressBar.Maximum) * $progressBar.Width
        } else {
            $progressBar.Value = $progressBar.Minimum
        }
    })
    $timer.Start()

    # Timer to change label text and stop animation after 11 seconds
    $updateLabelTimer = New-Object System.Windows.Forms.Timer
    $updateLabelTimer.Interval = 9500 # 11 seconds
    $updateLabelTimer.Add_Tick({
        $label.Text = "Operation Complete"
        $timer.Stop()
        $updateLabelTimer.Stop()
    })
    $updateLabelTimer.Start()

    # Background task for file operations
    $backgroundJob = Start-Job -ScriptBlock {
        PerformFileOperations $using:DownloadsPath $using:ArchiveDatePath
    }

    # Show the form
    $form.ShowDialog()

    # Stop timers and wait for the background job to finish if it's still running
    $timer.Stop()
    $updateLabelTimer.Stop()
    Receive-Job -Job $backgroundJob -Wait
    Remove-Job -Job $backgroundJob

    # Optional: Output for confirmation
    Write-Host "Script execution completed."
} catch {
    Write-Host "Error creating form: $($_.Exception.Message)"
}
