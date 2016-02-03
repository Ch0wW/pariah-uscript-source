class MenuActorSkeletalMesh extends Actor
    NotPlaceable;

simulated event AnimEnd( int Channel )
{
    local MenuBase M;
    
    M = MenuBase(Owner);
    
    if( M != None )
        M.ChildAnimEnd( self, Channel );
}

defaultproperties
{
     LODBias=100.000000
     DrawType=DT_Mesh
     RemoteRole=ROLE_None
     bHidden=True
     bNoSave=True
}
