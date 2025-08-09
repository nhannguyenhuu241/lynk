
import 'package:flutter/material.dart';
import 'package:lynk_an/common/assets.dart';
import 'package:lynk_an/common/lang_key.dart';
import 'package:lynk_an/common/localization/app_localizations.dart';
import 'package:lynk_an/common/theme.dart';
import 'package:lynk_an/common/utils/extension.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/enum/lynk_state_enum.dart';
import 'package:lynk_an/common/widgets/lynk_bot_manage/bot/flame/lynk_flame_widget.dart';
import 'package:lynk_an/common/widgets/widget.dart';
import 'package:lynk_an/data/model/base/profile_model.dart';
import 'package:lynk_an/presentation/modules/main_modules/information_module/src/bloc/information_sex_bloc.dart';
import 'package:lynk_an/presentation/modules/main_modules/main_chat_module/src/widget/chat_message_bubble.dart';

class InformationSexScreen extends StatefulWidget {
  final ProfileModel model;
  InformationSexScreen(this.model);

  @override
  State<InformationSexScreen> createState() => _InformationSexScreenState();
}

class _InformationSexScreenState extends State<InformationSexScreen> {
   late InformationSexBloc _bloc;
   String? selectedGender;

  @override
  void initState() {
    super.initState();
    _bloc = InformationSexBloc(context, widget.model);
    _bloc.initialBotWelcome();
  }

  @override
  void dispose() {
    super.dispose();
  }
   Widget _buildAnimatedBot() {
     return StreamBuilder(
         stream: _bloc.streamBotAlignment.output,
         initialData: Alignment(0.0, -0.5),
         builder: (context, snapshotAligment) {
           return AnimatedAlign(
             duration: Duration(milliseconds: 600),
             curve: Curves.easeInOutCubic,
             alignment: snapshotAligment.data ?? Alignment(0.0, 0.0),
             child: StreamBuilder(
                 stream: _bloc.streamBotSize.output,
                 initialData: 0.4,
                 builder: (context, snapshotBotSize) {
                   double botSize = snapshotBotSize.data ?? 0.5;
                   return AnimatedContainer(
                     duration: Duration(milliseconds: 600),
                     curve: Curves.easeInOutCubic,
                     width: MediaQuery.of(context).size.width * botSize,
                     height: MediaQuery.of(context).size.width * botSize,
                     child: StreamBuilder(
                         stream: _bloc.streamLynkState.output,
                         initialData: LynkState.amazed,
                         builder: (context, snapshot) {
                           LynkState _lynkState =
                               snapshot.data ?? LynkState.amazed;
                           return LynkFlameWidget(
                             key: ValueKey(botSize),
                             width: MediaQuery.of(context).size.width * botSize,
                             height: MediaQuery.of(context).size.height * botSize,
                             botSize: 1.2,
                             state: _lynkState,
                           );
                         }),
                   );
                 }),
           );
         });
   }

   Widget _buildChatArea() {
     return Stack(
       children: [
         _buildBotResponse(),
       ],
     );
   }

   Widget _buildBotResponse() {
     return StreamBuilder<Map<String, String>?>(
       stream: _bloc.streamCurrentBotMessage.output,
       builder: (context, snapshotMessage) {
         if (snapshotMessage.data == null) {
           return const SizedBox.shrink();
         }
         final message = snapshotMessage.data!;
         return StreamBuilder<BotReplyLayout>(
           stream: _bloc.streamBotReply.output,
           initialData: BotReplyLayout.medium,
           builder: (context, snapshotLayout) {
             final replyLayout = snapshotLayout.data!;
             Alignment bubbleAlignment;
             switch (replyLayout) {
               case BotReplyLayout.short:
                 bubbleAlignment = const Alignment(0.9, 0.0);
                 break;
               case BotReplyLayout.medium:
                 bubbleAlignment = Alignment(0.0, 0.0);
                 break;
               case BotReplyLayout.long:
                 bubbleAlignment = const Alignment(0.0, -0.3);
                 break;
             }
             return AnimatedAlign(
               duration: const Duration(milliseconds: 600),
               curve: Curves.easeInOutCubic,
               alignment: bubbleAlignment,
               child: AnimatedSwitcher(
                 duration: const Duration(milliseconds: 300),
                 transitionBuilder: (child, animation) =>
                     FadeTransition(opacity: animation, child: child),
                 child: Container(
                   key: ValueKey('bot_response_${message['text']}'),
                   child: StyledChatMessageBubble(
                     layout: replyLayout,
                     tail: TailDirection.top,
                     child: AnimatedTypingText(
                       text: message['text']!,
                       color: AppColors.white,
                       maxLines: null,
                       overflow: TextOverflow.visible,
                       key: ValueKey(message['text']!),
                     ),
                   ),
                 ),
               ),
             );
           },
         );
       },
     );
   }

   Widget _buildRender() {
     return Container(
       padding: EdgeInsets.symmetric(
         horizontal: AppSizes.maxPadding,
         vertical: AppSizes.maxPadding * 1.5,
       ),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           CustomGenderOption(
             gender: 'male',
             icon: Icons.male,
             label: AppLocalizations.text(LangKey.info_male),
             color: AppColors.infoLight,
             isSelected: selectedGender == 'male',
             onTap: () {
               setState(() {
                 selectedGender = 'male';
               });
               _bloc.handleGenderSelection(selectedGender!);
             },
           ),
           SizedBox(width: AppSizes.maxPadding),
           CustomGenderOption(
             gender: 'female',
             icon: Icons.female,
             label: AppLocalizations.text(LangKey.info_female),
             color: AppColors.sunriseTop,
             isSelected: selectedGender == 'female',
             onTap: () {
               setState(() {
                 selectedGender = 'female';
               });
               _bloc.handleGenderSelection(selectedGender!);
             },
           ),
         ],
       ),
     );
   }

   Widget _body() {
     return Stack(
       children: [
         Image.asset(
           Assets.imgBackground2,
           fit: BoxFit.cover,
           height: double.infinity,
           width: double.infinity,
           alignment: Alignment.center,
         ),
         SafeArea(
           child: Column(
             children: [
               Flexible(
                 flex: 3,
                 child: Stack(
                   children: [
                     Center(
                       child: _buildAnimatedBot(),
                     ),
                     Positioned(
                       bottom: AppSizes.maxPadding,
                       left: AppSizes.maxPadding,
                       right: AppSizes.maxPadding,
                       child: _buildChatArea(),
                     ),
                   ],
                 ),
               ),
               Expanded(
                 flex: 3,
                 child: Center(
                   child: _buildRender(),
                 ),
               ),
             ],
           ),
         ),
       ],
     );
   }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        body: _body(),
      ),
    );
  }
}
