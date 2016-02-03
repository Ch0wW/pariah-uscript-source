class MasterServerLink extends Info
	native
	transient;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var native const int LinkPtr;
var globalconfig int LANPort;
var globalconfig int LANServerPort;
var globalconfig int CurrentMasterServer;
var globalconfig int MasterServerPort[5];
var globalconfig string MasterServerAddress[5];

native function bool Poll( int WaitTime );

event GetMasterServer( out string OutAddress, out int OutPort )
{
	if( CurrentMasterServer<0 || CurrentMasterServer>=5 || CurrentMasterServer>=5 || MasterServerAddress[CurrentMasterServer]=="" || MasterServerPort[CurrentMasterServer]==0 )
		CurrentMasterServer = 0;

	if( MasterServerAddress[0]=="" || MasterServerPort[0]==0 )
	{
		Log("Warning: No master servers found in the INI file");
        OutAddress = "pariahmaster.digitalextremes.com";
		OutPort = 28909;
	}
	else
	{
		OutAddress	= MasterServerAddress[CurrentMasterServer];
		OutPort		= MasterServerPort[CurrentMasterServer];
	}
}

simulated function Tick( float Delta )
{
	Poll(0);
}

defaultproperties
{
     LANPort=11779
     LANServerPort=10779
     MasterServerPort(0)=28909
     MasterServerAddress(0)="pariahmaster.digitalextremes.com"
     bAlwaysTick=True
}
