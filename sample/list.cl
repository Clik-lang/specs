class List<T> {
  ::new();
  push(element: T);
  pop() T;
  get(index: size_t) T;
  set(index: size_t, element: T);
  length() size_t;
}

spe List<T> {
  // TODO: specializations

  impl {
    foreign malloc(size_t) -> ptr;
    foreign free(ptr);
    foreign memcpy(ptr, ptr, size_t) -> ptr;

    initial_length: size_t = 0;
    initial_values: [T] = [T; 16];
    // Find pattern starting with `::new()` followed by an unknown amount of constant operations
    // This allow us to constant fold all operations after initialization
    pattern ::new() &&
      (push(const) || pop() || get(const) || set(const, const) || length())... {
        // All callbacks are called in program order
        push {
          // TODO resize array
          initial_values[initial_length] = element;
          initial_length += 1;
        }
        pop -> initial_length -= 1;
        get -> initial_values[index];
        set -> initial_values[index] = element;
        length -> initial_length;
    }

    struct {
      array: [T]
      length: size_t,
    }

    ::new {
      self.array = initial_values.clone();
      self.length = initial_length;
    }

    push {
      if self.length == self.array.length {
        // Resize array
        self.array = self.array.resize(self.array.length * 2);
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
  }
}

test "list" {
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