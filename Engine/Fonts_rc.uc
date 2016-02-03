class Fonts_rc extends Resource
    dependson(Interactions);

// See FontCharacters.txt for character list.
#exec new TrueTypeFontFactory Name="FontMono"               Height=9  Kerning=0  MinScaleX=1.0  MinScaleY=1.0  DropShadowX=0 DropShadowY=0 Style=400 AntiAlias=0 USize=2048 VSize=512 FontName="Arial"     CharactersPerPage=65536 Path=..\System Wildcard="*.txt,*.int,*.de,*.esp,*.fr,*.itt"
#exec new TrueTypeFontFactory Name="FontSmall"              Height=16 Kerning=0  MinScaleX=0.8  MinScaleY=0.8  DropShadowX=0 DropShadowY=0 Style=200 AntiAlias=1 USize=2048 VSize=512 FontName="Arial Unicode MS"	 CharactersPerPage=65536 Path=..\System Wildcard="*.txt,*.int,*.de,*.esp,*.fr,*.itt"  ButtonTexturePath=..\Fonts\Buttons ButtonScale=0.71
#exec new TrueTypeFontFactory Name="FontMedium"             Height=21 Kerning=0  MinScaleX=0.5  MinScaleY=0.5  DropShadowX=0 DropShadowY=0 Style=400 AntiAlias=1 USize=2048 VSize=512 FontName="Arial Unicode MS"     CharactersPerPage=65536 Path=..\System Wildcard="*.txt,*.int,*.de,*.esp,*.fr,*.itt"  ButtonTexturePath=..\Fonts\Buttons XPad=2 LineSpacingAdjust=-3 ButtonScale=0.93

const MAX_BUTTONS = 26;
const MAX_INT_BUTTONS = 14;
var String ButtonNames[MAX_BUTTONS];
var int ButtonCharIndex;

var() localized String StringPressButton;
var() localized String StringTypeKey;
var() localized String StringPullTrigger;
var() localized String StringClickThumbstick;

static function String LocalizedDescribeBinding( String BindingString, PlayerController PC )
{       
    local int Cursor;
    local String KeyName;
    local int KeyIndex;    
    local String LocalizedKeyName;   
        		
	while( Len( BindingString ) > 0 )
	{		
		Cursor = InStr( BindingString, "," );		
		if( Cursor < 0 )
		{			    
			KeyName = BindingString;
			Cursor = Len( BindingString );
		}
		else
		{		
		    KeyName = Left( BindingString, Cursor );
		    Cursor = Cursor + 1;
		}
		
		KeyIndex = class'LocalizedKeys'.static.FindKeyIndex( KeyName, PC );		
		if( KeyIndex >= 0 )
		{
			LocalizedKeyName = class'LocalizedKeys'.static.LocalizeKeyIndex( KeyIndex );
					
			if( Len( LocalizedKeyName ) > 0 )
			{
  				return( LocalizedKeyName );
			}
        }
		  	        
		BindingString = Right( BindingString, Len( BindingString ) - Cursor );
	}	
	
	return("");
}

// Converts shit like "Joy1" -> "Press (A)" or "Joy7" -> "Pull (LT)" or "G" -> "Press G"
static function String DescribeBinding( String BindingString, out PlayerController PC )
{
    local int b, ButtonIndex;
    local String ButtonName;
    local bool bFoundButton;
    local int LocalStartIndex;
    local String LangSuffix;
    local String Result;
		
	Result = LocalizedDescribeBinding( BindingString, PC );
	if( Len( Result ) > 0 )
	{
		return( ReplaceSubstring( default.StringTypeKey, "<KEY>", Result ) );
	}
	    
    LangSuffix = PC.ConsoleCommand("GET_LANGUAGE");

    if(LangSuffix == "est")
        LocalStartIndex = 14;
    else if(LangSuffix == "frt")
        LocalStartIndex = 18;
    else if(LangSuffix == "itt")
        LocalStartIndex = 22;
    else
        LocalStartIndex = 0;

    // check for localized button
    if( LocalStartIndex > 0 )
    {
        for( b = LocalStartIndex; b < LocalStartIndex + 4; ++b )
        {
            if( InStr(Caps(BindingString), Caps(default.ButtonNames[b])) >= 0 )
            {
                bFoundButton = true;
                ButtonIndex = b;
                break;
            }
        }
    }

    // no localized button, use default
    if( !bFoundButton )
    {
        for( b = 0; b < MAX_INT_BUTTONS; ++b )
        {
            if( InStr(Caps(BindingString), Caps(default.ButtonNames[b])) >= 0 )
            {
                bFoundButton = true;
                ButtonIndex = b;
                break;
            }
        }
    }

    if( bFoundButton )
    {
        ButtonName = default.ButtonNames[ButtonIndex];

        // Triggers:
        if( (ButtonName ~= "Joy7") || (ButtonName ~= "Joy8") )
        {
            return( ReplaceSubstring( default.StringPullTrigger, "<TRIGGER>", Chr(default.ButtonCharIndex + ButtonIndex) ) );
        }
        else if( (ButtonName ~= "Joy11") || (ButtonName ~= "Joy12") )
        {
            return( ReplaceSubstring( default.StringClickThumbstick, "<THUMBSTICK>", Chr(default.ButtonCharIndex + ButtonIndex) ) );
        }
        else
        {
            return( ReplaceSubstring( default.StringPressButton, "<BUTTON>", Chr(default.ButtonCharIndex + ButtonIndex) ) );
        }
    }
    
    if( IsOnConsole() )
    {
        log("Could not find icon character for" @ BindingString, 'Warning');
    }
    
    return("");
}

defaultproperties
{
     ButtonCharIndex=9985
     ButtonNames(0)="Joy11"
     ButtonNames(1)="Joy12"
     ButtonNames(2)="Joy1"
     ButtonNames(3)="Joy2"
     ButtonNames(4)="Joy3"
     ButtonNames(5)="Joy4"
     ButtonNames(6)="Joy5"
     ButtonNames(7)="Joy6"
     ButtonNames(8)="Joy7"
     ButtonNames(9)="Joy8"
     ButtonNames(10)="JoyPovUp"
     ButtonNames(11)="JoyPovDown"
     ButtonNames(12)="JoyPovLeft"
     ButtonNames(13)="JoyPovRight"
     ButtonNames(14)="Joy11"
     ButtonNames(15)="Joy7"
     ButtonNames(16)="Joy12"
     ButtonNames(17)="Joy8"
     ButtonNames(18)="Joy11"
     ButtonNames(19)="Joy7"
     ButtonNames(20)="Joy12"
     ButtonNames(21)="Joy8"
     ButtonNames(22)="Joy11"
     ButtonNames(23)="Joy7"
     ButtonNames(24)="Joy12"
     ButtonNames(25)="Joy8"
     StringPressButton="Press <BUTTON>"
     StringTypeKey="Press <KEY>"
     StringPullTrigger="Pull <TRIGGER>"
     StringClickThumbstick="Click <THUMBSTICK>"
}
