import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/common/lang_key.dart';
import '../model/zodiac_model.dart';

// Events
abstract class ZodiacSelectionEvent extends Equatable {
  const ZodiacSelectionEvent();

  @override
  List<Object?> get props => [];
}

class ZodiacSelectedEvent extends ZodiacSelectionEvent {
  final ZodiacModel zodiac;

  const ZodiacSelectedEvent(this.zodiac);

  @override
  List<Object?> get props => [zodiac];
}

class ZodiacConfirmedEvent extends ZodiacSelectionEvent {
  const ZodiacConfirmedEvent();
}

class BotMessageDisplayedEvent extends ZodiacSelectionEvent {
  const BotMessageDisplayedEvent();
}

// States
abstract class ZodiacSelectionState extends Equatable {
  const ZodiacSelectionState();

  @override
  List<Object?> get props => [];
}

class ZodiacSelectionInitial extends ZodiacSelectionState {
  final String defaultMessage;

  ZodiacSelectionInitial({
    String? defaultMessage,
  }) : defaultMessage = defaultMessage ?? AppLocalizations.text(LangKey.zodiac_welcome_message);

  @override
  List<Object?> get props => [defaultMessage];
}

class ZodiacSelectionLoaded extends ZodiacSelectionState {
  final List<ZodiacModel> zodiacs;
  final ZodiacModel? selectedZodiac;
  final String currentMessage;
  final bool isConfirmButtonEnabled;
  final bool showingExplanation;

  const ZodiacSelectionLoaded({
    required this.zodiacs,
    this.selectedZodiac,
    required this.currentMessage,
    this.isConfirmButtonEnabled = false,
    this.showingExplanation = false,
  });

  ZodiacSelectionLoaded copyWith({
    List<ZodiacModel>? zodiacs,
    ZodiacModel? selectedZodiac,
    String? currentMessage,
    bool? isConfirmButtonEnabled,
    bool? showingExplanation,
  }) {
    return ZodiacSelectionLoaded(
      zodiacs: zodiacs ?? this.zodiacs,
      selectedZodiac: selectedZodiac ?? this.selectedZodiac,
      currentMessage: currentMessage ?? this.currentMessage,
      isConfirmButtonEnabled: isConfirmButtonEnabled ?? this.isConfirmButtonEnabled,
      showingExplanation: showingExplanation ?? this.showingExplanation,
    );
  }

  @override
  List<Object?> get props => [
        zodiacs,
        selectedZodiac,
        currentMessage,
        isConfirmButtonEnabled,
        showingExplanation,
      ];
}

class ZodiacSelectionConfirmed extends ZodiacSelectionState {
  final ZodiacModel selectedZodiac;

  const ZodiacSelectionConfirmed(this.selectedZodiac);

  @override
  List<Object?> get props => [selectedZodiac];
}

// Bloc
class ZodiacSelectionBloc extends Bloc<ZodiacSelectionEvent, ZodiacSelectionState> {
  ZodiacSelectionBloc() : super(ZodiacSelectionInitial()) {
    on<ZodiacSelectedEvent>(_onZodiacSelected);
    on<ZodiacConfirmedEvent>(_onZodiacConfirmed);
    on<BotMessageDisplayedEvent>(_onBotMessageDisplayed);

    // Load initial data
    add(const BotMessageDisplayedEvent());
  }

  @override
  Future<void> close() {
    return super.close();
  }

  void _onBotMessageDisplayed(
    BotMessageDisplayedEvent event,
    Emitter<ZodiacSelectionState> emit,
  ) {
    emit(ZodiacSelectionLoaded(
      zodiacs: ZodiacModel.allZodiacs,
      currentMessage: AppLocalizations.text(LangKey.zodiac_welcome_message),
    ));
  }

  void _onZodiacSelected(
    ZodiacSelectedEvent event,
    Emitter<ZodiacSelectionState> emit,
  ) {
    final currentState = state;
    if (currentState is ZodiacSelectionLoaded) {
      // Prevent selection if the same zodiac is already selected
      if (currentState.selectedZodiac?.id == event.zodiac.id) {
        return;
      }
      
      // Get bot explanation for selected zodiac
      final explanation = event.zodiac.getBotExplanation();

      emit(currentState.copyWith(
        selectedZodiac: event.zodiac,
        currentMessage: explanation,
        isConfirmButtonEnabled: true,
        showingExplanation: true,
      ));
    }
  }

  void _onZodiacConfirmed(
    ZodiacConfirmedEvent event,
    Emitter<ZodiacSelectionState> emit,
  ) {
    final currentState = state;
    if (currentState is ZodiacSelectionLoaded && 
        currentState.selectedZodiac != null && 
        currentState.isConfirmButtonEnabled) {
      emit(ZodiacSelectionConfirmed(currentState.selectedZodiac!));
    }
  }

  // Helper method to get current selected zodiac
  ZodiacModel? get selectedZodiac {
    final currentState = state;
    if (currentState is ZodiacSelectionLoaded) {
      return currentState.selectedZodiac;
    }
    return null;
  }

  // Helper method to check if confirm button should be enabled
  bool get isConfirmEnabled {
    final currentState = state;
    if (currentState is ZodiacSelectionLoaded) {
      return currentState.isConfirmButtonEnabled;
    }
    return false;
  }
}