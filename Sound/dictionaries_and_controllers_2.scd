

(
~stanza = (
	id: Ref(0),
	mode: Ref('seq'),
	num_of_phrases: Ref(0),
	scale: Scale.major,
	steps_octave: Ref(12),
	phrases: Ref(List.new)
);
);

(
// initialize new Stanza
// for every new Stanza-> reset its Phrases_List
// reset Phrase trig counter
~stanza_init.remove;
~stanza_init = SimpleController(~stanza.id).put(
	\init, {|values, tag, args|
		~stanza.phrases.value_(List.new);
		~phrase.trig.value_(0);
	};
);


// make sure all phrases are loaded on to the Servers before the playback starts
// underlying Logic: receive the num_of_phrases and compare if the size of the
// loaded-phrases-list is the same. If yes, then start playback.
// every new phrase (~phrase_builder) triggers this controller when done.
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

~phrase.id
~phrase.num_words
~phrase.adjectives

(
~phrase= (
	trig: Ref(0),
	id: Ref('symbol'),

	syll_length: Ref([]),
	syll_stress: Ref([]),
	syll_weight: Ref([]),
	num_words: {|self| self.syll_length.value.size },
	adjectives: Ref([]),
	nouns: Ref([]),

	instr: Ref([]),
	pitch_material: Ref([]),
	pitch_offset: Ref(0),

	stack: Ref(true), // affects Pdefns // wait until the end of phrase or not
	recursion: Ref(true), // affects Pbindef players

	all_srvrs: { Server.allRunningServers },
	server: Ref(nil),
	group_main: Ref(nil),
	group_id: Ref(0),

	fx_list: Ref([]),
	fx_maker: { // it is a double function so it doesn't evaluate as soon as it is called !
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
);

~phrase.adjectives

(

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



// id controller
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
		values.value.do{ |i|
			if (i.isKindOf(Integer)){
				new_list.add(i)
			}{
				new_list.add(Rest(1))
			}
		};
		Pdefn((\syllab_length_++id).asSymbol,Pseq(new_list.asArray, 1));
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
		values.value.do{ |i|
			if (i.isKindOf(Symbol)){
				if(i != 'Rest(0)') { i.asString.do{ |x|
					// x.class.postln;
					case
					{x == $P}{ new_list.add(1.0)} // Primary stress
					{x == $S}{ new_list.add(0)} // Secondary stress
					{x == $U}{ new_list.add(0)} // Unstressed
				}
				}{
					// new_list.add(Rest(0))
					// new_list.add(0)
				}
			}
		};
		Pdefn((\syllab_stress_++id).asSymbol,Pseq(new_list.asArray, 1));
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

		// new_list.add(0); // init list
		values.value.do{ |i|
			if (i.isKindOf(Symbol)){
				if(i != 'Rest(0)') { i.asString.do{ |x|
					// x.class.postln;
					case
					{x == $H}{ new_list.add(2.0)} // heavy
					{x == $L}{ new_list.add(1.0)} // light
				}
				}{
					new_list.add(0)
				}
			}
		};
		Pdefn((\syllab_weight_++id).asSymbol, Pseq(new_list.asArray, inf));
		("weights are: "++ values).postln;
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
				addAction: 1, in: fx_bus, out:0)).play;

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


		~stanza.phrases.value.add(
			PbdefClean(
				//cleanup function
				{ var time=3;
					fork{
						group.release(time);
						(time+1).wait;
						fx_bus.free;
						group.free;
						// clear phrase Pdefs
						Pdef.all.keys.do{ |key,i|
							if (key.asString.contains(id.asString)) { Pdef(key).remove}
						};
						// clear phrase Pdefns
						Pdefn.all.keys.do{ |key,i|
							if (key.asString.contains(id.asString)) { Pdefn(key).remove}
						};
					}
				},
				// name
				(\player_++id).asSymbol,
				// Pbind
				\server, server,
				\group, group,
				\addAction, 0,
				\dur, 0.25* Pdefn((\syllab_weight_++id).asSymbol),
				// \degree, Pshuf([1,3,5,2,6],2)*2,
				\degree, Pseq([2,3,6],inf)+Pdefn((\syllab_stress_++id).asSymbol)*Pshuf([1,2],inf),
				\amp, 0.05,
				\pan, Pwhite(-1,1),
				\scale, Pfunc{topEnvironment[\stanza].scale},
				\out, fx_bus.index
				/*,
				{ var time=3;
				fork{ group.release(time);
				(time+1).wait;
				group.free}
				}*/
		));
		~stanza.phrases.changed(\update);
	}
);

);


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

(50-60).midiratio
(
SynthDef(\help_PlayBuf, {| out = 0, bufnum = 0, freq=1, pos=0 , gate=1, amp=0.1 |
	var env = Linen.kr(gate, 0.0005, amp, 0.7, 2);
	OffsetOut.ar(out,
		PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum)*(freq.cpsmidi-60).midiratio, startPos:pos, loop: 1.0)!2 * env
	)
}).add;
)
b.free
b = Buffer.readChannel(s,"/Users/Makis/Documents/Tidal/Dirt/samples/brane2/13.wav",channels:0);
b.numFrames
(Pbindef(\bufy,
	\instrument, \help_PlayBuf,
	\bufnum, b.bufnum,
	\degree, Pseq([0,1,2],inf),
	\pos, Pwhite(0.0,b.numFrames*0.25,inf),
	\dur, 0.02,
	\amp,0.1
))
Pbindef(\bufy).play
Pbindef(\bufy).stop
Pbindef(\bufy).release(4)
Pbindef(\bufy, \gtranspose, Pseq([1,4,1,2,4,7,4,3,12]*10.neg,inf))







(
~length_ctrl.remove;
~length_ctrl=SimpleController(~phrase.syll_length).put(
	\value, {|values, tag, args|
		// Here I work around the problem that ".condition_" imposes
		// on the included Pdefns. quickFix= every time place the incoming
		// list into a new List, so that the new Pdefn can register correctly
		// the List.size and use it as "wait" argument in its conditional execution.
		var newList = List.new;
		var local_env = ();
		var pos = ("pos"++~phrase.id.value).asSymbol; // create a new name every time

		if(~phrase.stack.value==true){// check if phrases are played throughout before new phrase begins
			// i.e. sequenced/stacked playback
			values.value.do{ |i|
				if (i.isKindOf(Integer)){
					newList.add(i)
				}{
					newList.add(Rest(1))
			}};
			local_env.put(pos, newList);// store the new list in a new local env
			local_env.postln;
			("lenghts are: "++ values.value).postln;
			Pdefn(\sylab_length, Pseq(local_env[pos].asArray, 1)).condition_({ |val,i|
				var size = local_env[pos].size;
				("New Pattern starts in ..."++ (size- i)).postln;
				i.postln%size==0;
			});
		}{ // or, switch to new Pdefn immediately
			values.value.do{ |i|
				if (i.isKindOf(Integer)){
					newList.add(i)
				}{
					newList.add(Rest(1))
			}};
			local_env.put(pos, newList);
			local_env.postln;
			("lenghts are: "++ values.value).postln;
			Pdefn(\sylab_length, Pseq(local_env[pos].asArray, 1)).reset// no conditional trigger here!
		};
	}
);

);

~length_ctrl.put(\fafa, {|a,b,c| "haha".postln})


currentEnvironment.keys

~phrase.syll_length.value_([1,2,5,3,4]).changed(\value)
~phrase.id
~checker= List.new;
~checker[2].value.class

~phrase
