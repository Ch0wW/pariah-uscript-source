class OverlaySpectating extends MenuTemplateTitled;

var() MenuText      PressFireToRespawn;
var() MenuText		RespawnCounter;
var   int			SpawnCounter;
var   bool			bTimerStarted;

var() localized String StringRespawn;

simulated function DrawMenu( Canvas C, bool HasFocus )
{
    local PlayerController PC;

    PC = PlayerController(Owner);
    assert( PC != None );


	if(!PC.PlayerReplicationInfo.bOutOfLives)
	{
		if( PC.bFrozen && !PC.IsInState('MostlyDead') )
		{
			PressFireToRespawn.bHidden = 1;
		}
		else
		{
			PressFireToRespawn.bHidden = 0;
		}
	}

	if(!PC.IsInState('MostlyDead') ) {
		RespawnCounter.bHidden = 1;
	}
	else {
		RespawnCounter.bHidden = 0;
		if(!bTimerStarted) {
			RespawnCounter.Text = StringRespawn @ "15";
			SetTimer(1, false);
			bTimerStarted = true;
		}
		if(SpawnCounter == 0)
			SpawnCounter = 15;
	}

    if( C.SizeX < 640 )
    {
        MenuTitle.bHidden = 1;
        if( PressFireToRespawn.bHidden==0 )
        {
            DrawQuadScreen(C);
            return;
        }
    }
    else
    {
        MenuTitle.bHidden = 0;
    }

    Super.DrawMenu( C, HasFocus );
}

simulated function Timer()
{
	SpawnCounter--;
	if(SpawnCounter < 0) {
		SpawnCounter = 0;
		bTimerStarted = false;
	}
	else
		SetTimer(1, false);

	RespawnCounter.Text = StringRespawn @ SpawnCounter;
}


simulated function DrawQuadScreen(Canvas C)
{
    C.Font = Font'Engine.FontSmall';
    C.DrawScreenText( PressFireToRespawn.Text, 0.5, 0.85, DP_LowerMiddle );
}

defaultproperties
{
     PressFireToRespawn=(Text="Press fire to respawn",DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.896000,Style="LabelText")
     RespawnCounter=(Text="Respawn in 15",PosX=0.850000,PosY=0.100000,Style="LabelText")
     SpawnCounter=15
     StringRespawn="Respawn in"
     MenuTitle=(Text="Spectator Camera")
     Background=(bHidden=1)
     ReservedNames(1)="Default"
     ReservedNames(2)="New"
     ReservedNames(3)="Player"
     ReservedNames(4)="Pariah"
     ReservedNames(5)="Build"
     ReservedNames(6)="Default"
     ReservedNames(7)="DefPariahEd"
     ReservedNames(8)="DefUser"
     ReservedNames(9)="Manifest"
     ReservedNames(10)="MiniEdLaunch"
     ReservedNames(11)="MiniEdUser"
     ReservedNames(12)="PariahEd"
     ReservedNames(13)="PariahEdTips"
     ReservedNames(14)="Running"
     ReservedNames(15)="TEMP"
     ReservedNames(16)="User"
     bRenderLevel=True
}
