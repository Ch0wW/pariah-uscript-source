class DialogBoxSimple extends MenuTemplate;

var() MenuText DialogText;

var bool bCloseOnFinish;

var string CharacterName;

//TODO:  Make this get the dialog string name and portriat name from the args
//should probably also give it a time to kill itself maybe?  Have to think on that one a bit.
simulated function Init( String Args )
{
	local string TextId, CharId;

	//log("DialogBox received init with Args: "$Args);
	
	TextID = class'GameInfo'.static.ParseOption(Args, "TextID");
	CharID = class'GameInfo'.static.ParseOption(Args, "CharID");

	
	//if(CharID=="Karina")
	//{
	//	Portrait.WidgetTexture = Material(DynamicLoadObject("PariahPlayerMugShotsTextures.KarinaPortrait", class'Material'));
	//}
	//else
	//	Portrait.WidgetTexture = None;
	
	if(CharID != "")
	{
		CharacterName = CharID;
	}

	bCloseOnFinish = bool(class'GameInfo'.static.ParseOption(Args, "bAutoClose"));
	
	DialogText.Text = CharacterName$":  "$Localize( "DecoText", TextID, "PariahSPDialog" );
	
	//log("got text "$DialogText.Text);
	if(bCloseOnFinish)
		SinglePlayerController(Owner).SetDialogLength( Len(DialogText.Text) * 0.08);//GetDecoTextTime(DialogText));

}

simulated event DecoTextComplete()
{
	if(bCloseOnFinish)
		SetTimer(5,False);
}

defaultproperties
{
     DialogText=(MenuFont=Font'Engine.FontSmall',DrawColor=(B=180,G=180,R=180,A=255),PosX=0.050000,PosY=0.800000,ScaleX=1.000000,ScaleY=1.000000,Kerning=1,MaxSizeX=0.900000,bNoFontRemapping=1,bWordWrap=1,TextAlign=TA_Right,Pass=3)
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
     bIgnoresInput=True
     bAllowStats=True
}
