class List<T> {
  ::new();
  push(element: T);
  pop() T;
  get(index: usize) T;
  set(index: usize, element: T);
  length() usize;
  collect() [T];
}

spe List<T> {
  // TODO: specializations

  impl {
    DEFAULT_SIZE :: 16;

    initial_length: usize = 0;
    initial_values: [T] = [T; DEFAULT_SIZE];
    // Find pattern starting with `::new()` followed by an unknown amount of constant operations
    // This allow us to constant fold all operations after initialization
    // `const` is a keyword that guarantee the value to be a compile-time constant
    // `_` is a wildcard that doesn't offer any guarantees. In this case we do not care whether or not `push` is pushing a constant.
    pattern ::new() &&
      (push(_) || pop() || get(const) || set(const, const) || length())... {
        // All callbacks are called in program order
        // `::new()` is not overrided here, so the default implementation is used instead
        push {
          if initial_length >= initial_values.length() {
            initial_values = initial_values.resize(initial_values.length() * 2);
          }
          initial_values[initial_length] = element;
          initial_length += 1;
        }
        pop -> initial_length -= 1;
        get -> initial_values[index];
        set -> initial_values[index] = element;
        length -> initial_length;
    }

    struct {
      array: [T],
      length: usize,
    }

    ::new {
      // Copy over the potential constant data retrieved from the pattern
      // Otherwise, the array is empty, and the length 0
      self.array = initial_values.clone();
      self.length = initial_length;
    }
    push {
      if self.length == self.array.length {
        // Resize array
        self.array = self.array.resized(self.array.length * 2);
      }
      self.array[self.length] = element;
      self.length += 1;
    }
    pop {
      self.length -= 1;
      self.array[self.length];
    }
    get {
      self.array[index];
    }
    set {
      self.array[index] = element;
    }
    length -> self.length;
    collect -> |#return_layout| self.array.slice(0, self.length);
  }
}

test "List" {
  // `list` should be entirely constant folded thanks to the pattern
  list :: List<i32>::new();
  assert list.length() == 0;

  list.push(1);
  assert list.length() == 1;
  assert list.get(0) == 1;

  list.set(0, 2);
  assert list.get(0) == 2;
  assert list.pop() == 2;
  assert list.length() == 0;
}
test "List.collect" {
  list :: List<i32>::new();
  list.push(1);
  list.push(2);
  list.push(3);
  assert list.collect() == [1, 2, 3];
}
test "List.collect() with layout" {
  Point :: struct { x: i32, y: i32 }
  list :: List<Point>::new();
  list.push(Point { x: 1, y: 2 });
  list.push(Point { x: 3, y: 4 });
  list.push(Point { x: 5, y: 6 });
  collect :: |x| list.collect();
  expected :: |x| [Point { x: 1, y: 2 }, Point { x: 3, y: 4 }, Point { x: 5, y: 6 }];
  // Compare `x` components [1, 3, 5]
  assert collect == expected;
}
