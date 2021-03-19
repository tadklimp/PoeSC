(
~phrase= (
	id: 0,
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
	server: {|self| // select the least busy Server available
		var active = self.all_srvrs.value.asArray;
		var select = active.minIndex({|item|
			item.avgCPU.round });
		active[select];
	},
	group_main: {|self|
		var serv = self.server.value;
		var group = Group.new(serv);
		self.group_id = group.nodeID;
	},
	group_id: nil,
	fx_bus: {|self|
		var serv = self.server.value;
		var bus = Bus.audio(serv,2);
		self.fx_bus_index = bus.index;
		bus;
	},
	fx_bus_index:nil,
	out: 0
);

);
~phrase.stack.value_(false)
~phrase.stack.value_(true)
~phrase.stack.value
~phrase.postcs

~phrase.server
~phrase.group_main.value
~phrase.group_id
~phrase.fx_bus
~phrase.fx_bus_index
~phrase.use{ ~all_srvrs.()}

Server.allRunningServers.asArray.minIndex({|item| item.avgCPU.round });

g = Bus.audio(s,2)
g.index

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
			local_env.put(pos, newList);
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
		~phrase.id = ~phrase.id+1;
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
