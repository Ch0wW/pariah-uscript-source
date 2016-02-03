class StocktonStage extends Stage
	placeable;


#exec Texture Import File=Textures\stocktonstage.tga Name=StocktonStageIcon Mips=Off MASKED=1


var Array<Generator> Generators;
var() name GeneratorTag;
var Array<StocktonCeilingPart> CeilingParts;
var() name CeilingPartsTag;

var Array<GeneratorShieldMesh> GeneratorShields;

var SPAIStockton StocktonAI;


var() edfindable StocktonStage NextStage;

var int GeneratorCount;
var int CeilingPartCount;

var int GroundCoverCount;




function PostBeginPlay()
{
	local Generator g;
	local StocktonCeilingPart p;
	local GeneratorShieldMesh s;
	local float GenHurtTime;

	//hook up gens

	Super.PostBeginPlay();


	ForEach DynamicActors(class'Generator', g, GeneratorTag)
	{
		g.OwningStage=self;
		g.SetInvulnerable(true);
		Generators[Generators.Length] = g;
		GenHurtTime += 0.05;
		g.NextHurtTime = GenHurtTime;
		GeneratorCount++;
	}

	ForEach DynamicActors(class'StocktonCeilingPart', p, CeilingPartsTag)
	{
		p.OwningStage=self;
		CeilingParts[CeilingParts.Length] = p;

		CeilingPartCount++;
	}

	ForEach DynamicActors(class'GeneratorShieldMesh', s)
	{
		SetClosestGenerator(s);
		GeneratorShields[GeneratorShields.Length] = s;
	}

}

function SetClosestGenerator(GeneratorShieldMesh Shield)
{
	local int i, nearest;
	local float neardist, f;

	neardist = 1000000.0;

	for(i=0;i<Generators.Length;i++)
	{
		f = VSize(Shield.Location - Generators[i].Location);
		if(f < neardist)
		{
			neardist = f;
			nearest = i;
		}
	}

	Generators[nearest].MyShield = Shield;
}

function DropGeneratorShields()
{
	local int i;

	log("TURNING OFF SHIELDS");

	//set flags on gens
	for(i=0;i<Generators.Length;i++)
	{
		Generators[i].SetInvulnerable(false);
	}

	//hide and de-collisionify shield
	for(i=0;i<GeneratorShields.Length;i++)
	{
		GeneratorShields[i].TurnOff();
	}
}

function RaiseGeneratorShields()		   
{
	local int i;
	log("TURNING On SHIELDS");
	for(i=0;i<Generators.Length;i++)
	{
		Generators[i].SetInvulnerable(true);
	}

	//show and collisionify shield
	for(i=0;i<GeneratorShields.Length;i++)
	{
		GeneratorShields[i].TurnOn();
	}

}



function bool CeilingPartsLeft()
{
	return CeilingParts.Length > 0;
}

function RemoveCeilingPart(StocktonCeilingPart p)
{
	local int i;

	GroundCoverCount++;

	for(i=0;i<CeilingParts.Length;i++)
	{
		if(CeilingParts[i]==p)
		{
			CeilingParts[i]=None;
			CeilingParts.Remove(i,1);
			break;
		}
	}

	//for(j=i;j<CeilingParts.Length-1;j++)
	//{
	//	CeilingParts[j] = CeilingParts[j+1];
	//}

	//CeilingParts.Length--;
}


function bool GeneratorsLeft()
{
	return Generators.Length != 0;
}

function RemoveGenerator(Generator g)
{
	local int i;

	log("============== "$self$" REMOVING GEN "$g);

	for(i=0;i<Generators.Length;i++)
	{
		if(Generators[i]==g)
		{
			log("removing generator "$g$" from gen list");
			Generators[i]=None;
			Generators.Remove(i,1);
			break;
		}
	}

	if(Generators.Length == 0)
	{
		if(NextStage != None)
		{
			log("========== Forcing stockton on to new stage "$NextStage);
			StocktonAI.StageOrder_JoinStage( NextStage );
			SPAIRoleStockton(StocktonAI.myAIRole).GOTO_NewStage();
		}
		else
		{
			log("========== FORCING STOCKTON TO FINISH FIGHT");
			SPAIRoleStockton(StocktonAI.myAIRole).GOTO_FinishFight();
		}
	}
	else
	{
		log("telling AI generator "$g$" destroyed");
		StocktonAI.GeneratorDestroyed(g);
	}

}


function StocktonCeilingPart GetCeilingTarget()
{
	return CeilingParts[ Rand(CeilingParts.Length) ];
}

function StagePosition FindGeneratorSpot(Pawn p, out Generator gOut)
{
    local int i;
    local Generator g;
	local float closest, dist;

	closest = 10000000.0;
	for(i=0; i < Generators.Length; i++)
    {
        if( Generators[i]!=None )
        {
            //numAvail++;
            //if( FRand() < 1.0f/float(numAvail) ) //  odds are  1/1, 1/2, 1/3, 1/4 ...
            //{
            //    g = Generators[i];
            //}

			dist = VSize(p.Location - Generators[i].Location);
			if(dist < closest)
			{
				closest = dist;
				g = Generators[i];
			}

        }
    }

	gOut=g;
	return g.ChargeStagePosition;
}

defaultproperties
{
     Texture=Texture'PariahSPPawns.StocktonStageIcon'
}
