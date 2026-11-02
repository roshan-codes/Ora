class AudioOption {
  final String id;
  final String title;
  final String assetPath;

  const AudioOption({
    required this.id,
    required this.title,
    required this.assetPath,
  });
}

class AudioConstants {
  static const AudioOption defaultSound = AudioOption(
    id: 'classic_alarm',
    title: 'Classic Alarm',
    assetPath: 'assets/audio/classic_alarm.wav',
  );

  static const List<AudioOption> availableSounds = [
    defaultSound,
    AudioOption(
      id: 'gentle_chime',
      title: 'Gentle Chime',
      assetPath: 'assets/audio/gentle_chime.wav',
    ),
    AudioOption(
      id: 'digital_pulse',
      title: 'Digital Pulse',
      assetPath: 'assets/audio/digital_pulse.wav',
    ),
    AudioOption(
      id: 'sunrise_bell',
      title: 'Sunrise Bell',
      assetPath: 'assets/audio/sunrise_bell.wav',
    ),
  ];

  static AudioOption getById(String id) {
    return availableSounds.firstWhere(
      (s) => s.id == id,
      orElse: () => defaultSound,
    );
  }

  static AudioOption getByPath(String path) {
    return availableSounds.firstWhere(
      (s) => s.assetPath == path,
      orElse: () => defaultSound,
    );
  }
}
