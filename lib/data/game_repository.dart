import '../logic/collection.dart';
import 'list_repository.dart';

typedef GameRepository = ListRepository<Game>;

/// Device storage for games (shared_preferences, JSON).
const GameRepository deviceGameRepository =
    SharedPreferencesListRepository<Game>(
  storageKey: 'game_collection_games_v1',
  fromJson: Game.fromJson,
  toJson: gameToJson,
);
