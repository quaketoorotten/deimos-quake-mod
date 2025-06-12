

// grabbed this from https://github.com/id-Software/quake-rerelease-qc/tree/main/quakec

float COUNTER_TOGGLE = 1;
float COUNTER_LOOP = 2;
float COUNTER_STEP = 4;
float COUNTER_RESET = 8;
float COUNTER_RANDOM = 16;
float COUNTER_FINISHCOUNT = 32;
float COUNTER_START_ON = 64;

void() counter_off_use;
void() counter_on_use;

/*
==============================================================================

FUNC_COUNTER & FUNC_ONCOUNT STUFF

==============================================================================
*/

void() counter_think =
	{
	self.cnt = self.cnt + 1;
	if ( self.spawnflags & COUNTER_RANDOM )
		{
		self.state = random() * self.count;
		self.state = floor( self.state ) + 1;
		}
	else
		{
		self.state = self.cnt;
		}

	activator = other;
	SUB_UseTargets();
	self.nextthink = time + self.wait;

	if ( self.spawnflags & COUNTER_STEP )
		{
		counter_on_use();
		}

	if ( self.cnt >= self.count )
		{
		self.cnt = 0;
		if ( ( self.aflag ) || !( self.spawnflags & COUNTER_LOOP ) )
			{
			if (self.spawnflags & COUNTER_TOGGLE)
				{
				counter_on_use();
				}
			else
				{
				remove (self);
				}
			}
		}
	};

void() counter_on_use =
	{
	if ( ( self.cnt != 0 ) && ( self.spawnflags & COUNTER_FINISHCOUNT ) )
		{
		self.aflag = TRUE;
		return;
		}

	self.use = counter_off_use;
	self.think = SUB_Null;
	self.aflag = FALSE;
	};

void() counter_off_use =
	{
	self.aflag = FALSE;
	if (self.spawnflags & COUNTER_TOGGLE)
		{
		self.use = counter_on_use;
		}
	else
		{
		self.use = SUB_Null;
		}

	if ( self.spawnflags & COUNTER_RESET )
		{
		self.cnt = 0;
		self.state = 0;
		}
	self.think = counter_think;
	if (self.delay)
		{
		self.nextthink = time + self.delay;
		}
	else
		{
		counter_think();
		}
	};

float( entity counter ) counter_GetCount =
	{

	if ( counter.classname == "counter" )
		{
		return counter.state;
		}
	return 0;
	};

//============================================================================

/*QUAKED func_counter (0 0 0.5) (0 0 0) (32 32 32) TOGGLE LOOP STEP RESET RANDOM FINISHCOUNT START_ON
TOGGLE causes the counter to switch between an on and off state
each time the counter is triggered.

LOOP causes the counter to repeat infinitly.  The count resets to zero
after reaching the value in "count".

STEP causes the counter to only increment when triggered.  Effectively,
this turns the counter into a relay with counting abilities.

RESET causes the counter to reset to 0 when restarted.

RANDOM causes the counter to generate random values in the range 1 to "count"
at the specified interval.

FINISHCOUNT causes the counter to continue counting until it reaches "count"
before shutting down even after being set to an off state.

START_ON causes the counter to be on when the level starts.

"count" specifies how many times to repeat the event.  If LOOP is set,
it specifies how high to count before reseting to zero.  Default is 10.

"wait"  the length of time between each trigger event. Default is 1 second.

"delay" how much time to wait before firing after being switched on.
*/

void() func_counter =
	{
	if ( !self.wait )
	   {
	   self.wait = 1;
	   }

	self.count = floor( self.count );
	if ( self.count <= 0 )
	   {
	   self.count = 10;
	   }
	self.cnt = 0;
	self.state = 0;

	self.classname = "counter";
	self.use = counter_off_use;
	self.think = SUB_Null;
   if ( self.spawnflags & COUNTER_START_ON )
      {
      self.think = counter_off_use;
      self.nextthink = time + 0.1;
      }
	};

//============================================================================

void() oncount_use =
	{
	if ( counter_GetCount( other ) == self.count )
		{
		activator = other;
		SUB_UseTargets();
		}
	};

/*QUAKED func_oncount (0 0 0.5) (0 0 0) (16 16 16)
Must be used as the target for func_counter.  When the counter
reaches the value set by count, func_oncount triggers its targets.

"count" specifies the value to trigger on.  Default is 1.

"delay" how much time to wait before firing after being triggered.
*/

void() func_oncount =
	{
	self.count = floor( self.count );
	if ( self.count <= 0 )
	   {
	   self.count = 1;
	   }

	self.classname = "oncount";
	self.use = oncount_use;
	self.think = SUB_Null;
	};

/*
==============================================================================

FUNC_PARTICLEFIELD STUFF

==============================================================================
*/

float USE_COUNT = 1;

void () particlefield_XZ =
	{
	local vector pos;
   local vector start;
   local vector end;

   if ( ( self.spawnflags & USE_COUNT ) &&
      ( counter_GetCount( other ) != self.cnt ) )
      {
      return;
      }
//   dprint( "XZ\n" );

   self.ltime = time + 0.25;

   // Only show particles if client is visible.
   // This helps to keep network traffic down to a minimum.
   if (!checkclient() )
      return;

   start = self.dest1 + self.origin;
   end   = self.dest2 + self.origin;
   pos_y = start_y;
   pos_z = start_z;
   while( pos_z <= end_z )
		{
      pos_x = start_x;
      while( pos_x <= end_x )
			{
         particle ( pos, '0 0 0', self.color, self.count );
         pos_x = pos_x + 16;
			}
      pos_z = pos_z + 16;
		}
	};

void () particlefield_YZ =
	{
	local vector pos;
   local vector start;
   local vector end;

   if ( ( self.spawnflags & USE_COUNT ) &&
      ( counter_GetCount( other ) != self.cnt ) )
      {
      return;
      }

//   dprint( "YZ: " );
//   dprint( vtos( self.dest1 ) );
//   dprint( " - " );
//   dprint( vtos( self.dest2 ) );
//   dprint( "\n" );
   self.ltime = time + 0.25;

   // Only show particles if client is visible.
   // This helps to keep network traffic down to a minimum.
   if (!checkclient() )
      return;

   start = self.dest1 + self.origin;
   end   = self.dest2 + self.origin;
   pos_x = start_x;
   pos_z = start_z;
   while( pos_z < end_z )
		{
      pos_y = start_y;
      while( pos_y < end_y )
			{
         particle ( pos, '0 0 0', self.color, self.count );
			pos_y = pos_y + 16;
			}
		pos_z = pos_z + 16;
		}
	};

void () particlefield_XY =
	{
	local vector pos;
   local vector start;
   local vector end;

   if ( ( self.spawnflags & USE_COUNT ) &&
      ( counter_GetCount( other ) != self.cnt ) )
      {
      return;
      }

//   dprint( "XY\n" );
   self.ltime = time + 0.25;

   // Only show particles if client is visible.
   // This helps to keep network traffic down to a minimum.
   if (!checkclient() )
      return;


   start = self.dest1 + self.origin;
   end   = self.dest2 + self.origin;
   pos_x = start_x;
   pos_z = start_z;
   while( pos_x < end_x )
		{
      pos_y = start_y;
      while( pos_y < end_y )
			{
         particle ( pos, '0 0 0', self.color, self.count );
			pos_y = pos_y + 16;
			}
		pos_x = pos_x + 16;
		}
	};

//============================================================================

void () particlefield_touch =
	{
   if ( !self.dmg )
      return;

   if ( time > self.ltime)
      return;

	if (time < self.attack_finished)
		return;
	self.attack_finished = time + 0.5;
	T_Damage (other, self, self, self.dmg, 0);
   };

//============================================================================

/*QUAKED func_particlefield (0 .5 .8) ? USE_COUNT
Creates a brief particle flash roughly the size of the defining
brush each time it is triggered.

USE_COUNT when the activator is a func_counter, the field will only
   activate when count is equal to "cnt".  Same as using a func_oncount
   to trigger.

"cnt" is the count to activate on when USE_COUNT is set.
"color" is the color of the particles.  Default is 192 (yellow).
"count" is the density of the particles.  Default is 2.
"noise" is the sound to play when triggered.  Do not use a looping sound here.
"dmg" is the amount of damage to cause when touched.
*/

void() func_particlefield =
	{
   if ( !self.color )
	   {
      self.color = 192;
	   }
   if ( self.count == 0 )
	   {
      self.count = 2;
	   }
   self.classname = "particlefield";
   self.solid = SOLID_NOT;
   self.movetype = MOVETYPE_NONE;
   setmodel (self, self.model);
   self.model = string_null;

   self.origin = ( self.mins + self.maxs ) * 0.5;
   setorigin (self, self.origin);
   self.dest = self.maxs - self.mins - '16 16 16';
   self.dest1 = self.mins + '8 8 8' - self.origin;
   self.dest2 = self.maxs + '7.9 7.9 7.9' - self.origin;
   setsize (self, self.mins, self.maxs);
   self.touch = particlefield_touch;
//   dprint( vtos( self.dest ) );
//   dprint( "  " );
   if ( self.dest_x > self.dest_z )
		{
      if ( self.dest_y > self.dest_z )
			{
//         dprint( "XY1 - " );
//         dprint( ftos( self.cnt ) );
//         dprint( "\n" );
         self.use = particlefield_XY;
         self.dest1_z = ( self.dest1_z + self.dest2_z ) / 2;
			}
		else
			{
//         dprint( "XZ1 - " );
//         dprint( ftos( self.cnt ) );
//         dprint( "\n" );
         self.use = particlefield_XZ;
         self.dest1_y = ( self.dest1_y + self.dest2_y ) / 2;
			}
		}
	else
		{
      if ( self.dest_y > self.dest_x )
         {
//         dprint( "YZ2 - " );
//         dprint( ftos( self.cnt ) );
//         dprint( "\n" );
         self.use = particlefield_YZ;
         self.dest1_x = ( self.dest1_x + self.dest2_x ) / 2;
			}
		else
			{
//         dprint( "XZ2 - " );
//         dprint( ftos( self.cnt ) );
//         dprint( "\n" );
         self.use = particlefield_XZ;
         self.dest1_y = ( self.dest1_y + self.dest2_y ) / 2;
			}
		}

   if ( self.noise )
      {
      precache_sound( self.noise );
      }
   self.ltime = time;
   };


/*
==============================================================================

FUNC_TOGGLEWALL STUFF

==============================================================================
*/


void () blocker_touch =
	{
	
if (other.classname == "player" && self.message != "")
	{
		centerprint (other, self.message);
		if (!self.noise)
			sound (activator, CHAN_VOICE, "misc/talk1.wav", 1, ATTN_NORM);
	}
	
   if ( !self.dmg )
      return;

	if (time < self.attack_finished)
		return;
	self.attack_finished = time + 0.5;
	T_Damage (other, self, self, self.dmg, 0);
   };

void () blocker_use =
	{
   if ( !self.state )
      {
      self.state = 1;
      setorigin( self, self.origin - '8000 8000 8000' );
      sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
      }
   else
      {
      self.state = 0;
      setorigin( self, self.origin + '8000 8000 8000' );
      sound(self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
      }
   };

//============================================================================

/*QUAKED func_togglewall (0 .5 .8) ? START_OFF
Creates a invisible wall that can be toggled on and off.

START_OFF wall doesn't block until triggered.

"noise" is the sound to play when wall is turned off.
"noise1" is the sound to play when wall is blocking.
"dmg" is the amount of damage to cause when touched.
*/

void() func_togglewall =
	{
   self.classname = "togglewall";
   self.movetype = MOVETYPE_PUSH;
   self.mdl = self.model;
   setmodel (self, self.model);
   setsize (self, self.mins, self.maxs);
   setorigin (self, self.origin);
   self.touch = blocker_touch;
   self.use = blocker_use;
	self.message = self.message;
   if ( !self.noise )
      {
      self.noise = ("misc/null.wav");
      }
   if ( !self.noise1 )
      {
      self.noise1 = ("misc/null.wav");
      }

   precache_sound( self.noise );
   precache_sound( self.noise1 );

   self.solid = SOLID_BSP;
   self.model = string_null;
   if ( self.spawnflags & START_OFF )
      {
      self.state = 0;
      setorigin( self, self.origin + '8000 8000 8000' );
      }
   else
      {
      self.state = 1;
      sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
      }
   };