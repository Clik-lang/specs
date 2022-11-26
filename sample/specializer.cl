/////////////////////////////////
// Specializers & Templates //
/////////////////////////////////

Class Object{
  ::new();
  get() i32;
  set(value: i32);
}

// Specializers are attached to classes, and serve to change the implementation based on use.

spe Object {
  // Declarations are allowing in the specializer context
  get_count: i32 = 0;

  // Enter the block if all function contraints are met
  // Syntax: `impl [<constraints> <block>]`
	impl ::new(), set(const), get() {
    // Object has been initialized using `Object::new()` and `set` has been guaranteed to only be called using constant(s)
    // Unmentioned functions are guaranteed to not be called.

    // The pattern syntax is able to specialize specific successive calls
    // In this case we are interested in a pattern where `set()` is first called with a constant,
    // then a undefined amount of `get()` or `set()` calls.
    // Syntax: `pattern <constraints> <block>`
    pattern set(const) && (set(const) || get()) {
      // Pattern has been matched, override functions to output constants
      // Following overrides are executed in program order
      current : i32 = self.value;
      get -> current;
      set {
        self.value = value;
        current = value;
      }
    }

    // Implementation
    struct {
      value: i32,
    }
    ::new -> self.value = 0;
    set -> self.value = value;
    get -> return self.value;
  }

  // Default implementation, no contraints
  impl {
    struct {
      value: i32,
    }
    ::new -> self.value = 0;
    set -> self.value = value;
    get -> return self.value;
  }
}