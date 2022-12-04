Player :: struct {
    name: string,
    score: i32,
}

basics :: () {
  // Table declaration. In this case storing a `Player` struct.
  players :: table Player;
  // Insertion of a new entry.
  // Syntax: `insert <table> <element>`
  insert players {name: "John", score: 10}
  // Retrieve the player "John"
  // Syntax: `select <table> [<layout>] [{<field>: <value_predicate>, ...}]`
  // Returns a list of elements matching the predicate.
  select_result: [Player] : select players {name: "John"}

  // Increment the score of the player "John"
  // Syntax: `update <table> [<layout>] [{<field>: <value_predicate>, ...}] <update>`
  // Returns a list of elements matching the predicate.
  update players {name: "John"} {score: score + 1}

  // Delete the player "John"
  // Syntax: `delete <table> [<layout>] [{<field>: <value_predicate>, ...}]`
  // Returns a list of elements matching the predicate.
  delete_result: [Player] : delete players {name: "John"}
}

layout :: () {
  players :: table Player;
  insert players {name: "John", score: 10}
  // Retrieve an array of scores.
  result: [Player{score}] : select players |score|;
  // Merge the scores
  merge: i32 = 0;
  for .score in result -> merge += score;
}

ecs :: () {
  Component :: union {
    Position :: struct {
      x: i32,
      y: i32,
    },
    Velocity :: struct {
      x: i32,
      y: i32,
    },
  }

  Entity :: struct {
    id: i32,
    components: [Component],
  }

  Entities :: table Entity;
  insert Entities {id: 0, components: [Position {x: 0, y: 0}]}

  // TODO improve query and better control over components layout
  positions: [Position] : select Entities |components.Position|;
  for position in positions -> print(position);
}
