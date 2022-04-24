class ShieldEquip extends SimpleEquipment
		implements  Engine.IAmShield, Engine.IHaveSkeletalRegions;
					
import enum ESkeletalRegion from Actor;

enum ProtectionLevel
{
  Level_0,            // Doesn't stop anything (AKA gas mask, night vision, no armor)
  Level_1,            // Stops .380 ACP FMJ (AKA Nothing)
  Level_2a,           // Stops .45 from pistols (AKA Glock, M1911)
  Level_2,            // Stops 9mm and .45 from SMGs (AKA MP5, UMP)
  Level_3a,           // Stops .357 and remaining pistol calibers (AKA Python, Desert Eagle)
  Level_3,            // Stops rifle calibers up to .308 (AKA 5.56 JHP, 7.62 FMJ)
  Level_3X,           // Stops rifle calibers and armor piercing calibers up to .308 (AKA 5.56 FMJ, 7.62 AP)
  Level_4             // Stops .308 AP (AKA Nothing yet)
};


var() name UnequipSocket;
var(ArmorPenetration) config ProtectionLevel ArmorProtection "What level of armor I represent?";
var (ArmorPenetration) int ProtectionType "Internal measure to know the BulletClass";
var protected int Health;
var(ArmorPenetration) float MomentumToPenetrate "A bullet will penetrate this material if-and-only-if it impacts with more than this Momentum.  A bullet's Momentum is its Mass times the MuzzleVelocity of the FiredWeapon from which it was fired, minus any Momentum that the bullet has already lost (due to prior impact(s)).  The bullet will impart 10% of its Momentum to a KActor it hits if it penetrates the KActor, or 100% of its Momentum if it doesn't penetrate the KActor.";

var protected int Damage_level;

function Equip()
{
	local Pawn PawnOwner;
    
	if ( Owner.isa('Hands') )//first person
	{
		log("Shield Hands equip");
	   Owner.AttachToBone(self, AttachmentBone);	
	   return;
	}
	
	PawnOwner = Pawn(Owner);
	if ( PawnOwner != None ) //third person
	{
		log("Shield TP equip");
		Pawn(Owner).AttachToBone(self, AttachmentBone);
	}
		
}

function UnEquip()
{
	local Pawn PawnOwner;
	
	
	
	if ( Owner.isa('Hands') )//first person
	{
	  log("Shield Hands Unequip");
      Owner.DetachFromBone(self);
	  return;
	}
	
	PawnOwner = Pawn(Owner);
	if ( PawnOwner != None ) //third person
	{	
		log("Shield TP Unequip");
		Pawn(Owner).DetachFromBone(self);
		Pawn(Owner).AttachToBone(self, UnequipSocket);
	}
	
}

simulated function int GetProtectionType() 
{			
	switch(ArmorProtection) 
		{				
		case Level_0:
			ProtectionType = 1;
			break;
		case Level_1:
			ProtectionType = 2;
			break;
		case Level_2a:
			ProtectionType = 3;
			break;
		case Level_2:
			ProtectionType = 4;
			break;
		case Level_3a:
			ProtectionType = 5;
			break;
		case Level_3:
			ProtectionType = 6;
			break;
		case Level_3X:
			ProtectionType = 7;
			break;		
		case Level_4:
			ProtectionType = 8;
			break;
		default:
			ProtectionType = 1;
		}
	return ProtectionType;
}

simulated function int GetProtectionLevel() 
 {
   return ArmorProtection;
 }

simulated function float GetMtP() {
  return MomentumToPenetrate;
}

event PostTakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{

	Health = Health - Damage;
	log("Shield " $ self.name $ " got hit - health " $ Health $ " ");

	//apply shake effect!
	SwatPlayer(Owner).ReactToC2Detonation(self, 0.1, 0.1);

	if ( Health < 888 && Health  >= 555 && Damage_level == 0 )
	{
		//glass 1st damage state
		Damage_level=1;
		IShieldHandgun(Pawn(Owner).GetActiveItem()).SetShieldDamage(damage_level);
	}
	else if ( Health < 555 && Damage_level == 1 )
	{
		//glass 2nd damage state
		Damage_level=2;	
		IShieldHandgun(Pawn(Owner).GetActiveItem()).SetShieldDamage(damage_level);
	}
	else if ( Health < 333 && Damage_level == 2 )
	{
		//glass 3rd damage state
		Damage_level=3;	
		IShieldHandgun(Pawn(Owner).GetActiveItem()).SetShieldDamage(damage_level);
	}
}

// IHaveSkeletalRegions implementation

// Notification that we were hit
simulated function OnSkeletalRegionHit(ESkeletalRegion RegionHit, vector HitLocation, vector HitNormal, int Damage, class<DamageType> DamageType, Actor Instigator)
{
    log("ShieldEquip::OnSkeletalRegionHit() Region:" $RegionHit );    
}


simulated function int GetShieldState()
{
	return Health;
}

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=SkeletalMesh'Shield_model.Shield_mesh'
	//DrawType=DT_StaticMesh
	//StaticMesh=StaticMesh'Shield_static.Shield_static'
	AttachmentBone=Shield
	UnequipSocket=ShieldUnequip
	CollisionRadius=+0002.000000
    CollisionHeight=+0002.000000
	bCollideActors=true
	bCollideWorld=false
	bAcceptsProjectors=true
	bActorShadows=true
	bProjTarget=true
	bWorldGeometry=false
	bBlockPlayers=false
	bBlockActors=false
	bBlockNonZeroExtentTraces=false
	bBlockZeroExtentTraces=true
	bUseCollisionBoneBoundingBox=true
	ArmorProtection=Level_3X
	Health=1000
	MomentumToPenetrate=1000.0
}