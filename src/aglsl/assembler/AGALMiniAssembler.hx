///<reference path="../../away/_definitions.ts" />
package aglsl.assembler;
import haxe.ds.StringMap.StringMap;
import  aglsl.assembler.ERegTools; 
using aglsl.assembler.ERegTools;
class AGALMiniAssembler {

	public var r : StringMap<Part>;
	public var cur : Part;
	public function new() {
		this.r = new StringMap<Part>();
		this.cur = new Part();
	}

	public function assemble(source : String, ext_part : String = null, ext_version : Int = 0) : StringMap<Part> {
		if(ext_version==0)  {
			ext_version = 1;
		}
		if(ext_part != null)  {
			this.addHeader(ext_part, ext_version);
		}
		
		var reg:EReg=~/[\n\r]+/g;
		var lines:Array<String> =reg.split(source);
		// handle breaks, then split into lines
		for (  i in 0...lines.length) {
			this.processLine(lines[i], i);
		}

		return this.r;
	}

	function processLine(line : String, linenr : Int) : Void {
		var startcomment = line.indexOf("//");
		// remove comments
		if(startcomment != -1)  {
			line = line.substr(0, startcomment);
		}
		var reg:EReg=~/^\s+|\s+$/g;
		line = line.replace(reg, "");
		// remove outer space
		if(!(line.length > 0))  {
			return;
		}
		reg=~/<.*>/g;
		var optsi = line.search(reg);
		// split of options part <*> if there
		var opts = null;
		if (optsi != -1)  {
			reg=~/([\w\.\-\+]+)/gi;
			opts = line.substr(optsi).match(reg);
			line = line.substr(0, optsi);
		}
		reg=~/([\w\.\+\[\]]+)/gi;
		var tokens = line.match(reg);
		// get tokens in line
		if( tokens.length < 1)  {
			if(line.length >= 3)  {
				//trace("Warning: bad line " + linenr + ": " + line);
			}
			return;
		}
		var _sw0_ = (tokens[0]);
		switch(_sw0_) {
		case "part":
			this.addHeader(tokens[1], Std.parseInt(tokens[2]) /* WARNING check type */);
		case "endpart":
			if(this.cur==null)  {
				throw "Unexpected endpart";
			}
			this.cur.data.position = 0;
			this.cur = null;
			return;
			if(this.cur==null)  {
				//trace("Warning: bad line " + linenr + ": " + line + " (Outside of any part definition)");
				return;
			}
			if(this.cur.name == "comment")  {
				return;
			}
			var op : Opcode =   cast(OpcodeMap.map.get(tokens[0]), Opcode)  ;
			if(op==null)  {
				throw "Bad opcode " + tokens[0] + " " + linenr + ": " + line;
			}
			this.emitOpcode(this.cur, op.opcode);
			var ti : Int = 1;
			if(op.dest!=null && op.dest != "none")  {
				if(!this.emitDest(this.cur, tokens[ti++], op.dest))  {
					throw "Bad destination register " + tokens[ti - 1] + " " + linenr + ": " + line;
				}
			}

			else  {
				this.emitZeroDword(this.cur);
			}

			if(op.a!=null && op.a.format != "none")  {
				if(!this.emitSource(this.cur, tokens[ti++], op.a)) throw "Bad source register " + tokens[ti - 1] + " " + linenr + ": " + line;
			}

			else  {
				this.emitZeroQword(this.cur);
			}

			if(op.b!=null && op.b.format != "none")  {
				if(op.b.format == "sampler")  {
					if(!this.emitSampler(this.cur, tokens[ti++], op.b, opts))  {
						throw "Bad sampler register " + tokens[ti - 1] + " " + linenr + ": " + line;
					}
				}

				else  {
					if(!this.emitSource(this.cur, tokens[ti++], op.b))  {
						throw "Bad source register " + tokens[ti - 1] + " " + linenr + ": " + line;
					}
				}

			}

			else  {
				this.emitZeroQword(this.cur);
			}

		default:
			if(this.cur==null)  {
				//trace("Warning: bad line " + linenr + ": " + line + " (Outside of any part definition)");
				return;
			}
			if(this.cur.name == "comment")  {
				return;
			}
			var op : Opcode =   cast(OpcodeMap.map.get(tokens[0]), Opcode)  ;
			if(op==null)  {
				throw "Bad opcode " + tokens[0] + " " + linenr + ": " + line;
			}
			this.emitOpcode(this.cur, op.opcode);
			var ti : Int = 1;
			if(op.dest!=null && op.dest != "none")  {
				if(!this.emitDest(this.cur, tokens[ti++], op.dest))  {
					throw "Bad destination register " + tokens[ti - 1] + " " + linenr + ": " + line;
				}
			}

			else  {
				this.emitZeroDword(this.cur);
			}

			if(op.a !=null&& op.a.format != "none")  {
				if(!this.emitSource(this.cur, tokens[ti++], op.a)) throw "Bad source register " + tokens[ti - 1] + " " + linenr + ": " + line;
			}

			else  {
				this.emitZeroQword(this.cur);
			}

			if(op.b!=null && op.b.format != "none")  {
				if(op.b.format == "sampler")  {
					if(!this.emitSampler(this.cur, tokens[ti++], op.b, opts))  {
						throw "Bad sampler register " + tokens[ti - 1] + " " + linenr + ": " + line;
					}
				}

				else  {
					if(!this.emitSource(this.cur, tokens[ti++], op.b))  {
						throw "Bad source register " + tokens[ti - 1] + " " + linenr + ": " + line;
					}
				}

			}

			else  {
				this.emitZeroQword(this.cur);
			}

		}
	}

	public function emitHeader(pr : Part) : Void{
		pr.data.writeByte(0xa0);
		// tag version
		pr.data.writeUnsignedInt(pr.version);
		if(pr.version >= 0x10)  {
			pr.data.writeByte(0);
			// align, for higher versions
		}
		pr.data.writeByte(0xa1);
		// tag program id
		var _sw1_ = (pr.name);
		switch(_sw1_) {
		case "fragment":
			pr.data.writeByte(1);
		case "vertex":
			pr.data.writeByte(0);
		case "cpu":
			pr.data.writeByte(2);
		default:
			pr.data.writeByte(0xff);
		}
	}

	public function emitOpcode(pr : Part, opcode) :Void{
		pr.data.writeUnsignedInt(opcode);
		//trace("Emit opcode: ", opcode);
	}

	public function emitZeroDword(pr : Part) : Void{
		pr.data.writeUnsignedInt(0);
	}

	public function emitZeroQword(pr : Part) :Void{
		pr.data.writeUnsignedInt(0);
		pr.data.writeUnsignedInt(0);
	}

	public function emitDest(pr : Part, token:String, opdest) : Bool {
		//console.log( 'aglsl.assembler.AGALMiniAssembler' , 'emitDest' , 'RegMap.map' , RegMap.map);
		var tmp:EReg = ~/([fov]?[tpocidavs])(\d*)(\.[xyzw]{1,4})?/i;
		var reg = token.match(tmp,3);
		// g1: regname, g2:regnum, g3:mask
		// console.log( 'aglsl.assembler.AGALMiniAssembler' , 'emitDest' , 'reg' , reg , reg[1] , RegMap.map[reg[1]] );
		// console.log( 'aglsl.assembler.AGALMiniAssembler' , 'emitDest' , 'RegMap.map[reg[1]]' , RegMap.map[reg[1]] , 'bool' , !RegMap.map[reg[1]] ) ;
		
		
		var _map : StringMap<Reg>=RegMap.map;
		if (!RegMap.map.exists(reg[1])) return false;
		if (Std.parseInt(reg[2]) == null) reg[2] = "0";
		 
		var em = {
			num : Std.int(Std.parseInt(reg[2])) ,
			code : RegMap.map.get(reg[1]).code,
			mask : this.stringToMask(reg[3]),

		};
		var tmp2:EReg = ~/([fov]?[tpocidavs])(\d*)(\.[xyzw]{1,4})?/i;
		tmp2.match(token);
		pr.data.writeShort(em.num);
		pr.data.writeByte(em.mask);
		pr.data.writeByte(em.code);
		//trace ( "  Emit dest: ", em );
		return true;
	}

	public function stringToMask(s : String) : Int {
		if(s == null) return 0xf;
		var r = 0;
		if(s.indexOf("x") != -1) r |= 1;
		if(s.indexOf("y") != -1) r |= 2;
		if(s.indexOf("z") != -1) r |= 4;
		if(s.indexOf("w") != -1) r |= 8;
		return r;
	}

	public function stringToSwizzle(s : String) : Int {
		if(s==null)  {
			return 0xe4;
		}
		var chartoindex = {
			x : 0,
			y : 1,
			z : 2,
			w : 3

		};
		var sw = 0;
		if(s.charAt(0) != ".")  {
			throw "Missing . for swizzle";
		}
		if(s.length > 1)  {
			sw |= Reflect.field(chartoindex,s.charAt(1));
		}
		if(s.length > 2)  {
			sw |= Reflect.field(chartoindex,s.charAt(2)) << 2;
		}

		else  {
			sw |= (sw & 3) << 2;
		}

		if(s.length > 3)  {
			sw |= Reflect.field(chartoindex,s.charAt(3)) << 4;
		}

		else  {
			sw |= (sw & (3 << 2)) << 2;
		}

		if(s.length > 4)  {
			sw |= Reflect.field(chartoindex,s.charAt(4)) << 6;
		}

		else  {
			sw |= (sw & (3 << 4)) << 2;
		}

		return sw;
	}

	public function emitSampler(pr : Part, token:String, opsrc, opts : Array<Dynamic>) : Bool {
		var tmp:EReg = ~/fs(\d*)/i;
		var reg :Array<String>= token.match(tmp);
		// g1:regnum
		if(reg.length<1)  {
			return false;
		}
		if (reg[1] == null) reg[1] = "0";
		pr.data.writeShort(Std.parseInt(reg[1]));
		pr.data.writeByte(0);
		// bias
		pr.data.writeByte(0);
		var samplerbits : Int = 0x5;
		var sampleroptset : Int = 0;
		var i : Int = 0;
		while (i < opts.length) {
			 
			 
			var o : Sampler =   cast(SamplerMap.map.get(opts[i].toLowerCase()), Sampler) ;
			//console.log( 'AGALMiniAssembler' , 'emitSampler' , 'SampleMap opt:' , o , '<-------- WATCH FOR THIS');
			if(o!=null)  {
				if(((sampleroptset >> o.shift) & o.mask) != 0)  {
					//trace("Warning, duplicate sampler option");
				}
				sampleroptset |= o.mask << o.shift;
				samplerbits &= ~(o.mask << o.shift);
				samplerbits |= o.value << o.shift;
			}

			else  {
				//trace("Warning, unknown sampler option: ", opts[i]);
				// todo bias
			}

			i++;
		}
		pr.data.writeUnsignedInt(samplerbits);
 
		return true;
	}

	public function emitSource(pr : Part, token : String, opsrc) : Bool {
		var tmp:EReg = ~/vc\[(v[tcai])(\d+)\.([xyzw])([\+\-]\d+)?\](\.[xyzw]{1,4})?/i;
		var indexed:Array<String> = token.match(tmp,4);
		// g1: indexregname, g2:indexregnum, g3:select, [g4:offset], [g5:swizzle]
		var reg;
		if(indexed.length>0)  {
			if(!RegMap.map.exists(indexed[1]))  {
				return false;
			}
			var selindex = {
				x : 0,
				y : 1,
				z : 2,
				w : 3
			};
			 
			var em = {
				num : Std.parseInt(indexed[2]) | 0,
				code : RegMap.map.get(indexed[1]).code,
				swizzle : this.stringToSwizzle(indexed[5]),
				select : Reflect.field(selindex,indexed[3]),
				offset :  Std.parseInt(indexed[4]) | 0
			};
			pr.data.writeShort(em.num);
			pr.data.writeByte(em.offset);
			pr.data.writeByte(em.swizzle);
			pr.data.writeByte(0x1);
			// constant reg
			pr.data.writeByte(em.code);
			pr.data.writeByte(em.select);
			pr.data.writeByte(1 << 7);
		}

		else  {
			tmp = ~/([fov]?[tpocidavs])(\d*)(\.[xyzw]{1,4})?/i;
			reg = token.match(tmp,3);
			// g1: regname, g2:regnum, g3:swizzle
			if(!RegMap.map.exists(reg[1]))  {
				return false;
			}
			 
			var em = {
				num : Std.parseInt(reg[2]) | 0,
				code : RegMap.map.get(reg[1]).code,
				swizzle : this.stringToSwizzle(reg[3])
			};
			pr.data.writeShort(em.num);
			pr.data.writeByte(0);
			pr.data.writeByte(em.swizzle);
			pr.data.writeByte(em.code);
			pr.data.writeByte(0);
			pr.data.writeByte(0);
			pr.data.writeByte(0); 
			//trace( "  Emit source: ", em, pr.data.length );
		}

		return true;
	}

	public function addHeader(partname : String, version : Int) :Void{
		if(version==0)  {
			version = 1;
		}
		if(this.r.exists(partname) == false)  {
			this.r.set(partname,new Part(partname, version));
			this.emitHeader(this.r.get(partname));
		}

		else if(this.r.get(partname).version != version)  {
			throw "Multiple versions for part " + partname;
		}
		this.cur = this.r.get(partname);
	}

}

