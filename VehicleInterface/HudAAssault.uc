class HudAAssault extends HudATeamDeathMatch;

var Texture AssaultBarBG, AssaultBar;
var Material NextAssaultPoint;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(1.0, True);

}

// Alpha Pass ==================================================================================
simulated function DrawHudPassA (Canvas C)
{
	local vector vNextPoint;

	if(PlayerOwner.GameReplicationInfo.GameObjStates[0] == GOS_HeldRed)
	{
		HudHighlightColor.R=255;
		HudHighlightColor.G=0;
		HudHighlightColor.B=0;
		HudHighlightColor.A=255;

	}
	else if(PlayerOwner.GameReplicationInfo.GameObjStates[0] == GOS_HeldBlue)
	{
		HudHighlightColor.R=0;
		HudHighlightColor.G=0;
		HudHighlightColor.B=255;
		HudHighlightColor.A=255;
	}
	else
		HudHighlightColor = default.HudHighlightColor;


	Super.DrawHudPassA (C);


	//draw the next point, if available
	if(PlayerOwner.PlayerReplicationInfo.Team.TeamIndex==0)
	{
		if(AssaultReplicationInfo(PlayerOwner.GameReplicationInfo).Team0NextPoint != Vect(0,0,0))
		{
			vNextPoint = AssaultReplicationInfo(PlayerOwner.GameReplicationInfo).Team0NextPoint;
		}
	}
	else if(PlayerOwner.PlayerReplicationInfo.Team.TeamIndex==1)
	{
		if(AssaultReplicationInfo(PlayerOwner.GameReplicationInfo).Team1NextPoint != Vect(0,0,0))
		{
			vNextPoint = AssaultReplicationInfo(PlayerOwner.GameReplicationInfo).Team1NextPoint;
		}
	}

	DrawAssaultHud(C, vNextPoint, PlayerOwner.PlayerReplicationInfo.Team.TeamIndex, AssaultReplicationInfo(PlayerOwner.GameReplicationInfo).AssaultBar, AssaultBar, NextAssaultPoint);


}

function Timer()
{
	Super.Timer();

    if( PlayerOwner.GameReplicationInfo == None || PlayerOwner.IsInState('GameEnded'))
    {
        return;
    }

    if( PlayerOwner.GameReplicationInfo.GameObjStates[1] == GOS_HeldRed )
	{
		if(PawnOwnerPRI.Team.TeamIndex==0 )
			PlayerOwner.ReceiveLocalizedMessage( class'AssaultHUDMessage', 0 );
		else 
			PlayerOwner.ReceiveLocalizedMessage( class'AssaultHUDMessage', 1 );
	}
	else if( PlayerOwner.GameReplicationInfo.GameObjStates[1] == GOS_HeldBlue )
	{
		if(PawnOwnerPRI.Team.TeamIndex==1 )
			PlayerOwner.ReceiveLocalizedMessage( class'AssaultHUDMessage', 0 );
		else 
			PlayerOwner.ReceiveLocalizedMessage( class'AssaultHUDMessage', 1 );
	}
}

defaultproperties
{
     AssaultBarBG=Texture'InterfaceContent.HUD.reticle_bar'
     AssaultBar=Texture'InterfaceContent.HUD.reticle_bar2'
     NextAssaultPoint=Texture'PariahInterface.HUD.ObjReticleSecond'
     HudHighlightColor=(B=255,G=255,R=255,A=255)
     bHighlightFlagpos=True
}
