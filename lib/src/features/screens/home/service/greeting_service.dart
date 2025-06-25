import 'dart:math';

class GreetingModel {
  final String mainText;
  final String subtitle;
  final String emoji;

  GreetingModel({
    required this.mainText,
    required this.subtitle,
    required this.emoji,
  });
}

class GreetingService {
  static final Random _random = Random();

  // Change greeting every 30 minutes (you can adjust this value)
  static const int _rotationIntervalMinutes = 30;

  static GreetingModel getCoolGreeting() {
    final now = DateTime.now();
    final hour = now.hour;
    final dayOfWeek = now.weekday;
    final isWeekend = dayOfWeek == 6 || dayOfWeek == 7;

    // Create a seed based on time interval for consistent rotation
    final intervalSeed = (now.millisecondsSinceEpoch ~/ (1000 * 60 * _rotationIntervalMinutes));
    final seededRandom = Random(intervalSeed);

    // Get day name
    final dayNames = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = dayNames[dayOfWeek];

    List<Map<String, String>> greetings = [];

    if (hour >= 5 && hour < 12) {
      // Morning greetings
      greetings = _getMorningGreetings();

      if (isWeekend) {
        greetings.addAll([
          {'text': 'Weekend Warrior! 🛡️', 'subtitle': 'Even weekends can\'t stop you'},
          {'text': '$dayName Morning Magic! ✨', 'subtitle': 'Making the most of your time'},
        ]);
      }
    } else if (hour >= 12 && hour < 17) {
      // Afternoon greetings
      greetings = _getAfternoonGreetings();

      if (isWeekend) {
        greetings.addAll([
          {'text': '$dayName Dedication! 💎', 'subtitle': 'Your commitment shows'},
          {'text': 'Weekend Productivity! ⚔️', 'subtitle': 'Going above and beyond'},
        ]);
      }
    } else if (hour >= 17 && hour < 21) {
      // Evening greetings
      greetings = _getEveningGreetings();
    } else {
      // Night greetings
      greetings = _getNightGreetings();

      if (hour >= 22 || hour < 5) {
        greetings.addAll([
          {'text': 'Night Owl Innovator! 💡', 'subtitle': 'Great ideas come at night'},
          {'text': 'Stars Align for Success! ⭐', 'subtitle': 'Cosmic energy working for you'},
        ]);
      }
    }

    // Add special day-specific greetings
    greetings.addAll(_getSpecialDayGreetings(dayOfWeek));

    // Select greeting using seeded random for consistent rotation
    final randomGreeting = greetings[seededRandom.nextInt(greetings.length)];

    return GreetingModel(
      mainText: randomGreeting['text']!,
      subtitle: randomGreeting['subtitle']!,
      emoji: _getRandomMotivationalEmoji(seededRandom),
    );
  }

  static List<Map<String, String>> _getMorningGreetings() {
    return [
      {'text': 'Rise & Shine! ☕✨', 'subtitle': 'Let\'s make today amazing!'},
      {'text': 'Good Morning, Champion! 🌅', 'subtitle': 'Ready to conquer the day?'},
      {'text': 'Morning Energy Mode ON! 💪', 'subtitle': 'Time to turn dreams into reality'},
      {'text': 'Fresh Start, Fresh Goals! 🚀', 'subtitle': 'Your journey awaits'},
      {'text': 'Sunrise, Spirits Up! 🌄', 'subtitle': 'Another day, another opportunity'},
      {'text': 'Early Bird Achiever! 🐦', 'subtitle': 'Starting strong today'},
      {'text': 'Morning Motivation! 💰', 'subtitle': 'Beginning with purpose'},
      {'text': 'Dawn of Possibilities! 🌅', 'subtitle': 'Your potential is limitless'},
    ];
  }

  static List<Map<String, String>> _getAfternoonGreetings() {
    return [
      {'text': 'Afternoon Power Hour! ⚡', 'subtitle': 'Peak performance time'},
      {'text': 'Midday Momentum! 💰', 'subtitle': 'Energy building strong'},
      {'text': 'Crushing It This Afternoon! 🔥', 'subtitle': 'Keep that energy flowing'},
      {'text': 'Afternoon Achiever! 🎯', 'subtitle': 'Goals in sight'},
      {'text': 'Midday Magic! 🍽️💸', 'subtitle': 'Never stop progressing'},
      {'text': 'Afternoon Excellence! 💎', 'subtitle': 'Shining bright like a diamond'},
      {'text': 'Midday Mastery! 🌟', 'subtitle': 'Riding the wave of productivity'},
    ];
  }

  static List<Map<String, String>> _getEveningGreetings() {
    return [
      {'text': 'Evening Excellence! 🌆', 'subtitle': 'Finishing strong today'},
      {'text': 'Golden Hour Energy! 🌅', 'subtitle': 'Prime time for progress'},
      {'text': 'Sunset Success Mode! 🌇', 'subtitle': 'Ending the day right'},
      {'text': 'Evening Achiever! 🏰', 'subtitle': 'Your dedication shows daily'},
      {'text': 'Twilight Triumph! 🌟', 'subtitle': 'Another productive day'},
      {'text': 'Evening Warrior! 💼', 'subtitle': 'Consistency is key'},
      {'text': 'Dusk Till Dawn Drive! 🌅', 'subtitle': 'Your commitment inspires'},
    ];
  }

  static List<Map<String, String>> _getNightGreetings() {
    return [
      {'text': 'Night Owl Achiever! 🦉', 'subtitle': 'Dedication never sleeps'},
      {'text': 'Burning the Midnight Oil! 🛢️🔥', 'subtitle': 'Commitment at its finest'},
      {'text': 'Late Night, Big Dreams! 🌙✨', 'subtitle': 'Building tomorrow today'},
      {'text': 'Moonlight Motivation! 🌙💰', 'subtitle': 'Working while others rest'},
      {'text': 'After Hours Achiever! 🌃', 'subtitle': 'Going the extra mile'},
      {'text': 'Midnight Warrior! 🌙👑', 'subtitle': 'Dedication never stops'},
      {'text': 'Night Shift Navigator! 🗺️', 'subtitle': 'Charting your path forward'},
    ];
  }

  static List<Map<String, String>> _getSpecialDayGreetings(int dayOfWeek) {
    List<Map<String, String>> specialGreetings = [];

    switch (dayOfWeek) {
      case 1: // Monday
        specialGreetings.addAll([
          {'text': 'Monday Momentum! 🚀', 'subtitle': 'Starting the week strong'},
          {'text': 'Manic Monday Magic! 💰', 'subtitle': 'Week one, goals won'},
          {'text': 'Monday Motivation! 💪', 'subtitle': 'New week, new victories'},
        ]);
        break;
      case 2: // Tuesday
        specialGreetings.addAll([
          {'text': 'Tuesday Takeover! 👑', 'subtitle': 'Dominating day two'},
          {'text': 'Terrific Tuesday! ⭐', 'subtitle': 'Building on yesterday\'s progress'},
        ]);
        break;
      case 3: // Wednesday
        specialGreetings.addAll([
          {'text': 'Wednesday Winner! 🏆', 'subtitle': 'Midweek momentum strong'},
          {'text': 'Wonderful Wednesday! 🌟', 'subtitle': 'Halfway to weekend victory'},
        ]);
        break;
      case 4: // Thursday
        specialGreetings.addAll([
          {'text': 'Thursday Thriller! ⚡', 'subtitle': 'Almost there, keep pushing'},
          {'text': 'Thriving Thursday! 🔥', 'subtitle': 'Success is within reach'},
        ]);
        break;
      case 5: // Friday
        specialGreetings.addAll([
          {'text': 'Friday Finale! 🎉', 'subtitle': 'Ending the week victorious'},
          {'text': 'TGIF - Thank God It\'s Fantastic! 💸', 'subtitle': 'Friday feels and achievements'},
          {'text': 'Fantastic Friday! 🌟', 'subtitle': 'Week champion status unlocked'},
        ]);
        break;
      case 6: // Saturday
        specialGreetings.addAll([
          {'text': 'Saturday Superstar! ⭐', 'subtitle': 'Weekend dedication is real'},
          {'text': 'Super Saturday! 💎', 'subtitle': 'Going above and beyond'},
        ]);
        break;
      case 7: // Sunday
        specialGreetings.addAll([
          {'text': 'Sunday Success! 🌅', 'subtitle': 'Even rest days bring progress'},
          {'text': 'Supreme Sunday! 👑', 'subtitle': 'Consistency knows no weekends'},
        ]);
        break;
    }

    return specialGreetings;
  }

  static String _getRandomMotivationalEmoji([Random? seededRandom]) {
    final emojis = ['🚀', '💎', '⚡', '🔥', '💪', '🎯', '👑', '⭐', '💰', '🏆', '🌟', '⚔️', '🛡️', '💼', '🎉'];
    final random = seededRandom ?? _random;
    return emojis[random.nextInt(emojis.length)];
  }

  // Method to set custom rotation interval (in minutes)
  static int get rotationIntervalMinutes => _rotationIntervalMinutes;

  // Optional: Method to get next rotation time
  static DateTime getNextRotationTime() {
    final now = DateTime.now();
    final currentInterval = now.millisecondsSinceEpoch ~/ (1000 * 60 * _rotationIntervalMinutes);
    final nextIntervalStart = (currentInterval + 1) * (1000 * 60 * _rotationIntervalMinutes);
    return DateTime.fromMillisecondsSinceEpoch(nextIntervalStart);
  }
}