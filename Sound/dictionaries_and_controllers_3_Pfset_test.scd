
~stanza.phrases.().size
(
~stanza = (
	id: Ref(0),
	mode: Ref('seq'),
	num_of_phrases: Ref(0),
	scale: Ref( Scale.major ),
	steps_octave: {|self| self.scale.value.pitchesPerOctave },
	phrases: Ref(List.new)
);



// initialize new Stanza
// for every new Stanza-> reset its 'phrases' key and
// reset Phrase's 'trig' key
~stanza_init.remove;
~stanza_init = SimpleController(~stanza.id).put(
	\init, {|values, tag, args|
		~stanza.phrases.value_(List.new);
		~phrase.trig.value_(0);
	};
);


// make sure all phrases are loaded on to the Servers before the playback starts
// underlying Logic: check  ~stanza.num_of_phrases and compare if the size of the
// loaded-phrases-list ('~stanza.phrases') is the same. If yes, then start playback.
// every new phrase (~phrase_builder controller) updates this controller when done.
~stanza_ready_to_play.remove;
~stanza_ready_to_play = SimpleController(~stanza.phrases).put(
	\update, {|values, tag, args|
		var phrases = ~stanza.phrases.value.asArray;
		var num_phrases = ~stanza.num_of_phrases.value;
		if (phrases.size == num_phrases){
			// if ready trigger the ~stanza_mode Controller
			~stanza.mode.changed(\mode);
		}
	}
);

// this is the main Player for each Stanza
// Select Pseq or Ppar as the main playback mode
~stanza_mode.remove;
~stanza_mode = SimpleController(~stanza.mode).put(
	\mode, {|values, tag, args|
		var phrases = ~stanza.phrases.value.asArray;
		case
		{~stanza.mode.value == 'seq'} {Pseq( phrases ).play(quant:1)}
		{~stanza.mode.value == 'par'} {Ppar( phrases ).play(quant:1)}
	}
);

);

~phrase.syll_length
~phrase.num_words
~phrase.steps_octave
~phrase.scale.value.degrees
~phrase.scale.value[32]


(
~phrase= (
	trig: Ref(0),
	id: Ref('symbol'),
	tempo_grid: Ref(4),

	syll_length: Ref([]),
	syll_stress: Ref([]),
	syll_weight: Ref([]),
	syll_score: Ref([]),
	num_words: {|self| var num = self.syll_length.value.reject{|x| x=='Rest(0)'}; num.size },//reject punctuation & calculate num words
	punctuation: Ref([]),
	adjectives: Ref([]),
	nouns: Ref([]),

	instr: Ref([]),
	pitch_collection: Ref([]),
	pitch_root: Ref(0),

	stack: Ref(true), // affects Pdefns // wait until the end of phrase or not
	recursion: Ref(true), // affects Pbindef players
	repeats:Ref(1),

	all_srvrs: { Server.allRunningServers },
	server: Ref(nil),
	group_main: Ref(nil),
	group_id: Ref(0),

	fx_list: Ref([]),
	fx_maker: { // this is a double function, so it doesn't evaluate as soon as it is called
		{ |id, group, server, fx_bus, fx_name|
			Pdef((fx_name++'_'++id).asSymbol,
				( type: \on, instrument: fx_name,
					server: server, group: group,
					addAction: 1, out: fx_bus)).play
		}
	},
	fx_bus: Ref(nil),
	fx_bus_index: Ref(nil),
	fx_builder: Ref(nil),
	main_builder: Ref(nil),
	out: Ref(0)
);






// trigger controller
// when triggered create the id name of the phrase and trigger the ~phrase_init
~phrase_trig.remove;
~phrase_trig = SimpleController(~phrase.trig).put(
	\value, { |values, tag, args|
		var id_stanza, trig, id;
		id_stanza = ~stanza.id.value.asSymbol;
		trig = values.value.asSymbol;
		id = id_stanza++'_'++ trig;
		~phrase.id.value_(id.asSymbol).changed(\init);
	}
);



// init controller
// initialise phrase
// create Group, Busses etc.
~phrase_init.remove;
~phrase_init = SimpleController(~phrase.id).put(
	\init, { |values, tag, args|
		var id, all_srvrs, choose, selected, group, bus;
		id = ~phrase.id.value;

		// select the most chilled Server :)
		all_srvrs= ~phrase.all_srvrs.value.asArray;
		// update Servers' status. It helps with choosing server when receiving very fast OSC msgs
		all_srvrs.do{|i| i.status};
		fork{
			// choose = all_srvrs.minIndex({ |item| item.avgCPU.round });
			choose = all_srvrs.minIndex({ |item| item.numGroups });
			selected = all_srvrs[choose]; // selected Server
			~phrase.server.value_(selected);
			("==============> "++selected).postln;

			// create main Group + fx_bus
			group = Group.new(selected);
			bus = Bus.audio(selected,2);
			selected.sync;

			// assign them
			~phrase.group_main.value_(group);
			~phrase.group_id.value_(group.nodeID);
			~phrase.fx_bus.value_(bus);
			~phrase.fx_bus_index.value_(bus.index);

			// set main Out bus
			~phrase.out.value_(0);
			// selected.sync;

			// start init of selected FX
			// send [id, group, server, fxBus] as args
			~phrase.fx_builder.changed(\init,[id, group, selected, bus]);
		};

	}
);

// syll_length controller
~length_ctrl.remove;
~length_ctrl = SimpleController(~phrase.syll_length).put(
	\value,{ |values, tag, args|
		var new_list = List.new;
		var id = ~phrase.id.value;
		var repeats = ~phrase.repeats.value;

		values.value.do{ |i|
			if (i.isKindOf(Integer)){
				new_list.add(i)
			}{
				new_list.add(Rest(0))
			}
		};
		Pdefn((\syllab_length_++id).asSymbol, Pn(Pseq(new_list.asArray, 1),repeats));
		("lenghts are: "++ values).postln;

	}
);


// syll_stress controller
// it creates a Pdefn that scales the pitch collection
~stress_ctrl.remove;
~stress_ctrl = SimpleController(~phrase.syll_stress).put(
	\value,{ |values, tag, args|
		var new_list = List.new;
		var id = ~phrase.id.value;
		var repeats = ~phrase.repeats.value;
		values.value.do{ |i|
			if (i.isKindOf(Symbol)){
				if(i != 'Rest(0)') { i.asString.do{ |x|
					// x.class.postln;
					case
					{x == $P}{ new_list.add(0)} // Primary stress
					{x == $S}{ new_list.add(0)} // Secondary stress
					{x == $U}{ new_list.add(0)} // Unstressed
				}
				}{
					// new_list.add(Rest(0))
					new_list.add(0)
				}
			}
		};
		Pdefn((\syllab_stress_++id).asSymbol,Pn(Pseq(new_list.asArray, 1),repeats));
		("stresses are: "++ values).postln;
	}
);

// syll_weight controller
// it creates a Pdefn that scales duration
~weight_ctrl.remove;
~weight_ctrl = SimpleController(~phrase.syll_weight).put(
	\value,{ |values, tag, args|
		var new_list = List.new;
		var id = ~phrase.id.value;
		var repeats = ~phrase.repeats.value;

		values.value.do{ |i|
			if (i.isKindOf(Symbol)){
				if(i != 'Rest(0)') { i.asString.do{ |x|
					// x.class.postln;
					case
					{x == $H}{ new_list.add(2)} // heavy
					{x == $L}{ new_list.add(1.0)} // light
				}
				}{
					new_list.add(1)
				}
			}
		};
		Pdefn((\syllab_weight_++id).asSymbol, Pn(Pseq(new_list.asArray, 1),repeats));
		("weights are: "++ values).postln;
	}
);


~syll_score_ctrl.remove;
~syll_score_ctrl = SimpleController(~phrase.syll_score).put(
	\value,{ |values, tag, args|
		var new_list = List.new;
		var id = ~phrase.id.value;
		var repeats = ~phrase.repeats.value;
		var scale = ~stanza.scale.value;

		values.value.do{ |i|
			if (i != 'Rest(0)')
			{ new_list.add( i % ~stanza.steps_octave) }
			{ new_list.add( Rest(0)) }
		};
		~phrase.pitch_collection.value_(new_list);

		Pdefn((\pitch_collection_++id).asSymbol, Pn(Pseq(new_list.asArray, 1),repeats));
		("pitches are: "++ new_list).postln;
	}
);




// punctuation controller
// different punctuations are transformed into \dur stretch values
// it creates (a) one Pdefn that controlls a Pstretch
// and (b) one Pdefn that sets the \amp to 0 whenever there is a punctuation, thus creating a rest.
~punct_ctrl.remove;
~punct_ctrl = SimpleController(~phrase.punctuation).put(
	\value,{ |values, tag, args|
		var new_list = List.new;
		var id = ~phrase.id.value;
		var repeats = ~phrase.repeats.value;
		var amp_transform;
		// transform punctuation to /dur multiplier
		values.value.do{ |i|
			if (i.isKindOf(Symbol)){
				if(i != 'None') {
					i.do{ |x|
						case
						{x == ','}{ new_list.add(1.5)}
						{x == '.'}{ new_list.add(2.0)}
						{x == ';'}{ new_list.add(2.5)}
						{x == '!'}{ new_list.add(3)}
						{x == '?'}{ new_list.add(4)}
				}}
				{
					new_list.add(1) // if no punctuation then multiply with 1
				}
			}
		};
		("the puncs are"++new_list.asArray).postln;
		// transform the /dur list into /amp list
		// if any value is > 1 => set the amp to 0, i.e. Rest
		amp_transform = new_list.asArray.collect{|x| if (x>1){x=0}{x=1}};
		//create the stretch Pdefn
		Pdefn((\punct_stretch++id).asSymbol, Pn(Pseq(new_list.asArray, 1), repeats));
		// create the "rest" Pdefn
		Pdefn((\punct_rest++id).asSymbol, Pn(Pseq(amp_transform, 1), repeats));

	}
);

// are there any adjectives? if yes: map them to corresponding effects
~map_adjs_to_fx.remove;
~map_adjs_to_fx = SimpleController(~phrase.adjectives).put(
	\update, { |values, tag, args|
		var list = List.new;
		("adjectives are: " ++ values).postln;
		if (values.value.size > 0){
			values.value.do{ |x|
				case
				{x == 'colour'}{ list.add(\verb) }
				// {x == 'size'}{ list.add(\delay) }
				{x == 'opinion'}{ list.add(\echo) }
				/*{x == 'quantity'}{ list.add() }
				{x == 'texture'}{ list.add() }
				{x == 'age'}{ list.add() }
				{x == 'weight'}{ list.add() }*/
				{x == 'state'}{ list.add(\FreeVerb2x2) }
				;
			};
			~phrase.fx_list.value_(list);
		}{
			~phrase.fx_list.value_([]);
		}
	}
);

// initialize phrase FX
// receives trigger from ~phrase_init
~fx_init.remove;
~fx_init = SimpleController(~phrase.fx_builder).put(
	\init, { |values, tag, args|
		var id = args[0];
		var group = args[1];
		var server = args[2];
		var fx_bus = args[3];
		var main_out = ~phrase.out.value;

		// if the fx list is not empty, create the FX chain
		if (~phrase.fx_list.value.size > 0){
			~phrase.fx_list.value.do{ |fx_name|
				~phrase.fx_maker.(id, group, server, fx_bus, fx_name)
			}
		};
		// always instantiate a monitoring fx as the last element in a chain
		Pdef((\fxMonitor_++id).asSymbol,
			( type: \on, instrument: \monitor,
				server: server, group: group,
				addAction: 1, in: fx_bus, out:main_out)).play;

		// when all is done, trigger the phrase_builder
		~phrase.main_builder.changed(\init,[id, group, server, fx_bus]);
	}
);

// build the whole phrase
// receives trigger from ~fx_init
~phrase_builder.remove;
~phrase_builder = SimpleController(~phrase.main_builder).put(
	\init, { |values, tag, args|
		var id = args[0];
		var group = args[1];
		var server = args[2];
		var fx_bus = args[3];
		var tempo_grid = ~phrase.tempo_grid.value;

		// add phrase to the Stanza's 'phrases' list
		// surround everything in a Pstretch so that punctuation can "stretch" silences accordingly
		// use the custom class PbdefClean which is a Pbindef with a cleanup function

		~stanza.phrases.value.add(
			Pfset({
				~buf=	Buffer.readChannel(server,"/Volumes/Archive1/Sample Libraries/SuperCollider Recordings/SC-2020_Dec/Ircam/ircam_beat-28(FFT-singleLow).wav" , channels:0);
			},
			Pstretch(
				Pdefn((\punct_stretch++id).asSymbol),
				/*					Pbindef(
				// name
				(\player_++id).asSymbol,
				// PbindProxy
				\server, server,
				\group, group,
				\addAction, 0, // place at head of group
				\dur, tempo_grid.reciprocal* Pdefn((\syllab_weight_++id).asSymbol),
				// \degree, Pshuf([1,3,5,2,6],2)*2,
				\degree, Pshuf([1,3,5,2,6],inf)*Pdefn((\syllab_stress_++id).asSymbol),
				\octave, Pgate(Pfunc{[4,5,6,7].choose}),
				\amp, 0.05 * Pdefn((\punct_rest++id).asSymbol),
				\pan, Pwhite(-1,1),
				\scale, Pfunc{topEnvironment[\stanza].scale},
				\out, fx_bus.index
				)*/
				Pbindef(
					(\player_++id).asSymbol,
					\instrument, Pstutter(4,Pshuf([\trig_buf,\pulse_noizy,\wire,\sine_arp,\ringz_space,\bufRd, \for_ur_joy,\feed_flageolet,\feed_low,\drone1,\minor1,\siren],inf)),
					\bufnum, Pfunc{|ev| ev.buf.normalize.bufnum},
					\server, server,
					\group, group,
					\addAction, 0, // place at head of group
					\dur, tempo_grid.reciprocal* Pdefn((\syllab_weight_++id).asSymbol),
					// \degree, Pshuf([1,3,5,2,6],2)*2,
					// \degree, Pshuf([1,3,5,2,6],inf)*Pdefn((\syllab_stress_++id).asSymbol),
					\degree, Pdefn((\pitch_collection_++id).asSymbol).trace,
					// \detune, Pdefn((\syllab_stress_++id).asSymbol),
					// \octave, Pgate(Pfunc{[4,5,6,7].choose}),
					\amp, (0.25 * Pdefn((\punct_rest++id).asSymbol))*0.5,
					\pan, Pwhite(-1,1),
					\scale, Pfunc{topEnvironment[\stanza].scale.value},
					\out, fx_bus.index
				)
			)
			,		//cleanup function:
			{ var time=3;
				fork{
					group.release(time);
					(time+1).wait;
					fx_bus.free;
					group.free;
					~buf.free;
					// clear phrase Pdefs
					Pdef.all.keys.do{ |key,i|
						if (key.asString.contains(id.asString)) { Pdef(key).remove}
					};
					// clear phrase Pdefns
					Pdefn.all.keys.do{ |key,i|
						if (key.asString.contains(id.asString)) { Pdefn(key).remove}
					};
				}
			}
			)
		);

		~stanza.phrases.changed(\update);
	}
);

);





~phrase.tempo_grid.value_(4)

~stanza.phrases.value.asArray
Pseq(~stanza.phrases.value.asArray).play(quant:1)
~stanza.phrases.value
~stanza.id.value
~stanza.mode.value


~phrase.id.value_(~phrase.id.value+1).changed(\init);
~phrase.id.value_(~phrase.id.value+1).changed(\init);
~phrase.id.value_(~phrase.id.value+1).changed(\init);
~phrase.id.value
Pdef.clear;
Pdefn.clear;
Pdef.gui;
Pdefn.all.keys;

Pdefn(\syllab_stress_17_1).asCode

Pdefn.all.keys.do{ |key,i| if (key.asString.contains("7_2")) { Pdefn(key).remove}};

Pdef.modulateAll(\mtranspose, Pstep(Pseq([5,2,-2],inf),8), \scale, Scale.major.tuning_(Tuning.werckmeister))
Pdef.modulateAll(\mtranspose, 0, \scale, Scale.major.tuning_(Tuning.werckmeister))
Pdef.modulateAll(\detune, PXLine(1,200,20))
Pdef.modulateAll(\detune, PXLine(200,1,80))
Pdef.modulateAll(\detune, PLFTri(4,0,200,0))
Pdef.modulateAll(\detune, 0)
Pdef.modulateAll(\amp, 0.001)

