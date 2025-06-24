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

  static GreetingModel getCoolGreeting() {
    final now = DateTime.now();
    final hour = now.hour;
    final dayOfWeek = now.weekday;
    final isWeekend = dayOfWeek == 6 || dayOfWeek == 7;

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
          {'text': '$dayName Morning Magic! ✨', 'subtitle': 'Making money while others sleep in'},
        ]);
      }
    } else if (hour >= 12 && hour < 17) {
      // Afternoon greetings
      greetings = _getAfternoonGreetings();

      if (isWeekend) {
        greetings.addAll([
          {'text': '$dayName Dedication! 💎', 'subtitle': 'Your commitment pays off'},
          {'text': 'Weekend Sales Warrior! ⚔️', 'subtitle': 'Going above and beyond'},
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
          {'text': 'Insomniac Innovator! 💡', 'subtitle': 'Great ideas come at night'},
          {'text': 'Stars Align for Success! ⭐', 'subtitle': 'Cosmic energy working for you'},
        ]);
      }
    }

    // Add special day-specific greetings
    greetings.addAll(_getSpecialDayGreetings(dayOfWeek));

    // Select random greeting
    final randomGreeting = greetings[_random.nextInt(greetings.length)];

    return GreetingModel(
      mainText: randomGreeting['text']!,
      subtitle: randomGreeting['subtitle']!,
      emoji: _getRandomMotivationalEmoji(),
    );
  }

  static List<Map<String, String>> _getMorningGreetings() {
    return [
      {'text': 'Rise & Grind! ☕✨', 'subtitle': 'Let\'s make today profitable!'},
      {'text': 'Good Morning, Boss! 🌅', 'subtitle': 'Ready to dominate the market?'},
      {'text': 'Morning Hustle Mode ON! 💪', 'subtitle': 'Time to turn dreams into sales'},
      {'text': 'Fresh Start, Fresh Sales! 🚀', 'subtitle': 'Your empire awaits'},
      {'text': 'Sunrise, Sales Up! 🌄', 'subtitle': 'Another day, another opportunity'},
      {'text': 'Early Bird Entrepreneur! 🐦', 'subtitle': 'Catching all the profits'},
      {'text': 'Morning Money Maker! 💰', 'subtitle': 'Starting strong, finishing stronger'},
      {'text': 'Dawn of Success! 🌅', 'subtitle': 'Your journey to greatness begins'},
    ];
  }

  static List<Map<String, String>> _getAfternoonGreetings() {
    return [
      {'text': 'Afternoon Power Hour! ⚡', 'subtitle': 'Peak performance time'},
      {'text': 'Midday Money Moves! 💰', 'subtitle': 'Sales momentum building'},
      {'text': 'Crushing It This Afternoon! 🔥', 'subtitle': 'Keep that energy flowing'},
      {'text': 'Afternoon Achiever! 🎯', 'subtitle': 'Targets in sight'},
      {'text': 'Lunch Break? More Like Profit Break! 🍽️💸', 'subtitle': 'Never stop grinding'},
      {'text': 'Afternoon Excellence! 💎', 'subtitle': 'Shining bright like a diamond'},
      {'text': 'Midday Momentum! 🌟', 'subtitle': 'Riding the wave of success'},
    ];
  }

  static List<Map<String, String>> _getEveningGreetings() {
    return [
      {'text': 'Evening Excellence! 🌆', 'subtitle': 'Finishing strong today'},
      {'text': 'Golden Hour, Golden Sales! 🌅', 'subtitle': 'Prime time for profits'},
      {'text': 'Sunset Success Mode! 🌇', 'subtitle': 'Ending the day right'},
      {'text': 'Evening Empire Builder! 🏰', 'subtitle': 'Your legacy grows daily'},
      {'text': 'Twilight Triumph! 🌟', 'subtitle': 'Another successful day ahead'},
      {'text': 'Evening Entrepreneur! 💼', 'subtitle': 'Business never sleeps'},
      {'text': 'Dusk Till Dawn Dedication! 🌅', 'subtitle': 'Your commitment shows'},
    ];
  }

  static List<Map<String, String>> _getNightGreetings() {
    return [
      {'text': 'Night Owl Entrepreneur! 🦉', 'subtitle': 'Success never sleeps'},
      {'text': 'Burning the Midnight Oil! 🛢️🔥', 'subtitle': 'Dedication at its finest'},
      {'text': 'Late Night, Big Dreams! 🌙✨', 'subtitle': 'Building tomorrow today'},
      {'text': 'Moonlight Money Maker! 🌙💰', 'subtitle': 'Working while others rest'},
      {'text': 'After Hours Achiever! 🌃', 'subtitle': 'Going the extra mile'},
      {'text': 'Midnight Mogul! 🌙👑', 'subtitle': 'Empire building never stops'},
      {'text': 'Night Shift Navigator! 🗺️', 'subtitle': 'Charting your path to success'},
    ];
  }

  static List<Map<String, String>> _getSpecialDayGreetings(int dayOfWeek) {
    List<Map<String, String>> specialGreetings = [];

    switch (dayOfWeek) {
      case 1: // Monday
        specialGreetings.addAll([
          {'text': 'Monday Momentum! 🚀', 'subtitle': 'Starting the week strong'},
          {'text': 'Manic Monday Millions! 💰', 'subtitle': 'Week one, profits won'},
          {'text': 'Monday Motivation! 💪', 'subtitle': 'New week, new victories'},
        ]);
        break;
      case 2: // Tuesday
        specialGreetings.addAll([
          {'text': 'Tuesday Takeover! 👑', 'subtitle': 'Dominating day two'},
          {'text': 'Terrific Tuesday! ⭐', 'subtitle': 'Building on yesterday\'s success'},
        ]);
        break;
      case 3: // Wednesday
        specialGreetings.addAll([
          {'text': 'Wednesday Winner! 🏆', 'subtitle': 'Midweek mastery in action'},
          {'text': 'Wonderful Wednesday! 🌟', 'subtitle': 'Halfway to weekend glory'},
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
          {'text': 'TGIF - Thank God It\'s Profitable! 💸', 'subtitle': 'Friday feels and deals'},
          {'text': 'Fantastic Friday! 🌟', 'subtitle': 'Week champion status unlocked'},
        ]);
        break;
      case 6: // Saturday
        specialGreetings.addAll([
          {'text': 'Saturday Superstar! ⭐', 'subtitle': 'Weekend hustle is real'},
          {'text': 'Super Saturday! 💎', 'subtitle': 'Going above and beyond'},
        ]);
        break;
      case 7: // Sunday
        specialGreetings.addAll([
          {'text': 'Sunday Success! 🌅', 'subtitle': 'Even rest days bring results'},
          {'text': 'Supreme Sunday! 👑', 'subtitle': 'Dedication knows no weekends'},
        ]);
        break;
    }

    return specialGreetings;
  }

  static String _getRandomMotivationalEmoji() {
    final emojis = ['🚀', '💎', '⚡', '🔥', '💪', '🎯', '👑', '⭐', '💰', '🏆', '🌟', '⚔️', '🛡️', '💼', '🎉'];
    return emojis[_random.nextInt(emojis.length)];
  }

  // Bonus: Get greeting based on sales performance
  static GreetingModel getPerformanceBasedGreeting(double todayRevenue, double targetRevenue) {
    final performanceRatio = todayRevenue / targetRevenue;

    if (performanceRatio >= 1.5) {
      return GreetingModel(
        mainText: 'Sales Rockstar! 🎸⭐',
        subtitle: 'You\'re crushing those targets!',
        emoji: '🔥',
      );
    } else if (performanceRatio >= 1.2) {
      return GreetingModel(
        mainText: 'Target Destroyer! 💥',
        subtitle: 'Above and beyond as always!',
        emoji: '🚀',
      );
    } else if (performanceRatio >= 1.0) {
      return GreetingModel(
        mainText: 'Goal Getter! 🎯',
        subtitle: 'Right on track for success!',
        emoji: '💪',
      );
    } else if (performanceRatio >= 0.7) {
      return GreetingModel(
        mainText: 'Progress Maker! 📈',
        subtitle: 'Steady climb to the top!',
        emoji: '⚡',
      );
    } else {
      return GreetingModel(
        mainText: 'Opportunity Awaits! 🌅',
        subtitle: 'Every challenge is a chance to shine!',
        emoji: '💎',
      );
    }
  }


}