class VGHavokBogieCoop extends VGHavokBogieSP
    placeable;

//simulated function InitializeVehicle()
//{
//	Super.InitializeVehicle();
//	PassengerPoints[0].z+=93;
//}

//simulated function DoVehicleDeathEffects()
//{
//	Super.DoVehicleDeathEffects();
//
//	spawn(class'VehicleEffects.CaboomDistort',,,Location);
//	spawn(class'VehicleEffects.CaboomExplosion',,,Location);
//	spawn(class'VehicleEffects.DavidVehicleExplosionTiresBogie',,,Location);
//}

defaultproperties
{
     FrontWheelMass=20.000000
     FrontWheelFriction=1.500000
     FrontSuspStrength=35.000000
     RearWheelFriction=1.550000
     RearSuspStrength=35.000000
     MaxSpeedFullSteeringAngle=5500.000000
     MaxTorque=2500.000000
     FrontalArea=20000.000000
     InAirCollisionSpinDamping=5.000000
     HitImpulseScale=1.000000
     Begin Object Class=TireEffectInfo Name=TireEffectInfo96
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=300.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Dirt
         SurfaceTypes(1)=EST_Rock
         MaxPPS=15.000000
         EmitterClass=Class'VehicleEffects.DavidTireDirt'
     End Object
     TireEffects(0)=TireEffectInfo'VehicleVehicles.TireEffectInfo96'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo97
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=300.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Dirt
         SurfaceTypes(1)=EST_Rock
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireDirtB'
     End Object
     TireEffects(1)=TireEffectInfo'VehicleVehicles.TireEffectInfo97'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo98
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=10.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Water
         SurfaceTypes(1)=EST_Wet
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireWater'
     End Object
     TireEffects(2)=TireEffectInfo'VehicleVehicles.TireEffectInfo98'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo99
         TireSlipScale=0.500000
         TireSlipRange=(Min=100.000000,Max=300.000000)
         SurfaceTypes(0)=EST_Dirt
         SurfaceTypes(1)=EST_Rock
         MaxPPS=10.000000
         EmitterClass=Class'VehicleEffects.DavidTireDust'
     End Object
     TireEffects(3)=TireEffectInfo'VehicleVehicles.TireEffectInfo99'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo100
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=10.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Metal
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireDirtC'
     End Object
     TireEffects(4)=TireEffectInfo'VehicleVehicles.TireEffectInfo100'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo101
         TireSlipScale=0.500000
         TireSlipRange=(Min=100.000000,Max=300.000000)
         SurfaceTypes(0)=EST_Metal
         MaxPPS=10.000000
         EmitterClass=Class'VehicleEffects.DavidTireDustB'
     End Object
     TireEffects(5)=TireEffectInfo'VehicleVehicles.TireEffectInfo101'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo102
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=100.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Plant
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireDustB'
     End Object
     TireEffects(6)=TireEffectInfo'VehicleVehicles.TireEffectInfo102'
     Suspensions(0)=(DecoPieces=((BaseOffset=(X=160.276993,Y=34.770000,Z=-35.516998),Target=SPL_Wheel0,TargetOffset=(Z=-10.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.bogie.BogieSuspensionBase01'),(BaseOffset=(X=160.645004,Y=42.374001,Z=10.774000),Target=SPL_Wheel0,TargetOffset=(Y=28.600000),StaticMesh=StaticMesh'PariahVehicleMeshes.bogie.BogieSuspensionSpring01')))
     Suspensions(1)=(DecoPieces=((BaseOffset=(X=160.276993,Y=34.770000,Z=-35.516998),Target=SPL_Wheel1,TargetOffset=(Z=-10.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.bogie.BogieSuspensionBase02'),(BaseOffset=(X=160.645004,Y=42.374001,Z=10.774000),Target=SPL_Wheel1,TargetOffset=(Y=28.600000),StaticMesh=StaticMesh'PariahVehicleMeshes.bogie.BogieSuspensionSpring02')))
     Suspensions(2)=(DecoPieces=((BaseOffset=(X=-140.300995,Y=34.770000,Z=-35.516998),Target=SPL_Wheel2,TargetOffset=(Z=-10.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.bogie.BogieSuspensionBase01'),(BaseOffset=(X=-139.932999,Y=42.374001,Z=10.774000),Target=SPL_Wheel2,TargetOffset=(Y=28.600000),StaticMesh=StaticMesh'PariahVehicleMeshes.bogie.BogieSuspensionSpring01')))
     Suspensions(3)=(DecoPieces=((BaseOffset=(X=-140.300995,Y=34.770000,Z=-32.516998),Target=SPL_Wheel3,TargetOffset=(Z=-10.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.bogie.BogieSuspensionBase02'),(BaseOffset=(X=-139.932999,Y=42.374001,Z=10.774000),Target=SPL_Wheel3,TargetOffset=(Y=28.600000),StaticMesh=StaticMesh'PariahVehicleMeshes.bogie.BogieSuspensionSpring02')))
     Tiretracks(0)=(Surfaces=(EST_Metal,EST_Rock,EST_Plant,EST_Dirt),MinSkidEnergy=1.000000,MaxSkidEnergy=250.000000,Material=Texture'PariahVehicleTextures.Shared.TireTreadColour')
     GearRatios(0)=1.400000
     GearRatios(1)=1.000000
     GearRatios(2)=0.600000
     MaxSteerAngle=8000.000000
     camdist=750.000000
     camheight=300.000000
     MinRamSpeed=1000.000000
     StopEngineSoundSpeed=10.000000
     RiderAnims(1)="MaleBogieRear"
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo125
         DamageRadius=200.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.bogie.BogiePanel01'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointPanel01"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(RequiredImpactDamage=20,RequiredOtherDamage=20,Action=DSA_SpawnEmitter)
         DamageSequence(2)=(RequiredImpactDamage=20,RequiredOtherDamage=20,Action=DSA_RelMoveMesh)
         DamageSequence(3)=(RequiredImpactDamage=20,RequiredOtherDamage=20,Action=DSA_TurnOnKarmaWithAttachedEmitter,IArg1=1,FArg1=5.000000,Vec=(Y=-20000.000000,Z=25000.000000))
         DamageSequence(4)=(RequiredImpactDamage=20,RequiredOtherDamage=20,Action=DSA_Destroy,IArg1=3)
     End Object
     DamageableParts(4)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo125'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo126
         DamageRadius=200.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.bogie.BogiePanel02'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointPanel02"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(RequiredOtherDamage=20,Action=DSA_SpawnEmitter)
         DamageSequence(2)=(RequiredOtherDamage=20,Action=DSA_RelMoveMesh)
         DamageSequence(3)=(RequiredOtherDamage=20,Action=DSA_TurnOnKarmaWithAttachedEmitter,IArg1=1,FArg1=5.000000,Vec=(Y=20000.000000,Z=25000.000000))
         DamageSequence(4)=(RequiredOtherDamage=20,Action=DSA_Destroy,IArg1=3)
     End Object
     DamageableParts(5)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo126'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo127
         DamageRadius=200.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.bogie.BogiePanel03'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointPanel03"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(RequiredImpactDamage=20,RequiredOtherDamage=20,Action=DSA_SpawnEmitter)
         DamageSequence(2)=(RequiredImpactDamage=20,RequiredOtherDamage=20,Action=DSA_RelMoveMesh)
         DamageSequence(3)=(RequiredImpactDamage=20,RequiredOtherDamage=20,Action=DSA_TurnOnKarmaWithAttachedEmitter,IArg1=1,FArg1=5.000000,Vec=(Y=-20000.000000,Z=25000.000000))
         DamageSequence(4)=(RequiredImpactDamage=20,RequiredOtherDamage=20,Action=DSA_Destroy,IArg1=3)
     End Object
     DamageableParts(6)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo127'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo128
         DamageRadius=200.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.bogie.BogiePanel04'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointPanel04"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(RequiredOtherDamage=20,Action=DSA_SpawnEmitter)
         DamageSequence(2)=(RequiredOtherDamage=20,Action=DSA_RelMoveMesh)
         DamageSequence(3)=(RequiredOtherDamage=20,Action=DSA_TurnOnKarmaWithAttachedEmitter,IArg1=1,FArg1=5.000000,Vec=(Y=20000.000000,Z=25000.000000))
         DamageSequence(4)=(RequiredOtherDamage=20,Action=DSA_Destroy,IArg1=3)
     End Object
     DamageableParts(7)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo128'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo10
         DamageRadius=200.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.bogie.BogieSteeringWheel'
         AttachPoints(0)="PointSteeringWheel"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(Action=DSA_SteeringMovesMesh,Rot=(Roll=-20000))
     End Object
     DamageableParts(10)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo10'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo13
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.bogie.BogieCoopRearBad'
         AttachPoints(0)="PointRear"
         DamageSequence(0)=(Action=DSA_AttachMesh)
     End Object
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo12
         DamageRadius=300.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.bogie.BogieCoopRearClean'
         PartMeshes(1)=StaticMesh'PariahVehicleMeshes.bogie.BogieCoopRearDamaged'
         PartMeshes(2)=StaticMesh'PariahVehicleMeshes.bogie.BogieRearOff'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointRear"
         DamageableParts(0)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo13'
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(RequiredImpactDamage=10,RequiredOtherDamage=10,Action=DSA_SpawnEmitter)
         DamageSequence(2)=(RequiredImpactDamage=10,RequiredOtherDamage=10,Action=DSA_AttachMesh)
         DamageSequence(3)=(RequiredImpactDamage=20,RequiredOtherDamage=20,Action=DSA_SpawnEmitter)
         DamageSequence(4)=(RequiredImpactDamage=20,RequiredOtherDamage=20,Action=DSA_AttachMesh,IArg1=1)
     End Object
     DamageableParts(12)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo12'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo131
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.bogie.BogieFrontBad'
         AttachPoints(0)="PointFront"
         DamageSequence(0)=(Action=DSA_AttachMesh)
     End Object
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo14
         DamageRadius=250.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.bogie.BogieFrontClean'
         PartMeshes(1)=StaticMesh'PariahVehicleMeshes.bogie.BogieFrontDamaged'
         PartMeshes(2)=StaticMesh'PariahVehicleMeshes.bogie.BogieFrontOff'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointFront"
         DamageableParts(0)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo131'
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(RequiredImpactDamage=10,RequiredOtherDamage=10,Action=DSA_SpawnEmitter)
         DamageSequence(2)=(RequiredImpactDamage=10,RequiredOtherDamage=10,Action=DSA_AttachMesh)
         DamageSequence(3)=(RequiredImpactDamage=20,RequiredOtherDamage=20,Action=DSA_SpawnEmitter)
         DamageSequence(4)=(RequiredImpactDamage=20,RequiredOtherDamage=20,Action=DSA_AttachMesh,IArg1=1)
         DamageSequence(5)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_SpawnEmitter)
         DamageSequence(6)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_AttachMesh,IArg1=2)
         DamageSequence(7)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_SpawnEmitter)
         DamageSequence(8)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_SpawnDamageablePart)
         DamageSequence(9)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_RelMoveMesh)
         DamageSequence(10)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_TurnOnKarmaWithAttachedEmitter,IArg1=1,FArg1=10.000000,Vec=(X=20000.000000,Z=20000.000000))
         DamageSequence(11)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_Destroy,IArg1=3)
     End Object
     DamageableParts(14)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo14'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo117
         DamageRadius=200.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.bogie.BogieGunnerStick'
         AttachPoints(0)="PointGunnerStick"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(Action=DSA_SteeringMovesMesh,Rot=(Roll=-20000))
     End Object
     DamageableParts(15)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo117'
     DriverEntryNames(0)="PointDriverIn"
     PassengerPointNames(0)="PointGunner"
     PassengerPointNames(1)="PointPassenger"
     PassengerPointEntryNames(0)="PointGunnerIn"
     PassengerPointEntryNames(1)="PointPassengerIn"
     DefaultWeapons(0)="VehicleWeapons.Puncher"
     Begin Object Class=VehicleEffectInfo Name=VehicleEffectInfo14
         PPSBase=50.000000
         PPSScale=-1.000000
         ControlRange=(Min=0.000000,Max=200.000000)
         ControlType=VEC_Health
         MaxPPS=30.000000
         EmitterClass=Class'VehicleEffects.DavidEngineSmoke'
     End Object
     CarEffects(0)=(OnWhenCarEmpty=True,Location=(X=95.000000,Z=85.000000),Effects=(VehicleEffectInfo'VehicleVehicles.VehicleEffectInfo14'))
     PreLoadClasses(0)="VehicleWeapons.BogieGun"
     PreLoadClasses(1)="VehicleWeapons.BogieLauncher"
     ChassisCOMOffset=(X=50.000000)
     PassengerCameras(1)=(bLimitYaw=True,CenterYaw=32768,MaxYaw=10000)
     PassengerPointCount=2
     StaticMesh=StaticMesh'PariahVehicleMeshes.bogie.BogieCoopChassisSP'
     Begin Object Class=HavokParams Name=HavokParams21
         LinearDamping=0.100000
         AngularDamping=0.100000
         StartEnabled=True
         Restitution=0.100000
     End Object
     HParams=HavokParams'VehicleVehicles.HavokParams21'
}
