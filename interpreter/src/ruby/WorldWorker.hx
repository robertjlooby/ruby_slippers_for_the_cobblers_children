package ruby;

import ruby.ds.InternalMap;
import ruby.ds.objects.*;


class WorldWorker {
  public static inline function toplevelNamespace(worker:Worldly):RClass {
    return worker.world.toplevelNamespace;
  }

  public static inline function currentExpression(worker:Worldly):RObject {
    return worker.world.currentExpression;
  }

  public static function intern(worker:Worldly, name:String):RSymbol {
    var world = worker.world;
    if(!world.symbols.exists(name)) {
      var symbol:RSymbol = {name: name, klass: world.objectClass, ivars: new InternalMap()};
      world.symbols.set(name, symbol);
    }
    return world.symbols.get(name);
  }

  public static inline function currentBinding(worker:Worldly):RBinding {
    return worker.world.stack[0]; // FIXME
  }



  // these don't even use the world
  public static inline function hasMethod(worker:Worldly, methodBag:RClass, name:String):Bool {
    return methodBag.imeths.exists(name);
  }

  public static inline function localsForArgs(worker:Worldly, meth:RMethod, args:Array<RObject>):InternalMap<RObject> {
    return new InternalMap(); // FIXME
  }

  public static inline function getConstant(worker:Worldly, namespace:RClass, name:String):RObject {
    return namespace.constants.get(name);
  }

  public static inline function setConstant(worker:Worldly, namespace:RClass, name:String, object:RObject):RObject {
    namespace.constants.set(name, object);
    return object;
  }

  public static inline function getMethod(worker:Worldly, methodBag:RClass, methodName:String):RMethod {
    return methodBag.imeths.get(methodName);
  }

}