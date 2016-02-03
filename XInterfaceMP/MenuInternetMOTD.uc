class MenuInternetMOTD extends MenuTemplateTitledBA;

// Set by creator:
var array<MasterServerClient.MOTDResponse>	MOTDResponses;

var() MenuText MOTDText;
var() MenuText UrlText;
var() MenuButtonText UrlButton;
var() float ParagraphSpacing;

var() String UpgradeURL; // TODO: ideally this would taken from the MS

struct MOTDModeString
{
    var() MasterServerClient.EMOTDResponse	MOTDMode;
    var() localized String					MOTDMessage;
};

var() MOTDModeString MOTDModes[4];

simulated function Init( String Args )
{
    local int r, i;
	local bool bFirst, bNeedUpgradeURL;
	local string temp;

	bFirst = true;
	bNeedUpgradeURL = false;
	for ( r = 0; r < MOTDResponses.Length; ++r )
	{
	    if( MOTDResponses[r].MR == MR_MandatoryUpgrade || MOTDResponses[r].MR == MR_OptionalUpgrade )
		{
			bNeedUpgradeURL = true;
			if ( class'MasterServerClient'.static.DownloadListValid() )
			{
				BButtonHidden=0;
			}
		}
		if ( MOTDResponses[r].MR == MR_UpgradeURL )
		{
			UpgradeURL = MOTDResponses[r].Value;
		}

		for( i = 1; i < ArrayCount(MOTDModes); ++i )
		{
			if( MOTDModes[i].MOTDMode == MOTDResponses[r].MR )
			{
				if ( bFirst )
				{
					bFirst = false;
				}
				else
				{
					MOTDText.Text = MOTDText.Text $ "\\n\\n";
				}
				temp = MOTDModes[i].MOTDMessage;
			    UpdateTextField( temp, "<MOTD>", MOTDResponses[r].Value );
				MOTDText.Text = MOTDText.Text $ temp;
				break;
			}
		}
	}

    if( bNeedUpgradeURL )
    {
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
    local float MOTDDY;
    local float TotalDY;
    local int UrlParse;
    local int i;

    local float BaseDX, BaseDY;
    local float UrlDX, UrlDY;
    local float DX, DY;
    
    Super.DoDynamicLayout( C );
    
    if( bool(UrlText.bHidden) )
    {
        MOTDText.DrawPivot = DP_MiddleLeft;
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

    MOTDText.DrawPivot = DP_UpperLeft;

    MOTDDY = GetWrappedTextHeight( C, MOTDText );
    UrlDY = GetWrappedTextHeight( C, UrlText );
    
    TotalDY = MOTDDY + UrlDY + ParagraphSpacing;

    MOTDText.PosY = 0.5 - (TotalDY * 0.5);
    
    UrlText.PosX = MOTDText.PosX;
    UrlText.PosY = MOTDText.PosY + MOTDDY + ParagraphSpacing;
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
    CloseMenu();
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
	CloseMenu();
}

defaultproperties
{
     MOTDText=(PosX=0.100000,MaxSizeX=0.800000,Style="MedMessageText")
     UrlText=(Text="Visit <URL> for more information.",Style="MedMessageText")
     URLButton=(OnSelect="OnURL",Pass=5,Style="URLButton")
     ParagraphSpacing=0.040000
     UpgradeURL="http://www.groovegames.com"
     MOTDModes(0)=(MOTDMessage="The Pariah master server appears to be very angry. Please come back later after it's had a chance to cool off.")
     MOTDModes(1)=(MOTDMessage="<MOTD>")
     MOTDModes(2)=(MOTDMode=MR_MandatoryUpgrade,MOTDMessage="A required update which upgrades Pariah to version <MOTD> is available. You must apply the latest patch before you can play Pariah on the internet.")
     MOTDModes(3)=(MOTDMode=MR_OptionalUpgrade,MOTDMessage="An optional update which upgrades Pariah to version <MOTD> is available. It is highly recommended that you apply the latest patch before you play Pariah on the internet.")
     ALabel=(Text="Continue")
     APlatform=MWP_All
     BLabel=(Text="Upgrade")
     BPlatform=MWP_PC
     BButtonHidden=1
     MenuTitle=(Text="Message of the Day")
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
