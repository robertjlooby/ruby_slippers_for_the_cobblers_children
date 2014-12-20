package ruby.support;
import ruby.Bootstrap;
import ruby.Interpreter;
import ruby.ds.World;
import ruby.ds.Errors;
import ruby.ds.objects.*;
import haxe.PosInfos;

using ruby.LanguageGoBag;

class TestCase extends haxe.unit.TestCase {
  public var world:ruby.World;
  public var interpreter:Interpreter;

  function rInspect(obj:RObject):String {
    if(obj == null) return 'Haxe null';

    var klass = switch(obj) {
      case {klass: k}: k;
      case _: throw "no kass here: " + obj;
    }

    if(klass.name == 'Class') {
      var tmp:Dynamic = obj;
      var objClass:RClass = tmp;
      return objClass.name;
    } else if(klass.name == 'String') {
      var tmp:Dynamic = obj;
      var objString:RString = tmp;
      return '"'+objString.value+'"'; // will do for now
    } else {
      return "#<" + obj.klass.name + ">";
    // } else {
    //   return "" + obj; // :D
    }
  }

  override function setup() {
    var worldDs = ruby.Bootstrap.bootstrap();
    world       = new ruby.World(worldDs);
    interpreter = new Interpreter(worldDs);
  }

  function rEqual(l:RObject, r:RObject):Bool {
    return rInspect(l) == rInspect(r);
  }

  function rAssertEq(expected:RObject, actual:RObject, ?c:haxe.PosInfos) : Void {
		currentTest.done = true;
		if (rEqual(expected, actual)) return;
    currentTest.success = false;
    currentTest.error   = "expected '"  + rInspect(expected) +
                          "' but was '" + rInspect(actual)   + "'";
    currentTest.posInfos = c;
    throw currentTest;
  }

  function assertLooksKindaSimilar<T>(a: T, b:T, ?pos:haxe.PosInfos):Void {
    assertEquals(Std.string(a), Std.string(b), pos);
  }

  function assertInObjectSpace(obj:RObject, ?pos:haxe.PosInfos):Void {
    currentTest.done = true;
    for(potential in world.objectSpace)
      if(potential == obj) return;
    currentTest.success = false;
    currentTest.error = "Expected "+ rInspect(obj) + " to be in ObjectSpace, but it wasn't!";
      throw currentTest;
  }

  function addCode(rawCode:String):Void {
    var ast = ParseRuby.fromCode(rawCode);
    interpreter.addCode(ast);
  }

  // sigh, constantly fucking fighting this type system, and making some shitty tradeoffs.
  // e.g. instead of returning a subtype of Errors, we can only catch Errors, b/c no way that I can tell
  // what type you're catching at compile time or fucking something
  function assertThrows(fn:Void->Void, ?c:PosInfos):Void {
		currentTest.done     = true;
    try { fn(); } catch(e:Errors) return;
    currentTest.success  = false;
    currentTest.error    = "Expected " + Errors + " to be thrown";
    currentTest.posInfos = c;
    throw currentTest;
  }

  function assertNextExpressions(expected:Array<RObject>, ?c:PosInfos) {
    currentTest.done = true;
    var actual:Array<RObject> = [];
    while(interpreter.isUnfinished) {
      actual.push(interpreter.nextExpression());
    };
    for(pair in expected.zip(actual)) rAssertEq(pair.l, pair.r);
    if(expected.length <= actual.length) return
    currentTest.success  = false;
    currentTest.error    = "Expected at least " + expected.length + " expressions, but there were " + actual.length;
    currentTest.posInfos = c;
    throw currentTest;
  }
}