/*
==============================================================================

DEMON

==============================================================================
*/

$cd id1/models/demon3
$scale	0.8
$origin 0 0 24
$base base
$skin base

//============================================================================

void()	Demon_JumpTouch;
float()	CheckDemonMelee;
float()	CheckDemonMelee;
void(float dmg)	Demon_Melee;

void()	demon1_stand1	=[	0,	demon1_stand2	] {ai_stand();};
void()	demon1_stand2	=[	1,	demon1_stand3	] {ai_stand();};
void()	demon1_stand3	=[	2,	demon1_stand4	] {ai_stand();};
void()	demon1_stand4	=[	3,	demon1_stand5	] {ai_stand();};
void()	demon1_stand5	=[	4,	demon1_stand6	] {ai_stand();};
void()	demon1_stand6	=[	5,	demon1_stand7	] {ai_stand();};
void()	demon1_stand7	=[	6,	demon1_stand8	] {ai_stand();};
void()	demon1_stand8	=[	7,	demon1_stand1	] {ai_stand();
if (random() < 0.2)
    sound (self, CHAN_VOICE, "demon/idle2.wav", 1, ATTN_IDLE);

};

void()	demon1_walk1	=[	8,		demon1_walk2	] {
if (random() < 0.2)
    sound (self, CHAN_VOICE, "demon/idle1.wav", 1, ATTN_IDLE);
ai_walk(8);
};
void()	demon1_walk2	=[	9,		demon1_walk3	] {ai_walk(6);};
void()	demon1_walk3	=[	10,		demon1_walk4	] {ai_walk(6);};
void()	demon1_walk4	=[	11,		demon1_walk5	] {ai_walk(7);};
void()	demon1_walk5	=[	12,		demon1_walk6	] {ai_walk(4);};
void()	demon1_walk6	=[	13,		demon1_walk7	] {ai_walk(6);};
void()	demon1_walk7	=[	14,		demon1_walk8	] {ai_walk(10);};
void()	demon1_walk8	=[	15,		demon1_walk1	] {ai_walk(10);};

void()	demon1_run1	=[	22,		demon1_run2	] {
if (random() < 0.2)
    sound (self, CHAN_VOICE, "demon/idle1.wav", 1, ATTN_IDLE);
ai_run(20);}
void()	demon1_run2	=[	17,		demon1_run3	] {ai_run(20);};
void()	demon1_run3	=[	18,		demon1_run4	] {ai_run(26);};
void()	demon1_run4	=[	19,		demon1_run5	] {ai_run(28);};
void()	demon1_run5	=[	20,		demon1_run6	] {ai_run(26);};
void()	demon1_run6	=[	21,		demon1_run1	] {ai_run(21);};

void()	demon1_jump1	=[	64,		demon1_jump2	] {ai_face();};
void()	demon1_jump2	=[	65,		demon1_jump3	] {ai_face();};
void()	demon1_jump3	=[	66,		demon1_jump4	] {ai_face();};
void()	demon1_jump4	=[	67,		demon1_jump5	]
{
	ai_face();
	local float vel;
	vel = CalcVelocity(1200, self.origin - self.enemy.origin, 450); // the more it accelerates the more distance cap it needs
	
	self.touch = Demon_JumpTouch;
	makevectors (self.angles);
	self.origin_z = self.origin_z + 3;
	self.velocity = v_forward * vel + '0 0 350';
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
};
void()	demon1_jump5	=[	68,		demon1_jump6	] {};
void()	demon1_jump6	=[	69,		demon1_jump7	] {};
void()	demon1_jump7	=[	70,		demon1_jump8	] {};
void()	demon1_jump8	=[ 	71,		demon1_jump9	] {};
void()	demon1_jump9	=[ 	72,		demon1_jump10	] {};
void()	demon1_jump10	=[ 	73,	demon1_jump1	] {
self.nextthink = time + 3;
// if three seconds pass, assume demon is stuck and jump again
};

void()	demon1_jump11	=[ 	74,	demon1_jump12	] {};
void()	demon1_jump12	=[ 	75,	demon1_run1	] {};


void()	demon1_atta1	=[	34,		demon1_atta2	] {ai_charge(1);};
void()	demon1_atta2	=[	36,		demon1_atta3	] {ai_charge(2);};
void()	demon1_atta3	=[	37,		demon1_atta4	] {ai_charge(2);};
void()	demon1_atta4	=[	38,		demon1_atta5	] {ai_charge(6); Demon_Melee(15 + 5*random()); };
void()	demon1_atta5	=[	39,		demon1_atta6	] {ai_charge(3);};
void()	demon1_atta6	=[	40,		demon1_run1       ] {ai_charge(4);};

void()	demon2_atta1	=[	41,		demon2_atta2	] {ai_charge(1);};
void()	demon2_atta2	=[	42,		demon2_atta3	] {ai_charge(2);};
void()	demon2_atta3	=[	43,		demon2_atta4	] {ai_charge(2);};
void()	demon2_atta4	=[	44,		demon2_atta5	] {ai_charge(6);};
void()	demon2_atta5	=[	45,		demon2_atta6	] {ai_charge(3);};
void()	demon2_atta6	=[	46,		demon2_atta7	] {ai_charge(3);Demon_Melee(15 + 5*random());};
void()	demon2_atta7	=[	47,		demon1_run1       ] {ai_charge(4);};

void() Demon_MeleeAttack =
{
	local float chance;
	chance = random();

	if (chance > 0.5)
		demon1_atta1 ();
	else
		demon2_atta1 ();
};

void(float ldmg)	Demon_Melee =
{
	local vector	delta;

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100)
		return;
	if (!CanDamage (self.enemy, self))
		return;
		
      sound (self, CHAN_WEAPON, "demon/dhit2.wav", 1, ATTN_NORM);
	T_Damage (self.enemy, self, self, ldmg, 25);
};

void()	demon1_duckdown1	=[	79,	demon1_duckdown2	] 
{
	self.nextthink = self.dspeed; 
	self.maxs_z -= 64; 
	self.takedamage = DAMAGE_YES;
};
void()	demon1_duckdown2	=[	80,	demon1_duckdown3	] {};
void()	demon1_duckdown3	=[	81,	demon1_duckdown4	] {};
void()	demon1_duckdown4	=[	82,	demon1_duckhold	] {self.pausetime = time + 0.5;};

void()	demon1_duckup1	=[	82,	demon1_duckup2	] {self.dodge_finished = time + 1 + random()*2; self.takedamage = DAMAGE_AIM; self.flags = self.flags - (self.flags & FL_DODGED); self.maxs_z += 64;};
void()	demon1_duckup2	=[	81,	demon1_duckup3	] {};
void()	demon1_duckup3	=[	80,	demon1_duckup4	] {};
void()	demon1_duckup4	=[	79,	demon1_madchrge10	] {};

void() demon1_duckhold =[	83,	demon1_duckhold 	]
{	
	if(time > self.pausetime)
		self.think = demon1_duckup1;
}

void()	demon1_madchrge1	=[	28,		demon1_madchrge2	] 
{ ai_face();sound (self, CHAN_VOICE, "demon/sight2.wav", 1, ATTN_NORM);};
void()	demon1_madchrge2	=[	29,		demon1_madchrge3	] {ai_face();};
void()	demon1_madchrge3	=[	30,		demon1_madchrge4	] {ai_face();};
void()	demon1_madchrge4	=[	31,		demon1_madchrge5	] {ai_face(); self.th_dodge = demon1_duckdown1; sound (self, CHAN_VOICE, "demon/dland2.wav", 1, ATTN_NORM);};
void()	demon1_madchrge5	=[	32,		demon1_madchrge6	] {ai_face();};
void()	demon1_madchrge6	=[	29,		demon1_madchrge7	] {ai_face();};
void()	demon1_madchrge7	=[	30,		demon1_madchrge8	] {ai_face(); sound (self, CHAN_VOICE, "demon/dland2.wav", 1, ATTN_NORM);};
void()	demon1_madchrge8	=[	31,		demon1_madchrge9	] {ai_face();};
void()	demon1_madchrge9	=[	22,		demon1_madchrge10	] {ai_charge(60); Demon_Melee ((random() + random() + random()) * 7); sound (self, CHAN_VOICE, "demon/dland2.wav", 1, ATTN_NORM);};
void()	demon1_madchrge10	=[	23,		demon1_madchrge11	] {ai_charge(66); Demon_Melee ((random() + random() + random()) * 7);};
void()	demon1_madchrge11	=[	24,		demon1_madchrge12	] {ai_charge(68); Demon_Melee ((random() + random() + random()) * 7);};
void()	demon1_madchrge12	=[	25,		demon1_madchrge13	] {ai_charge(66); Demon_Melee ((random() + random() + random()) * 7); sound (self, CHAN_VOICE, "demon/dland2.wav", 1, ATTN_NORM);};
void()	demon1_madchrge13	=[	26,		demon1_madchrge14	] {ai_charge(61); Demon_Melee ((random() + random() + random()) * 7);};
void()	demon1_madchrge14	=[	27,		demon1_madchrge15	] {ai_charge(60); Demon_Melee ((random() + random() + random()) * 7);};
void()	demon1_madchrge15	=[	22,		demon1_madchrge16	] {ai_charge(66); Demon_Melee ((random() + random() + random()) * 7); sound (self, CHAN_VOICE, "demon/dland2.wav", 1, ATTN_NORM);};
void()	demon1_madchrge16	=[	23,		demon1_madchrge17	] {ai_charge(68); Demon_Melee ((random() + random() + random()) * 7);};
void()	demon1_madchrge17	=[	24,		demon1_madchrge18	] {ai_charge(64); Demon_Melee ((random() + random() + random()) * 7);};
void()	demon1_madchrge18	=[	25,		demon1_madchrge19	] {ai_charge(61); Demon_Melee ((random() + random() + random()) * 7); sound (self, CHAN_VOICE, "demon/dland2.wav", 1, ATTN_NORM); };
void()	demon1_madchrge19	=[	27,		demon1_run1	      ] 
{ai_charge(61); self.th_dodge = 0; SUB_AttackFinishedSpecial (self, 1);};

void()	demon1_pain1	=[	48,		demon1_pain2	] {};
void()	demon1_pain2	=[	49,		demon1_pain3	] {ai_pain(13);};
void()	demon1_pain3	=[	50,		demon1_pain4	] {ai_pain(9);};
void()	demon1_pain4	=[	51,		demon1_pain5	] {};
void()	demon1_pain5	=[	52,		demon1_pain6	] {ai_pain(13);};
void()	demon1_pain6	=[	53,		demon1_run1	] {};

void(entity attacker, float damage)	demon1_pain =
{
	if(self.health < self.max_health / 2)
		self.skin = 1;
	
	if (self.touch == Demon_JumpTouch)
		return;

	if (self.flags & FL_DODGED)
		return;

	if (self.pain_finished > time)
		return;

	if (random()*650 > damage)
		return;		// didn't flinch

	sound (self, CHAN_VOICE, "demon/dpain1.wav", 1, ATTN_NORM);
	self.pain_finished = time + 3;

	if (skill == 3)
		return;
		
	demon1_pain1 (); 
	self.th_dodge = 0;
};

void()	demon1_die4		=[	57,		demon1_die5	] {};
void()	demon1_die5		=[	58,		demon1_die6	] {ai_back(9);};
void()	demon1_die6		=[	59,		demon1_die7	] {ai_back(12);};
void()	demon1_die7		=[	60,		demon1_die8	] {ai_back(7); self.solid = SOLID_NOT; setorigin(self, self.origin);};
void()	demon1_die8		=[	61,		demon1_die8	] {};



void() demon_die =
{
// check for gib
	self.th_dodge = 0;
	self.skin = 0;

	if(self.flags & FL_DODGED)
	{
		self.maxs_z += 64;
		self.flags = self.flags - (self.flags & FL_DODGED);
	}
	
	if (self.health < -80)
	{	
		self.skin = 0;
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_demon.mdl", self.health);
		//for(float i = 0; i < 2; i++)
			ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		//for(float i = 0; i < 3; i++)
			ThrowGib ("progs/gib3.mdl", self.health);
		remove(self);
		return;
	}
	
// don't die a regular death again as corpse
	if((self.deadflag & DEAD_DEAD))
		return;

// regular death
	self.movetype = MOVETYPE_TOSS;
	self.takedamage = DAMAGE_YES;
	self.skin = 1;
	
	demon1_die4 ();
	sound (self, CHAN_VOICE, "demon/ddeath.wav", 1, ATTN_NORM);

	self.deadflag = DEAD_DEAD;
};

/*
==============================================================================

DEMON

==============================================================================
*/

/*
==============
CheckDemonMelee

Returns TRUE if a melee attack would hit right now
==============
*/
float()	CheckDemonMelee =
{
	if (enemy_range == RANGE_MELEE)
	{
		if (CanDamage (self.enemy, self))
		{
			self.attack_state = AS_MELEE;
			return TRUE;
		}
	}
	return FALSE;
};

/*
==============
CheckDemonJump

==============
*/
float()	CheckDemonJump =
{
	local	vector	dist;
	local	float	d;

	if (self.origin_z + self.mins_z > self.enemy.origin_z + self.enemy.mins_z
	+ 0.75 * self.enemy.size_z)
		return FALSE;
		
	if (self.origin_z + self.maxs_z < self.enemy.origin_z + self.enemy.mins_z
	+ 0.25 * self.enemy.size_z)
		return FALSE;
		
	dist = self.enemy.origin - self.origin;
	dist_z = 0;
	
	d = vlen(dist);
	
	if (d < 600)
		return FALSE;
		
	if (d > 900)
	{
		if (random() <= 0.6)
			return FALSE;
	}
		
	return TRUE;
};

float()	CheckDemonMadCharge =
{	
	if (!enemy_vis)
		return FALSE;
	
	if ( fabs(self.origin_z - self.enemy.origin_z) > 20)
		return FALSE;		// too much height change

	if ( vlen (self.origin - self.enemy.origin) < 200 )
		return FALSE;
		
	if ( vlen (self.origin - self.enemy.origin) > 400 )
		return FALSE;
	
	if (random() <= 0.5)
		return FALSE;	
	
	return TRUE;
};

float()	DemonCheckAttack =
{
// if close enough for slashing, go for it
	if (CheckDemonMelee ())
	{
		self.attack_state = AS_MELEE;
		return TRUE;
	}

	if (time < self.attack_finished)
		return FALSE;

	if (CheckDemonMadCharge ())
	{
		demon1_madchrge1();
		return TRUE;
	}
	
	if (CheckDemonJump ())
	{
		self.attack_state = AS_MISSILE;
        	sound (self, CHAN_VOICE, "demon/djump.wav", 1, ATTN_NORM);
		SUB_AttackFinished (self, 2*random());
		return TRUE;
	}
	
	return FALSE;
};


//===========================================================================


void() Demon_JumpTouch =
{	
	if (!checkbottom(self))
	{
		if (self.flags & FL_ONGROUND)
		{	
			self.touch = SUB_Null;
			self.think = demon1_jump1;
			self.nextthink = time + 0.1;
		}
		return;	// not on ground yet
	}

	self.touch = SUB_Null;
	self.think = demon1_jump11;
	self.nextthink = time + 0.1;
};

/*QUAKED monster_demon1 (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/

void() monster_demon1_cache =
{
	precache_model ("progs/demon.mdl");
	precache_model ("progs/h_demon.mdl");

	precache_sound ("demon/ddeath.wav");
	precache_sound ("demon/dhit2.wav");
	precache_sound ("demon/djump.wav");
	precache_sound ("demon/dpain1.wav");
	precache_sound ("demon/idle1.wav");
	precache_sound ("demon/idle2.wav");
	precache_sound ("demon/sight2.wav");
}

void() spawn_demon1 =
{	
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/demon.mdl");

	setsize (self, VEC_HULL3_MIN, VEC_HULL3_MAX);
	self.health = 475;
	self.max_health = 475;
	self.skin = 0;
	self.mass = 350;

	self.th_stand = demon1_stand1;
	self.th_walk = demon1_walk1;
	self.th_run = demon1_run1;
	self.th_die = demon_die;
	self.th_melee = Demon_MeleeAttack;		// one of two attacks
	self.th_missile = demon1_jump1;			// jump attack
	self.th_pain = demon1_pain;
	self.th_checkattack= DemonCheckAttack;
	self.th_spawn = spawn_demon1;		

	walkmonster_start();
};

void() monster_demon1 =
{		
	if (deathmatch)
	{
		remove(self);
		return;
	}
	
	monster_demon1_cache ();
	spawn_demon1 ();
};

