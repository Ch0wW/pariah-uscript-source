class MenuInternetError extends MenuTemplateTitledBA;

var() MenuText ErrorText;
var() MenuText UrlText;
var() MenuButtonText UrlButton;
var() float ParagraphSpacing;

var() String UpgradeURL; // TODO: ideally this would taken from the MS

struct ErrorCodeString
{
    var() String ErrorCode;
    var() localized String ErrorMessage;
};

var() ErrorCodeString ErrorCodes[8];

simulated function Init( String Args )
{
    local int i;
    local String Token;
    
    Token = ParseToken( Args );
    
    for( i = 1; i < ArrayCount(ErrorCodes); ++i )
    {
        if( ErrorCodes[i].ErrorCode ~= Token )
        {
            ErrorText.Text = ErrorCodes[i].ErrorMessage;
            break;
        }
    }
    
    if( i >= ArrayCount(ErrorCodes) )
    {
        ErrorText.Text = ErrorCodes[0].ErrorMessage;
    }

    if( Token == "RI_MustUpgrade" )
    {
		if ( class'MasterServerClient'.static.DownloadListValid() )
		{
			BButtonHidden=0;
		}
        UrlButton.Blurred.Text = UpgradeURL; 
        UrlButton.Focused.Text = UpgradeURL; 
    }
    else
    {
        UrlText.bHidden = 1;
        UrlButton.bHidden = 1;
    }
}

simulated function DoDynamicLayout( Canvas C )
{
    local float ErrorDY;
    local float TotalDY;
    local int UrlParse;
    local int i;

    local float BaseDX, BaseDY;
    local float UrlDX, UrlDY;
    local float DX, DY;
    
    Super.DoDynamicLayout( C );
    
    if( bool(UrlText.bHidden) )
    {
        ErrorText.DrawPivot = DP_MiddleLeft;
        return;
    }
    
    // Find out where the URL starts:
    UrlParse = InStr( default.UrlText.Text, "<URL>" );
    Assert( UrlParse > 0 );
    UrlText.Text = Left( default.UrlText.Text, UrlParse );
    
    GetMenuTextSize( C, UrlText, BaseDX, BaseDY);
    
    // Find out how much longer we need to make it:
    GetMenuTextSize( C, UrlButton.Blurred, UrlDX, UrlDY );
    
    // Find the longest stretch of spaces that will fit BaseDX + UrlDX:
    for( i = 0; i < 200; ++i )
    {
        UrlText.Text = UrlText.Text $ " ";
        GetMenuTextSize( C, UrlText, DX, DY );
        
        if( DX > (BaseDX + UrlDX) )
        {
            break;
        }
    }
    
    UrlText.Text = UrlText.Text $ Right( default.UrlText.Text, Len(default.UrlText.Text) - UrlParse - Len("<URL>") );

    ErrorText.DrawPivot = DP_UpperLeft;

    ErrorDY = GetWrappedTextHeight( C, ErrorText );
    UrlDY = GetWrappedTextHeight( C, UrlText );
    
    TotalDY = ErrorDY + UrlDY + ParagraphSpacing;

    ErrorText.PosY = 0.5 - (TotalDY * 0.5);
    
    UrlText.PosX = ErrorText.PosX;
    UrlText.PosY = ErrorText.PosY + ErrorDY + ParagraphSpacing;
    UrlText.DrawPivot = DP_UpperLeft;
    
    UrlButton.Blurred.PosX = UrlText.PosX + BaseDX;
    UrlButton.Blurred.PosY = UrlText.PosY;
    UrlButton.Blurred.DrawPivot = DP_UpperLeft;
    
    UrlButton.Focused.PosX = UrlButton.Blurred.PosX;
    UrlButton.Focused.PosY = UrlButton.Blurred.PosY;
    UrlButton.Focused.DrawPivot = DP_UpperLeft;
}

simulated function OnAButton()
{
    GotoMenuClass("XInterfaceCommon.MenuMain");
}

simulated function OnBButton()
{
	class'MasterServerClient'.static.LaunchAutoUpdate();
}

simulated function OnURL()
{
    ConsoleCommand( "OPENURL" @ UpgradeURL );
}

simulated function HandleInputBack()
{
}

defaultproperties
{
     ErrorText=(PosX=0.100000,MaxSizeX=0.800000,Style="MedMessageText")
     UrlText=(Text="Visit <URL> for more information.",Style="MedMessageText")
     URLButton=(OnSelect="OnURL",Pass=5,Style="URLButton")
     ParagraphSpacing=0.040000
     UpgradeURL="http://www.groovegames.com"
     ErrorCodes(0)=(ErrorMessage="The Pariah master server appears to be very angry. Please come back later after it's had a chance to cool off.")
     ErrorCodes(1)=(ErrorCode="RI_AuthenticationFailed",ErrorMessage="You could not connect to the Pariah master server because the authenticity of your copy could not be verified. This might happen if you are using a pirated copy of Pariah.")
     ErrorCodes(2)=(ErrorCode="RI_ConnectionFailed",ErrorMessage="The Pariah master server is temporarily unavailable. Please try again later.")
     ErrorCodes(3)=(ErrorCode="RI_ConnectionTimeout",ErrorMessage="The Pariah master server is very busy and could not respond. Please try again later.")
     ErrorCodes(4)=(ErrorCode="RI_MustUpgrade",ErrorMessage="A required update is available for Pariah. You must apply the latest patch before you can play Pariah on the internet.")
     ErrorCodes(5)=(ErrorCode="RI_DevClient",ErrorMessage="Your client is currently operating in developer mode and its access to the master server has been restricted.\n\nPlease restart the game and avoid using SET commands that may cause problems.\n\nIf the problem persists, please contact Groove Technical Support.")
     ErrorCodes(6)=(ErrorCode="RI_BadClient",ErrorMessage="Your copy of Pariah has been modified in some way.\n\nBecause of this, its access to the Pariah master server has been restricted. If this problem persists, please reinstall the game or the latest patch.\n\nThis error has been logged.")
     ErrorCodes(7)=(ErrorCode="RI_BannedClient",ErrorMessage="Your CD Key has been banned by the Pariah master server.")
     ALabel=(Text="Continue")
     APlatform=MWP_All
     BLabel=(Text="Upgrade")
     BPlatform=MWP_PC
     BButtonHidden=1
     MenuTitle=(Text="Error",bHidden=1)
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
}
