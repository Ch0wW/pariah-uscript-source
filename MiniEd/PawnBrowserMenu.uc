/*******************************************************
 PawnBrowserMenu
 Desc: Opens from the MeshBrowserMenu when the user presses
	   LT.  Otherwise operates similarly to the MeshBrowserMenu
 ******************************************************/
class PawnBrowserMenu extends ToolMenuBase
	native;

const NUM_THUMBS_PER_ROW	= 3;
const NUM_THUMBS_PER_PAGE	= 9;
const MESH_DIM				= 40.0;

var float				MeshScale[NUM_THUMBS_PER_PAGE];
var MenuButtonSprite	Buttons[NUM_THUMBS_PER_PAGE];
var MenuActor			MeshPreview;
var MenuText			PawnText;
var Vector				MeshPreviewPosition;
var Rotator				MeshPreviewRotSpeed;
var Rotator				MeshPreviewRotation;
var StaticMesh			PreviewMeshes[NUM_THUMBS_PER_PAGE];
var int					ActivePage; //the page index displaying meshes
var int					SelectedMesh;
var class<actor>		SelectedClass;
var int					PageSelectedMesh;
var String				SelectedMeshName;
var String				SelectedClassName;
var array<String>		CategoryNames;		//List of the mesh categories
var int					NumCategories;

var array<String> PawnNames;
var array<String> PawnThumbs;
var array<String> PawnMesh;
var array<vector> PawnOffset;
var array<class<actor> > PawnClasses;
var array<String> PawnDesc;	// pawn description

var vector MeshOffset;

var bool bWantDynamicPanel;	// want to bring up dynamic object (pawn) panel

//Help text
var localized string	HelpText_SelectGameObject;
var localized string	HelpText_CloseMenu;


event AnimatorDone( int Id )
{
	switch( Id )
	{
	case 1:
		CloseMenu();		
		break;
	}
}

simulated function MakePanelPanIn()
{
	local int i;

	MakeTranslator( 0, MD_Left, 0.5, 0.4 );
	
	//Add the widgets to the animator
	AddToAnimator( DrawerBackground );
	for( i=0; i < ArrayCount(Buttons); i++ )
		AddToAnimator( Buttons[i] );

	MoveAnimatedDir( MD_Right, 0.4 );
}


simulated function MakePanelPanOut()
{
	local int i;

	MakeTranslator( 1, MD_Right, 0.5, 0.4 );

	//Add the widgets to the animator
	AddToAnimator( DrawerBackground );
	for( i=0; i < ArrayCount(Buttons); i++ )
		AddToAnimator( Buttons[i] );
}


simulated function Init( String Args )
{
	//After laying out gui
	Super.Init( Args );

	NumCategories = PawnNames.Length / NUM_THUMBS_PER_PAGE;
	if( (PawnNames.Length % NUM_THUMBS_PER_PAGE) != 0 )
		NumCategories++;

	UpdateButtonVisibility();
	InitThumbnails();
	InitMeshPreview();

	ActivePage = 0;
	SelectedMesh = 0;
	UpdatePage();

	MakePanelPanIn();
	
	FocusOnWidget( Buttons[0] );
	SelectWidget( Buttons[0] );
    SetPreview(0);

	SetHelpText_A( HelpText_SelectGameObject );
	SetHelpText_B( HelpText_CloseMenu );
}


// Goes through each button and checks if it has a sprite, if not, the button is hidden
simulated function UpdateButtonVisibility()
{
	local int i;
	local int NumInLast;

	for( i = 0; i < NUM_THUMBS_PER_PAGE; i++ )	
	{
		Buttons[i].bHidden = 0;
	}

	// have to be careful here because if we have a multiple of NUM_THUMBS_PER_PAGE and we're on the last page
	// then it would actually hide all the thumbnails
	if( ActivePage == NumCategories-1 && (PawnNames.Length % NUM_THUMBS_PER_PAGE) != 0)
	{
		NumInLast = PawnNames.Length % NUM_THUMBS_PER_PAGE;
		for( i = NumInLast; i < NUM_THUMBS_PER_PAGE; i++ )	
			Buttons[i].bHidden = 1;
	}
}


simulated function InitThumbnails()
{
	local float spacingX, spacingY, OffsetY, PosX, PosY, ScaleX, ScaleY;
	local int i;
	local Material DefaultMat;

	spacingX = 0.115;
	spacingY = 0.115;
	OffsetY = 0.535;
	ScaleX = 0.11;
	ScaleY = 0.12;
	DefaultMat = Material'PariahPlayerMugShotsTextures.cDefault';

	for( i = 0; i < NUM_THUMBS_PER_PAGE; i++ )
	{
		PosX = 0.55 + ((i%NUM_THUMBS_PER_ROW)+1) * spacingX;
		PosY = OffsetY + (i/NUM_THUMBS_PER_ROW) * spacingY;
		InitMenuButtonSprite( Buttons[i], PosX, PosY, ScaleX, ScaleY, DefaultMat );

        if( !IsOnConsole() )
            Buttons[i].OnFocus='ChangePreview';
	}
}


simulated function ChangePreview()
{
    UpdateSelection();
}


simulated function InitMeshPreview()
{
	local class<actor>	MeshPreviewClass;
	MeshPreviewClass = class<Actor>(DynamicLoadObject("XInterface.MenuActorStaticMesh",class'Class'));
	MeshPreview.Actor = Spawn( MeshPreviewClass, self, , MeshPreviewPosition );
}

simulated function Tick( float DeltaTime )
{
	MeshPreviewRotation = MeshPreviewRotation + MeshPreviewRotSpeed*DeltaTime;
	MeshPreview.Actor.SetRotation( MeshPreviewRotation );
}

//When the user presses A the selected mesh is spawned in the level at the 
//terrain lookat position, but a bit off the ground
simulated function HandleInputSelect()
{
	Super.HandleInputSelect(); //So that a focused widget can be selected
}


simulated function OnMesh()
{
	UpdateSelection();
}


simulated function int GetSelectionOnFocus()
{
    local int i;
    for( i = 0; i < NUM_THUMBS_PER_PAGE; i++ )
    {
        if( Buttons[i].bHasFocus != 0 )
            return i;
    }
    return -1;
}


simulated function UpdateSelection()
{
    local int SelectionIndex;
    SelectionIndex = GetSelectionOnFocus();
    if( SelectionIndex != -1 && (ActivePage*NUM_THUMBS_PER_PAGE + SelectionIndex) != SelectedMesh )
        SetPreview(SelectionIndex);
}


simulated function SetPreview( int i )
{
    local vector PreviewHalfHeight;
    PageSelectedMesh = i;
    SelectedMesh = ActivePage*NUM_THUMBS_PER_PAGE + i;
    if( PreviewMeshes[i] == None )
	{
		log( "preview mesh no good" );
		return;
    }
	MeshPreview.Actor.SetStaticMesh( PreviewMeshes[i] );
	MeshPreview.Actor.SetDrawScale( MeshScale[i]*0.5 );
	PreviewHalfHeight.Z = 0.5f * MeshScale[i]*0.5 * GetHeight( PreviewMeshes[i] );
	MeshPreview.Actor.SetLocation( MeshPreviewPosition - PreviewHalfHeight );
	PawnText.text = PawnDesc[SelectedMesh];
}


simulated function bool OnLeftSide()
{
	if( (PageSelectedMesh % NUM_THUMBS_PER_ROW) == 0 )	
	{
		return true;
	}
	return false;
}


simulated function bool OnRightSide()
{
	if( (PageSelectedMesh % NUM_THUMBS_PER_ROW) == (NUM_THUMBS_PER_ROW-1) )	
	{
		return true;
	}
	return false;
}


//To select the thumbnail button on the left
simulated function HandleInputLeft()
{
	//If the focus was on a button on the left side of the set of thumbnails
	if( OnLeftSide() )
	{
		if( ActivePage != 0 )
		{
			ActivePage--;
			FocusOnWidget( Buttons[NUM_THUMBS_PER_PAGE-1] );
			SelectWidget( Buttons[NUM_THUMBS_PER_PAGE-1] );	
			UpdatePage();
		}
	}
	else
	{
		Super.HandleInputLeft();
	}
	UpdateSelection();
}


//To select the thumbnail button on the right
simulated function HandleInputRight()
{
	//If the focus was on a button on the right side of the set of thumbnails
	if( OnRightSide() )
	{
		if( ActivePage != (NumCategories-1) )
		{
			ActivePage++;
			FocusOnWidget( Buttons[0] );
			SelectWidget( Buttons[0] );					
			UpdatePage();
		}
	}
	else
	{
		Super.HandleInputRight();
	}
	UpdateSelection();
}


simulated function HandleInputUp()
{
	Super.HandleInputUp();
	UpdateSelection();
}


simulated function HandleInputDown()
{
	Super.HandleInputDown();
	UpdateSelection();
}


// When the active page is changed this is called to swap the sprites and the static meshes
// I do this swap to have more memory available
simulated function UpdatePage()
{
	local Material M;
	local float LargestDim;
	local int i, Index;

	for( i = 0; i < NUM_THUMBS_PER_PAGE; i++ )	
	{
		// Change the thumbnails
		Index = ActivePage*NUM_THUMBS_PER_PAGE + i;

		if( index >= PawnThumbs.Length )
			M = Material'PariahPlayerMugShotsTextures.cDefault';
		else
			M = Material(DynamicLoadObject( PawnThumbs[index], class'Material'));

		Buttons[i].Blurred.WidgetTexture = M;
		Buttons[i].Focused.WidgetTexture = M;

		// Change loaded meshes
		if( Index < PawnNames.Length )
			PreviewMeshes[i]=StaticMesh(DynamicLoadObject(PawnMesh[Index], class'StaticMesh'));			

		if( PreviewMeshes[i] == None )
		{
			log( "MESH DOES NOT EXIST: " $ PawnMesh[Index] );
		}
		else
		{
			LargestDim = GetLargestDim( PreviewMeshes[i] );
			MeshScale[ i ] = MESH_DIM/LargestDim;		
		}
	}
	
	UpdateButtonVisibility();
}


simulated function OnARelease()
{
	SelectedMeshName = PawnMesh[SelectedMesh];
	SelectedClassName = PawnNames[SelectedMesh];
	SelectedClass = PawnClasses[SelectedMesh];
	MeshOffset = PawnOffset[SelectedMesh];
	CloseMenu();
	MeshPreview.Actor.SetStaticMesh( None );
	MakePanelPanOut();
}


simulated function OnBRelease()
{
	Super.OnBRelease();
	MeshPreview.bHidden = 1;
}


simulated function CloseMenu()
{
	Super.CloseMenu();
	SelectedMesh = 0;
	ActivePage = 0;
}


simulated function Destroyed()
{
    if( MeshPreview.Actor != None )
    {
        MeshPreview.Actor.Destroy();
        MeshPreview.Actor = None;
    }
    
    Super.Destroyed();
}

defaultproperties
{
     Buttons(0)=(Blurred=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleMode=MSM_Fit),BackgroundBlurred=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleMode=MSM_Fit),OnSelect="OnMesh",Pass=1)
     Buttons(1)=(Blurred=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleMode=MSM_Fit),BackgroundBlurred=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleMode=MSM_Fit),OnSelect="OnMesh",Pass=1)
     Buttons(2)=(Blurred=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleMode=MSM_Fit),BackgroundBlurred=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleMode=MSM_Fit),OnSelect="OnMesh",Pass=1)
     Buttons(3)=(Blurred=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleMode=MSM_Fit),BackgroundBlurred=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleMode=MSM_Fit),OnSelect="OnMesh",Pass=1)
     MeshPreview=(FOV=90.000000,Lights=((Position=(Y=-50.000000),Color=(B=255,G=255,R=255,A=255),Radius=360.000000)),AmbientGlow=110,Pass=2)
     PawnText=(MenuFont=Font'Engine.FontSmall',Text="This is a test",DrawPivot=DP_MiddleLeft,PosX=0.568000,PosY=0.250000,ScaleX=0.900000,ScaleY=0.900000,Pass=3,Style="LabelText")
     MeshPreviewPosition=(X=100.000000,Y=55.000000,Z=22.000000)
     MeshPreviewRotSpeed=(Yaw=6000)
     PawnNames(0)="MiniEdPawns.MiniEdDroneArea"
     PawnNames(1)="MiniEdPawns.MiniEdDroneAreaKamikaze"
     PawnNames(2)="MiniEdPawns.MiniEdDroneAreaProtector"
     PawnNames(3)="MiniEdPawns.MiniEdPopUpMine"
     PawnNames(4)="MiniEdPawns.MiniEdAutoTurret"
     PawnNames(5)="MiniEdPawns.MiniEdPlayerTurretTwo"
     PawnNames(6)="MiniEdPawns.MiniEdExplodingBarrel"
     PawnNames(7)="MiniEdPawns.MiniEdAmmoStation"
     PawnThumbs(0)="AM_MiniEdExileTextures.ThumbNails.AssaultDrone"
     PawnThumbs(1)="AM_MiniEdExileTextures.ThumbNails.KamikazeDrone"
     PawnThumbs(2)="AM_MiniEdExileTextures.ThumbNails.ProtectorDrone"
     PawnThumbs(3)="AM_MiniEdExileTextures.ThumbNails.PopUpMine"
     PawnThumbs(4)="AM_MiniEdExileTextures.ThumbNails.MiniTurret"
     PawnThumbs(5)="AM_MiniEdExileTextures.ThumbNails.Turret2"
     PawnThumbs(6)="AM_MiniEdExileTextures.ThumbNails.ExplodingBarrel"
     PawnThumbs(7)="AM_MiniEdExileTextures.ThumbNails.AmmoStation"
     PawnMesh(0)="MiniEdGameObjects.AssaultDrone"
     PawnMesh(1)="MiniEdGameObjects.KamaDrone"
     PawnMesh(2)="MiniEdGameObjects.Protector"
     PawnMesh(3)="MiniEdGameObjects.MPopUp"
     PawnMesh(4)="JR_MiniEdForestPrefabs.Installations.Turret_01"
     PawnMesh(5)="MiniEdGameObjects.MPlayerTurret"
     PawnMesh(6)="HavokObjectsPrefabs.Barrels.ExplosiveBarrel"
     PawnMesh(7)="MiniedGameObjects.MAmmoStation"
     PawnOffset(0)=(Z=200.000000)
     PawnOffset(1)=(Z=200.000000)
     PawnOffset(2)=(Z=200.000000)
     PawnClasses(0)=Class'MiniEdPawns.MiniEdDroneArea'
     PawnClasses(1)=Class'MiniEdPawns.MiniEdDroneAreaKamikaze'
     PawnClasses(2)=Class'MiniEdPawns.MiniEdDroneAreaProtector'
     PawnClasses(3)=Class'MiniEdPawns.MiniEdPopUpMine'
     PawnClasses(4)=Class'MiniEdPawns.MiniEdAutoTurret'
     PawnClasses(5)=Class'MiniEdPawns.MiniEdPlayerTurretTwo'
     PawnClasses(6)=Class'MiniEdPawns.MiniEdExplodingBarrel'
     PawnClasses(7)=Class'MiniEdPawns.MiniEdAmmoStation'
     PawnDesc(0)="Assault Drone"
     PawnDesc(1)="Kamikaze Drone"
     PawnDesc(2)="Protector Drone"
     PawnDesc(3)="Pop-up Mine"
     PawnDesc(4)="Automatic Turret"
     PawnDesc(5)="Player Turret 2"
     PawnDesc(6)="Explodable Barrel"
     PawnDesc(7)="Ammo Refill Station"
     HelpText_SelectGameObject="Select this game object"
     HelpText_CloseMenu="Close Menu"
     DrawerBackground=(ScaleX=0.450000,ScaleY=0.650000)
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
