/*
	HudFunctional: Functions that both the MiniEd HUD and the game HudBase need
	xmatt
*/
class HudFunctional extends HUD
    exportstructs
    native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

enum EScaleMode
{
    SM_None,
    SM_Up,
    SM_Down,
    SM_Left,
    SM_Right
};

struct DigitSet
{
    var Material DigitTexture;
    var IntBox TextureCoords[11]; // 0-9, 11th element is negative sign
};

struct SpriteWidget
{
    var Material		WidgetTexture;
    var ERenderStyle	RenderStyle;
    var IntBox			TextureCoords;
    var float			TextureScale;
    var EDrawPivot		DrawPivot;
    var float			PosX, PosY;
    var int				OffsetX, OffsetY;
    var EScaleMode		ScaleMode;
    var float			Scale;
    var Color			Tints[2];
    var bool			bNeverScalePos;
};

struct NumericWidget
{
    var ERenderStyle	RenderStyle;
    var int				MinDigitCount;
    var float			TextureScale;
    var EDrawPivot		DrawPivot;
    var float			PosX, PosY;
    var int				OffsetX, OffsetY;
    var Color			Tints[2];
    var int				bPadWithZeroes;
    var transient int	Value;
};

var() SpriteWidget FriendsIconRecivedFriendInvite;
var() SpriteWidget FriendsIconRecivedGameInvite;

var() transient ERenderStyle PassStyle; // For debugging.

native simulated function DrawSpriteWidget (Canvas C, out SpriteWidget W);
native simulated function DrawNumericWidget (Canvas C, out NumericWidget W, out DigitSet D);
native simulated function GetSpriteWidgetExtents( Canvas C, SpriteWidget W, out int left, out int top, out int width, out int height);

simulated function RenderLiveIcons(Canvas C)
{
    if( PlayerOwner.NumFriendRequests > 0 )
		DrawSpriteWidget (C, FriendsIconRecivedFriendInvite );
    
    if( PlayerOwner.NumGameInvites > 0 )
		DrawSpriteWidget (C, FriendsIconRecivedGameInvite );
}

defaultproperties
{
     FriendsIconRecivedFriendInvite=(WidgetTexture=FinalBlend'InterfaceContent.LiveIcons.fbFriendInviteReceived',RenderStyle=STY_Alpha,TextureCoords=(X2=63,Y2=63),TextureScale=0.700000,DrawPivot=DP_MiddleRight,PosX=0.100000,PosY=0.440000,Tints[0]=(G=150,R=255,A=255),Tints[1]=(G=150,R=255,A=255))
     FriendsIconRecivedGameInvite=(WidgetTexture=FinalBlend'InterfaceContent.LiveIcons.fbGameInviteReceived',RenderStyle=STY_Alpha,TextureCoords=(X2=63,Y2=63),TextureScale=0.700000,DrawPivot=DP_MiddleRight,PosX=0.100000,PosY=0.520000,Tints[0]=(G=150,R=255,A=255),Tints[1]=(G=150,R=255,A=255))
}
