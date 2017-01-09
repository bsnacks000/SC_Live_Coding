( // cloud generator
var num = 15;
~pattern_perc_train=nil;
num.do({|i|
	~pattern_perc_train[i] = Pbind(\instrument,\perc_train,
		\dur,0.25,
		\freq,Pseq((10,50..300),inf),\nharm,Prand([5,10,130,78,200],inf),\amp,Pwhite(0.01,0.5),
		\atk,0.01,\rel,0.3,\pos,Pbrown(-1,1)
	);
});
)

( // cloud_player
~cloud_perc_train = Pbind(\instrument, \cloud_env,
	\inbus, ~pattern_perc_train.index,
	\sus_lvl,0.5, \dur,5,                         // watch duration
	\atk,0.01, \dec,0.01, \sus,2, \rel,0.01
);
)

~out3_ptrain = {FreeVerb.ar(~cloud_perc_train.ar,0.5,0.7,0.45)}
~out3_ptrain.play;
~out3_ptrain.end;

~pattern_perc_train=nil;
~cloud_perc_train=nil;