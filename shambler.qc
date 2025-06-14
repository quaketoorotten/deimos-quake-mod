/*
==============================================================================

SHAMBLER

==============================================================================
*/

$cd id1/models/shams
$origin 0 0 24
$base base		
$skin base

.string midpointtarg;

/*
===========
ShamCheckAttack

The player is in view, so decide to move or launch an attack
Returns FALSE if movement should continue
============
*/
float() ShamCheckAttack =
{
	local vector	spot1, spot2;	
	local entity	targ;
	
	targ = self.enemy;
	
	// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, self);

	if (trace_ent != targ)
	{
		return FALSE;	// don't have a clear shot
	}

	if ( enemy_range == RANGE_MELEE)
	{
		if (CanDamage (self.enemy, self))
		{
			self.attack_state = AS_MELEE;
			self.attack_finished = 0;
			return TRUE;
		}
	}

	if (time < self.attack_finished)
		return FALSE;
	
	if (!enemy_vis)
		return FALSE;

	// missile attack
		
	self.attack_state = AS_MISSILE;
	return TRUE;
};



void() firebarontargs =
{	
	local entity t, stemp, otemp, act;
//	
// fire targets
//
	if (self.midpointtarg)
	{
		act = activator;
		t = world;
		do
		{
			t = find (t, targetname, self.midpointtarg);
			if (!t)
			{
				return;
			}
			stemp = self;
			otemp = other;
			self = t;
			other = stemp;
			if (self.use != SUB_Null)
			{
				if (self.use)
					self.use ();
			}
			self = stemp;
			other = otemp;
			activator = act;
		} while ( 1 );
	}
	

};

void() sham_stand1	=[	0,	sham_stand2	] {ai_stand();};
void() sham_stand2	=[	1,	sham_stand3	] {ai_stand();};
void() sham_stand3	=[	2,	sham_stand4	] {ai_stand();};
void() sham_stand4	=[	3,	sham_stand5	] {ai_stand();};
void() sham_stand5	=[	4,	sham_stand6	] {ai_stand();};
void() sham_stand6	=[	5,	sham_stand7	] {ai_stand();};
void() sham_stand7	=[	6,	sham_stand8	] {ai_stand();};
void() sham_stand8	=[	7,	sham_stand9	] {ai_stand();};
void() sham_stand9	=[	8,	sham_stand10] {ai_stand();};
void() sham_stand10	=[	9,	sham_stand11] {ai_stand();};
void() sham_stand11	=[	10,	sham_stand12] {ai_stand();};
void() sham_stand12	=[	11,	sham_stand13] {ai_stand();};
void() sham_stand13	=[	12,	sham_stand14] {ai_stand();};
void() sham_stand14	=[	13,	sham_stand15] {ai_stand();};
void() sham_stand15	=[	14,	sham_stand16] {ai_stand();};
void() sham_stand16	=[	15,	sham_stand17] {ai_stand();};
void() sham_stand17	=[	16,	sham_stand1 ] {ai_stand();};

void() sham_walk1		=[      17,        sham_walk2 ] {ai_walk(7);};
void() sham_walk2       =[      18,        sham_walk3 ] {ai_walk(8);};
void() sham_walk3       =[      19,        sham_walk4 ] {ai_walk(9);};
void() sham_walk4       =[      20,        sham_walk5 ] {ai_walk(10);};
void() sham_walk5       =[      21,        sham_walk6 ] {ai_walk(11);};
void() sham_walk6       =[      22,        sham_walk7 ] {ai_walk(12);};
void() sham_walk7       =[      23,        sham_walk8 ] {ai_walk(7);};
void() sham_walk8       =[      24,        sham_walk9 ] {ai_walk(8);};
void() sham_walk9       =[      25,        sham_walk10] {ai_walk(9);};
void() sham_walk10      =[      26,        sham_walk11] {ai_walk(10);};
void() sham_walk11      =[      27,        sham_walk12] {ai_walk(11);};
void() sham_walk12      =[      28,        sham_walk1 ] {ai_walk(12);
if (random() > 0.8)
	sound (self, CHAN_VOICE, "shambler/sidle.wav", 1, ATTN_IDLE);};

void() sham_run1       =[      29,        sham_run2      ] {ai_run(30);};
void() sham_run2       =[      30,        sham_run3      ] {ai_run(30);};
void() sham_run3       =[      31,        sham_run4      ] {ai_run(34);};
void() sham_run4       =[      32,        sham_run5      ] {ai_run(30);};
void() sham_run5       =[      33,        sham_run6      ] {ai_run(30);};
void() sham_run6       =[      34,        sham_run1      ] {ai_run(34);
if (random() > 0.8)
	sound (self, CHAN_VOICE, "shambler/sidle.wav", 1, ATTN_IDLE);
};

//============================================================================



void() MagicExplode =
{
	T_RadiusDamage (self, self.owner, 160, other);
	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

void() MagicTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner

	local float damg = 45 + random()*12;
	
	if (other.health)
	{
		T_Damage (other, self, self.owner, damg, 90);
	}	
	
	MagicExplode ();

};

void(vector org, vector dir) launch_magic=
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	newmis.classname = "baronfire";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/s_fire.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);

	if(skill <= 1) newmis.velocity = dir * 900;
	else newmis.velocity = dir * 1000;
	newmis.dmg = 75;

	newmis.touch = MagicTouch;
};

void() sham_swingr1;

void() CastMagic = 
{
	local vector	dir, org;

	self.effects = self.effects | EF_MUZZLEFLASH;

	makevectors (self.angles);
	
	sound (self, CHAN_WEAPON, "shambler/sboom.wav", 1, ATTN_NORM);
	
	org = self.origin + v_forward * 30 + v_right * 8.5 + v_up * 8 + '0 0 16';
 	dir = normalize ((self.enemy.origin + self.enemy.view_ofs) - org);

	launch_magic (org, dir);
};

void(float side) ShamClaw =
{
local vector	delta;
local float 	ldmg;

	if (!self.enemy)
		return;
	ai_charge(0);

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 130)	
		return;

	if (!CanDamage (self.enemy, self))
		return;
		
	ldmg = (random() + random() + random()) * 36;
	T_Damage (self.enemy, self, self, ldmg, 100);
	sound (self, CHAN_VOICE, "shambler/smack.wav", 1, ATTN_NORM);

	SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);
	SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);
};


void() shamkick =
{
	local vector	delta;
	local float 	ldmg;

	if (!self.enemy)
		return;
	ai_charge(0);

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 160)	
		return;

	if (!CanDamage (self.enemy, self))
		return;
		
	ldmg = 10 + (random() + random() + random()) * 36;
	T_Damage (self.enemy, self, self, ldmg, 300);
	self.enemy.origin_z = self.enemy.origin_z + 5;
	sound (self, CHAN_VOICE, "shambler/smack.wav", 1, ATTN_NORM);
};

void(float radius, entity ignore) ShamSmashDamage=
{
	local	float 	points;
	local	entity	target;
	local vector	org;
	local float 	damage = 130 + random()*30;

	for (target = findradius(self.origin, radius); target; target= target.chain)
	{
    		if(!target.takedamage)
                	continue;
        	if(target == self)
                	continue;
		if(target == ignore)
                	continue;
        	if(!CanDamage(target, self))
            	continue;
		if(!(target.flags & FL_ONGROUND))
                	continue;

		org = target.origin + (target.mins + target.maxs)*0.2;
		points = 0.2*vlen (self.origin - org);
		points = damage - points;

		if (points < 0)
			points = 0;

		if (points > 0)
			T_Damage (target, self, self, points, points);
		if (target.movetype == MOVETYPE_WALK)
		{	
			target.origin_z = target.origin_z + 5;
			target.velocity_z = 300;
		}
	}

};

void() sham_swingl1; 
void() sham_magic1;
void() sham_ranged;

void() sham_swingr1	=[      48,      sham_swingr2   ] {
	sound (self, CHAN_VOICE, "shambler/melee1.wav", 1, ATTN_NORM);
	ai_charge(1);
};
void() sham_swingr2 =[      49,      sham_swingr3   ] {ai_charge(8);};
void() sham_swingr3 =[      50,      sham_swingr4   ] {ai_charge(14);};
void() sham_swingr4 =[      51,      sham_swingr5   ] {ai_charge(7);};
void() sham_swingr5 =[      52,      sham_swingr6   ] {ai_charge(3);};
void() sham_swingr6 =[      53,      sham_swingr7   ] {ai_charge(6);};
void() sham_swingr7 =[      54,      sham_swingr8   ] {ai_charge(6); ShamClaw(250);};
void() sham_swingr8 =[      55,      sham_swingr9   ] {ai_charge(3);};
void() sham_swingr9 =[      56,      sham_run1      ] {ai_charge(1);
	if (random() > 0.5 && (self.enemy.health > 0))
		sham_swingl1 ();
};


void() sham_swingl1	=[      73,      sham_swingl2   ] {
	sound (self, CHAN_VOICE, "shambler/melee1.wav", 1, ATTN_NORM);
	ai_charge(1);
};
void() sham_swingl2 =[      74,      sham_swingl3   ] {ai_charge(8);};
void() sham_swingl3 =[      75,      sham_swingl4   ] {ai_charge(14);};
void() sham_swingl4 =[      76,      sham_swingl5   ] {ai_charge(7);};
void() sham_swingl5 =[      77,      sham_swingl6   ] {ai_charge(7);};
void() sham_swingl6 =[      78,      sham_swingl7   ] {ai_charge(7);ShamClaw(-250);};
void() sham_swingl7 =[      79,      sham_swingl8   ] {ai_charge(3);};
void() sham_swingl8 =[      80,      sham_swingl9   ] {ai_charge(3);};
void() sham_swingl9 =[      81,      sham_swingl10   ] {ai_charge(3);};
void() sham_swingl10 =[      82,      sham_swingl11   ] {ai_charge(3);};
void() sham_swingl11 =[      83,      sham_run1   ] {ai_charge(6);
	if (random() > 0.5 && (self.enemy.health > 0))
		sham_ranged ();
};

void() sham_kick1	=[      85,     sham_kick2]{
	sound (self, CHAN_VOICE, "shambler/sattck1.wav", 1, ATTN_NORM);
	ai_charge(1);
};
void() sham_kick2=[      86,     sham_kick3] {ai_charge(8);};
void() sham_kick3=[      87,     sham_kick4] {ai_charge(14);};
void() sham_kick4=[      88,     sham_kick5] {ai_charge(7);};
void() sham_kick5=[      89,     sham_kick6] {ai_charge(3);};
void() sham_kick6=[      90,     sham_kick7] {ai_charge(6);};
void() sham_kick7=[      91,     sham_kick8] {ai_charge(6);};
void() sham_kick8=[      92,     sham_kick9] {ai_charge(3);shamkick ();};
void() sham_kick9=[      93,     sham_kick10] {ai_charge(3); };
void() sham_kick10=[      94,     sham_kick11] {ai_charge(3);};
void() sham_kick11=[      95,   sham_run1      ] {ai_charge(1);};


void() sham_magic1     =[      48,       sham_magic2    ] {
	sound (self, CHAN_VOICE, "shambler/sboom.wav", 1, ATTN_NORM);
	ai_charge(1);
};
void() sham_magic2     =[      49,       sham_magic3    ] {ai_charge(8);};
void() sham_magic3     =[      50,       sham_magic4    ] {ai_charge(14);};
void() sham_magic4     =[      51,       sham_magic5    ] {ai_charge(7);};
void() sham_magic5     =[      52,       sham_magic6    ] {ai_charge(3);};
void() sham_magic6     =[      53,       sham_magic7    ] {ai_charge(6);CastMagic();};																	
void() sham_magic7     =[      54,       sham_magic8    ] {ai_charge(6);};
void() sham_magic8     =[      55,       sham_magic9    ] {ai_charge(3);};
void() sham_magic9     =[      56,       sham_run1      ] {ai_charge(1); SUB_AttackFinishedSpecial (self, 1 + 2*random() );};

void(vector to) ring =
{
	local entity thingamabob;
	thingamabob = spawn();
	thingamabob.origin = to;
	thingamabob.movetype = MOVETYPE_NONE;
	thingamabob.velocity = '0 0 0';
	thingamabob.touch = SUB_Null;
	setmodel (thingamabob , "progs/s_light.mdl");
	thingamabob.solid = SOLID_NOT;
	thingamabob.think = SUB_Remove;
	thingamabob.nextthink = time + 0.22;
};

void() ShamSmash = 
{	
	ShamSmashDamage (250, world); 
	self.effects = self.effects | EF_DIMLIGHT;
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z - 32);

	sound (self, CHAN_VOICE, "demon/dland2.wav", 1, ATTN_NORM);
	ring(self.origin - '0 0 8');
};

void() sham_melee =
{
	local float chance;
	chance = random();

	if (chance > 0.4 && (self.health < (self.max_health / 2)))
		sham_kick1 ();
	else if (chance > 0.5)
		sham_swingr1 ();
	else
		sham_swingl1 ();
};	
	

void() sham_smash1     =[      35,       sham_smash2    ] {
sound (self, CHAN_VOICE, "shambler/sattck1.wav", 1, ATTN_NORM);
ai_charge(2);
};
void() sham_smash2     =[      36,       sham_smash3    ] { ai_face ();};
void() sham_smash3     =[      37,       sham_smash4    ] { ai_face ();};
void() sham_smash4     =[      38,       sham_smash5    ] { ai_face ();};
void() sham_smash5     =[      39,       sham_smash6    ] { ai_face ();};
void() sham_smash6     =[      40,       sham_smash7    ] { ai_charge(2);};
void() sham_smash7     =[      41,       sham_smash8    ] { ai_charge(3);};
void() sham_smash8     =[      42,       sham_smash9    ] { ai_charge(5);};
void() sham_smash9     =[      43,       sham_smash10   ] { ai_charge(6);};
void() sham_smash10    =[      44,       sham_smash11   ] { ai_charge(2); ShamSmash ();};
void() sham_smash11    =[      45,       sham_run1   ] { self.effects = 0; SUB_AttackFinishedSpecial (self, 1 + 0.5*random() );};


void() sham_ranged = 
{
	local vector	spot1, spot2;	
	local entity	targ;
	
	targ = self.enemy;
	
	// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	if (vlen(spot1 - spot2) <= 200)
	{
		if ( fabs(self.origin_z - targ.origin_z) > 20)
			sham_magic1();
	
		if(((targ.flags & FL_ONGROUND) || !(targ.flags & FL_FLY)) && (random() < 0.5))
			sham_smash1();
		else
			sham_magic1();
	}
	else
		sham_magic1();
};

void() sham_pain1      =[      57, 	sham_pain2      ] {};
void() sham_pain2      =[      58, 	sham_pain3      ] {};
void() sham_pain3      =[      59, 	sham_pain4      ] {};
void() sham_pain4      =[      60, 	sham_pain5      ] {};
void() sham_pain5      =[      61, 	sham_pain6      ] {};
void() sham_pain6      =[      62, 	sham_pain7      ] {};
void() sham_pain7      =[      63, 	sham_run1       ] {};


void(entity attacker, float damage)	sham_pain =
{
	if (self.health <= self.max_health / 2)
		firebarontargs ();

	if(self.health < self.max_health / 2)
		self.skin = 1;

	if (self.health <= 0)
		return;		// allready dying, don't go into pain frame

	if (random()*6000 > damage)
		return;		// didn't flinch
	
	if (self.pain_finished > time)
		return;
	sound (self, CHAN_VOICE, "shambler/shurt2.wav", 1, ATTN_NORM);
	self.pain_finished = time + 1.25;
		
	sham_pain1 ();
	self.effects = 0;
};


//============================================================================

void() sham_death1      =[      64,       sham_death2     ] {};
void() sham_death2      =[      65,       sham_death3     ] {};
void() sham_death3      =[      66,       sham_death4     ] {ai_back(8);};
void() sham_death4      =[      67,     	sham_death5     ] {ai_back(14);};
void() sham_death5      =[      68, 	sham_death6     ] {ai_back(20);};
void() sham_death6      =[      69,       sham_death7     ] {ai_back(15);};
void() sham_death7      =[      70,       sham_death8     ] {};
void() sham_death8      =[      71,       sham_death9     ] {};
void() sham_death9      =[      72,       sham_death9     ] {
	self.solid = SOLID_NOT; 
};


void() sham_die =
{
// check for gib
	if ( self.health < -300 )
	{
		self.effects = 0; self.skin = 0;
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_shams.mdl", self.health);
		//for(float i = 0; i < 4; i++)
			ThrowGib ("progs/gib1_green.mdl", self.health);
		ThrowGib ("progs/gib2_green.mdl", self.health);
		//for(float i = 0; i < 8; i++)
			ThrowGib ("progs/gib3_green.mdl", self.health);
		remove(self);
		return;
	}
	
// don't die a regular death again as corpse
	if((self.deadflag & DEAD_DEAD))
		return;

// regular death
	sound (self, CHAN_VOICE, "shambler/sdeath.wav", 1, ATTN_NORM);
	self.effects = 0;
	self.takedamage = DAMAGE_YES;
	self.movetype = MOVETYPE_TOSS;
	self.skin = 1;
	sham_death1 ();
	self.deadflag = DEAD_DEAD;
};

//============================================================================


/*QUAKED monster_shambler (1 0 0) (-42 -42 -24) (42 42 88) Ambush
*/
void() monster_shambler_cache = 
{
	precache_model ("progs/shambler.mdl");
	precache_model ("progs/h_shams.mdl");
	precache_model ("progs/s_light.mdl");
	precache_model ("progs/s_fire.mdl");
	
	precache_sound ("shambler/sattck1.wav");
	precache_sound ("shambler/sboom.wav");
	precache_sound ("shambler/sdeath.wav");
	precache_sound ("shambler/shurt2.wav");
	precache_sound ("shambler/sidle.wav");
	precache_sound ("shambler/ssight.wav");
	precache_sound ("shambler/melee1.wav");
	precache_sound ("shambler/melee2.wav");
	precache_sound ("shambler/smack.wav");
}


void() monster_shambler =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_shambler_cache();
	spawn_shambler();
	self.th_spawn = spawn_shambler;
};

void() spawn_shambler =
{
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_STEP;
	setmodel (self, "progs/shambler.mdl");

	setsize (self,VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.health = 1600;
	self.max_health = 1600;
	self.mass = 1000;
	self.skin = 0;
	self.cnt = 0;
	self.color = 58;

	self.th_stand = sham_stand1;
	self.th_walk = sham_walk1;
	self.th_run = sham_run1;
	self.th_die = sham_die;
	self.th_melee = sham_melee;
	self.th_missile = sham_ranged;
	self.th_pain = sham_pain;
	self.th_checkattack = ShamCheckAttack;
		
	walkmonster_start();
};
