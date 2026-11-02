import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/audio_constants.dart';
import '../models/alarm_model.dart';
import '../../../shared/services/sound_preview_service.dart';

class AddEditAlarmScreen extends StatefulWidget {
  final AlarmModel? existingAlarm;
  final ValueChanged<AlarmModel> onSave;
  final ValueChanged<int>? onDelete;

  const AddEditAlarmScreen({
    super.key,
    this.existingAlarm,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<AddEditAlarmScreen> createState() => _AddEditAlarmScreenState();
}

class _AddEditAlarmScreenState extends State<AddEditAlarmScreen> {
  late int _hour;
  late int _minute;
  late TextEditingController _labelController;
  late List<int> _repeatDays;
  late String _audioPath;
  late String _audioTitle;
  late double _volume;
  late bool _gradualVolume;
  late bool _vibrate;
  late int _snoozeMinutes;
  late bool _sunriseAlarm;

  @override
  void initState() {
    super.initState();
    final a = widget.existingAlarm;
    _hour = a?.hour ?? 7;
    _minute = a?.minute ?? 0;
    _labelController = TextEditingController(text: a?.label ?? 'Alarm');
    _repeatDays = List<int>.from(a?.repeatDays ?? [1, 2, 3, 4, 5]);
    _audioPath = a?.audioPath ?? AudioConstants.defaultSound.assetPath;
    _audioTitle = a?.audioTitle ?? AudioConstants.defaultSound.title;
    _volume = a?.volume ?? 0.8;
    _gradualVolume = a?.gradualVolume ?? false;
    _vibrate = a?.vibrate ?? true;
    _snoozeMinutes = a?.snoozeDurationMinutes ?? 10;
    _sunriseAlarm = a?.sunriseAlarm ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    SoundPreviewService.instance.stopPreview();
    super.dispose();
  }

  void _save() {
    final newId = widget.existingAlarm?.id ?? DateTime.now().millisecondsSinceEpoch % 100000;
    final alarm = AlarmModel(
      id: newId,
      hour: _hour,
      minute: _minute,
      label: _labelController.text.trim().isEmpty
          ? 'Alarm'
          : _labelController.text.trim(),
      isEnabled: true,
      repeatDays: _repeatDays,
      audioPath: _audioPath,
      audioTitle: _audioTitle,
      volume: _volume,
      gradualVolume: _gradualVolume,
      vibrate: _vibrate,
      snoozeDurationMinutes: _snoozeMinutes,
      sunriseAlarm: _sunriseAlarm,
    );

    widget.onSave(alarm);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingAlarm != null;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEditing ? 'Edit Alarm' : 'New Alarm',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _save,
              child: const Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.orange,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Time Selector Card
            _buildTimePickerCard(),
            const SizedBox(height: 16),

            // 2. Repeat Days Selector
            _buildRepeatDaysCard(),
            const SizedBox(height: 16),

            // 3. Label Input
            _buildLabelCard(),
            const SizedBox(height: 16),

            // 4. Sound & Volume Settings
            _buildSoundAndVolumeCard(),
            const SizedBox(height: 16),

            // 5. Options (Vibrate, Gradual Volume, Sunrise)
            _buildTogglesCard(),
            const SizedBox(height: 16),

            // 6. Snooze Duration
            _buildSnoozeCard(),
            const SizedBox(height: 24),

            // 7. Delete Button (if editing)
            if (isEditing) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    widget.onDelete?.call(widget.existingAlarm!.id);
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Delete Alarm',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.errorRed,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerCard() {
    final displayHour = _hour % 12 == 0 ? 12 : _hour % 12;
    final period = _hour >= 12 ? 'pm' : 'am';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hour button
              _buildStepper(
                value: displayHour.toString().padLeft(2, '0'),
                label: 'Hour',
                onIncrement: () {
                  setState(() {
                    _hour = (_hour + 1) % 24;
                  });
                },
                onDecrement: () {
                  setState(() {
                    _hour = (_hour - 1 + 24) % 24;
                  });
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              // Minute button
              _buildStepper(
                value: _minute.toString().padLeft(2, '0'),
                label: 'Minute',
                onIncrement: () {
                  setState(() {
                    _minute = (_minute + 1) % 60;
                  });
                },
                onDecrement: () {
                  setState(() {
                    _minute = (_minute - 1 + 60) % 60;
                  });
                },
              ),
              const SizedBox(width: 16),
              // AM / PM Toggle
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_hour < 12) {
                      _hour += 12;
                    } else {
                      _hour -= 12;
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    period.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepper({
    required String value,
    required String label,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up, color: AppColors.textDark),
          onPressed: onIncrement,
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            letterSpacing: -1.0,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textDark),
          onPressed: onDecrement,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRepeatDaysCard() {
    const days = [
      {'id': 1, 'name': 'M'},
      {'id': 2, 'name': 'T'},
      {'id': 3, 'name': 'W'},
      {'id': 4, 'name': 'T'},
      {'id': 5, 'name': 'F'},
      {'id': 6, 'name': 'S'},
      {'id': 7, 'name': 'S'},
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Repeat',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              final id = day['id'] as int;
              final name = day['name'] as String;
              final isSelected = _repeatDays.contains(id);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _repeatDays.remove(id);
                    } else {
                      _repeatDays.add(id);
                    }
                  });
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.orange : AppColors.screenBackground,
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.orange.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _labelController,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          labelText: 'Label',
          labelStyle: TextStyle(color: AppColors.textMuted),
          hintText: 'e.g. Work, Workout, Morning',
        ),
      ),
    );
  }

  Widget _buildSoundAndVolumeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alarm Sound',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          // Sound selection list
          ...AudioConstants.availableSounds.map((sound) {
            final isSelected = _audioPath == sound.assetPath;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.music_note_outlined,
                color: isSelected ? AppColors.orange : AppColors.unselectedIcon,
                size: 22,
              ),
              title: Text(
                sound.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.orange : AppColors.textDark,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      SoundPreviewService.instance.currentlyPlayingPath == sound.assetPath
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_outline,
                      color: AppColors.orange,
                      size: 22,
                    ),
                    onPressed: () {
                      setState(() {
                        SoundPreviewService.instance.playPreview(sound.assetPath);
                      });
                    },
                  ),
                  if (isSelected)
                    const Icon(Icons.check, color: AppColors.orange, size: 20),
                ],
              ),
              onTap: () {
                setState(() {
                  _audioPath = sound.assetPath;
                  _audioTitle = sound.title;
                });
              },
            );
          }),
          const Divider(height: 24),
          // Volume slider
          Row(
            children: [
              const Icon(Icons.volume_down_outlined, size: 20, color: AppColors.textMuted),
              Expanded(
                child: Slider(
                  value: _volume,
                  min: 0.1,
                  max: 1.0,
                  activeColor: AppColors.orange,
                  inactiveColor: AppColors.screenBackground,
                  onChanged: (val) {
                    setState(() {
                      _volume = val;
                    });
                  },
                ),
              ),
              const Icon(Icons.volume_up_outlined, size: 20, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Text(
                '${(_volume * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTogglesCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Vibration
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.orange,
            title: const Text(
              'Vibrate',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            value: _vibrate,
            onChanged: (val) => setState(() => _vibrate = val),
          ),
          const Divider(height: 1),
          // Gradual volume
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.orange,
            title: const Text(
              'Gradual Volume',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            subtitle: const Text(
              'Gently ramps volume over 15 seconds',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            value: _gradualVolume,
            onChanged: (val) => setState(() => _gradualVolume = val),
          ),
          const Divider(height: 1),
          // Sunrise Alarm
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.orange,
            title: const Text(
              'Sunrise Alarm',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            subtitle: const Text(
              'Slowly brighten screen before alarm',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            value: _sunriseAlarm,
            onChanged: (val) => setState(() => _sunriseAlarm = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSnoozeCard() {
    const options = [5, 10, 15, 20];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Snooze Duration',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: options.map((mins) {
              final isSelected = _snoozeMinutes == mins;
              return GestureDetector(
                onTap: () => setState(() => _snoozeMinutes = mins),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.orange : AppColors.screenBackground,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.orange.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    '$mins min',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

