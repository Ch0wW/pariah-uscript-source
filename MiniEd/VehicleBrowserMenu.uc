/*
 Desc: A tab within the place object tool. Allows the
	   user to place vehicles.
 ksue
*/
class VehicleBrowserMenu extends ToolMenuBase
	native;

const NUM_THUMBS_PER_ROW	= 3;
const NUM_THUMBS			= 4;
const MESH_DIM				= 40.0;
const NUM_VEHICLES			= 4;


var float				MeshScale[NUM_THUMBS];
var MenuButtonSprite	Buttons[NUM_THUMBS];
var MenuActor			MeshPreview;
var MenuText			VehicleText;
var Vector				MeshPreviewPosition;
var Rotator				MeshPreviewRotSpeed;
var Rotator				MeshPreviewRotation;
var StaticMesh			PreviewMeshes[NUM_THUMBS];
var int					VehicleTypeIndex;
var class<actor>		VehicleClass;
var String				SelectedMeshName;
var String				SelectedClassName;
var array<String>		CategoryNames;		//List of the mesh categories
var int					NumCategories;
var string				VehicleMeshNames[5];
var Material			VehicleThumbs[5];
var array<String>		VehicleClassNames[5];
var array<String>		VehicleDesc;	// vehicle description
var int					SelectedMeshIndex;

//Help text
var localized string HelpText_SelectBogie;
var localized string HelpText_SelectWasp;
var localized string HelpText_SelectDart;
var localized string HelpText_SelectDozer;
var localized string HelpText_CloseMenu;

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
	local int		i;
	local float		PosX, PosY, ScaleX, ScaleY, OffsetY, spacingX, spacingY;
	local Material	M;
	local float		LargestDim;
	
	//After laying out gui
	Super.Init( Args );

	spacingX = 0.115;
	spacingY = 0.115;
	PosX = 0.55 + ((i%NUM_THUMBS_PER_ROW)+1) * spacingX;
	PosY = OffsetY + (i/NUM_THUMBS_PER_ROW) * spacingY;

	OffsetY = 0.535;
	ScaleX = 0.11;
	ScaleY = 0.12;	
	
	M = Material'PariahPlayerMugShotsTextures.cDefault';
	
	for ( i = 0; i < NUM_THUMBS; i++ )
	{
		PosX = 0.55 + ((i%3)+1) * spacingX;
		PosY = OffsetY + (i/3) * spacingY;
		if ( VehicleThumbs[i] != None )
			M = VehicleThumbs[i];
		else
			M = Material'PariahPlayerMugShotsTextures.cDefault';
			
		InitMenuButtonSprite( Buttons[i], PosX, PosY, ScaleX, ScaleY, M );

        PreviewMeshes[i]=StaticMesh(DynamicLoadObject( VehicleMeshNames[i], class'StaticMesh'));

		LargestDim = GetLargestDim( PreviewMeshes[i] );
		MeshScale[ i ] = MESH_DIM/LargestDim;

        if( !IsOnConsole() )
            Buttons[i].OnFocus='ChangePreview';
	}
	
	UpdateButtonVisibility();
	InitMeshPreview();

	VehicleTypeIndex = 0;
	FocusOnWidget( Buttons[VehicleTypeIndex] );
	SelectWidget( Buttons[VehicleTypeIndex] );
	SetPreview(VehicleTypeIndex);

	MakePanelPanIn();
	SetHelpText_B( HelpText_CloseMenu );
}


simulated function ChangePreview()
{
    UpdateSelection();
}


// Goes through each button and checks if it has a sprite, if not, the button is hidden
simulated function UpdateButtonVisibility()
{
	local int i;
	
	for( i = 0; i < NUM_THUMBS; i++ )	
		Buttons[i].bHidden = 0;
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


simulated function OnBogie()
{
	SetHelpText_A( HelpText_SelectBogie );
}


simulated function SelectBogie()
{
	SelectedMeshName = VehicleMeshNames[0];
	VehicleClass = class'MiniEdPawns.MiniEdVehicleStartBogie';
	SelectedClassName = VehicleClassNames[0];
	UpdateSelection();
}


simulated function OnDart()
{
	SetHelpText_A( HelpText_SelectDart );
}


simulated function SelectDart()
{
	SelectedMeshName = VehicleMeshNames[1];
	VehicleClass = class'MiniEdPawns.MiniEdVehicleStartDart';
	SelectedClassName = VehicleClassNames[1];
	UpdateSelection();
}


simulated function OnDozer()
{
	SetHelpText_A( HelpText_SelectDozer );
}


simulated function SelectDozer()
{
	SelectedMeshName = VehicleMeshNames[2];
	VehicleClass = class'MiniEdPawns.MiniEdVehicleStartDozer';
	SelectedClassName = VehicleClassNames[2];
	UpdateSelection();
}


simulated function OnWasp()
{
	SetHelpText_A( HelpText_SelectWasp );
}


simulated function SelectWasp()
{
	SelectedMeshName = VehicleMeshNames[3];
	VehicleClass = class'MiniEdPawns.MiniEdVehicleStartWasp';
	SelectedClassName = VehicleClassNames[3];
	UpdateSelection();
}


simulated function int GetSelectionOnFocus()
{
    local int i;
    for( i = 0; i < NUM_THUMBS; i++ )
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
    if( SelectionIndex != -1 && (SelectionIndex != VehicleTypeIndex) )
        SetPreview(SelectionIndex);
}


simulated function SetPreview( int i )
{
    local vector PreviewHalfHeight;

    VehicleTypeIndex = i;
	switch (i)
	{
		case 0:
			VehicleClass = class'MiniEdPawns.MiniEdVehicleStartBogie';
			break;
		case 1:
			VehicleClass = class'MiniEdPawns.MiniEdVehicleStartDart';					
			break;
		case 2:
			VehicleClass = class'MiniEdPawns.MiniEdVehicleStartDozer';				
			break;
		case 3:
			VehicleClass = class'MiniEdPawns.MiniEdVehicleStartWasp';
			
	}

	VehicleText.text = VehicleDesc[i];

	if( PreviewMeshes[i] == None )
	{
		log( "sorry, no mesh to preview yet" );
		return;
	}
	MeshPreview.Actor.SetStaticMesh( PreviewMeshes[i] );
	MeshPreview.Actor.SetDrawScale( MeshScale[i] );
	PreviewHalfHeight.Z = 0.5f * MeshScale[i] * GetHeight( PreviewMeshes[i] );
	MeshPreview.Actor.SetLocation( MeshPreviewPosition - PreviewHalfHeight );
	
	SelectedMeshName = VehicleMeshNames[i];
	SelectedClassName = VehicleClassNames[i];
	SelectedMeshIndex = i;
}


simulated function bool OnLeftSide()
{
	if( (VehicleTypeIndex % NUM_THUMBS_PER_ROW) == 0 )	
	{
		return true;
	}
	return false;
}



//To select the thumbnail button on the left
simulated function HandleInputLeft()
{
	Super.HandleInputLeft();
	UpdateSelection();
}


//To select the thumbnail button on the right
simulated function HandleInputRight()
{
	//If the focus was on a button on the right side of the set of thumbnails
	Super.HandleInputRight();
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


simulated function OnARelease()
{
	MeshPreview.Actor.SetStaticMesh( None );
    CloseMenu();
    MakePanelPanOut();
    return;
}


simulated function OnBRelease()
{
	Super.OnBRelease();
	SelectedMeshName = "";
	SelectedClassName = "";
	MeshPreview.bHidden = 1;
}


simulated function CloseMenu()
{
	Super.CloseMenu();
	VehicleTypeIndex = 0;
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
     Buttons(0)=(Blurred=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleMode=MSM_Fit),BackgroundBlurred=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleMode=MSM_Fit),OnFocus="OnBogie",OnSelect="SelectBogie",Pass=1)
     Buttons(1)=(Blurred=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleMode=MSM_Fit),BackgroundBlurred=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleMode=MSM_Fit),OnFocus="OnDart",OnSelect="SelectDart",Pass=1)
     Buttons(2)=(Blurred=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleMode=MSM_Fit),BackgroundBlurred=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleMode=MSM_Fit),OnFocus="OnDozer",OnSelect="SelectDozer",Pass=1)
     Buttons(3)=(Blurred=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleMode=MSM_Fit),BackgroundBlurred=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleMode=MSM_Fit),OnFocus="OnWasp",OnSelect="SelectWasp",Pass=1)
     MeshPreview=(FOV=90.000000,Lights=((Position=(Y=-50.000000),Color=(B=255,G=255,R=255,A=255),Radius=360.000000)),AmbientGlow=30,Pass=2)
     VehicleText=(MenuFont=Font'Engine.FontSmall',Text="This is a test",DrawPivot=DP_MiddleLeft,PosX=0.568000,PosY=0.250000,ScaleX=0.900000,ScaleY=0.900000,Pass=3,Style="LabelText")
     MeshPreviewPosition=(X=100.000000,Y=55.000000,Z=28.000000)
     MeshPreviewRotSpeed=(Yaw=6000)
     VehicleMeshNames(0)="MiniEdMeshes.Vehicles.BogieMiniEd"
     VehicleMeshNames(1)="MiniEdMeshes.Vehicles.DartMiniEd"
     VehicleMeshNames(2)="MiniEdMeshes.Vehicles.DozerMiniEd"
     VehicleMeshNames(3)="MiniEdMeshes.Vehicles.WaspMiniEd"
     VehicleThumbs(0)=Texture'MiniEdTextures.Buttons.Bogie64'
     VehicleThumbs(1)=Texture'MiniEdTextures.Buttons.Dart64'
     VehicleThumbs(2)=Texture'MiniEdTextures.Buttons.Dozer64'
     VehicleThumbs(3)=Texture'MiniEdTextures.Buttons.Wasp64'
     VehicleClassNames(0)="MiniEdPawns.MiniEdVehicleStartBogie"
     VehicleClassNames(1)="MiniEdPawns.MiniEdVehicleStartDart"
     VehicleClassNames(2)="MiniEdPawns.MiniEdVehicleStartDozer"
     VehicleClassNames(3)="MiniEdPawns.MiniEdVehicleStartWasp"
     VehicleDesc(0)="Bogie"
     VehicleDesc(1)="Dart"
     VehicleDesc(2)="Dozer"
     VehicleDesc(3)="Wasp"
     HelpText_SelectBogie="Select Bogie"
     HelpText_SelectWasp="Select Wasp"
     HelpText_SelectDart="Select Dart"
     HelpText_SelectDozer="Select Dozer"
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
