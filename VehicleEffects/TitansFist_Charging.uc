Class TitansFist_Charging extends Emitter;

var()	int ParticlesPerSecond;

simulated function Stop()
{
	local int				e;
	local ParticleEmitter	SubEmitter;

	for ( e = 0; e < Emitters.Length; e++ )
	{
		SubEmitter = Emitters[e];
		SubEmitter.InitialParticlesPerSecond = 0; 
		SubEmitter.ParticlesPerSecond = 0;
		SubEmitter.AutomaticInitialSpawning = false;
		SubEmitter.RespawnDeadParticles = false;
		//SubEmitter.Disabled = true;
	}
}


simulated function Run()
{
	local int				e;
	local ParticleEmitter	SubEmitter;

	for ( e = 0; e < Emitters.Length; e++ )
	{
		SubEmitter = Emitters[e];
		SubEmitter.InitialParticlesPerSecond = ParticlesPerSecond;
		SubEmitter.ParticlesPerSecond = ParticlesPerSecond;
		SubEmitter.AutomaticInitialSpawning = false;
		SubEmitter.RespawnDeadParticles = true;
		SubEmitter.AllParticlesDead=false;
		SubEmitter.Disabled = false;
	}
}


//simulated function Increase( float Timer )
//{
//	local ParticleEmitter	SubEmitter;
//	SubEmitter = Emitters[0];
//	
//	SubEmitter.SphereRadiusRange.Min = 25.0 + Timer;
//	SubEmitter.SphereRadiusRange.Max = SubEmitter.SphereRadiusRange.Min;
//	SubEmitter.StartSizeRange.X.Min = 1.0 + Timer;
//	SubEmitter.StartSizeRange.X.Max = 3.0 * SubEmitter.StartSizeRange.X.Min;
//
//	SubEmitter.StartVelocityRadialRange.Min = -25.0 - Timer;
//	SubEmitter.StartVelocityRadialRange.Max = SubEmitter.StartVelocityRadialRange.Min;
//}

defaultproperties
{
     ParticlesPerSecond=40
     Begin Object Class=SpriteEmitter Name=SpriteEmitter15
         MaxParticles=80
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         SecondsBeforeInactive=0.000000
         Texture=Texture'MannyTextures.Coronas.blue_corona3'
         SizeScale(1)=(RelativeTime=0.500000,RelativeSize=0.800000)
         SphereRadiusRange=(Min=40.000000,Max=40.000000)
         SpinsPerSecondRange=(X=(Min=0.200000,Max=0.400000))
         StartSizeRange=(X=(Min=1.000000,Max=3.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRadialRange=(Min=-40.000000,Max=-40.000000)
         AddVelocityMultiplierRange=(X=(Min=-500.000000,Max=-500.000000))
         CoordinateSystem=PTCS_Relative
         StartLocationShape=PTLS_Sphere
         DrawStyle=PTDS_Brighten
         GetVelocityDirectionFrom=PTVD_AddRadial
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter15'
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
}
