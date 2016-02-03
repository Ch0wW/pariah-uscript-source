class DropShipCargoDoor extends Actor;

defaultproperties
{
     StaticMesh=StaticMesh'PariahDropShipMeshes.SmallDropShip.DropShipCargoHoldDoorB'
     Begin Object Class=HavokParams Name=CargoDoorHParams
         Mass=10.000000
         bWantContactEvent=True
     End Object
     HParams=HavokParams'PariahSP.CargoDoorHParams'
     DrawType=DT_StaticMesh
     SurfaceType=EST_Metal
     bHardAttach=True
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
}
