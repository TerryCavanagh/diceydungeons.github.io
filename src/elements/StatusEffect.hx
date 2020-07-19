package elements;

import states.*;
import haxegon.*;
import elements.templates.StatusTemplate;

class StatusEffect{
	public function new(_type:String, v:Int, _fighter:Fighter){
		type = _type.toLowerCase();
		name = S.left(type, 1).toUpperCase() + S.removefromleft(type, 1);
		remove_at_endturn = false;
		selfinflicted = false;
		invisible = false;
		remove_at_startturn = false;
		fighter = _fighter;
		jinxcastby = null;
		
		scriptwheninflicted = "";
		scriptonanystatusinfliction = "";
		scriptbeforestartturn = "";
		scriptonstartturn = "";
		scriptonanyequipmentuse = "";
		scriptonanycountdownreduce = "";
		scriptendturn = "";
		
		var isjinx:Bool = (S.left(type, "jinx_".length) == "jinx_");
		if (isjinx){
			var jinxsplit:Array<String> = _type.split("|");
			type = jinxsplit[0];
			jinxname = StringTools.replace(jinxsplit[1], " ", "_");
			jinxtooltipdescription = jinxsplit[2];
			jinxscript = "";
			jinx = true;
			template = null;
			name = jinxname;
			symbol = "jinx";
			stacks = true;
			_displayvalue = value = v;
			remove_at_endturn = false;
			remove_at_startturn = false;
			invisible = false;
			
			updatedescription();
		}else{
			jinx = false; jinxname = ""; jinxcarddescription = ""; jinxtooltipdescription = ""; jinxscript = "";
			template = Gamedata.getstatustemplate(_type);
			if (template != null){
				name = template.displayname;
				symbol = template.symbol;
				stacks = template.stacks;
				if (stacks){
					value = v;
				}else{
					value = 1;
				}
				_displayvalue = value;
				remove_at_endturn = template.removeatendturn;
				remove_at_startturn = template.removeatstartturn;
				invisible = template.invisible;
				
				scriptwheninflicted = template.scriptwheninflicted;
				scriptonanystatusinfliction = template.scriptonanystatusinfliction;
				scriptbeforestartturn = template.scriptbeforestartturn;
				scriptonstartturn = template.scriptonstartturn;
				scriptonanyequipmentuse = template.scriptonanyequipmentuse;
				scriptonanycountdownreduce = template.scriptonanycountdownreduce;
				scriptendturn = template.scriptendturn;
				
				updatedescription();
			}
		}
		
		if (type == Status.VAMPIRE){
			if (Game.player != null){
				if (Game.player.name == "Bear"){
					description = ["Can only be killed with a wooden stake[;]", "or your bear hands."];
				}
			}
		}
		
		if (type == "infinite"){
			Combat.infinitecounter = 0;
		}
	}
	
	
	public function runwheninflictedscript(inflicted_type:String, inflicted_value:Int, f:Fighter){
		//This passes the name of the inflicted status in the "when" script, needed for "wheninflicted" and "onanystatusinfliction"
		fighter = f;
		Script.rungamescript(scriptwheninflicted, "status_" + inflicted_type, fighter, null, this, inflicted_value);
	}
	
	public function runonanystatusinflictionscript(inflicted_type:String, inflicted_value:Int, f:Fighter){
		//This passes the name of the inflicted status in the "when" script, needed for "wheninflicted" and "onanystatusinfliction"
		fighter = f;
		Script.rungamescript(scriptonanystatusinfliction, "status_" + inflicted_type, fighter, null, this, inflicted_value);
	}
	
	public function runscript(when:String, d:Int, ?e:Equipment = null){
		switch(when){
			case "beforestartturn":
				if (scriptbeforestartturn != "") Script.rungamescript(scriptbeforestartturn, "status_scriptbeforestartturn", fighter, null, this, d);
			case "onstartturn":
				if (scriptonstartturn != "") Script.rungamescript(scriptonstartturn, "status_scriptonstartturn", fighter, null, this, d);
			case "onanyequipmentuse":
				if (scriptonanyequipmentuse != "") Script.rungamescript(scriptonanyequipmentuse, "status_scriptonanyequipmentuse", fighter, e, this, d);
			case "onanycountdownreduce":
				if (scriptonanycountdownreduce != "") Script.rungamescript(scriptonanycountdownreduce, "status_scriptonanycountdownreduce", fighter, e, this, d);
			case "endturn":
				if (scriptendturn != "") Script.rungamescript(scriptendturn, "status_scriptendturn", fighter, null, this, d);
		}
	}
	
	public function updatedescription(){
		if (jinx){
			var jinxdescription:String = "";
			if (value == 1){
				jinxdescription = Locale.variabletranslate("In 1 turn[;] {jinxaction}.",
				 {
					 jinxaction: Locale.translate(jinxtooltipdescription)
				 });
			}else{
				jinxdescription = Locale.variabletranslate("In {numturns} turns[;] {jinxaction}.",
				 {
					 numturns: Std.string(displayvalue),
					 jinxaction: Locale.translate(jinxtooltipdescription)
				 });
			}
			
			if (S.isinstring(jinxdescription, "%VAR%")){
				jinxdescription = StringTools.replace(jinxdescription, "%VAR%", "" + jinxvar);
			}
			
			description = Game.splittrimandtranslate(jinxdescription);
		}else	if(template != null){
			description = Game.splittrimandtranslate(template.description);
			
			for (i in 0 ... description.length){
				description[i] = Game.statusstring(description[i], displayvalue);
			}
		}
	}
	
	public function toshortString():String{
		if (invisible) return "";
		if (symbol != ""){
			if(stacks){
				return "[" + symbol + "]" + Locale.translate(name) + "_" + displayvalue;
			}else{
				return "[" + symbol + "]" + Locale.translate(name);
			}
		}
		
		return name;
	}
	
	public function totinyString():String{
		if (invisible) return "";
		if (symbol != ""){
			if(stacks){
				return "[" + S.trimspaces(symbol) + "]" + displayvalue;
			}else{
				return "[" + S.trimspaces(symbol) + "]";
			}
		}
		
		return name;
	}
	
	public function add(v:Int){
		if (stacks){
			value += v;
		}else{
			value = Std.int(Geom.max(v, value));
		}
		displayvalue = value;
	}
	
	public function clone():StatusEffect{
		var st:StatusEffect = new StatusEffect(type, value, fighter);
		st.stacks = this.stacks;
		st.symbol = this.symbol;
		st.col = this.col;
		st.value = this.value;
		st.displayvalue = this.displayvalue;
		st.type = this.type;
		st.name = this.name;
		st.fighter = this.fighter;
		st.description = Game.clonetextarray(this.description);
		st.remove_at_endturn = this.remove_at_endturn;
		st.remove_at_startturn = this.remove_at_startturn;
		st.selfinflicted = this.selfinflicted;
		st.invisible = this.invisible;
		
		st.scriptwheninflicted = this.scriptwheninflicted;
		st.scriptonanystatusinfliction = this.scriptonanystatusinfliction;
		st.scriptbeforestartturn = this.scriptbeforestartturn;
		st.scriptonstartturn = this.scriptonstartturn;
		st.scriptonanyequipmentuse = this.scriptonanyequipmentuse;
		st.scriptonanycountdownreduce = this.scriptonanycountdownreduce;
		st.scriptendturn = this.scriptendturn;
		
		return st;
	}
	
	public function removenow(){
		fighter.removestatus(type);
	}
	
	public var displayvalue(get, set):Int;
	public var _displayvalue:Int;
	function get_displayvalue():Int{
		return _displayvalue;
	}
	
	function set_displayvalue(newval:Int):Int{
		if(newval != _displayvalue){
			_displayvalue = newval;
			updatedescription();
		}
		
		return _displayvalue;
	}
	
	public var stacks:Bool;
	public var symbol:String;
	public var col:Int;
	
	public var value:Int;
	
	public var type:String;
	public var name:String;
	public var description:Array<String>;
	public var remove_at_endturn:Bool;
	public var remove_at_startturn:Bool;
	public var selfinflicted:Bool;
	public var invisible:Bool;
	public var template:StatusTemplate;
	
	public var jinx:Bool;
	public var jinxname:String;
	public var jinxtooltipdescription:String;
	public var jinxcarddescription:String;
	public var jinxscript:String;
	public var jinxcastby:Fighter;
	public var jinxvar:Int;
	
	public var scriptwheninflicted:String;
	public var scriptonanystatusinfliction:String;
	public var scriptbeforestartturn:String;
	public var scriptonstartturn:String;
	public var scriptonanyequipmentuse:String;
	public var scriptonanycountdownreduce:String;
	public var scriptendturn:String;
	
	public var fighter:Fighter;
}