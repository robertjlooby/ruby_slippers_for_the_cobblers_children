package ruby4.ast;

class NilAst extends Ast {
  override public function get_isNil() return true;
  override public function toNil() return this;
}
