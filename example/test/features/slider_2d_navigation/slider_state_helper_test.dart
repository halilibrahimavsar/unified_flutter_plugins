import 'package:flutter_test/flutter_test.dart';
import 'package:unified_flutter_features/features/slider_2d_navigation/helpers/slider_state_helper.dart';
import 'package:unified_flutter_features/features/slider_2d_navigation/models/slider_models.dart';

void main() {
  test('SliderStateHelper maps values to states and targets', () {
    expect(
      SliderStateHelper.getStateFromValue(0.16, 3),
      SliderState.savedMoney,
    );
    expect(
      SliderStateHelper.getStateFromValue(0.5, SliderState.values.length),
      SliderState.transactions,
    );
    expect(
      SliderStateHelper.getStateFromValue(1.0, SliderState.values.length),
      SliderState.debt,
    );

    expect(
      SliderStateHelper.getTargetValue(
        SliderState.savedMoney,
        SliderState.values.length,
      ),
      0.0,
    );
    expect(
      SliderStateHelper.getTargetValue(
        SliderState.transactions,
        SliderState.values.length,
      ),
      0.5,
    );
    expect(
      SliderStateHelper.getTargetValue(
        SliderState.debt,
        SliderState.values.length,
      ),
      1.0,
    );
  });

  test('SliderStateHelper returns labels and icons', () {
    expect(
      SliderStateHelper.getLabelForState(SliderState.savedMoney),
      'BİRİKİM',
    );
    expect(
      SliderStateHelper.getLabelForState(SliderState.transactions),
      'İŞLEMLER',
    );
    expect(
      SliderStateHelper.getLabelForState(SliderState.debt),
      'BORÇ',
    );

    expect(
      SliderStateHelper.getIconForState(SliderState.savedMoney),
      isNotNull,
    );
    expect(
      SliderStateHelper.getIconForState(SliderState.transactions),
      isNotNull,
    );
    expect(
      SliderStateHelper.getIconForState(SliderState.debt),
      isNotNull,
    );
  });

  test('SliderStateHelper handles edge cases', () {
    // Test boundary values
    expect(
      SliderStateHelper.getStateFromValue(0.33, 3),
      SliderState.transactions,
    );
    expect(
      SliderStateHelper.getStateFromValue(0.75, 3),
      SliderState.debt,
    );
    expect(
      SliderStateHelper.getStateFromValue(0.99, 3),
      SliderState.debt,
    );

    // Test out of bounds values (should clamp)
    expect(
      SliderStateHelper.getStateFromValue(-0.1, 3),
      SliderState.savedMoney,
    );
    expect(
      SliderStateHelper.getStateFromValue(1.1, 3),
      SliderState.debt,
    );

    // Test with different state counts
    expect(
      SliderStateHelper.getStateFromValue(0.33, 3),
      SliderState.transactions,
    );
    expect(
      SliderStateHelper.getStateFromValue(0.66, 3),
      SliderState.transactions,
    );
  });

  test('SliderStateHelper target value calculations', () {
    // Test exact target values
    expect(
      SliderStateHelper.getTargetValue(SliderState.savedMoney, 3),
      closeTo(0.0, 0.01),
    );
    expect(
      SliderStateHelper.getTargetValue(SliderState.transactions, 3),
      closeTo(0.5, 0.01),
    );
    expect(
      SliderStateHelper.getTargetValue(SliderState.debt, 3),
      closeTo(1.0, 0.01),
    );
  });

  test('SliderStateHelper state progression', () {
    // Test state transitions based on values
    final states = [
      SliderState.savedMoney,
      SliderState.transactions,
      SliderState.debt,
    ];

    for (int i = 0; i < states.length; i++) {
      final expectedState = states[i];
      final value = i / (states.length - 1);
      final actualState =
          SliderStateHelper.getStateFromValue(value, states.length);
      expect(actualState, expectedState);
    }
  });
}
