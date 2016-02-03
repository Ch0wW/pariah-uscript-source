class VGHavokBogieSP extends VGHavokSimpleCar
    placeable;

simulated function InitializeVehicle()
{
	Super.InitializeVehicle();
	PassengerPoints[0].z+=93;
}


simulated function DoVehicleDeathEffects()
{
	Super.DoVehicleDeathEffects();

	spawn(class'VehicleEffects.CaboomDistort',,,Location);
	spawn(class'VehicleEffects.CaboomExplosion',,,Location);
	spawn(class'VehicleEffects.DavidVehicleExplosionTiresBogie',,,Location);

}

defaultproperties
{
     FrontRightSuspIndex=1
     RearLeftSuspIndex=2
     RearRightSuspIndex=3
     FrontWheelAlong=161.093994
     FrontWheelAcross=120.000000
     FrontWheelVert=-30.000000
     FrontWheelRadius=55.000000
     FrontWheelWidth=52.000000
     FrontWheelMass=10.000000
     FrontWheelViscosityFriction=0.050000
     FrontSuspStrength=25.000000
     FrontSuspCompressionDamping=1.300000
     FrontSuspRelaxationDamping=0.800000
     FrontSuspLength=20.000000
     FrontMaxBrakingTorque=8000.000000
     FrontMinPedalInputToBlock=0.700000
     RearWheelAlong=-140.524002
     RearWheelAcross=120.000000
     RearWheelVert=-30.000000
     RearWheelRadius=55.000000
     RearWheelWidth=52.000000
     RearWheelMass=20.000000
     RearWheelFriction=0.550000
     RearWheelViscosityFriction=0.050000
     RearSuspStrength=25.000000
     RearSuspCompressionDamping=1.300000
     RearSuspRelaxationDamping=0.800000
     RearSuspLength=20.000000
     RearMaxBrakingTorque=6000.000000
     RearMinPedalInputToBlock=0.700000
     FrontWheelMesh=StaticMesh'PariahVehicleMeshes.bogie.BogieTire'
     RearWheelMesh=StaticMesh'PariahVehicleMeshes.bogie.BogieTire'
     TiretrackParameterScale=50.000000
     MaxSpeedFullSteeringAngle=4500.000000
     OptRPM=4000.000000
     MaxRPM=8000.000000
     MaxTorque=2000.000000
     TorqueFactorAtMinRPM=1.600000
     ResistanceFactorAtMinRPM=0.100000
     ResistanceFactorAtOptRPM=0.250000
     ResistanceFactorAtMaxRPM=0.750000
     ClutchSlipRPM=500.000000
     DownshiftRPM=800.000000
     UpshiftRPM=2600.000000
     PrimaryTransmissionRatio=8.000000
     ReverseGearRatio=1.400000
     MinTimeToLockWheels=0.100000
     FrontalArea=15000.000000
     LiftCoefficient=-0.350000
     InAirSpinDampingTime=0.001000
     InAirNormalSpinDamping=0.010000
     InAirCollisionSpinDamping=1.500000
     NormalSpinDamping=4.000000
     CollisionSpinDamping=8.000000
     CollisionAngVelThreshold=2.000000
     MinSpeedForExtraLinearDamping=1800.000000
     ExtraLinearDampingRate=0.010000
     TorquePitchFactor=0.400000
     TorqueYawFactor=0.400000
     ExtraSteerTorqueFactor=0.000000
     HitImpulseScale=5.000000
     HitImpulseRadialScale=0.450000
     MaxHitImpulse=270000.000000
     FlipDropHeight=250.000000
     Begin Object Class=TireEffectInfo Name=TireEffectInfo89
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=300.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Dirt
         SurfaceTypes(1)=EST_Rock
         MaxPPS=15.000000
         EmitterClass=Class'VehicleEffects.DavidTireDirt'
     End Object
     TireEffects(0)=TireEffectInfo'VehicleVehicles.TireEffectInfo89'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo90
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=300.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Dirt
         SurfaceTypes(1)=EST_Rock
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireDirtB'
     End Object
     TireEffects(1)=TireEffectInfo'VehicleVehicles.TireEffectInfo90'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo91
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=10.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Water
         SurfaceTypes(1)=EST_Wet
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireWater'
     End Object
     TireEffects(2)=TireEffectInfo'VehicleVehicles.TireEffectInfo91'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo92
         TireSlipScale=0.500000
         TireSlipRange=(Min=100.000000,Max=300.000000)
         SurfaceTypes(0)=EST_Dirt
         SurfaceTypes(1)=EST_Rock
         MaxPPS=10.000000
         EmitterClass=Class'VehicleEffects.DavidTireDust'
     End Object
     TireEffects(3)=TireEffectInfo'VehicleVehicles.TireEffectInfo92'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo93
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=10.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Metal
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireDirtC'
     End Object
     TireEffects(4)=TireEffectInfo'VehicleVehicles.TireEffectInfo93'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo94
         TireSlipScale=0.500000
         TireSlipRange=(Min=100.000000,Max=300.000000)
         SurfaceTypes(0)=EST_Metal
         MaxPPS=10.000000
         EmitterClass=Class'VehicleEffects.DavidTireDustB'
     End Object
     TireEffects(5)=TireEffectInfo'VehicleVehicles.TireEffectInfo94'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo95
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=100.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Plant
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireDustB'
     End Object
     TireEffects(6)=TireEffectInfo'VehicleVehicles.TireEffectInfo95'
     Suspensions(0)=(DecoPieces=((BaseOffset=(X=160.276993,Y=34.770000,Z=-35.516998),Target=SPL_Wheel0,TargetOffset=(Z=-10.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.bogie.BogieSuspensionBase01'),(BaseOffset=(X=160.645004,Y=42.374001,Z=10.774000),Target=SPL_Wheel0,TargetOffset=(Y=28.600000),StaticMesh=StaticMesh'PariahVehicleMeshes.bogie.BogieSuspensionSpring01')))
     Suspensions(1)=(DecoPieces=((BaseOffset=(X=160.276993,Y=34.770000,Z=-35.516998),Target=SPL_Wheel1,TargetOffset=(Z=-10.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.bogie.BogieSuspensionBase02'),(BaseOffset=(X=160.645004,Y=42.374001,Z=10.774000),Target=SPL_Wheel1,TargetOffset=(Y=28.600000),StaticMesh=StaticMesh'PariahVehicleMeshes.bogie.BogieSuspensionSpring02')))
     Suspensions(2)=(DecoPieces=((BaseOffset=(X=-140.300995,Y=34.770000,Z=-35.516998),Target=SPL_Wheel2,TargetOffset=(Z=-10.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.bogie.BogieSuspensionBase01'),(BaseOffset=(X=-139.932999,Y=42.374001,Z=10.774000),Target=SPL_Wheel2,TargetOffset=(Y=28.600000),StaticMesh=StaticMesh'PariahVehicleMeshes.bogie.BogieSuspensionSpring01')))
     Suspensions(3)=(DecoPieces=((BaseOffset=(X=-140.300995,Y=34.770000,Z=-32.516998),Target=SPL_Wheel3,TargetOffset=(Z=-10.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.bogie.BogieSuspensionBase02'),(BaseOffset=(X=-139.932999,Y=42.374001,Z=10.774000),Target=SPL_Wheel3,TargetOffset=(Y=28.600000),StaticMesh=StaticMesh'PariahVehicleMeshes.bogie.BogieSuspensionSpring02')))
     Tiretracks(0)=(Surfaces=(EST_Metal,EST_Rock,EST_Plant,EST_Dirt),MinSkidEnergy=1.000000,MaxSkidEnergy=250.000000,Material=Texture'PariahVehicleTextures.Shared.TireTreadColour')
     GearRatios(0)=1.400000
     GearRatios(1)=1.000000
     GearRatios(2)=0.600000
     ExtraGravity=(Z=-250.000000)
     WeaponMounts=1
     MaxSteerAngle=7000.000000
     ChassisMass=700.000000
     ChassisFriction=1.000000
     TailLightSeparation=28.320999
     HeadLightProjectorDistance=800.000000
     HeadLightReattachDistance=50.000000
     ShadowDrawScale=3.000000
     campitch=-2000.000000
     camdist=650.000000
     camheight=200.000000
     LookAngleForMaxSteer=8192.000000
     HitSoundMinImpactThreshold=100.000000
     HitSoundMaxImpactThreshold=1000.000000
     EngineSoundPitchScale=1600.000000
     ReverseSoundPitchScale=-1000.000000
     ReverseSoundMinVelocity=100.000000
     TireSlipSoundMinSlipVel=100.000000
     TireSlipSoundMaxSlipVel=1200.000000
     TireImpactSoundMinImpactThreshold=100.000000
     TireImpactSoundMaxImpactThreshold=500.000000
     MinRamSpeed=500.000000
     RammingDamage=100.000000
     RammingDamageMultiplier=2.000000
     RammingTimeout=3.000000
     ExitBrakeTime=0.100000
     ShadowTexture=Texture'PariahVehicleEffectsTextures.GroundShadows.BogieShadow'
     EnterVehicleSound=Sound'NewVehicleSounds.bogie.BogieEngineStartA'
     ExitVehicleSound=Sound'NewVehicleSounds.bogie.BogieEngineStopA'
     EngineSound=Sound'NewVehicleSounds.bogie.BogieEngineIdle'
     HitSound=Sound'NewVehicleSounds.Dozer.DozerImpactA'
     DeathSound=Sound'NewVehicleSounds.explosions.VehicleExplosionA'
     ReverseSound=Sound'NewVehicleSounds.bogie.BogieEngineIdle'
     TireSlipSound=Sound'NewVehicleSounds.TireSpin.TireSpinGravelC'
     TireImpactSound=Sound'PariahVehicleSounds.Vehicle_Bump.22-Bumps_Road'
     DrivingAnim="Bogie_Driver"
     DrivingAnimR="Bogie_SteerR"
     DrivingAnimL="Bogie_SteerL"
     WeaponMountName(0)="WP3"
     DriverPointName="PointDriver"
     DriverEntryAnims(0)="Bogie_Driver_In"
     DriverExitAnim="Bogie_Driver_Out"
     PassengerEntryAnims(0)="Bogie_Gunner_In"
     RiderAnims(0)="Bogie_Gunner"
     GunnerExitAnim="Bogie_Gunner_Out"
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo109
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
     DamageableParts(4)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo109'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo110
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
     DamageableParts(5)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo110'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo111
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
     DamageableParts(6)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo111'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo112
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
     DamageableParts(7)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo112'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo113
         DamageRadius=200.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.bogie.BogieSteeringWheel'
         AttachPoints(0)="PointSteeringWheel"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(Action=DSA_SteeringMovesMesh,Rot=(Roll=-20000))
     End Object
     DamageableParts(10)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo113'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo115
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.bogie.BogieRearBad'
         AttachPoints(0)="PointRear"
         DamageSequence(0)=(Action=DSA_AttachMesh)
     End Object
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo116
         DamageRadius=300.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.bogie.BogieRearClean'
         PartMeshes(1)=StaticMesh'PariahVehicleMeshes.bogie.BogieRearDamaged'
         PartMeshes(2)=StaticMesh'PariahVehicleMeshes.bogie.BogieRearOff'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointRear"
         DamageableParts(0)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo115'
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
     DamageableParts(12)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo116'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo114
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.bogie.BogieFrontBad'
         AttachPoints(0)="PointFront"
         DamageSequence(0)=(Action=DSA_AttachMesh)
     End Object
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo118
         DamageRadius=250.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.bogie.BogieFrontClean'
         PartMeshes(1)=StaticMesh'PariahVehicleMeshes.bogie.BogieFrontDamaged'
         PartMeshes(2)=StaticMesh'PariahVehicleMeshes.bogie.BogieFrontOff'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointFront"
         DamageableParts(0)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo114'
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
     DamageableParts(14)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo118'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo95
         DamageRadius=200.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.bogie.BogieGunnerStick'
         AttachPoints(0)="PointGunnerStick"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(Action=DSA_SteeringMovesMesh,Rot=(Roll=-20000))
     End Object
     DamageableParts(15)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo95'
     DriverEntryNames(0)="PointDriverIn"
     PassengerPointNames(0)="PointPassenger01"
     PassengerPointEntryNames(0)="PointPassengerIn"
     DefaultWeapons(0)="VehicleWeapons.Puncher"
     Begin Object Class=VehicleEffectInfo Name=VehicleEffectInfo13
         PPSBase=50.000000
         PPSScale=-1.000000
         ControlRange=(Min=0.000000,Max=200.000000)
         ControlType=VEC_Health
         MaxPPS=30.000000
         EmitterClass=Class'VehicleEffects.DavidEngineSmoke'
     End Object
     CarEffects(0)=(OnWhenCarEmpty=True,Location=(X=95.000000,Z=85.000000),Effects=(VehicleEffectInfo'VehicleVehicles.VehicleEffectInfo13'))
     PreLoadClasses(0)="VehicleWeapons.BogieGun"
     PreLoadClasses(1)="VehicleWeapons.BogieLauncher"
     ChassisCOMOffset=(X=-15.000000)
     LightOffset=(X=210.000000,Z=61.000000)
     TailLightOffset=(X=-220.000000,Z=20.000000)
     PassengerCameras(0)=(bUse3rdPerson=True)
     VehicleName="Bogie"
     TailLightBrakeSaturation=200
     TailLightBrakeBrightness=150
     TailLightBackupBrightness=0
     TailLightDrivingSaturation=0
     TailLightDrivingBrightness=0
     HeadLightHue=40
     HeadLightBrightness=130
     EngineSoundVolume=180
     DeathSoundVolume=255
     ReverseSoundPitch=64
     ReverseSoundVolume=180
     EngineSoundScaler=ESS_VehicleSpeed
     TireSlipSoundMaxVolume=132
     IsGunnerSpot(0)=1
     PassengerPointCount=1
     bEnableHeadLightEmitter=False
     bEnableShadow=True
     Health=600
     HealthMax=600.000000
     CollisionRadius=250.000000
     CollisionHeight=150.000000
     StaticMesh=StaticMesh'PariahVehicleMeshes.bogie.BogieChassisSP'
     Begin Object Class=HavokParams Name=HavokParams20
         LinearDamping=0.100000
         AngularDamping=0.100000
         StartEnabled=True
         Restitution=0.100000
     End Object
     HParams=HavokParams'VehicleVehicles.HavokParams20'
}
