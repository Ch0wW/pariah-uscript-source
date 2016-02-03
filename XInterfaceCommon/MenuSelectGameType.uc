class MenuSelectGameType extends MenuTemplateTitledBA;

var() MenuText          NormalTitle;
var() MenuButtonText    NormalGameTypes[7];

var() MenuText          CustomTitle;
var() MenuButtonText    CustomGameTypes[7];

var() Array<xUtil.GameTypeRecord> GameTypeRecords;

var() config String GameTypeName;

var() int CustomCount;
var() int NormalCount;

var() float TitleX;
var() float ItemX;

var() float TitleDY;
var() float ItemDY;

simulated function Init( String Args )
{
    local int i;
    local int NormalIndex;
    local int CustomIndex;
	
    Super.Init( Args );

    LoadGameTypes();
    
    for( i = 0; i < GameTypeRecords.Length; i++ )
    {
        if( GameTypeRecords[i].bCustomMaps != 0 )
        {
            if( CustomIndex >= ArrayCount(CustomGameTypes) )
            {
                continue;
            }
        
		    CustomGameTypes[CustomIndex].Blurred.Text = GameTypeRecords[i].GameName;
    	    CustomGameTypes[CustomIndex].Focused.Text = CustomGameTypes[CustomIndex].Blurred.Text;
    	    CustomGameTypes[CustomIndex].ContextId = i;
    	    ++CustomIndex;
        }
        else
        {
            if( NormalIndex >= ArrayCount(NormalGameTypes) )
            {
                continue;
            }
        
		    NormalGameTypes[NormalIndex].Blurred.Text = GameTypeRecords[i].GameName;
    	    NormalGameTypes[NormalIndex].Focused.Text = NormalGameTypes[CustomIndex].Blurred.Text;
    	    NormalGameTypes[NormalIndex].ContextId = i;
    	    ++NormalIndex;
        }
    }
    
    CustomCount = CustomIndex;
    NormalCount = NormalIndex;

    while( CustomIndex < ArrayCount(CustomGameTypes) )
    {
        CustomGameTypes[CustomIndex].bHidden = 1;
        CustomGameTypes[CustomIndex].ContextID = -1;
        ++CustomIndex;
    }
    
    while( NormalIndex < ArrayCount(NormalGameTypes) )
    {
        NormalGameTypes[NormalIndex].bHidden = 1;
        NormalGameTypes[NormalIndex].ContextID = -1;
        ++NormalIndex;
    }

    i = 0;

    for( i = GameTypeRecords.Length - 1; i > 0; --i )
    {
        if( GameTypeRecords[i].ClassName == GameTypeName )
            break;
    }
    
	FocusOnGameType(i);
}

simulated function FocusOnGameType( int i )
{
    local int NormalIndex;
    local int CustomIndex;

	ShowGameTypeDetails(i);
    
    for( CustomIndex = 0; CustomIndex < ArrayCount(CustomGameTypes); ++CustomIndex )
    {
        if( CustomGameTypes[CustomIndex].ContextID == i )
        {
	        FocusOnWidget(CustomGameTypes[CustomIndex]);
        }
    }
    
    for( NormalIndex = 0; NormalIndex < ArrayCount(NormalGameTypes); ++NormalIndex )
    {
        if( NormalGameTypes[NormalIndex].ContextID == i )
        {
	        FocusOnWidget(NormalGameTypes[NormalIndex]);
        }
    }
}

simulated function DoDynamicLayout( Canvas C )
{
    local int i;
    local float TotalHeight;
    local float CurY;

    if( (NormalCount > 0) && (CustomCount > 0) )
    {
        NormalTitle.bHidden = 0;
        CustomTitle.bHidden = 0;
    }
    else
    {
        NormalTitle.bHidden = 1;
        CustomTitle.bHidden = 1;
    }

    if( (NormalCount > 0) && (CustomCount > 0) )
    {
        TotalHeight = (((NormalCount - 1) + (CustomCount - 1)) * ItemDY) + 4 * TitleDY;
        CurY = 0.5 - (TotalHeight * 0.5);
        
        NormalTitle.PosX = TitleX;
        NormalTitle.PosY = CurY;
        CurY += TitleDY;
        
        for( i = 0; i < NormalCount; ++i )
        {
            NormalGameTypes[i].Blurred.PosX = ItemX;
            NormalGameTypes[i].Focused.PosX = ItemX;

            NormalGameTypes[i].Blurred.PosY = CurY;
            NormalGameTypes[i].Focused.PosY = CurY;
            
            if( i == (NormalCount - 1) )
            {
                CurY += 2 * TitleDY;
            }
            else
            {
                CurY += ItemDY;
            }
        }

        CustomTitle.PosX = TitleX;
        CustomTitle.PosY = CurY;
        CurY += TitleDY;
        
        for( i = 0; i < CustomCount; ++i )
        {
            CustomGameTypes[i].Blurred.PosX = ItemX;
            CustomGameTypes[i].Focused.PosX = ItemX;
        
            CustomGameTypes[i].Blurred.PosY = CurY;
            CustomGameTypes[i].Focused.PosY = CurY;
            CurY += ItemDY;
        }
    }
    else
    {
        LayoutArray( CustomGameTypes[0], 'TitledOptionLayout' );
        LayoutArray( NormalGameTypes[0], 'TitledOptionLayout' );
    }

    Super.DoDynamicLayout( C );
}

simulated function LoadGameTypes()
{
    class'xUtil'.static.GetGameTypeList( GameTypeRecords );
}

simulated function OnSelect( int ContextId )
{
	GameTypeName = GameTypeRecords[ContextId].ClassName;
	SaveConfig();
	GotoNextMenu();
}

simulated function GotoNextMenu()
{
}

simulated function HandleInputBack()
{
    local int i;

    for( i = 0; i < ArrayCount(NormalGameTypes); i++ )
    {
        if( NormalGameTypes[i].bHasFocus != 0 )
        {
			GameTypeName = GameTypeRecords[NormalGameTypes[i].ContextId].ClassName;
			SaveConfig();
			break;
        }
    }

    for( i = 0; i < ArrayCount(CustomGameTypes); i++ )
    {
        if( CustomGameTypes[i].bHasFocus != 0 )
        {
			GameTypeName = GameTypeRecords[CustomGameTypes[i].ContextId].ClassName;
			SaveConfig();
			break;
        }
    }
}

simulated function ShowGameTypeDetails( int i )
{
    local String MapBink;
    
    MapBink = GameTypeRecords[i].Acronym $ "Loop.bik";
    
    if( Left(MapBink, 1) == "X" )
    {
        MapBink = Right(MapBink, Len(MapBink) - 1);
    }
    
    // log("MapBink:"@MapBink);
    SetBackgroundVideo( MapBink );
}

defaultproperties
{
     NormalTitle=(Text="Normal Maps",DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleLeft,PosX=0.510000,PosY=0.650000,ScaleX=0.700000,ScaleY=0.700000,Pass=2,Style="TitleText")
     NormalGameTypes(0)=(Blurred=(MaxSizeX=0.450000),OnFocus="ShowGameTypeDetails",OnSelect="OnSelect",Style="TitledTextOption")
     CustomTitle=(Text="Custom Maps",DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleLeft,PosX=0.510000,PosY=0.650000,ScaleX=0.700000,ScaleY=0.700000,Pass=2,Style="TitleText")
     CustomGameTypes(0)=(Blurred=(MaxSizeX=0.450000),OnFocus="ShowGameTypeDetails",OnSelect="OnSelect",Style="TitledTextOption")
     TitleX=0.100000
     ItemX=0.110000
     TitleDY=0.060000
     ItemDY=0.050000
     MenuTitle=(Text="Select Gametype")
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
