enum JournalMood {
  happy,
  calm,
  sad,
  anxious,
  excited,
  tired;

  String get label {
    switch (this) {
      case happy:
        return '开心';
      case calm:
        return '平静';
      case sad:
        return '难过';
      case anxious:
        return '焦虑';
      case excited:
        return '兴奋';
      case tired:
        return '疲惫';
    }
  }

  String get emoji {
    switch (this) {
      case happy:
        return '😊';
      case calm:
        return '😌';
      case sad:
        return '😢';
      case anxious:
        return '😰';
      case excited:
        return '🤩';
      case tired:
        return '😴';
    }
  }
}

enum JournalWeather {
  sunny,
  cloudy,
  rainy,
  snowy,
  windy;

  String get label {
    switch (this) {
      case sunny:
        return '晴';
      case cloudy:
        return '多云';
      case rainy:
        return '雨';
      case snowy:
        return '雪';
      case windy:
        return '风';
    }
  }

  String get emoji {
    switch (this) {
      case sunny:
        return '☀️';
      case cloudy:
        return '☁️';
      case rainy:
        return '🌧️';
      case snowy:
        return '❄️';
      case windy:
        return '💨';
    }
  }
}
