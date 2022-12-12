Point :: struct {x: i32, y: i32}

shared_variable :: () {
  // Shared variable declared with `~`
  counter :~ 0;

  constant: i32 : 1;
  variable: i32 = 1;
  fork {
    counter = constant;
    // counter = variable; // Error: variable is mutable and not shared
    break; // Exit the task
  }
  assert counter == constant;
}

nested_tasks :: () {
  counter :~ 0;
  counter = 1;
  fork 0..10 {
    // `counter` is copied into the stack, taking a snapshot of its value before entering the task
    // So in this case, the value of `counter` is 1
    counter += 1; // `counter` becomes 2
  } // `counter` exits the task, the value is merged back into the main thread
  // Each fork has incremented `counter` by 1, the current thread will merge the changes.
  // The merging phase allows tasks to be executed in parallel without worrying about data race.
  // The final value of `counter` is 11
  // Blocks until all the nested forks have exited
  assert counter == 11;
}

conditional_fork :: () {
  // TODO
}

// TODO: how to handle global variables?
// Everything below is POC
global :~ 0;
// Create a background task by declaring it in the global scope
fork {
  // Run when `global` == 1
  select {
    where global == 1 {
      // Do something
    },
    // Timeout after 1 second
    timeout 1000 {
      // Do something else
    },
  }
  where
  break;
}
