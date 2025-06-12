/*
==============================================================================

OGRE

==============================================================================
*/

$cd id1/models/ogre_c
$origin 0 0 24
$base base		
$skin base

//=============================================================================

/*
===========
OgreCheckAttack

The player is in view, so decide to move or launch an attack
Returns FALSE if movement should continue
============
*/
float() OgreCheckAttack =
{
	local vector	spot1, spot2;	
	local entity	targ;
	local float		chance;

	if (time < self.attack_finished)
		return FALSE;
	
	if (!enemy_vis)
		return FALSE;
		
	targ = self.enemy;
	
// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, self);

	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (enemy_range == RANGE_MELEE)
	{
		if (CanDamage (self.enemy, self))
		{
			self.attack_state = AS_MELEE;
			return TRUE;
		}
	}

	if (trace_ent != targ)
		return FALSE;	// don't have a clear shot
	
	if (vlen(spot1 - spot2) <= 200)
		return FALSE;
			
// missile attack
	if (time < self.attack_finished)
		return FALSE;
		
	if (enemy_range == RANGE_FAR)
		return FALSE;

	if (enemy_range == RANGE_CLOSE)
		chance = 0.2;	
	else if (enemy_range == RANGE_NEAR)
		chance = 0.1;
	else if (enemy_range == RANGE_MID)
		chance = 0.05;
	else
		chance = 1;

	self.attack_state = AS_MISSILE;
	SUB_AttackFinished (self, 1 + 2*random());
	return TRUE;
};



void() OgreGrenadeExplode =
{
	T_RadiusDamage (self, self.owner, 80, world);
	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

void() OgreGrenadeTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner
	if (other.takedamage == DAMAGE_AIM)
	{
		OgreGrenadeExplode();
		return;
	}
	sound (self, CHAN_VOICE, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

/*
================
OgreFireGrenade
================
*/
void() OgreFireGrenade =
{
	local	entity missile;
	
	self.effects = self.effects | EF_MUZZLEFLASH;

	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "grenade";
		
// set missile speed	

	makevectors (self.angles);

	missile.velocity = normalize(self.enemy.origin - self.origin);
	missile.velocity = missile.velocity * 400;
	missile.velocity_z = 200;
	

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);
	
	missile.touch = OgreGrenadeTouch;
	
// set missile duration
	missile.nextthink = time + 2.5;
	missile.think = OgreGrenadeExplode;
	missile.dmg = 40;

	setmodel (missile, "progs/lavaball.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin);
};


//=============================================================================

/*
================
chainsaw

FIXME
================
*/
void(float side) chainsaw =
{
local vector	delta;
local float 	ldmg;

	if (!self.enemy)
		return;
	if (!CanDamage (self.enemy, self))
		return;

	ai_charge(10);

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100)
		return;
		
	ldmg = (random() + random() + random()) * 4;
	T_Damage (self.enemy, self, self, ldmg, 12);
	sound (self, CHAN_WEAPON, "demon/dhit2.wav", 1, ATTN_NORM);
	
	if (side)
	{
		makevectors (self.angles);
		if (side == 1)
			SpawnMeatSpray (self.origin + v_forward*16, crandom() * 100 * v_right);
		else
			SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
	}
};


void() ogre_stand1	=[	0,	ogre_stand2	] {ai_stand();};
void() ogre_stand2	=[	1,	ogre_stand3	] {ai_stand();};
void() ogre_stand3	=[	2,	ogre_stand4	] {ai_stand();};
void() ogre_stand4	=[	3,	ogre_stand5	] {ai_stand();};
void() ogre_stand5	=[	4,	ogre_stand6	] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "ogre/ogidle.wav", 1, ATTN_IDLE);
ai_stand();
};
void() ogre_stand6	=[	5,	ogre_stand7	] {ai_stand();};
void() ogre_stand7	=[	6,	ogre_stand8	] {ai_stand();};
void() ogre_stand8	=[	7,	ogre_stand9	] {ai_stand();};
void() ogre_stand9	=[	8,	ogre_stand1	] {ai_stand();};

void() ogre_walk1	=[	9,		ogre_walk2	] {ai_walk(3);};
void() ogre_walk2	=[	10,		ogre_walk3	] {ai_walk(2);};
void() ogre_walk3	=[	11,		ogre_walk4	] {
ai_walk(2);
if (random() < 0.2)
	sound (self, CHAN_VOICE, "ogre/ogidle.wav", 1, ATTN_IDLE);
};
void() ogre_walk4	=[	12,		ogre_walk5	] {ai_walk(2);};
void() ogre_walk5	=[	13,		ogre_walk6	] {ai_walk(2);};
void() ogre_walk6	=[	14,		ogre_walk7	] {
ai_walk(5);
if (random() < 0.1)
	sound (self, CHAN_VOICE, "ogre/ogidle2.wav", 1, ATTN_IDLE);
};
void() ogre_walk7	=[	15,		ogre_walk8	] {ai_walk(3);};
void() ogre_walk8	=[	16,		ogre_walk9	] {ai_walk(2);};
void() ogre_walk9	=[	17,		ogre_walk10	] {ai_walk(3);};
void() ogre_walk10	=[	18,	ogre_walk11	] {ai_walk(1);};
void() ogre_walk11	=[	19,	ogre_walk12	] {ai_walk(2);};
void() ogre_walk12	=[	20,	ogre_walk13	] {ai_walk(3);};
void() ogre_walk13	=[	21,	ogre_walk14	] {ai_walk(3);};
void() ogre_walk14	=[	22,	ogre_walk15	] {ai_walk(3);};
void() ogre_walk15	=[	23,	ogre_walk16	] {ai_walk(3);};
void() ogre_walk16	=[	24,	ogre_walk1	] {ai_walk(4);};

void() ogre_run1	=[	25,		ogre_run2	] {ai_run(9);
if (random() < 0.2)
	sound (self, CHAN_VOICE, "ogre/ogidle2.wav", 1, ATTN_IDLE);
};
void() ogre_run2	=[	26,		ogre_run3	] {ai_run(12);};
void() ogre_run3	=[	27,		ogre_run4	] {ai_run(8);};
void() ogre_run4	=[	28,		ogre_run5	] {ai_run(22);};
void() ogre_run5	=[	29,		ogre_run6	] {ai_run(16);};
void() ogre_run6	=[	30,		ogre_run7	] {ai_run(4);};
void() ogre_run7	=[	31,		ogre_run8	] {ai_run(13);};
void() ogre_run8	=[	32,		ogre_run1	] {ai_run(24);};

void() ogre_swing1	=[	33,		ogre_swing2	] {ai_charge(11);};
void() ogre_swing2	=[	34,		ogre_swing3	] {ai_charge(1);};
void() ogre_swing3	=[	35,		ogre_swing4	] {ai_charge(4);};
void() ogre_swing4	=[	36,		ogre_swing5	] {ai_charge(13);};
void() ogre_swing5	=[	37,		ogre_swing6	] {ai_charge(9); chainsaw(0);self.angles_y = self.angles_y + random()*25;};
void() ogre_swing6	=[	38,		ogre_swing7	] {chainsaw(200);self.angles_y = self.angles_y + random()* 25;};
void() ogre_swing7	=[	39,		ogre_swing8	] {self.angles_y = self.angles_y + random()* 25;};
void() ogre_swing8	=[	40,		ogre_swing9	] {self.angles_y = self.angles_y + random()* 25;};
void() ogre_swing9	=[	41,		ogre_swing10 ] {self.angles_y = self.angles_y + random()* 25;};
void() ogre_swing10	=[	42,		ogre_swing11 ] {self.angles_y = self.angles_y + random()* 25;};
void() ogre_swing11	=[	43,		ogre_swing12 ] {self.angles_y = self.angles_y + random()* 25;};
void() ogre_swing12	=[	44,		ogre_swing13 ] {chainsaw(200); ai_charge(3);};
void() ogre_swing13	=[	45,		ogre_swing14 ] {chainsaw(200); ai_charge(8);};
void() ogre_swing14	=[	46,		ogre_run1	] {ai_charge(9);};

void() ogre_nail1	=[	47,		ogre_nail2	] {ai_face();};
void() ogre_nail2	=[	48,		ogre_nail3	] {ai_face();};
void() ogre_nail3	=[	49,		ogre_nail4	] {ai_face();};
void() ogre_nail4	=[	50,		ogre_nail5	] {ai_face();OgreFireGrenade();};
void() ogre_nail5	=[	51,		ogre_nail6	] {ai_face();};
void() ogre_nail6	=[	52,		ogre_nail7	] {ai_face();};
void() ogre_nail7	=[	53,		ogre_run1	] {ai_face();};

void()	ogre_pain1	=[	54,		ogre_pain2	] {};
void()	ogre_pain2	=[	55,		ogre_pain3	] {};
void()	ogre_pain3	=[	56,		ogre_pain4	] {};
void()	ogre_pain4	=[	57,		ogre_pain5	] {};
void()	ogre_pain5	=[	58,		ogre_run1	] {};


void()	ogre_painb1	=[	59,	ogre_painb2	] {};
void()	ogre_painb2	=[	60,	ogre_painb3	] {};
void()	ogre_painb3	=[	61,	ogre_run1	] {};


void(entity attacker, float damage)	ogre_pain =
{
	local float	r; 	r = random();

	if(self.health < self.max_health / 2)
		self.skin = 1;
	
	if (self.flags & FL_DODGED)
		return;

// don't make multiple pain sounds right after each other
	if (self.pain_finished > time)
		return;

	sound (self, CHAN_VOICE, "ogre/ogpain1.wav", 1, ATTN_NORM);	
	
	if (r < 0.25)
		self.pain_finished = time + 1;
	else if (r < 0.5)
		self.pain_finished = time + 2.5;
	
	if (r < 0.25)
		ogre_pain1 ();
	else if (r < 0.5)
		ogre_painb1 ();

};

void() ogre_dead = 
{	
	InitCorpse ();
	self.maxs_z = -8;	
	self.nextthink = -1;
};

void()	ogre_die1	=[	63,	ogre_die2	] {};
void()	ogre_die2	=[	64,	ogre_die3	] {};
void()	ogre_die3	=[	65,	ogre_die4	] {};
void()	ogre_die4	=[	66,	ogre_die5	] {};
void()	ogre_die5	=[	67,	ogre_die6	] {};
void()	ogre_die6	=[	68,	ogre_die7	] {};
void()	ogre_die7	=[	69,	ogre_die8	] {};
void()	ogre_die8	=[	70,	ogre_die9	] {};
void()	ogre_die9	=[	71,	ogre_die10	] {};
void()	ogre_die10	=[	72,	ogre_die11	] {};
void()	ogre_die11	=[	73,	ogre_dead	] {};

void()	ogre_bdie1	=[	74,	ogre_bdie2	] {};
void()	ogre_bdie2	=[	75,	ogre_bdie3	] {ai_forward(5);};
void()	ogre_bdie3	=[	76,	ogre_bdie4	] {};
void()	ogre_bdie4	=[	77,	ogre_bdie5	] {ai_forward(1);};
void()	ogre_bdie5	=[	78,	ogre_bdie6	] {ai_forward(3);};
void()	ogre_bdie6	=[	79,	ogre_bdie7	] {ai_forward(7);};
void()	ogre_bdie7	=[	80,	ogre_bdie8	] {ai_forward(25);};
void()	ogre_bdie8	=[	81,	ogre_bdie9	] {};
void()	ogre_bdie9	=[	82,	ogre_bdie10	] {};
void()	ogre_bdie10	=[	83,	ogre_dead	] {};


void()	ogre_duckdown1	=[	85,	ogre_duckdown2	] 
{
	if(random() < 0.4)
		OgreFireGrenade(); 
	
	self.nextthink = self.dspeed; 
	self.maxs_z -= 60; 
	self.takedamage = DAMAGE_YES;
};
void()	ogre_duckdown2	=[	86,	ogre_duckdown3	] {};
void()	ogre_duckdown3	=[	87,	ogre_duckdown4	] {};
void()	ogre_duckdown4	=[	88,	ogre_duckhold	] {self.pausetime = time + (random()) % 2 + 0.4;};

void()	ogre_duckup1	=[	88,	ogre_duckup2	] 
{ self.takedamage = DAMAGE_AIM; self.flags = self.flags - (self.flags & FL_DODGED); self.maxs_z += 60;};
void()	ogre_duckup2	=[	87,	ogre_duckup3	] {};
void()	ogre_duckup3	=[	86,	ogre_duckup4	] {};
void()	ogre_duckup4	=[	85,	ogre_run1	      ] {};

void() ogre_duckhold =[	89,	ogre_duckhold 	]
{	
	if(time > self.pausetime)
		self.think = ogre_duckup1;
}


void() ogre_die =
{
// if die while dodging remove all dodge related tags
	if(self.flags & FL_DODGED)
	{
		self.maxs_z += 60;
		self.flags = self.flags - (self.flags & FL_DODGED);
	}
	
// check for gib
	if (self.health < -120)
	{
		self.skin = 0;
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM); 
		ThrowHead ("progs/h_ogre.mdl", self.health);
		//for(float i = 0; i < 2; i++)
			ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		//for(float i = 0; i < 3; i++)
			ThrowGib ("progs/gib3.mdl", self.health);
		return;
	}
	
// don't die a regular death again as corpse
	if((self.deadflag & DEAD_DEAD))
		return;

// regular death
	sound (self, CHAN_VOICE, "ogre/ogdth.wav", 1, ATTN_NORM);
	self.skin = 1;

	if (random() < 0.5)
		ogre_die1 ();
	else
		ogre_bdie1 ();

	self.deadflag = DEAD_DEAD;
};

/*QUAKED monster_ogre (1 0 0) (-32 -32 -24) (32 32 64) Ambush // self.max_z -= 88;

*/
void() monster_ogre =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/ogre.mdl");
	precache_model ("progs/h_ogre.mdl");
	precache_model ("progs/grenade.mdl");

	precache_sound ("ogre/ogdrag.wav");
	precache_sound ("ogre/ogdth.wav");
	precache_sound ("ogre/ogidle.wav");
	precache_sound ("ogre/ogidle2.wav");
	precache_sound ("ogre/ogpain1.wav");
	precache_sound ("demon/dhit2.wav");
	precache_sound ("ogre/ogwake.wav");

	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/ogre.mdl");

	setsize (self, VEC_HULL3_MIN, VEC_HULL3_MAX);
	self.health = 250;
	self.max_health = 250;
	self.skin = 0;

	self.th_stand = ogre_stand1;
	self.th_walk = ogre_walk1;
	self.th_run = ogre_run1;
	self.th_die = ogre_die;
	self.th_melee = ogre_swing1;
	self.th_missile = ogre_nail1;
	self.th_pain = ogre_pain;
	self.th_dodge = ogre_duckdown1;
	self.th_checkattack = OgreCheckAttack;
	self.mass = 200;
	self.dspeed = 0;
		
	walkmonster_start();
};

void() monster_ogre_marksman =
{
	monster_ogre ();
};


