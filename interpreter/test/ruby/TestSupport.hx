package ruby;

import ruby.ds.objects.RObject;

class TestSupport extends ruby.support.TestCase {
  function assertInspects(obj:RObject, expected:String, ?pos:haxe.PosInfos) {
    assertEquals(expected, rInspect(obj));
  }
  function testInspect() {
    assertInspects(world.stringLiteral("abc"), '"abc"');
  }

  function testAssertNextExpressionsWithFewer() {
    addCode("true; nil; true");
    assertNextExpressions([
      world.rubyTrue,
      world.rubyNil,
      world.rubyTrue,
    ]);
  }

  function testAssertNextExpressionsWithExact() {
    addCode("true; nil; true");
    assertNextExpressions([
      world.rubyTrue,
      world.rubyNil,
      world.rubyTrue,
      world.rubyTrue, // list evaluates to last expression in it
    ]);
  }
}