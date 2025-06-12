/*
==============================================================================

BLOB

==============================================================================
*/

$cd id1/models/tarbaby
$origin 0 0 24
$base base		

$skin skin

void()	tbaby_stand1	=[	0,		tbaby_stand2	] {ai_stand();};
void()	tbaby_stand2	=[	1,		tbaby_stand3	] {ai_stand();};
void()	tbaby_stand3	=[	2,		tbaby_stand1	] {ai_stand();};


void()	tbaby_walk1	=[	3,		tbaby_walk1	] {ai_walk(4);};
void()	tbaby_walk2	=[	4,		tbaby_walk2	] {ai_walk(5);};
void()	tbaby_walk3	=[	5,		tbaby_walk3	] {ai_walk(2);};
void()	tbaby_walk4	=[	6,		tbaby_walk4	] {ai_walk(4);};
void()	tbaby_walk5	=[	7,		tbaby_walk5	] {ai_walk(6);};
void()	tbaby_walk6	=[	8,		tbaby_walk6	] {ai_walk(1);};


void()	tbaby_run1	=[	9,		tbaby_run2	] {ai_run(20);};
void()	tbaby_run2	=[	10,		tbaby_run3	] {ai_run(20);};
void()	tbaby_run3	=[	11,		tbaby_run4	] {ai_run(20);};
void()	tbaby_run4	=[	12,		tbaby_run5	] {ai_run(20);};
void()	tbaby_run5	=[	13,		tbaby_run6	] {ai_run(20);};
void()	tbaby_run6	=[	14,		tbaby_run1	] {ai_run(20);};


//============================================================================

void() CheckContinueCharge2 =
{
	if (!self.enemy)
	{
		self.angles = '0 0 0';
		self.movetype = MOVETYPE_STEP;	
		tbaby_stand1 ();
		return;	
	}

	if (time > self.ltime)
	{
		self.angles = '0 0 0';
		self.movetype = MOVETYPE_STEP;	
		SUB_AttackFinishedSpecial (self,2 + 2*random());
		tbaby_run1 ();
		return;	
	}
};

void() tbaby_melee =
{
	local float 	ldmg;
	
	if (other.health <= 0)
		return;

	if (time < self.dmgtime)
		return;

	self.dmgtime = time + 0.33;
		
	if (other.takedamage)
	{
		ldmg = 10 + 10*random();
		T_Damage (other, self, self, ldmg, 2);	
		sound (self, CHAN_VOICE, "blob/hit1.wav", 1, ATTN_NORM);
	}	
};


void() tbaby_leap1	=[	15 ,		tbaby_leap2	] {ai_face(); };
void() tbaby_leap2	=[	16 ,		tbaby_leap3	] {ai_face(); };
void() tbaby_leap3	=[	17 ,		tbaby_leap4	] {ai_face(); self.ltime = time + 1; };
void() tbaby_leap4	=[	18 ,		tbaby_leap5	] 
{
	ai_face();
	self.movetype = MOVETYPE_FLY;	
	self.flags = self.flags - (self.flags & FL_ONGROUND);

	local vector dir = normalize((self.enemy.origin + self.enemy.view_ofs)- self.origin);

	self.velocity = dir * 500; 
	self.angles = vectoangles(dir);
	self.touch = tbaby_melee;
};
void() tbaby_leap5	=[	19 ,		tbaby_leap6	] {ai_face(); };
void() tbaby_leap6	=[	20 ,		tbaby_leap7	] {ai_face(); };
void() tbaby_leap7	=[	21 ,		tbaby_leap8	] {ai_face(); };
void() tbaby_leap8	=[	22 ,		tbaby_leap4	] {ai_face(); CheckContinueCharge2();};



//=============================================================================

void()	tbaby_die1	=[	23,		tbaby_die2	] {self.takedamage = DAMAGE_NO; self.nextthink = 0.2;};
void()	tbaby_die2	=[	24,		tbaby_die3	] {self.nextthink = 0.35;};

void()	tbaby_die3	=[	24,		tbaby_run1	]
{
	sound (self, CHAN_VOICE, "blob/death1.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_TAREXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	
	self.cnt = 1;
	BecomeExplosion ();
};

//=============================================================================


/*QUAKED monster_tarbaby (1 0 0) (-16 -16 -24) (16 16 24) Ambush
*/
void() monster_tarbaby =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/tarbaby.mdl");

	precache_sound ("blob/death1.wav");
	precache_sound ("blob/hit1.wav");
	precache_sound ("blob/land1.wav");
	precache_sound ("blob/sight1.wav");
	
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/tarbaby.mdl");

	setsize (self, '-16 -16 -24', '16 16 40');
	self.health = 45;
	self.max_health = 45;
	self.mass = 0;

	self.th_stand = tbaby_stand1;
	self.th_walk = tbaby_walk1;
	self.th_run = tbaby_run1;
	self.th_die = tbaby_die1;
	self.th_melee = tbaby_leap1;
	self.th_missile = tbaby_leap1;
	
	flymonster_start ();
};

