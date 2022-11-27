// UTF-8 chain of characters
class String {
  ::from_utf8(content: [i8]);
  concat(value: String) String;
  length() usize;
  collect() [i8];
}

spe String {
  // TODO how to optimize immutable classes?
  impl {
    struct {
      content: [i8],
    }
    ::from_utf8 {
      self.content = content;
    }
    concat {
      result :: collect() ++ value.collect(); // Array concatenation
      return String::new(result);
    }
    length -> content.length();
    collect -> self.content.clone();
  }
}

test "String.concat" {
  string := "Hello";
  string = string.concat(" World");
  assert string == "Hello World";
}