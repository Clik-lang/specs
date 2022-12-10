Player :: struct {
    name: string,
    score: i32,
}

// Layout
{
  Players :: table Player;

  players :: Players {};
  insert players {.name: "John", .score: 10}
  // Retrieve an array of scores.
  result: [Player{score}] : select players |score|;
  // Merge the scores
  merge: i32 = 0;
  for .score: result -> merge += score;
}

// Map
{
  Entry :: struct {key: string, value: i32}
  Map :: table {
    using Entry {unique key},
  }

  map :: Map {};
  // Insertion of a new entry.
  insert map {.key: "John", .value: 10}
  // Retrieve the player "John"
  // TODO: how to retrieve a single element?
  select_result: [Entry] : select map where .key "John";
  // Delete the player "John"
  delete map {key: "John"}
}

// ECS
{
  Component :: union {
    Position :: struct {x: i32, y: i32},
    Velocity :: struct {x: i32, y: i32},
  }
  Entity :: struct {
    id: i32,
    components: <Component>,
  }
  Entities :: table Entity;

  entities :: Entities {};
  insert entities {.id: 0, .components: <Position {x: 0, y: 0}>}

  // Retrieve the `Position` component of every entity, only if present.
  positions: [Position] : select entities |components<Position>| where .components <Position>;
  for position: positions -> print(position);
}
