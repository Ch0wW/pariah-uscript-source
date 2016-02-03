class DialogBox extends DialogBoxSimple;

var() MenuSprite DialogBorder;

simulated function Init( String Args )
{

	Super.Init(Args);
	
}

simulated function DoDynamicLayout( Canvas C )
{
	local float height;

	height = GetWrappedTextHeight(C,DialogText);

	DialogBorder.ScaleY = height + (6.0 / C.ClipY);
	
	Super.DoDynamicLayout(C);
}

defaultproperties
{
     DialogBorder=(PosX=0.100000,PosY=0.695000,ScaleX=0.800000,ScaleY=0.300000,Style="DarkBorder")
     DialogText=(PosX=0.145000,PosY=0.700000,MaxSizeX=0.700000)
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
