( // cloud generator
var num = 7;
var sf = (0..b[\voice].size-1).choose;
~pattern_pulse_convolve=nil;
num.do({|i|
	~pattern_pulse_convolve[i] = Pbind(\instrument,\pulse_convolver2,
		\dur, Pwhite(1,5),  // do not set too low... min 1 for performance.. might crash!
		\env_dur,Pwhite(0.7,2),  // be careful here too..
		\freq,Pxrand([5,10,130,170, 250, 350, 550],inf),
		\nharm,Pxrand([10,50,100,200,500],inf),
		\amp,Pwhite(0.1,0.7),\rate,Pbrown(0.5,1),
		\bufnum,b[\voice][sf],
		\bufsize,b[\voice][sf].numFrames,
		\pos,Pbrown(-1,1,0.33)
	);
});
)

( // cloud_player
~cloud_pulse_convolve = Pbind(\instrument, \cloud_env,
	\inbus, ~pattern_pulse_convolve.index,
	\sus_lvl,0.7, \dur,2,
	\atk,0.01, \dec,0.25, \sus,2, \rel,2
);
)
~out1_pconv = {FreeVerb.ar(~cloud_pulse_convolve.ar,0.5,0.7,0.45)}
~out1_pconv.play;
~out1_pconv.end;

~pattern_pulse_convolve=nil; // will fadeout cloud and pattern proxys
~cloud_pulse_convolve=nil;