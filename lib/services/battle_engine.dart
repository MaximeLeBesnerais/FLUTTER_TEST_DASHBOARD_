import 'dart:math';
import '../models/gladiator.dart';
import '../models/opponent.dart';

class BattleResult {
  final bool gladiatorWon;
  final int gladiatorDamage;
  final int opponentDamage;
  final int rewardMoney;
  final String battleLog;

  BattleResult({
    required this.gladiatorWon,
    required this.gladiatorDamage,
    required this.opponentDamage,
    required this.rewardMoney,
    required this.battleLog,
  });
}

class BattleEngine {
  static final Random _random = Random();

  static BattleResult simulateBattle(Gladiator gladiator, Opponent opponent) {
    print('BATTLE ENGINE: Starting battle simulation');
    print('BATTLE ENGINE: Gladiator=${gladiator.name}, HP=${gladiator.hp}, Power=${gladiator.totalPower}');
    print('BATTLE ENGINE: Opponent=${opponent.name}, HP=${opponent.hp}, Power=${opponent.totalPower}');
    
    final List<String> log = [];
    
    // Create working copies
    int gladiatorHP = gladiator.hp;
    int opponentHP = opponent.hp;
    
    // Simple 3-sentence battle log
    log.add('Fight is starting!');
    
    // Calculate win probability and difficulty
    final winProbability = calculateWinProbability(gladiator, opponent);
    print('BATTLE ENGINE: Win probability calculated as ${winProbability}');
    
    String difficulty;
    if (winProbability >= 0.7) {
      difficulty = 'super easy';
    } else if (winProbability >= 0.5) {
      difficulty = 'even';
    } else {
      difficulty = 'difficult';
    }
    log.add('Fight is $difficulty!');
    print('BATTLE ENGINE: Difficulty assessed as $difficulty');
    
    // Simulate the battle with simplified logic
    final randomRoll = _random.nextDouble();
    bool gladiatorWon = randomRoll < winProbability;
    print('BATTLE ENGINE: Random roll=${randomRoll}, winProbability=${winProbability}, gladiatorWon=${gladiatorWon}');
    
    // Calculate damage based on outcome
    int gladiatorDamage = 0;
    int opponentDamage = 0;
    
    if (gladiatorWon) {
      // Gladiator wins - takes less damage
      gladiatorDamage = (_random.nextInt(20) + 5).clamp(0, gladiatorHP - 1);
      opponentDamage = opponentHP; // Opponent defeated
      log.add('Fight is done! We won!');
      print('BATTLE ENGINE: Victory! Gladiator damage=${gladiatorDamage}');
    } else {
      // Gladiator loses - takes more damage
      gladiatorDamage = (_random.nextInt(30) + 15).clamp(0, gladiatorHP - 1);
      opponentDamage = (_random.nextInt(40) + 10).clamp(0, opponentHP - 1);
      log.add('Fight is done! We lost!');
      print('BATTLE ENGINE: Defeat! Gladiator damage=${gladiatorDamage}');
    }

    final result = BattleResult(
      gladiatorWon: gladiatorWon,
      gladiatorDamage: gladiatorDamage,
      opponentDamage: opponentDamage,
      rewardMoney: gladiatorWon ? opponent.rewardMoney : 0,
      battleLog: log.join('\n'),
    );
    
    print('BATTLE ENGINE: Final result - won=${result.gladiatorWon}, damage=${result.gladiatorDamage}, reward=${result.rewardMoney}');
    return result;
  }

  static double calculateWinProbability(Gladiator gladiator, Opponent opponent) {
    // Simple probability calculation based on total power
    double gladiatorPower = gladiator.totalPower.toDouble();
    double opponentPower = opponent.totalPower.toDouble();
    
    // Factor in HP
    gladiatorPower += gladiator.hp * 0.5;
    opponentPower += opponent.hp * 0.5;
    
    double ratio = gladiatorPower / (gladiatorPower + opponentPower);
    
    // Add some variance but keep between 5% and 95%
    return ratio.clamp(0.05, 0.95);
  }

  static String getDifficultyDescription(double winProbability) {
    if (winProbability >= 0.8) return "Very Easy";
    if (winProbability >= 0.6) return "Easy";
    if (winProbability >= 0.4) return "Moderate";
    if (winProbability >= 0.2) return "Hard";
    return "Very Hard";
  }
}
