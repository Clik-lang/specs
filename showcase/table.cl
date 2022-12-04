Player :: struct {
    name: string,
    score: i32,
}

PlayerEntry :: struct {
  // `using` allow the use of `name` and `score` as if they were
  // fields of the table. (instead of `player.name` and `player.score`)
  using player: Player
}

basics :: () {
  // Table declaration. In this case storing a `PlayerEntry` struct.
  players :: table PlayerEntry;
  // Insertion of a new entry.
  // Syntax: `insert <table> <element>`
  insert players {name: "John", score: 10}
  // Retrieve the player "John"
  // Syntax: `select <table> [<layout>] [{<field>: <value_predicate>, ...}]`
  // Returns a list of elements matching the predicate.
  select_result: [PlayerEntry] : select players {name: "John"}

  // Increment the score of the player "John"
  // Syntax: `update <table> [<layout>] [{<field>: <value_predicate>, ...}] <update>`
  // Returns a list of elements matching the predicate.
  update players {name: "John"} {score: score + 1}

  // Delete the player "John"
  // Syntax: `delete <table> [<layout>] [{<field>: <value_predicate>, ...}]`
  // Returns a list of elements matching the predicate.
  delete_result: [PlayerEntry] : delete players {name: "John"}
}

layout :: () {
  players :: table PlayerEntry;
  insert players {name: "John", score: 10}
  // Retrieve an array of scores.
  result: [PlayerEntry{score}] : select players |score|;
  // Merge the scores
  merge: i32 = 0;
  for .score in result -> merge += score;
}