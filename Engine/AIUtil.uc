class AIUtil extends Actor;

const R_PROSCRIBED = 128;
const R_DYN_BLOCKED = 1024;
const NOT_R_DYN_BLOCKED = 0x3ff; //mask out 1024 - "NOT_R_DYN_BLOCKED"

//This function will check the pathnodes around a dynamic object to see if it blocks any of them.
//It first removes any "blockages" the object might have had, then adds a relation for any new ones, proscribing paths
//that become blocked, so the AI can avoid them
static function ModifyPaths(LevelInfo Level, Actor object, float radius)
{
	local bool bStillInList;
	local NavigationPoint N;
	local ReachSpec R;
	local int i,j;
	local actor TraceHit;
	local vector HitLocation, HitNormal, ExtentVector;
	local float RDist, distStart, distEnd;
	local plane boundingSphere;
	//remove this object from any current relations
	//start from the end since we're removing elements and don't want to skip indices
	
	for(i=Level.PathObstacles.Length-1; i>=0; i--)
	{
		if(Level.PathObstacles[i].obstacle == object)
		{
			R = Level.PathObstacles[i].path;
			Level.PathObstacles.Remove(i,1);
		
			//if no other relations for a path, clean it up.
			bStillInList = false;
			for(j=0; j<Level.PathObstacles.Length; j++)
			{
				if(Level.PathObstacles[j].path == R)
				{
					bStillInList = true;
					break;
				}
			}
			if(!bStillInList)
			{	R.reachFlags = R.reachFlags & NOT_R_DYN_BLOCKED;
			}
		}

	}

	boundingSphere = object.GetRenderBoundingSphere();

	//check for new blockages.
	for(N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint)
	{
		distStart =	VSize(N.Location - object.Location);
		for(i=0; i<N.PathList.Length; i++)
		{
			R = N.PathList[i];
			//don't bother checking blockage if the path is already permanently blocked
			if( (R.reachFlags | R_PROSCRIBED) != R_PROSCRIBED )
			{
				RDist = R.Distance + radius + boundingSphere.W * 2f; //fudge value
				//cull distant paths
				if( distStart < RDist)
				{
					distEnd = VSize(R.End.Location - object.Location);
					if( distEnd < RDist )
					{
						//does the obstacle block the path?
						ExtentVector.X = radius;
						ExtentVector.Y = radius;
						//ExtentVector.Z = Pawn.default.CollisionHeight;
						//ExtentVector.Z = 0.0;
						ForEach Level.TraceActors(class'Actor', TraceHit, HitLocation, HitNormal, R.End.Location,  R.Start.Location, ExtentVector)
						{
							if( TraceHit != None && TraceHit == object)
							{
								R.reachFlags = R.reachFlags | R_DYN_BLOCKED; //mask in 128 - "R_PROSCRIBED"
								//add relation
								Level.PathObstacles.Length = Level.PathObstacles.Length + 1;
								Level.PathObstacles[Level.PathObstacles.Length-1].path = R;
								Level.PathObstacles[Level.PathObstacles.Length-1].obstacle = object;
							}
						} //foreach
					} //cull by end
				} //cull by start
			} //proscribed?
		} //for paths
	}//for navpoints
}

defaultproperties
{
}
