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

    struct {
      address: ptr,
      address_length: size_t,
      length: size_t,
    }

    size :: #sizeof(T);

    ::new {
      initialSize = size * 16;
      self.address = malloc(initialSize);
      self.address_length = initialSize;
      self.length = 0;
    }

    push {
      target :: size * (self.length + 1);
      if target + size > self.address_length {
        new_address_length = self.address_length * 2;
        new_address :: malloc(new_address_length);
        memcpy(new_address, self.address, self.address_length);
        free(self.address);
        self.address = new_address;
        self.address_length = new_address_length;
      }
      address.store<T>(self.length, element);
      self.length += 1;
    }

    pop {
      self.length -= 1;
      address.load<T>(self.length);
    }

    get {
      address.load<T>(index);
    }

    set {
      address.store<T>(index, element);
    }

    length -> self.length;

    defer {
      free(self.address);
    }
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