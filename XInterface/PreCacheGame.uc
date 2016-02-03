class PreCacheGame extends GameInfo
    native;

// Force precaching of a few resources that will most likely be needed so that
// they're in the LIN.
//
// This is the gametype used by MenuLevel.

var() Array <String> PackageList;
var() Array <Object> Cache;

const PRECACHE_LEVEL = 1;

simulated function PostBeginPlay()
{   
    local xUtil.PlayerRecord PlayerRecord;
    
    if( PRECACHE_LEVEL > 0 )
    {
        log( "Precaching menu resources..." );

        PlayerRecord = class'xUtil'.static.FindPlayerRecord("Mason");
        log("Precached:" @ DynamicLoadObject( PlayerRecord.MeshName, class'Mesh' ) );

        CachePackageList();
    }
    else
    {
        Cache[0] = DynamicLoadObject("XInterfaceCommon.MenuStart", class'Class');
    }
}

simulated native function CachePackageList();

defaultproperties
{
     PackageList(0)="XInterface.u"
     PackageList(1)="XInterfaceCommon.u"
     PackageList(2)="XInterfaceLive.u"
     PackageList(3)="XInterfaceMP.u"
     PackageList(4)="XInterfaceSettings.u"
     HUDType="Engine.HUD"
     PersonalStatsDisplayType=""
     bMenuLevel=True
}
