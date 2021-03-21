(
~phrase= (
	id: Ref(0),
	poly: Ref(false), // affects Pbindef players
	syll_length: Ref([]),
	syll_stress: Ref([]),
	syll_weight: Ref([]),
	num_words: 0,
	adjs: Ref([]),
	nouns: Ref([]),

	instr: Ref([]),
	pitch_material: Ref([]),
	scale: Scale.major,
	steps_octave: 12,
	stack: Ref(true), // affects Pdefns // wait until the end of phrase or not
	recursion: Ref(true), // affects Pbindef players

	fx:Ref([]),
	all_srvrs: { Server.allRunningServers },
	server: Ref(nil),
	group_main: Ref(nil),
	group_id: Ref(0),
	fx_bus: Ref(nil),
	fx_bus_index: Ref(nil),
	out: Ref(0)
);
);
~phrase.stack.value_(false)
~phrase.stack.value_(true)
~phrase.stack.value
~phrase.keys

~phrase.server
~phrase.group_main.value
~phrase.group_id
~phrase.fx_bus
~phrase.fx_bus_index
~phrase.fx.value_(12)
~phrase.use{ ~server}

~server

(
~phrase_init.remove;
~phrase_init = SimpleController(~phrase.id).put(
	\init, { |values, tag, args|
		var all_srvrs, choose, selected, group, bus;
		// select the most chilled Server :)
		all_srvrs= ~phrase.all_srvrs.value.asArray;
		choose = all_srvrs.minIndex({ |item| item.avgCPU.round });
		selected = all_srvrs[choose]; // selected Server
		~phrase.server.value_(selected);

		// create main Group + fx_bus
		fork{
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
			selected.sync;

			// start init of selected FX
			~phrase.fx.changed(\init);
			{"init done!".postln}.defer(0.5);
		};

	}
));





Pcleanup(
	{"can free".debug },
	Pbind( \degree, Pseq([0], inf), \dur, Pseq([1],inf), \amp, 0.1)
)


(
~fx_init.remove;
~fx_init = SimpleController(~phrase.fx).put(
	\init, { |values, tag, args|
		var dom;
		var id = ~phrase.id.value.asSymbol;
		var group = ~phrase.group_main.value;
		var server = ~phrase.server.value;
		var wrapper = { |pat|
			Prout { |inval|
				var stream = pat.asStream;
				var cleanup = EventStreamCleanup.new;
				var outval;
				// var event = inval.copy;
				cleanup.addFunction(inval, { var time=3;
					fork{ group.release(time);
						(time+1).wait;
						group.free;}
				});

				while {
					outval = stream.next(inval);
					outval.notNil;
				} {
					cleanup.update(outval);
					inval = outval.yield;
				};

				cleanup.exit(inval);
			}

		};

		Pdef(\echo_++id.asSymbol,
			( type: \on, instrument: \echo,
				server: server, group: group,
				addAction: 1, out: ~phrase.fx_bus_index.value)).play;
		/*
		Pdef(\verb_++id,
		\type, \on, \instrument, \verb,
		\server, ~phrase.server.value, \group, ~phrase.group_main.value,
		\addAction, 1, \out, ~phrase.fx_bus_index.value).play;
		*/
		Pdef(\fxMonitor_++id.asSymbol,
			( type: \on, instrument: \monitor,
				server: server, group: group,
				addAction: 1, in: ~phrase.fx_bus_index.value, out:0)).play;

		{"ti egine???".postln}.defer(0.5);
		// ~phrase.instr.value_(

		dom = wrapper.(
			Pbind(
				\server, server,
				\group, group,
				\addAction, 0,
				// \group, Pfunc({Group.new}),
				\dur, 0.313,
				\degree, Pshuf([0,2,4,5]+7,inf),
				\amp, 0.01,
				\pan, Pwhite(-1,1),
				\scale, Pfunc{topEnvironment[\phrase].scale},
				\out, ~phrase.fx_bus_index.value
		));

		Pdef(\player++id.asSymbol,dom ).play(quant:1);
		// )
	}
))


(
~fx_init.remove;
~fx_init = SimpleController(~phrase.fx).put(
	\init, { |values, tag, args|
		var dom;
		var id = ~phrase.id.value.asSymbol;
		var group = ~phrase.group_main.value;
		var server = ~phrase.server.value;
		/*		var wrapper = { |pat|
		Prout { |inval|
		var stream = pat.asStream;
		var cleanup = EventStreamCleanup.new;
		var outval;
		// var event = inval.copy;
		cleanup.addFunction(inval, { var time=3;
		fork{ group.release(time);
		(time+1).wait;
		group.free;}
		});

		while {
		outval = stream.next(inval);
		outval.notNil;
		} {
		cleanup.update(outval);
		inval = outval.yield;
		};

		cleanup.exit(inval);
		}

		};*/

		Pdef(\echo_++id.asSymbol,
			( type: \on, instrument: \echo,
				server: server, group: group,
				addAction: 1, out: ~phrase.fx_bus_index.value)).play;
		/*
		Pdef(\verb_++id,
		\type, \on, \instrument, \verb,
		\server, ~phrase.server.value, \group, ~phrase.group_main.value,
		\addAction, 1, \out, ~phrase.fx_bus_index.value).play;
		*/
		Pdef(\fxMonitor_++id.asSymbol,
			( type: \on, instrument: \monitor,
				server: server, group: group,
				addAction: 1, in: ~phrase.fx_bus_index.value, out:0)).play;

		{"ti egine???".postln}.defer(0.5);
		// ~phrase.instr.value_(
		Pdef(\player++id.asSymbol,
			Pcleanup(
				Pbind(
					\server, server,
					\group, group,
					\addAction, 0,
					// \group, Pfunc({Group.new}),
					\dur, 0.313,
					\degree, Pshuf([0,2,4,5]+7,inf),
					\amp, 0.01,
					\pan, Pwhite(-1,1),
					\scale, Pfunc{topEnvironment[\phrase].scale},
					\out, ~phrase.fx_bus_index.value
				)/*,
				{ var time=3;
				fork{ group.release(time);
				(time+1).wait;
				group.free}
				}*/
		)).play(quant:1);

		// Pdef(\player++id.asSymbol,dom ).play(quant:1);
		// )
	}
))






~phrase.id
~phrase.group_main.value.deepFree
~phrase.instr.value.asCompileString

~phrase.id.value_(~phrase.id.value+1).changed(\init);
Pdef.all.keys;
Pdef.all.values[0].pattern
Pdef.all.values[3].pattern.type_(\off)
Pdef.all.values[3].pattern.release
Pdef.all.values[1].set(\type, \off)
Pdef(\player32).play
Pdef.clear
Pdef.gui
Pdef(\fxMonitor_14).keys
Pdef("fxMonitor_4")

Pfset ??????????
Pspawner


u=( type: \on, instrument: \monitor,
	server: ~phrase.server.value, group: ~phrase.group_main.value,
	addAction: 1, in: ~phrase.fx_bus_index.value).play.collect({|event| ~mon = event; });

~mon.class
u.free


~lastBassEvent.class

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
		var pos = ("pos"++~phrase.id).asSymbol; // create a new name every time

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
