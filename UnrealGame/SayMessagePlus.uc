class SayMessagePlus extends StringMessagePlus;

var() Color TeamColors[2];

static function RenderComplexMessage( 
	Canvas Canvas, 
	out float XL,
	out float YL,
	optional string MessageString,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (RelatedPRI_1 == None)
		return;

	Canvas.SetDrawColor(0,255,0);
	Canvas.DrawText( RelatedPRI_1.RetrivePlayerName()$": ");
	Canvas.SetPos( Canvas.CurX, Canvas.CurY - YL );
	Canvas.SetDrawColor(0,128,0);
	Canvas.DrawText( MessageString );
}

static function string AssembleString(
	HUD myHUD,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional String MessageString
	)
{
	if ( RelatedPRI_1 == None )
		return "";
	if ( RelatedPRI_1.RetrivePlayerName() == "" )
		return "";
	return RelatedPRI_1.RetrivePlayerName()$": "@MessageString;
}

static function color GetConsoleColor( PlayerReplicationInfo RelatedPRI_1 )
{
    if( (RelatedPRI_1 == None) || (RelatedPRI_1.Team == None) )
    {
        return(default.DrawColor);
    }

    if( (RelatedPRI_1.Team.TeamIndex < 0) || (RelatedPRI_1.Team.TeamIndex > ArrayCount(default.TeamColors)) )
    {
        return(default.DrawColor);
    }
    
    return(default.TeamColors[RelatedPRI_1.Team.TeamIndex]);
}

defaultproperties
{
     TeamColors(0)=(R=255,A=255)
     TeamColors(1)=(B=255,A=255)
     Lifetime=6.000000
     bComplexString=True
}
