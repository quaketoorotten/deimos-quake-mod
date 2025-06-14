/*
==============================================================================

SHAL-RATH

==============================================================================
*/
$cd id1/models/shalrath
$origin 0 0 24
$base base
$skin skin
$scale 0.7


void(entity attacker, float damage) shal_pain;
void(float far) ShalMissile;
void() shal_jump1;
void() Shal_JumpTouch;
void() shal_stand     =[      25,       shal_stand    ] {ai_stand();};

void() shal_walk1     =[      23,       shal_walk2    ] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_IDLE);
ai_walk(6);};
void() shal_walk2     =[      24,       shal_walk3    ] {ai_walk(4);};
void() shal_walk3     =[      25,       shal_walk4    ] {ai_walk(0);};
void() shal_walk4     =[      26,       shal_walk5    ] {ai_walk(0);};
void() shal_walk5     =[      27,       shal_walk6    ] {ai_walk(0);};
void() shal_walk6     =[      28,       shal_walk7    ] {ai_walk(0);};
void() shal_walk7     =[      29,       shal_walk8    ] {ai_walk(5);};
void() shal_walk8     =[      30,       shal_walk9    ] {ai_walk(6);};
void() shal_walk9     =[      31,       shal_walk10    ] {ai_walk(5);};
void() shal_walk10    =[      32,       shal_walk11    ] {ai_walk(0);};
void() shal_walk11    =[      33,       shal_walk1    ] {ai_walk(4);};

void() shal_run1     =[      23,       shal_run2    ] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_IDLE);
ai_run(25);};
void() shal_run2     =[      26,       shal_run3    ] {ai_run(24);};
void() shal_run3     =[      29,       shal_run4    ] {ai_run(26);};
void() shal_run4     =[      31,       shal_run5    ] {ai_run(25);};
void() shal_run5     =[      33,       shal_run6    ] {ai_run(24);};
void() shal_run6     =[      34,       shal_run1    ] {ai_run(26);};

void() shal_attack1     =[      0,       shal_attack2    ] {
sound (self, CHAN_VOICE, "shalrath/attack.wav", 1, ATTN_NORM);
ai_face();
};
void() shal_attack2     =[      1,       shal_attack3    ] {ai_face();};
void() shal_attack3     =[      2,       shal_attack4    ] {ShalMissile(30);};
void() shal_attack4     =[      3,       shal_attack5    ] {ShalMissile(30);};
void() shal_attack5     =[      4,       shal_attack6    ] {ShalMissile(30);};
void() shal_attack6     =[      5,       shal_attack7    ] {ShalMissile(30);};
void() shal_attack7     =[      6,       shal_attack8    ] {ShalMissile(30);};
void() shal_attack8     =[      7,       shal_attack9    ] {ShalMissile(30);};
void() shal_attack9     =[      8,       shal_attack10   ] {ShalMissile(30);};
void() shal_attack10    =[      9,       shal_attack11   ] {};
void() shal_attack11    =[      10,      shal_run1  ] {};

void() shal_melee1     =[      0,       shal_melee2     ] {
sound (self, CHAN_VOICE, "shalrath/attack.wav", 1, ATTN_NORM);
ai_face();
};
void() shal_melee2     =[      1,       shal_melee3     ] {ai_face();};
void() shal_melee3     =[      2,       shal_melee4     ] {ShalMissile(30); self.nextthink = time + 0.05;};
void() shal_melee4     =[      3,       shal_melee5     ] {ShalMissile(30); self.nextthink = time + 0.05;};
void() shal_melee5     =[      4,       shal_melee6     ] {ShalMissile(30); self.nextthink = time + 0.05;};
void() shal_melee6     =[      5,       shal_melee7     ] {ShalMissile(30); self.nextthink = time + 0.05;};
void() shal_melee7     =[      6,       shal_melee8     ] {ShalMissile(30); self.nextthink = time + 0.05;};
void() shal_melee8     =[      7,       shal_melee9     ] {ShalMissile(30); self.nextthink = time + 0.05;};
void() shal_melee9     =[      8,       shal_melee10     ] {ShalMissile(30); self.nextthink = time + 0.05;};
void() shal_melee10     =[      9,       shal_melee11     ] {};
void() shal_melee11     =[      10,      shal_run1  ] {};

void() shal_pain1       =[      11, shal_pain2      ] {};
void() shal_pain2       =[      12, shal_pain3      ] {};
void() shal_pain3       =[      13, shal_pain4      ] {};
void() shal_pain4       =[      14, shal_pain5      ] {};
void() shal_pain5       =[      15, shal_run1      ] {};

void() shal_death1      =[      16,        shal_death2     ] {};
void() shal_death2      =[      17,        shal_death3     ] {};
void() shal_death3      =[      18,        shal_death4     ] {};
void() shal_death4      =[      19,        shal_death5     ] {};
void() shal_death5      =[      20,        shal_death6     ] {};
void() shal_death6      =[      21,        shal_death7     ] {};
void() shal_death7      =[      22,        shal_death7    ] {	
	self.solid = SOLID_NOT; 
};


void(entity attacker, float damage) shal_pain =
{
	if(self.health < self.max_health / 2)
		self.skin = 1;

	if (self.pain_finished > time)
		return;

	sound (self, CHAN_VOICE, "shalrath/pain.wav", 1, ATTN_NORM);	
	self.pain_finished = time + 3;

	if (random()*400 > damage)
		return;		// didn't flinch

	if (skill == 3)
		return;	

	shal_pain1();
};

void() shal_die =
{
// check for gib
	if (self.health < -100)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_shal.mdl", self.health);

		for(float i = 0; i < 2; i++)
			ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		for(float i = 0; i < 2; i++)
			ThrowGib ("progs/gib3.mdl", self.health);
		remove(self);
		return;
	}

	// don't die a regular death again as corpse
	if((self.deadflag & DEAD_DEAD))
		return;

	sound (self, CHAN_VOICE, "shalrath/death.wav", 1, ATTN_NORM);
	self.movetype = MOVETYPE_TOSS;
	self.takedamage = DAMAGE_YES;
	self.skin = 1;
	shal_death1();
	self.deadflag = DEAD_DEAD;
};

/*
================
ShalMissile
================
*/

void() Laser2_Touch =
{
	local vector org;
	
	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	org = self.origin - 8*normalize(self.velocity);

	if (other.health)
	{
		if (other.classname == "monster_shalrath")
		{
			remove(self);
			return;
		}
		
		if (other.color)	
			SpawnBlood (org, self.velocity*0.2, other.color, 15);
		else	
			SpawnBlood (org, self.velocity*0.2, 73, 15*1.25);

		T_Damage (other, self, self.owner, 15, 3);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
	
	remove(self);	
};

void(float far) ShalMissile =
{
	local vector org;

	self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors(self.angles);
	
	org = self.origin + v_forward * far + v_right * 13.5;
	ai_face();
	sound (self, CHAN_VOICE, "weapons/hyper.wav", 1, ATTN_NORM);	
	LaunchLaser(org, (self.enemy.origin + '0 0 16') - org);
	newmis.touch = Laser2_Touch;
};

void()	shal_jump1	=[	36,		shal_jump2	] {ai_face();};
void()	shal_jump2	=[	37,		shal_jump3	] { ShalMissile (80);};
void()	shal_jump3	=[	38,		shal_jump4	] { ShalMissile (80);};
void()	shal_jump4	=[	39,		shal_jump5	]
{
	ShalMissile (80);

	local float vel;
	vel = CalcVelocity(600, self.origin - self.enemy.origin, 175);

	self.touch = Shal_JumpTouch;
	makevectors (self.angles);
	self.origin_z = self.origin_z + 3;
	self.velocity = v_forward*vel + '0 0 350';
	
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
};
void()	shal_jump5	=[	40,		shal_jump6	] { ShalMissile (80);};
void()	shal_jump6	=[	41,		shal_jump7	] { ShalMissile (80);};
void()	shal_jump7	=[	40,		shal_jump8	] { ShalMissile (80);};
void()	shal_jump8	=[ 	41,		shal_jump9	] { ShalMissile (80);};
void()	shal_jump9	=[ 	40,		shal_jump10	] { ShalMissile (80);};
void()	shal_jump10	=[ 	39,	shal_jump1	] {
self.nextthink = time + 3;
// if three seconds pass, assume demon is stuck and jump again
};

void()	shal_jump11	=[ 	42,	shal_jump12	] {self.velocity = '0 0 0';};
void()	shal_jump12	=[ 	43,	shal_attack1	] {};

float()	CheckShalMelee =
{
	if (enemy_range == RANGE_MELEE)
	{
		if (CanDamage (self.enemy, self))
			return TRUE;
	}
	return FALSE;
};

float()	CheckShalJump =
{	
	if (!enemy_vis)
		return FALSE;
	
	if ( fabs(self.origin_z - self.enemy.origin_z) > 20)
		return FALSE;		// too much height change

	if ( vlen (self.origin - self.enemy.origin) < 100 )
		return FALSE;
		
	if ( vlen (self.origin - self.enemy.origin) > 400 )
		return FALSE;
		
	return TRUE;
};

float() CheckShalMissile =
{
	local vector	spot1, spot2;	
	local entity	targ;
	targ = self.enemy;
	
// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, self);

	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (trace_ent != targ)
		return FALSE;	
							// don't have a clear shot	
	return TRUE;
};

float()	ShalCheckAttack =
{
// if close enough for slashing, go for it
	if (CheckShalMelee ())
	{
		self.attack_state = AS_MISSILE;
		self.nextthink = time + 0.05;
		return TRUE;
	}

	if (time < self.attack_finished)
		return FALSE;
	
	if (CheckShalJump ())
	{
		shal_jump1();
        	sound (self, CHAN_VOICE, "shalrath/attack2.wav", 1, ATTN_NORM);
		SUB_AttackFinishedSpecial (self, 2 + 2*random());
		return TRUE;
	}

	if (CheckShalMissile ())
	{
		self.attack_state = AS_MISSILE;
		SUB_AttackFinishedSpecial (self, 0.65);
		return TRUE;
	}
	
	return FALSE;
};

void() Shal_JumpTouch =
{	
	if (self.health <= 0)
		self.th_die();
	
	if (!checkbottom(self))
	{
		if (self.flags & FL_ONGROUND)
		{	
			self.touch = SUB_Null;
			self.think = shal_jump1;
			self.nextthink = time + 0.1;
		}
		return;	// not on ground yet
	}
	
	self.touch = SUB_Null;
	self.think = shal_jump11;
	self.nextthink = time + 0.1;
};

//=================================================================

/*QUAKED monster_shalrath (1 0 0) (-32 -32 -24) (32 32 48) Ambush
*/
void() monster_shalrath =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model2 ("progs/shalrath.mdl");
	precache_model2 ("progs/h_shal.mdl");
	precache_model2 ("progs/v_spike.mdl");

	precache_sound2 ("shalrath/attack.wav");
	precache_sound2 ("shalrath/attack2.wav");
	precache_sound2 ("shalrath/death.wav");
	precache_sound2 ("shalrath/idle.wav");
	precache_sound2 ("shalrath/pain.wav");
	precache_sound2 ("shalrath/sight.wav");
	
	spawn_shalrath();
};

void() spawn_shalrath =
{
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_STEP;
	
	setmodel (self, "progs/shalrath.mdl");
	setsize (self, VEC_HULL3_MIN, VEC_HULL3_MAX);
	self.health = 925;
	self.max_health = 925;
	self.mass = 700;
	self.skin = 0;

	self.th_stand = shal_stand;
	self.th_walk = shal_walk1;
	self.th_run = shal_run1;
	self.th_die = shal_die;
	self.th_missile = shal_attack1;
	self.th_melee = shal_melee1;
	self.th_pain = shal_pain;
	self.th_checkattack = ShalCheckAttack;

	self.th_spawn = spawn_shalrath;
	
	walkmonster_start ();
}


