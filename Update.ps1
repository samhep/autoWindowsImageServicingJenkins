function ClearDownSpace {

    ## Clear down OSDBuilder Folders ##

    $directories = "E:\OSDBuilder\OSImport","E:\OSDBuilder\OSBuilds","E:\OSDBuilder\OSMedia","E:\OSDBuilder\Mount"

    foreach($directory in $directories){

        Get-ChildItem -Path $directory | Remove-Item -Recurse -Force -Verbose

    }

    ## Clear down WIMs in Windows Temp ##

    Get-ChildItem -Path "C:\Windows\Temp" -Filter *.wim | Remove-Item -Force -Verbose

}

## Clean up working directories ## 

ClearDownSpace

## Install Modules ## 

Install-Module -Name OSDBuilder -Force
Import-Module -Name OSDBuilder -Force

## Initialise OSDBuilder and check some config ##

Get-OSDBuilder -SetHome E:\OSDBuilder
Get-OSDBuilder -CreatePaths

if(!(Test-Path -Path "E:\WindowsISOCache")){New-Item -Path "E:\" -ItemType Directory -Name WindowsISOCache}

Get-DownOSDBuilder -ContentDownload ‘OneDriveSetup Production’

## Mount the reference image ##

$ReferenceISO = "E:\ReferenceImages\Windows10.iso"
Mount-DiskImage -ImagePath $ReferenceISO -Verbose

## Import the media, update it and run a OSBuild for each index ## 

$indexes = "Windows 10 Enterprise","Windows 10 Pro"
foreach($index in $indexes) { Import-OSMedia -ImageName $index -SkipGrid -Update -BuildNetFX }

## Eject the reference image ##

Dismount-DiskImage -ImagePath $ReferenceISO -Verbose

## Copy the new ISOs to a different folder and rename with version. ##

$folders = Get-ChildItem -Path "E:\OSDBuilder\OSBuilds"

foreach($item in $folders){
    
    ## Create ISOs ##

    New-OSBMediaISO -FullName $item.FullName

    ## Get the ISO and work out name ##

    $iso = Get-ChildItem -Path "E:\OSDBuilder\OSBuilds\$($item.Name)\ISO"

    if(!(Test-Path -Path "E:\WindowsISOCache\$($item.Name).iso")){
        
        ## Copy the ISO over if its not already there ##

        Write-Host "## INFO ## ISO for this version not found, copying to the cache"

        Copy-Item -Path $iso.FullName -Destination "E:\WindowsISOCache\$($item.Name).iso" -Verbose
    
    
    }else{

        ## Do nothing if it exists ##

        Write-Host "## INFO ## ISO already exists in the cache. Skipping...."

    }

}

## Clean up working directories ## 

ClearDownSpace
