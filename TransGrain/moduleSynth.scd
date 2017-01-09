//moduleSynth
// creates the model code (grain params, cloud params, cloudGen func, envGen func) for each grain synth

// global variable p needs to be setup in startup script for ProxySpace

Environment.make({

	//grain/cloud generators
	~gauss_sine_constructor = {|pattern_name, env_name, out_name, grain_synthdef_name, env_synthdef_name|

		// synthdef keys
		var grain_synthdef = grain_synthdef_name.asSymbol;
		var cloud_synthdef = env_synthdef_name.asSymbol;

		// node proxy keynames
		var pattern = pattern_name.asSymbol;   // pattern refers to grain pattern
		var cloud_env = env_name.asSymbol;    // cloud refers to ADSR envelope
		var out = out_name.asSymbol;

		var isOutputSet = false;
		var isDestroyed = false;

		(
			getPatternName: { |self| pattern },
			getCloudName: { |self| cloud_env },
			getOutName: { |self| out },
			getGrainSynthdefName: {|self| grain_synthdef },
			getCloudSynthdefName: {|self| cloud_synthdef },

			play: {|self| p[out].play; },
			end: {|self| p[out].end; },
			destroy: {|self| p[out] =nil; p[cloud_env]=nil; p[pattern]=nil; self.isDestroyed = true}, // gracefully kill all nodes associated with the instance


			patternParam: (
				instrument: grain_synthdef,   // don't change the instrument !
				dur: 0.1,
				freq: 1000,
				amp: 0.1,
				atk: 0.01,
				rel: 0.05,
				pos: 0
			),
			cloudParam: (
				instrument: cloud_synthdef,   // don't change the instrument !
				inbus: p[pattern].index,      // don't change the inbus !
				sus_lvl: 0.25,
				dur: 5,
				atk: 0.01,
				dec: 0.12,
				sus: 1,
				rel: 3
			),

			patternGen:{ |self, voices, fadeTime=3|

				p[pattern] = nil;         //reset pattern
				p[pattern].fadeTime = fadeTime; // changes individual pattern fadetime

				voices.do({ |i|
					p[pattern][i] = Pbind(
						\instrument, grain_synthdef,
						\dur, Pif(self.patternParam.dur.isKindOf(Function), self.patternParam.dur.value , self.patternParam.dur),
						\freq, Pif(self.patternParam.freq.isKindOf(Function), self.patternParam.freq.value, self.patternParam.freq),
						\amp, Pif(self.patternParam.amp.isKindOf(Function), self.patternParam.amp.value, self.patternParam.amp),
						\atk, Pif(self.patternParam.atk.isKindOf(Function), self.patternParam.atk.value, self.patternParam.atk),
						\rel, Pif(self.patternParam.rel.isKindOf(Function), self.patternParam.rel.value, self.patternParam.rel),
						\pos, Pif(self.patternParam.pos.isKindOf(Function), self.patternParam.pos.value, self.patternParam.pos),
					);
				});
			},

			cloudGen: {|self|

				p[cloud_env] = Pbind(
					\instrument, cloud_synthdef,
					\inbus, p[pattern].index,
					\sus_lvl, Pif(self.cloudParam.sus_lvl.isKindOf(Function), self.cloudParam.sus_lvl.value, self.cloudParam.sus_lvl),
					\dur, Pif(self.cloudParam.dur.isKindOf(Function), self.cloudParam.dur.value , self.cloudParam.dur),
					\atk, Pif(self.cloudParam.atk.isKindOf(Function), self.cloudParam.atk.value, self.cloudParam.atk),
					\dec, Pif(self.cloudParam.dec.isKindOf(Function), self.cloudParam.dec.value, self.cloudParam.dec),
					\sus, Pif(self.cloudParam.sus.isKindOf(Function), self.cloudParam.sus.value, self.cloudParam.sus),
					\rel, Pif(self.cloudParam.rel.isKindOf(Function), self.cloudParam.rel.value, self.cloudParam.rel)
				);

				p[out] = p[cloud_env];
			}

		)

	};

	// TODO:: add the rest of the constructors...

	/*~perc_sine_constructor = {|pattern_name, out_name|



	};
	~expodec_drum_samp_constructor = {|pattern_name, out_name|


	};
	~gauss_train_constructor = {| pattern_name, out_name |



	};
	~perc_train_constructor = { ||


	};
	~pulse_convolver2_constructor = {||


	};*/

}).know_(true);
