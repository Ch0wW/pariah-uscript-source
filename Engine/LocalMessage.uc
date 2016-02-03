//=============================================================================
// LocalMessage
//
// LocalMessages are abstract classes which contain an array of localized text.  
// The PlayerController function ReceiveLocalizedMessage() is used to send messages 
// to a specific player by specifying the LocalMessage class and index.  This allows 
// the message to be localized on the client side, and saves network bandwidth since 
// the text is not sent.  Actors (such as the GameInfo) use one or more LocalMessage 
// classes to send messages.  The BroadcastHandler function BroadcastLocalizedMessage() 
// is used to broadcast localized messages to all the players.
//
//=============================================================================
class LocalMessage extends Info;

var(Message) bool   bComplexString;                                 // Indicates a multicolor string message class.
var(Message) bool   bIsSpecial;                                     // If true, don't add to normal queue.
var(Message) bool   bIsUnique;                                      // If true and special, only one can be in the HUD queue at a time.
var(Message) bool   bIsPartiallyUnique;                             // If true and special, only one can be in the HUD queue with the same switch value
var(Message) bool   bIsConsoleMessage;                              // If true, put a GetString on the console.
var(Message) bool   bFadeMessage;                                   // If true, use fade out effect on message.
var(Message) bool   bBeep;                                          // If true, beep!
var(Message) float  Lifetime;                                       // # of seconds to stay in HUD message queue.

var(Message) class<LocalMessage> ChildMessage;                      // In some cases, we need to refer to a child message.

enum EStackMode
{
    SM_None,
    SM_Up,
    SM_Down,
};

var(Message) Color  DrawColor;
var(Message) EDrawPivot DrawPivot;
var(Message) EStackMode StackMode;                                  // Brutal hack!
var(Message) float PosX, PosY;
var(Message) int FontSize;                                          // 0: Huge, 1: Big, 2: Small ...

static function RenderComplexMessage( 
    Canvas Canvas, 
    out float XL,
    out float YL,
    optional String MessageString,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    );

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    if ( class<Actor>(OptionalObject) != None )
        return class<Actor>(OptionalObject).static.GetLocalString(Switch, RelatedPRI_1, RelatedPRI_2);
    return "";
}

static function string AssembleString(
    HUD myHUD,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional String MessageString
    )
{
    return "";
}

static function ClientReceive( 
    PlayerController P,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    local String S;
    
	if ( P.myHud != None )
		P.myHUD.LocalizedMessage( Default.Class, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );

    if ( Default.bIsConsoleMessage && (P.Player != None) && (P.Player.Console != None) )
    {
        S = Static.GetString( Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
        
        if( S != "" )
        {
            P.Player.InteractionMaster.Process_Message( S, 6.0, P.Player.LocalInteractions);
        }
    }
}

static function color GetColor(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2
    )
{
    return Default.DrawColor;
}

static function color GetConsoleColor( PlayerReplicationInfo RelatedPRI_1 )
{
    return Default.DrawColor;
}

static function GetPos( int Switch, out EDrawPivot OutDrawPivot, out EStackMode OutStackMode, out float OutPosX, out float OutPosY )
{
    OutDrawPivot = default.DrawPivot;
    OutStackMode = default.StackMode;
    OutPosX = default.PosX;
    OutPosY = default.PosY;
}

static function int GetFontSize( int Switch )
{
    return( default.FontSize );
}

static function float GetLifeTime(int Switch)
{
    return default.LifeTime;
}

static function bool IsValid(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    return(true);
}

defaultproperties
{
     Lifetime=5.000000
     PosX=0.500000
     PosY=0.500000
     DrawColor=(B=160,G=160,R=160,A=255)
     DrawPivot=DP_MiddleMiddle
     bIsSpecial=True
     bIsConsoleMessage=True
}
