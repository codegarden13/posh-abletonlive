#region Ableton - Processing as xml
#region ableton functions

function backup-Library ($source, $target){
# https://blog-it-solutions.de/mac-os-backup-mit-rsync/

#& rsync  -arg --no-perms --delete --group  $source $target
#& rsync -cazEL --delete --progress --verbose "/Volumes/Macintosh HD 2/TS-259 Pro+/Test/" admin@192.168.1.20:/share/Public
& rsync  -arg --delete --group --verbose --log-file="/users/salomon/Documents/1. Projekte/CODING/test.log"  $source $target

} # diff backup
function get-abletonsets ($folder) {
    #
    # get list of sets

    $setdata = @()
   
    $sets = get-childitem $folder -recurse -Filter *.als | Where-Object { $_.FullName -notMatch "Backup" }

    # i need to exclude backup
    #Properties Directory,Fullname,Name,Length,Lastwritetime

    write-host $sets.count "Sets gefunden"


    foreach ($item in $sets) {
        
        $obj = $null
        $dir = $null
        $dir = $Item.Directoryname.split("/")

        
        $setpath = Split-Path -path $item.Fullname
        $project = Split-Path -path $setpath -leaf 
                
        $obj = New-Object System.Object
        $obj | Add-Member -MemberType NoteProperty -Name "Set"          -Value $item.Basename
        $obj | Add-Member -MemberType NoteProperty -Name "Fullname"          -Value $item.Fullname
        $obj | Add-Member -MemberType NoteProperty -Name "Folder"          -Value $dir[5]
        $obj | Add-Member -MemberType NoteProperty -Name "Project"          -Value $project
        $obj | Add-Member -MemberType NoteProperty -Name "whenCreated"          -Value $item.CreationTime
        $obj | Add-Member -MemberType NoteProperty -Name "lastAccess"          -Value $item.LastAccessTime
        $obj | Add-Member -MemberType NoteProperty -Name "LastWrite"          -Value $Item.Lastwritetime
        $setdata += $obj
    }
    $setdata  
    
} #return set list with fullpath etc 

function get-abletonsetxml ($set) {
    #returns xml obj
    
    $setname = Split-Path -path $set -Leaf
    $setpath = Split-Path -path $set 
    $projectname = Split-Path -path $setpath -leaf 

    #write-host "processing" $setname "in" $projectname -ForegroundColor Yellow
    #write-host "Setpath" $setpath
    $tempname = $setpath + "/" + "tmp.gz"


    #write-host $tempname
    copy-item $set $tempname -Force
    if (test-path $tempname) { 

        & gzip -d --force $tempname # nur noch tmp ohne endung

        copy-item ($setpath + "/tmp") ($setpath + "/tmp.xml")
   
        $testfile = $setpath + "/" + "tmp"

    }
    else { write-host "not created:" $tempname -ForegroundColor Red } 

    

    # Works basically
    #$setdata1 = ([xml](get-content -path $testfile)).Ableton.LiveSet
    $setdata1 = ([xml](get-content -path $testfile)).Ableton
   
    return $setdata1

} #rename to gz, unpack to tmp.xml

function enter-abletonsetxml($xml) {
    
    <#
        .SYNOPSIS
        pick specific data out of the set xml, return Object ()

        .DESCRIPTION
        

        .PARAMETER xml
        an xml object, not a file

        .INPUTS
        None. You cannot pipe objects to enter-abletonsetxml.

        .OUTPUTS
        array object with set metadata

        .EXAMPLE
        C:\PS> enter-abletonsetxml($xml)
        File.txt

    #>
    

    $orgAbletonV =    ($xml.SelectNodes('//Ableton') | select-object creator).creator
    $scaleNameValue = ($xml.LiveSet.ScaleInformation.Name).Value
    $scaleRootValue = ($xml.LiveSet.ScaleInformation.RootNote).Value
    $AutomationMode = ($xml.LiveSet.AutomationMode).Value
    $tempo =          ($xml.Liveset.MasterTrack.DeviceChain.Mixer.Tempo.Manual).value



    <#
    <ScaleInformation>
			<RootNote Value="0" />
            <Name Value="Major" />
    #>
  
    $scenes = ($xml.LiveSet.SceneNames.Scene).count 
    $scenenames = ($xml.LiveSet.SceneNames.Scene).Value
    $scenenames = $scenenames -join ","
    #($test.SceneNames.Scene) | get-member
    #miditracknames
    $miditracks = (($xml.LiveSet.tracks.miditrack.name.EffectiveName).Value) -join ","
    $audiotracks = (($xml.LiveSet.tracks.audiotrack.name.EffectiveName).Value) -join ","
    $QuantisationGlobal = (($xml.LiveSet.GlobalQuantisation).Value) -join ","
    $QuantisationAuto = (($xml.LiveSet.AutoQuantisation).Value) -join ","                          

    $PSObject = New-Object PSObject 
    $PSObject | Add-Member -MemberType NoteProperty -Name 'Scenes' -Value $scenes
    $PSObject | Add-Member -MemberType NoteProperty -Name 'Tempo' -Value $tempo
    $PSObject | Add-Member -MemberType NoteProperty -Name 'Firstversion' -Value $orgAbletonV
    $PSObject | Add-Member -MemberType NoteProperty -Name 'Miditracks' -Value $miditracks
    $PSObject | Add-Member -MemberType NoteProperty -Name 'Audiotracks' -Value $audiotracks
    $PSObject | Add-Member -MemberType NoteProperty -Name 'Scenenames' -Value $scenenames
    $PSObject | Add-Member -MemberType NoteProperty -Name 'Locators' -Value $locators
    $PSObject | Add-Member -MemberType NoteProperty -Name 'GlobalQuantization' -Value $QuantisationGlobal
    $PSObject | Add-Member -MemberType NoteProperty -Name 'AutoQuantization' -Value $QuantisationAuto
    $PSObject | Add-Member -MemberType NoteProperty -Name 'ScaleNameVal' -Value $scaleNameValue
    $PSObject | Add-Member -MemberType NoteProperty -Name 'ScaleRootVal' -Value $scaleRootValue
    $PSObject | Add-Member -MemberType NoteProperty -Name 'AutomationMode' -Value $AutomationMode

    return $PSObject
    <#

    DetailClipKeyMidis                     # : 
    TracksListWrapper                      # : TracksListWrapper
    VisibleTracksListWrapper               # : VisibleTracksListWrapper
    ReturnTracksListWrapper               #  : ReturnTracksListWrapper
    ScenesListWrapper                     #  : ScenesListWrapper
    CuePointsListWrapper                  #  : CuePointsListWrapper
    ChooserBar                            #  : ChooserBar
    Annotation                            #  : Annotation
    SoloOrPflSavedValue                   #  : SoloOrPflSavedValue
    SoloInPlace                           #  : SoloInPlace
    CrossfadeCurve                        #  : CrossfadeCurve
    LatencyCompensation                   #  : LatencyCompensation
    HighlightedTrackIndex                 #  : HighlightedTrackIndex
    GroovePool                            #  : GroovePool
    AutomationMode                        #  : AutomationMode
    SnapAutomationToGrid                  #  : SnapAutomationToGrid
    ArrangementOverdub                    #  : ArrangementOverdub
    ColorSequenceIndex                     # : ColorSequenceIndex
    AutoColorPickerForPlayerAndGroupTracks # : AutoColorPickerForPlayerAndGroupTracks
    AutoColorPickerForReturnAndMasterTracks #: AutoColorPickerForReturnAndMasterTracks
    ViewData                                #: ViewData
    MidiFoldIn                              #: MidiFoldIn
    MidiPrelisten                          # : MidiPrelisten
    UseWarperLegacyHiQMode                 # : UseWarperLegacyHiQMode
    VideoWindowRect                         #: VideoWindowRect
    ShowVideoWindow                        # : ShowVideoWindow
    TrackHeaderWidth                       # : TrackHeaderWidth
    ViewStateArrangerHasDetail             # : ViewStateArrangerHasDetail
    ViewStateSessionHasDetail              # : ViewStateSessionHasDetail
    ViewStateDetailIsSample                # : ViewStateDetailIsSample
    ViewStates                             # : ViewStates

#> 
} # get details from xml data of set. Uses all the other functions

function get-SetsParameters {
    #.Example 
    param (
        $searchpath
    )

    $data = get-abletonsets $searchpath

    $export = "/users/salomon/Documents/1. Projekte/CODING/Ninox/AbletonFX.csv" #possible ninox data file
    $xml = $null
    $alldata = @()
    
    write-host "elements of data array (Files to process):"
    $data | select-object Project, Lastaccess.lastwrite | format-table -autosize
    
    foreach ($el in $data) {
    
        $setdata = @()
        $set = $el.fullname
        

        write-host ("function: {0} " -f $MyInvocation.MyCommand) "Retrieving data for"$el.set"in Project"$el.Project
        #.TODO logging function

        
    
        $xml = get-abletonsetxml ($set) 
        
    
        if ($xml) { 
            #region prepare Ableton SetParameters for Ninox: fill Variable $setdata which will be exported
    
           
            $setdetails = enter-abletonsetxml($xml)
    
            $obj = New-Object System.Object
            $obj | Add-Member -MemberType NoteProperty -Name "Setname"      -Value $el.set
            $obj | Add-Member -MemberType NoteProperty -Name "Tempo"        -Value $setdetails.Tempo
            $obj | Add-Member -MemberType NoteProperty -Name "Setpath"      -Value $set
            $obj | Add-Member -MemberType NoteProperty -Name "Project"      -Value $el.Project
            $obj | Add-Member -MemberType NoteProperty -Name "Firstversion" -Value $setdetails.Firstversion
            $obj | Add-Member -MemberType NoteProperty -Name "Created"      -Value $el.whenCreated
            $obj | Add-Member -MemberType NoteProperty -Name "lastAccess"   -Value $el.lastAccess #bringt wenig
            $obj | Add-Member -MemberType NoteProperty -Name "LastWrite"    -Value $el.lastWrite
            $obj | Add-Member -MemberType NoteProperty -Name "Scenes"       -Value $setdetails.scenes
            $obj | Add-Member -MemberType NoteProperty -Name "Miditracks"   -Value $setdetails.miditracks
            $obj | Add-Member -MemberType NoteProperty -Name "Audiotracks"  -Value $setdetails.audiotracks
            $obj | Add-Member -MemberType NoteProperty -Name "Scenenames"   -Value $setdetails.scenenames 
            $Obj | Add-Member -MemberType NoteProperty -Name "Locators"     -Value $setdetails.locators
            $Obj | Add-Member -MemberType NoteProperty -Name "Quantization Global" -Value $setdetails.GlobalQuantization
            $Obj | Add-Member -MemberType NoteProperty -Name "Quantization Auto" -Value $setdetails.AutoQuantization
            $Obj | Add-Member -MemberType NoteProperty -Name "ScaleNameVal" -Value $setdetails.ScaleNameVal
            
        
            $setdata += $obj
            #endregion 
        }   # we fill the dataset for $alldata which is the final export
        else {
            #write-host "could not get xml for" $set
            #exit loop or go up
        
        }
        $alldata += $setdata
    
    } #parse each set and get the deeper data from a function

    $presentation = $alldata | select-object Setname, Tempo,Project , Created, LastWrite,Firstversion,ScaleNameVal, ScaleRootVal, "Quantization Global", "Quantization Auto", AutomationMode,Miditracks, Audiotracks, Scenes , setpath
    #lastaccess ist immer der zugriff durch das lesen der eigenschaften
    
    #$presentation| format-table -autosize
    $presentation | Export-Csv -Path $export -Delimiter ";" -NoTypeInformation -Encoding UTF8 -Force
    #write-host "Daten wurden nach "$export "geschrieben" better to logfile
    
    #region (Inactive): Cleanup - which would remove the Examples ...
    #.TODO: Needs to be put to anoter Location / Function anyways ?
    #remove-item ($setpath + "/tmp")
    #remove-item ($setpath + "/tmp.xml")
    #remove-item $tempname

    #endregion
    invoke-item $export    
}#Parses the comlete search path an make a detailed set inventory

#endregion Ableton functions

#region backup Ableton Lib (works)

$source="/Volumes/03-USB-DATA/Ableton/"
$target="nas/Home/TH Musikprojekt/Backup 03-USB-Data/Ableton/"
# backup-Library $source $target
#endregion backup Ableton lib



#/Users/salomon/nas/Home/TH Musikprojekt/Backup 03-USB-Data

#region parse all sets 
# get-setsparameters "/Volumes/03-USB-DATA/Ableton/Projects 10.1/*/_*" #works !
# get-setsparameters "/Volumes/03-USB-DATA/Ableton/Projects 10.1/*/*.als" #works !
#endregion parse all sets




#region Test one xml - inactive
<#
$testxml="/Volumes/03-USB-DATA/Ableton/Projects 10.1/_Templates/tmp.xml"
$setdata1 = ([xml](get-content -path $testxml)).Ableton
enter-abletonsetxml $setdata1 
#>
#endregion Test one xml

#endregion Ableton
